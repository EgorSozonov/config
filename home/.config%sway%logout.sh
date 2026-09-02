#! /usr/bin/bash

menuResult=$(printf "Suspend\nLog out\nHelp\nCancel" \
   | fzf --color="fg+:#000000,bg+:#80c000,pointer:#00ff00,prompt:#80c000,gutter:#000000" \
      --no-info --layout=reverse --prompt="       Sway Menu" \
)
case "$menuResult" in
   "Suspend") aplay -q ~/music/xpMus/shutdown.wav; systemctl suspend ;;
   "Log out") swaymsg exit ;;
   "Help") ;;
   "Cancel") ;;
esac

foot --hold sh -c "
grep -E '^\s*(bindsym|bindcode)' ~/.config/sway/config | \
   sed -e 's;\$mod;Win;g'  -e 's;^ \+;;' -e 's;bindsym ;;' -e 's;bindcode ;;' \
      -e 's;--locked ;;' -e 's;\$left;<-;g' -e 's;\$right;->;g'  -e 's;\$up;^;g' -e 's;\$down;v;g' | \
   sed 's;\([^ ]\+\) \(.*$\);\1 :: \2;'
echo '' 
echo '(use Win+c to close this window)' 
"
