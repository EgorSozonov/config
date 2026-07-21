#! /usr/bin/bash
if swaymsg -t get_tree | jq -e '.. | select(.type? == "workspace" and .focused == true) | .nodes == [] and .floating_nodes == []' > /dev/null; then
   wofi --show drun --allow-images -a --prompt ""
fi
