#! /usr/bin/bash


doas pacman -Syu apparmor pacman-contrib
doas pacman -Syu alsa-utils pipewire 

doas pacman -Syu chrony
sys enable --now chronyd
sys start chronyd


