#! /usr/bin/bash

doas pacman -Syu apparmor pacman-contrib wl-clipboard sway-contrib otf-font-awesome
doas pacman -Syu alsa-utils pipewire pipewire-pulse tree man which jq rsync openssh

doas pacman -Syu chrony
sys enable --now chronyd
sys enable --now iwd
sys enable --now dnsmasq
sys start chronyd
sys start dnsmasq
sys start iwd

doas apt install debconf

doas pacman -Syu guile make base-devel devtools tig devtools
doas pacman -Syu impala id3v2 ffmpeg xdg-desktop-portal-wlr

mkdir -p ~/.local/share/tig
mkdir -p ~/.config/mozilla
mkdir -p ~/.config/git

doas grub-mkfont -s 24 -o /boot/grub/fonts/linejoy.pf2 ~/.local/share/fonts/Linejoy-Regular.ttf
