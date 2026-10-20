#!/usr/bin/bash

function output() {
   local batteryColor="#FFFFFF"

   charge=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "percentage" | grep -oE '[0-9]+')
   batteryStatus=$(upower --show-info $(upower --enumerate | grep 'BAT') \
      | grep -E "state" | cut -F 3)
   if [[ $batteryStatus = "discharging" ]]; then
      if (( charge > 80 )); then
         batterySymb="   $charge%"
         batteryColor="#00FF00"
      elif (( charge > 50 )); then
         batterySymb="   $charge%"
         batteryColor="#F0F0F0"
      elif (( charge > 20 )); then
         batterySymb="   $charge%"
         batteryColor="#F0F0F0"
      else
         batterySymb="   $charge%"
         batteryColor="#FF3030"
      fi
   else
      batterySymb="⚡ $charge%"
      batteryColor="#F0F000"
   fi

   cat <<EOF
[
{"name":"start", "full_text": "   ", "separator": true, "separator_block_width": 30},
{"name":"layout", "full_text": "en/ru", "separator": true, "separator_block_width": 30},
{"name":"keyboard", "full_text": "   ", "separator": true, "separator_block_width": 30},
{"name":"sound", "full_text": "  ", "separator": true, "separator_block_width": 30},
{"name":"wifi", "full_text": " ", "separator": true, "separator_block_width": 30},
{"name":"help", "full_text": "? ", "separator": true, "separator_block_width": 30},
{"name":"battery", "full_text":"$batterySymb", "color": "$batteryColor",
   "separator": true, "separator_block_width": 30},
{"name":"time", "full_text":"$(date '+%H:%M (%d)')", "separator": true,
   "separator_block_width": 30}
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
         foot sh -c alsamixer 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "wifi" ]]; then
         foot -a "leDialog" sh -c impala 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "help" ]]; then
         "$HOME/.config/sway/help.sh" 2>/dev/null
      elif  [[ "$widgetName" == "layout" ]]; then
         swaymsg input type:keyboard xkb_switch_layout next 1>/dev/null 2>/dev/null
      elif [[ "$widgetName" == "keyboard" ]]; then
         wvkbd-mobintl -l simple,cyrillic
      elif [[ "$widgetName" == "time" ]]; then
         foot -a "leDialog" sh -c "calcurse" 1>/dev/null 2>/dev/null
      fi
   done
}

#Clean up click handler on exit, and run it in the background
trap "kill $(jobs -p)" EXIT
handleClicks <&0 &

echo '{"version": 1, "click_events": true, "cont_signal": 18, "stop_signal": 19}'
echo '['
while true; do
   output
   sleep 0.5
done

