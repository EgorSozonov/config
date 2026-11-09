#!/usr/bin/bash




function readFromEnv() {
	declare -a volumes
	IFS=":" read -r -a volumes < /tmp/volume
	echo "read volume ${volumes[0]}"

   amixer -q set Master on
	amixer -q set Master "${volumes[0]}"

	echo "after setting $volMaster"
	amixer -q set Headphone 100
	amixer -q set Speaker 100
	amixer -q set Headphone on
}

function saveToEnv() {
	raw=$(amixer scontents | grep -E "'Master'|'Headphone'|'Speaker'|Playback [0-9]")
	volMaster=$(echo "$raw" |sed -n '3p' | grep -oP '^.*?\K[0-9]+')
	#volHeadphone=$(echo "$raw" |sed -n '6p' | grep -oP '^.*?\K[0-9]+')
	#volSpeaker=$(echo "$raw" |sed -n '10p' | grep -oP '^.*?\K[0-9]+')

	echo "writing volume ${volMaster}"

	echo "$volMaster:100:100" > /tmp/volume
}

if ! [[ -f /tmp/volume ]]; then
	echo "40:100:100" > /tmp/volume
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


