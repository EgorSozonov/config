#! /usr/bin/bash

echo "root=UUID=$(blkid -s UUID -o value /dev/sda1)" > /etc/cmdline.d/root.conf
