#!/usr/bin/bash

charge=$(upower --show-info $(upower --enumerate | grep 'BAT') \
   | grep -E "percentage" | grep -oE '[0-9]+')
batteryStatus=$(upower --show-info $(upower --enumerate | grep 'BAT') \
   | grep -E "state" | awk '{print $2}')
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
echo ""
echo $batteryColor
