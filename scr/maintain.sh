#! /usr/bin/bash

#pacnew
#find /etc -name '*.pacnew' -o -name '*.pacsave'

#unused packages
#pacman -Qqdt


#Array of menu entries [(int name)]
declare -a menuEntries
#Array of arrays. For every menu item, the array of strings behind it
declare -a menuData

declare -a insecureOnes

function securityAudit() {
   local -n entries=$1
   local -n data=$2
   readarray -t insecureOnes < <(arch-audit | grep 'High risk')
   if (( ${#insecureOnes[@]} > 0 )); then
      entries+=("0")
      entries+=("Insecure packages")
      data+=("insecureOnes")
      #for inse in "${insecureOnes[@]}"; do
      #   echo $inse
      #done
   fi
}


IFS='' read -r -d '' pkExtractor <<"EOF"
   BEGIN { 
      FS=":" 
      RS = "\n" 
   }
   /^Install Reason/ { printf " | " $2 "\n"}
   /^Installed Size/ { printf " | " $2}
EOF

declare -a unusedOnes

function unusedPackages {
   local -n entries=$1
   local -n data=$2
   
   readarray -t unusedOnes < <(pacman -Qqdt)
   if (( ${#unusedOnes[@]} > 0 )); then
      entries+=("0")
      entries+=("Unused packages")
      data+=("unusedOnes")
      #for unu in "${unusedOnes[@]}"; do
      #   echo $unu
      #done
   fi
   #local a=lld
   #printf $a
   #awk -e "$pkExtractor" <<< "$(pacman -Qi $a)"
}


function userExit() {
   clear
   echo "Your app has been closed successfully"
   exit 1
}

# $1 = index in menu
function showMenuItem() {
   declare -i dataLen=$(( ${#menuData[@]} ))
   
   local subarrayName="${menuData[$1]}"
   declare -n subarray="$subarrayName"
   
   clear
   for c in "${subarray[@]}"; do
      echo $c
   done;
   #declare -n subarray="$data[$1]"
   #clear
   #echo "--- Printing members of $1 len is $dataLen item len $dataItemLen ---"
   #for element in "${subarray[@]}"; do
   #   echo "$element"
   #done
}

function showMenu() {
   local -n entries=$1
   local -n data=$2
   declare -i menuLen=$(( ${#entries[@]} / 2 ))
   if $((menuLen == 0)); then
      return 0
   fi
   for ((i=0; i<menuLen; i+=1)); do
      entries[2*$i]=$((i))
      local tgt="${entries[2*$i + 1]}"
   done;
   
   result=$(dialog --clear --title " menu" \
      --backtitle "$BACKTITLE" \
      --cancel-label "Exit" \
      --stdout \
      --menu "Choose" 0 0 $((menuLen)) "${entries[@]}"
   )
   case $? in
   0) showMenuItem $((result)) ;;
   1) userExit ;;
   esac
} 

securityAudit menuEntries menuData
unusedPackages menuEntries menuData
showMenu menuEntries menuData
