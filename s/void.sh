cat s/userService | sed "s|username|$(id -un)|g" userService > run
doas mkdir -p /etc/sv/$(id -un)
doas mv run /etc/sv/$(id -un)/run


