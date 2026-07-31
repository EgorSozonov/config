#! /usr/bin/bash

#pacnew
#find /etc -name '*.pacnew' -o -name '*.pacsave'

#unused packages
#pacman -Qqdt


#Array of menu entries [(int name)]
declare -a menuEntries
#Array of arrays. For every menu item, the array of strings behind it
declare -a menuData


function securityAudit() {
   local -n entries=$1
   local -n data=$2
   readarray -t insecureOnes < <(arch-audit | grep 'High risk')
   if (( ${#insecureOnes[@]} > 0 )); then
      entries+=("0")
      entries+=("Insecure packages")
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

function unusedPackages {
   local -n entries=$1
   local -n data=$2
   
   readarray -t unusedOnes < <(pacman -Qqdt)
   if (( ${#unusedOnes[@]} > 0 )); then
      entries+=("0")
      entries+=("Unused packages")
      #for unu in "${unusedOnes[@]}"; do
      #   echo $unu
      #done
   fi
   #local a=lld
   #printf $a
   #awk -e "$pkExtractor" <<< "$(pacman -Qi $a)"
}


#function maintMenu() {
#   mainMenuOptions=(
#      0 "Run comm embedded"
#      1 "Dummy menu"
#      2 "Run comm literally"
#   )
#   
#   result=$(dialog --clear --title "Main menu" \
#      --backtitle "$BACKTITLE" \
#      --cancel-label "Exit" \
#      --stdout \
#      --menu "Choose" 0 0 3 "${mainMenuOptions[@]}"
#   )
#   case $? in
#   0) case $result in
#      0) menu1 ;;
#      1) menu2 ;;
#      2) menu3 ;;
#      esac
#      ;;
#   1) userExit ;;
#   esac
#} 


function userExit() {
   clear
   echo "Your app has been closed successfully"
   exit 1
}

# $1 = index in menu
function showMenuItem() {
   local -n data=$2
   
   declare -n ref=data[$1]
   
   echo "--- Printing members of $1 ---"
   for element in "${ref[@]}"; do
      echo "$element"
   done
}

function showMenu() {
   local -n entries=$1
   local -n data=$2
   declare -i menuLen=$(( ${#entries[@]} / 2 ))
   if $((menuLen == 0)); then
      return 0
   fi
   entries+=("0")
   entries+=("Quit")
   for ((i=0; i<menuLen; i+=1)); do
      entries[$i]=$((i))
      local tgt="${entries[2*$i + 1]}"
   done;
   
   result=$(dialog --clear --title " menu" \
      --backtitle "$BACKTITLE" \
      --cancel-label "Exit" \
      --stdout \
      --menu "Choose" 0 0 $((menuLen)) "${entries[@]}"
   )
   case $? in
   0) showMenuItem $result ;;
   1) userExit ;;
   esac
} 

securityAudit menuEntries menuData
unusedPackages menuEntries menuData
showMenu menuEntries menuData
