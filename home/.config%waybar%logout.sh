#! /usr/bin/bash

menuResult=$(printf "Suspend\nLog out\nCancel" \
   | fzf --color="fg+:#000000,bg+:#00ff00,pointer:#00ff00,prompt:#00ff00,gutter:#000000" \
      --no-info --layout=reverse --prompt="Sway Menu: " \
)
case "$menuResult" in
    "Suspend") aplay -q ~/music/xpMus/shutdown.wav; systemctl suspend ;;
    "Log out") swaymsg exit ;;
    "Cancel") ;;
esac
