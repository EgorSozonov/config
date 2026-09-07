#! /usr/bin/bash

#One-time script to populate the kernel command line with the active storate UUID
#Must substitute /dev/sda1 below with the root partition!

doas mkdir /etc/cmdline.d
doas chmod 755 /etc/cmdline.d
doas echo "root=UUID=$(doas blkid -s UUID -o value /dev/sda1)" > root.conf
doas mv root.conf /etc/cmdline.d
