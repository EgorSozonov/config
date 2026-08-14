#! /usr/bin/bash

doas pacman -Syu apparmor pacman-contrib wl-clipboard sway-contrib otf-font-awesome
doas pacman -Syu alsa-utils pipewire tree man which jq rsync

doas pacman -Syu chrony
sys enable --now chronyd
sys enable --now iwd
sys enable --now dnsmasq
sys start chronyd
sys start dnsmasq
sys start iwd

doas pacman -Syu guile make base-devel devtools tig
doas pacman -Syu impala id3v2 ffmpeg xdg-desktop-portal-wlr

