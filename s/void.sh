doas echo "kernel_cmdline=\"root=UUID=$(doas blkid -s UUID -o value $(findmnt -n -o SOURCE /)) \
rw quiet bgrt_disable amdgpu.dc=0\"" > /etc/dracut.conf.d/cmdline.conf

#cat s/userService | sed "s|username|$(id -un)|g" s/userService > run
#doas mkdir -p /etc/sv/$(id -un)
#doas mv run /etc/sv/$(id -un)/run

doas xbps-install pam_rundir jq alsa-utils

