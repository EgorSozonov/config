#! /usr/bin/bash

#runit services run as root by default. 
#swaymsg requires the correct user environment and SWAYSOCK.
#Replace 'your_username' with your actual login username.
user="onr"
userId=$(id -u onr)

# Run swaymsg as your user, inheriting the user's DBUS/wayland environment
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$userId/bus" \
   SWAYSOCK="/run/user/$userId/sway-ipc.$userId.$(pgrep -u $user -x sway).sock" \
   swaymsg -t send_tick

