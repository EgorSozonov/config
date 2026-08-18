#! /usr/bin/bash

commLine=$(mktemp)
function cleanup() {
   rm "$commLine"
}
trap cleanup EXIT

printf %s "$(doas cat /etc/cmdline.d/root.conf)" > "$commLine"
printf %s " rootflags=subvol=@snaps/beforeUpdate " >> "$commLine"
printf %s "$(doas cat /etc/cmdline.d/extra.conf)" >> "$commLine"

doas mkinitcpio /boot/EFI/Linux/archLinux.efi \
   --cmdline "$commLine" \
   -U /boot/EFI/Linux/beforeUpdate.efi

