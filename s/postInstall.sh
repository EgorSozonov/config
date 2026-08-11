#! /usr/bin/bash

doas pacman -Syu apparmor pacman-contrib wl-clipboard
doas pacman -Syu alsa-utils pipewire tree man which jq

doas pacman -Syu chrony
sys enable --now chronyd
sys start chronyd

doas pacman -Syu guile make base-devel

