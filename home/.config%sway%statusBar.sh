#!/usr/bin/bash

case $1 in
1)
   swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name'\
      | head -n 1 | cut -c 1-2
   echo ""
   echo "#F0F0F0"
   ;;
2)
   if [[ $(amixer sget Master | grep '\[on') ]]; then
      echo "  "
   else
      echo "🔊 "
   fi
   echo ""
   echo "#F0F0F0"
   ;;
3)
   charge=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "percentage" | grep -oE '[0-9]+')
   batteryStatus=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "state" | cut -F 3)
   batteryColor="#00FF00"
   if [[ $batteryStatus = "discharging" ]]; then
      if (( charge > 80 )); then
         batterySymb="  $charge%"
      elif (( charge > 50 )); then
         batterySymb="  $charge%"
      elif (( charge > 20 )); then
         batterySymb="  $charge%"
      else
         batterySymb="!! $charge%"
         batteryColor="#FF3030"
      fi
   else
      batterySymb="⚡$charge%"
      batteryColor="#E0FF00"
   fi

   echo $batterySymb
   echo $charge
   echo $batteryColor
   ;;
4)
   date '+%H:%M (%d)'
   ;;
esac
