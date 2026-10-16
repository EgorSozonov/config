#! /usr/bin/bash

if amixer sget Master | grep -q '\[on\]' ; then
   amixer set Master 3dB+
else
   amixer -q set Master on
   amixer -q set Speaker on
   amixer -q set Headphone on
fi
