#! /bin/bash

if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "devEnv")' > /dev/null; then
   swaymsg '[app_id="devEnv"] kill'
else
   currWorkspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
   swaymsg workspace 6
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl'

   swaymsg workspace 7
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl/src'

   swaymsg workspace 8
   swaymsg exec 'foot -a devEnv -D ~/repos/vim/src'

   swaymsg workspace 9
   swaymsg exec 'foot -a devEnv -D ~/proj/eegl/src'
   
   swaymsg workspace $currWorkspace
fi
