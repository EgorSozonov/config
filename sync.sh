#! /usr/bin/bash

backups="$HOME/.local/state/dotfiler/"

#$1 = source filename, $2 = target, $3 = array of files that already exist, $4 = "cp" command
#$5 = ptr to count of copied files
function copyIfNotExistsOrAddToArray() {
   local -n existingTgts=$3
   local -n cntCopied=$5
   if [[ ! -f $2 ]]; then
      $4 $1 $2
      ((cntCopied++))
   elif ! cmp -s $1 $2; then
      existingTgts+=($1) 
      existingTgts+=($2) 
   fi
}

#$1 = source dir we're looping on, $2 = target dir, $3 = "cp" command
function updateFromDir() {
   declare -a fileNames
   declare -a existingTargets
   declare -i countCopied
   readarray -t fileNames < <(ls -A $1)
   local targetDir="${2/%\//}"  # ensure no trailing slash in $2
   for fN in "${fileNames[@]}"; do
      local outFile="$targetDir/${fN//\%/\/}"
      copyIfNotExistsOrAddToArray "$1/$fN" $outFile existingTargets "$3" countCopied
   done;
   if ((countCopied > 0)); then
      echo "Copied $countCopied files"
   fi
   local countExisting="$((${#existingTargets[@]}/2))"
   if (( countExisting > 0 )) then
      echo "$countExisting files need to be updated:"
      for ((i=1; i<2*countExisting; i+=2)); do
         echo "${existingTargets[$i]}"
      done;
      echo ""
      
      read -p "OK to overwrite? " -n 1 -r
      echo
      
      if [[ $REPLY =~ ^[Yy]$ ]] then
         for ((i=0; i<2*countExisting; i+=2)); do
            local tgt="${existingTargets[$i + 1]}"
            $3 "$tgt" "$backups/${tgt//\//\%}"
            $3 "${existingTargets[$i]}" "$tgt"
         done;
         echo "$countExisting files overwritten, backups in $backups"
      else
         echo "File update was cancelled"
      fi
   fi
}

function initBackups() {
   mkdir -p $backups
}

initBackups
updateFromDir home ~ "install -D"
updateFromDir etc /etc "doas install -D"
updateFromDir armor /etc/apparmor.d "doas install -D"

#if /usr/bin/grep '\$HOME' ~/.config/rsync/rsync.conf; then
#   /usr/bin/sed -i -n "s;\$HOME;$HOME;" ~/.config/rsync/rsync.conf
#fi
