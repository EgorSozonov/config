#! /usr/bin/bash

doas btrfs subvolume delete /snaps/beforeUpdate
doas btrfs subvolume snapshot / /snaps/beforeUpdate

