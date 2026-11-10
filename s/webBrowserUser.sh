#!/usr/bin/bash

doas /usr/bin/useradd w
doas /usr/bin/mkdir /home/w
doas /usr/bin/passwd w
doas /usr/bin/usermod -aG w $(id -nu)
doas /usr/bin/chown w:w /home/w
doas /usr/bin/chmod 770 /home/w

setfacl -m u:w:rwx $XDG_RUNTIME_DIR
setfacl -m u:w:rw $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY

doas /usr/bin/mkdir -p /home/w/.config
doas chmod 700 /home/w/.config
doas /usr/bin/mkdir -p -m 700 /home/w/.local
doas /usr/bin/mkdir -p -m 770 /home/w/s
doas chown w:w /home/w/{.config,.local,s}

doas /usr/bin/install -m 770 s/runFirefox.sh /home/w/s
doas chown w:w /home/w/s/runFirefox.sh
