#!/usr/bin/bash

function readFromEnv() {
	local volume=$(cat /tmp/volume)

   amixer -q set Master on
	amixer -q set Master "$volume"

	amixer -q set Headphone 100
	amixer -q set Speaker 100
	amixer -q set Headphone on
}

function saveToEnv() {
	raw=$(amixer scontents | grep -E "'Master'|'Headphone'|'Speaker'|Playback [0-9]")
	volMaster=$(echo "$raw" |sed -n '3p' | grep -oP '^.*?\K[0-9]+')

	echo "$volMaster" > /tmp/volume
}

if ! [[ -f /tmp/volume ]]; then
	echo "42" > /tmp/volume
else
	readFromEnv
fi

if [[ "$1" == "up" ]]; then
	amixer -q set Speaker on
   amixer set Master 3dB+ && saveToEnv
elif [[ "$1" == "down" ]]; then
   amixer set Master 3dB- && saveToEnv
else
	amixer -q set Speaker off
fi

