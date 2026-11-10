#!/usr/bin/bash
#To be placed in /home/w/s and run via `doas -u w /home/w/s/runFirefox.sh`
export XDG_RUNTIME_DIR=/tmp/w
mkdir -p -m 0700 "$XDG_RUNTIME_DIR"

ln -sf /run/user/1000/$WAYLAND_DISPLAY "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"

unset DBUS_SESSION_BUS_ADDRESS
export MOZ_ENABLE_WAYLAND=1
/usr/bin/firefox
