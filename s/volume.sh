#!/usr/bin/bash

raw=$(amixer scontents | grep -E "'Master'|'Headphone'|'Speaker'|Playback [0-9]")


volMaster=$(echo "$raw" |sed -n '3p' | grep -oP '^.*?\K[0-9]+')
volHeadphone=$(echo "$raw" |sed -n '6p' | grep -oP '^.*?\K[0-9]+')
volSpeaker=$(echo "$raw" |sed -n '10p' | grep -oP '^.*?\K[0-9]+')


function readFromEnv() {
	declare -a volumes
	IFS=":" read -r -a volumes < /tmp/volume

	amixer -q set Master "${volumes[0]}"
	amixer -q set Headphone "${volumes[1]}"
	amixer -q set Speaker "${volumes[2]}"
}

function saveToEnv() {
	echo "$volMaster:$volHeadphone:$volSpeaker" > /tmp/volume
}

if ! [[ -f /tmp/volume ]]; then
	saveToEnv
fi

readFromEnv

