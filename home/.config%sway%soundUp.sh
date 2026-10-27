#! /usr/bin/bash

if amixer sget Master | grep -q '\[on\]' ; then
   amixer set Master 3dB+
else
   amixer -q set Speaker on
fi
