#! /usr/bin/bash
if  amixer sget Master | grep -q '\[on\]' ; then
    echo '{"text": "", "class": "on", "tooltip": "Sound is ON"}'
else
    echo '{"text": "", "class": "off", "tooltip": "Muted"}'
fi
