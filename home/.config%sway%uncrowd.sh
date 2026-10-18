#!/usr/bin/bash
#currWorkspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

# swaymsg -t get_workspaces | jq -r '.[] | select(.focused)'
#swaymsg "mark _$currWorkspace, move scratchpad"


a=$(swaymsg -t get_tree \
   | jq -r '[.. | (.nodes? // empty)[] | select(.pid and .visible)]
      | map({id: .id, f: .focused, x: .rect.x}) | sort_by(.x)'
)

b=$(jq 'map(select(.f))' <<< "$a")
echo "$b"

