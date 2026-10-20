#! /usr/bin/bash

if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "devEnv")' > /dev/null; then
   swaymsg '[app_id="devEnv"] kill'
else
   currWorkspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
   swaymsg workspace "9:A"
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl'
   swaymsg exec 'foot -a devEnv -D ~/proj/bin'

   swaymsg workspace "10:S"
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl/src'
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl/src'

   swaymsg workspace "11:D"
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl/docs'

   swaymsg workspace $currWorkspace
fi
