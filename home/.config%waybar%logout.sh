#! /usr/bin/bash

menuResult=$(printf "Suspend\nLog out\nCancel" \
   | fzf --color="fg+:#000000,bg+:#80c000,pointer:#00ff00,prompt:#80c000,gutter:#000000" \
      --no-info --layout=reverse --prompt="       Sway Menu" \
)
case "$menuResult" in
    "Suspend") aplay -q ~/music/xpMus/shutdown.wav; systemctl suspend ;;
    "Log out") swaymsg exit ;;
    "Cancel") ;;
esac
