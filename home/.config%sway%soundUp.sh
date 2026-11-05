#! /usr/bin/bash

if amixer sget Speaker | grep -q '\[on\]' ; then
   amixer set Speaker 3dB+
else
   amixer -q set Speaker on
fi
