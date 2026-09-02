#! /usr/bin/bash

#Audio and multimedia
soundActive=""
declare -i charge

function update() {
   monthDay=$(date "+%m")
   currTime=$(date "+%H:%M")

   #Battery
   charge=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "percentage" | grep -oE '[0-9]+')
   batteryStatus=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "state" | awk '{print $2}')
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
   
   keyLayout=$(swaymsg -t get_inputs | \
      jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name' | head -n 1 | cut -c 1-2)
}

function output() {
   #echo "$keyLayout  $soundActive | $batterySymb $charge% |  $currTime ($monthDay) "
   
   cat <<EOF
[
{"name":"start", "full_text": " ", "separator": true, "separator_block_width": 30},
{"name":"keyboard", "full_text": "$keyLayout", "separator": true, "separator_block_width": 30},
{"name":"sound", "full_text": "$soundActive", "separator": true, "separator_block_width": 30},
{"name":"logout", "full_text": "? ", "separator": true, "separator_block_width": 30},
{"name":"battery", "full_text":"$charge% $batterySymb", "separator": true, "separator_block_width": 30},
{"name":"time", "full_text":"$currTime ($monthDay)", "separator": true, "separator_block_width": 30}
],
EOF
}


#Function to handle click processing asynchronously
function handleClicks() {
   # Read stdin line-by-line, clearing buffers instantly
   while read -r line; do
      local widgetName=$(echo "$line" | sed 's/^,//' | jq -r '.name // empty')
      
      if [[ "$widgetName" == "start" ]]; then
         pkill wofi || wofi --show drun --allow-images -a --columns 2 --prompt ""
      elif [[ "$widgetName" == "sound" ]]; then
         $HOME/.config/sway/toggleSound.sh 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "logout" ]]; then
         foot -a "leDialog" sh -c "$HOME/.config/sway/logout.sh" 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "keyboard" ]]; then
         swaymsg input "*" xkb_switch_layout next 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "time" ]]; then
         foot -a "leDialog" sh -c "calcurse" 1>/dev/null 2>/dev/null
      fi
   done
}

#Clean up click handler on exit
trap "kill $(jobs -p)" EXIT

#Run the click handler in the background
handleClicks <&0 &

echo '{"version": 1, "click_events": true, "cont_signal": 18, "stop_signal": 19}'
echo '['
update
output

# Continuously listen for input event changes from Sway IPC
swaymsg -t subscribe '["input","tick"]' --monitor | while read -r line; do
   update
   output
done

