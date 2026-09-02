#! /usr/bin/bash

#Audio and multimedia
soundActive=""
declare -i charge

function update() {
   #Date and time
   monthDay=$(date "+%m")
   currTime=$(date "+%H:%M")

   #Battery
   charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | grep -E "percentage" | grep -oE '[0-9]+')
   batteryStatus=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')
   if [[ $batteryStatus = "discharging" ]]; then
      if (( charge > 80 )); then 
         batterySymb=" "
      elif (( charge > 60 )); then
         batterySymb=" "
      elif (( charge > 20 )); then
         batterySymb=''
      else
         batterySymb='⚠'  
      fi
   else
      batterySymb='⚡'
   fi
   
   local audioIsOn=$(amixer sget Master | grep '\[on')
   if [[ $audioIsOn == "" ]]; then
      soundActive='  '
   else
      soundActive='🔊 '
   fi
   
   keyLayout=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name' | head -n 1 | cut -c 1-2)
}

function output() {
   echo "$keyLayout  $soundActive | $batterySymb $charge% |  $currTime ($monthDay) "
}

update
output

# Continuously listen for input event changes from Sway IPC
swaymsg -t subscribe '["input","tick"]' --monitor | while read -r line; do
   update
   output
done

