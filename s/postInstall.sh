#! /usr/bin/bash

doas pacman -Syu apparmor pacman-contrib wl-clipboard
doas pacman -Syu alsa-utils pipewire tree

doas pacman -Syu chrony
sys enable --now chronyd
sys start chronyd


