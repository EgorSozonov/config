#! /usr/bin/bash

backups="$HOME/.local/state/dotfiler/"

#$1 = source filename, $2 = target, $3 = array of files that already exist, $4 = "cp" command
#$5 = ptr to count of copied files
function copyIfNotExistsOrAddToArray() {
   local -n existingTgts=$3
   local -n cntCopied=$5
   if [[ ! -f $2 ]]; then # if target doesn't exist
      $4 $1 $2
      ((cntCopied++))
   elif ! cmp -s $1 $2; then
      if [ -s $1 ]; then
         existingTgts+=($1) 
         existingTgts+=($2) 
      fi
   fi
}

#$1 = countExisting, $2 = existingTargets, $3 = "install" command, $4 = needToUpdateGrub
function overwriteFiles() {
   local -n cntExisting=$1
   local -n existingTgts=$2
   local -n needToUpdateGrb=$4
   echo "$cntExisting files need to be updated:"
   for ((i=1; i<2*cntExisting; i+=2)); do
      echo "${existingTgts[$i]}"
   done;
   echo ""
   
   read -p "OK to overwrite? " -n 1 -r
   echo
   
   if [[ $REPLY =~ ^[Yy]$ ]] then
      for ((i=0; i<2*cntExisting; i+=2)); do
         local tgt="${existingTgts[$i + 1]}"
         $3 "$tgt" "$backups/${tgt//\//\%}"
         $3 "${existingTgts[$i]}" "$tgt"
      done;
      echo "$cntExisting files overwritten, backups in $backups"
      echo ""
      if [[ "$needToUpdateGrb" == "overwritten" ]]; then
         doas grub-mkconfig -o /boot/grub/grub.cfg
         echo ""
      fi
   else
      echo "File update was cancelled"
   fi
}


#$1 = source dir we're looping on, $2 = target dir, $3 = "cp" command
function updateFromDir() {
   declare -a fileNames
   declare -a compSpecificFNames
   declare -a existingTargets
   declare -i countCreated
   readarray -t fileNames < <(ls -A $1)
   local hostName="$HOSTNAME"
   readarray -t compSpecificFNames < <(ls -A _$hostName/$1 2>/dev/null)
   local targetDir="${2/%\//}"  # ensure no trailing slash in $2
   local needToUpdateGrub="false"
   
   for fN in "${fileNames[@]}"; do
      local outFile="$targetDir/${fN//\%/\/}"
      local srcFile="$1/$fN"
      for compSpec in "${compSpecificFNames[@]}"; do
         if [[ "$compSpec" == "$fN" ]]; then
            srcFile="_$hostName/$1/$fN"
         fi
      done
      
      declare -i countCreatedSaved=$((countCreated))
      copyIfNotExistsOrAddToArray $srcFile $outFile existingTargets "$3" countCreated
      if [[ "$fN" == "default%grub" ]]; then
         if (( countCreated > countCreatedSaved )); then
            needToUpdateGrub="created"
         else 
            needToUpdateGrub="overwritten"
         fi
      fi
   done;
   if ((countCreated > 0)); then
      echo "Copied $countCreated files"
      echo ""
      if [[ "$needToUpdateGrub" == "created" ]]; then
         doas grub-mkconfig -o /boot/grub/grub.cfg
         echo ""
      fi
   fi
   
   local countExisting="$((${#existingTargets[@]}/2))"
   if (( countExisting > 0 )) then
      overwriteFiles countExisting existingTargets "$3" needToUpdateGrub
   fi
}


mkdir -p $backups
updateFromDir home ~ "install -D"
updateFromDir etc /etc "doas install -D"
updateFromDir armor /etc/apparmor.d "doas install -D"

