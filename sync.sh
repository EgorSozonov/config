#!/usr/bin/bash

backups="$HOME/.local/state/dotfiler/"

#$1 = target, $2 = source filename, $3 = array of files that already exist,
#$4 = are we copying to root?
#$5 = ptr to count of copied files.
#$6 = OUT 1 if copied, 2 if overwrote something, 0 otherwise
function copyIfNotExistsOrAddToArray() {
   local -n existingTgts=$3
   local -n cntCopied=$5
   local -n result=$6
   if [[ ! -f $1 ]]; then # if target doesn't exist
      installFile $1 $2 $4
      ((cntCopied++))
      ((result=1))
   elif ! cmp -s $1 $2; then
      if [[ -s $2 ]]; then
         existingTgts+=($1)
         existingTgts+=($2)
      fi
      ((result=2))
   else
      ((result=0))
   fi
}

# $1 target (full file name), $2 source (full file name), $3 = are we copying to root dir?
function installFile() {
   if (( $3 )); then
      if [[ "$1" =~ \.sh$ || "$1" =~ \.lua$ ]]; then
         doas /usr/bin/install -D -m755 $2 $1
      else
         doas /usr/bin/install -D -m644 $2 $1
      fi
   else
      if [[ "$1" =~ \.sh$ || "$1" =~ \.lua$ ]]; then
         /usr/bin/install -D -m700 $2 $1
      else
         /usr/bin/install -D -m600 $2 $1
      fi
   fi
}

#$1 = countExisting, $2 = existingTargets, $3 = are we copying to root dir?
function overwriteFiles() {
   local -n cntExisting=$1
   local -n existingTgts=$2
   echo "$cntExisting files need to be updated:"
   for ((i=0; i<2*cntExisting; i+=2)); do
      echo "${existingTgts[$i]}"
   done;
   echo ""

   read -p "^ ^ ^ OK to overwrite? " -n 1 -r
   echo

   if [[ $REPLY =~ ^[Yy]$ ]] then
      for ((i=0; i<2*cntExisting; i+=2)); do
         local existing="${existingTgts[$i]}"
         /usr/bin/install -D "$existing" "$backups/${existing//\//\%}"
         installFile "$existing" "${existingTgts[$i + 1]}" $3
      done;
      echo "$cntExisting files overwritten. Backups are in $backups"
      echo ""
   else
      echo "File update was cancelled"
   fi
}


#$1 = target dir, $2 = source dir we're looping on, $3 = are we copying to root dir?
function updateFromDir() {
   declare -a fileNames
   declare -a compSpecificFNames
   declare -a existingTargets
   declare -i countCreated
   readarray -t fileNames < <(ls -A $2)
   local hostName="$HOSTNAME"
   readarray -t compSpecificFNames < <(ls -A _$hostName/$2 2>/dev/null)
   local targetDir="${1/%\//}"  # ensure no trailing slash in $2

   for fN in "${fileNames[@]}"; do
      local outFile="$targetDir/${fN//\%/\/}"
      local srcFile="$2/$fN"
      for compSpec in "${compSpecificFNames[@]}"; do
         if [[ "$compSpec" == "$fN" ]]; then
            srcFile="_$hostName/$2/$fN"
         fi
      done

      declare -i currResult
      copyIfNotExistsOrAddToArray $outFile $srcFile existingTargets $3 countCreated currResult
   done;
   if ((countCreated > 0)); then
      echo "Copied $countCreated files"
      echo ""
   fi

   local countExisting="$((${#existingTargets[@]}/2))"
   if (( countExisting > 0 )) then
      overwriteFiles countExisting existingTargets $3
   fi
}


updateFromDir ~ home 0
updateFromDir /etc etc 1
updateFromDir /etc/apparmor.d armor 1

