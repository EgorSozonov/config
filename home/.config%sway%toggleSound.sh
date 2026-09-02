#! /usr/bin/bash

if amixer sget Master | grep -q '\[on\]' ; then
   amixer -q set Master off
   amixer -q set Speaker off
   amixer -q set Headphone off
else
   amixer -q set Master on
   amixer -q set Speaker on
   amixer -q set Headphone on
fi
swaymsg -t send_tick
#pkill -SIGUSR1 -f statusBar.sh
