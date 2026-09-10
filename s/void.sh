cat s/userService | sed "s|username|$(id -un)|g" s/userService > run
doas mkdir -p /etc/sv/$(id -un)
doas mv run /etc/sv/$(id -un)/run

doas xbps-install jq alsa-utils


