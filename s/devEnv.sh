#! /usr/bin/bash

if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "devEnv")' > /dev/null; then
   swaymsg '[app_id="devEnv"] kill'
else
   currWorkspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
   swaymsg workspace "5:q"
   swaymsg exec 'footclient -a devEnv -D ~/proj/eegl'

   swaymsg workspace "6:w"
   swaymsg exec 'footclient -a devEnv -D ~/proj/eegl/src'

   swaymsg workspace "8:r" 
   swaymsg exec 'footclient -a devEnv -D ~/proj/eegl/src'
   
   swaymsg workspace $currWorkspace
fi
