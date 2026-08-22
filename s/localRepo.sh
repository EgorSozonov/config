#! /usr/bin/bash
doas mkdir -p /opt/craft
doas chown root:alpm /opt/craft
doas chmod 755 /opt/craft

cat <<'EOF' > craftRepo.conf
[craft]
SigLevel = Optional TrustAll
Server = file:///opt/craft
EOF

doas mv craftRepo.conf /etc/pacman.d/craftRepo.conf
doas chmod 644 /etc/pacman.d/craftRepo.conf

