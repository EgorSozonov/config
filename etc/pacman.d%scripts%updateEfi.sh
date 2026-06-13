#! /usr/bin/bash
KERNEL_SRC="/boot/vmlinuz-linux"
INITRAMFS_SRC="/boot/initramfs-linux.img"
FALLBACK_SRC="/boot/initramfs-linux-lts.img"

cp "$KERNEL_SRC" "/efi/vmlinuz-linux"
cp "$INITRAMFS_SRC" "/efi/initramfs-linux.img"
cp "$FALLBACK_SRC" "/efi/initramfs-linux-lts.img"

# Optional: clean up existing entries
efibootmgr | grep "Arch Linux" | awk '{print $1}' | sed 's/Boot//;s/\*//' \
   | xargs -I {} efibootmgr -b {} -B
   
efibootmgr --create --disk /dev/m/root --part 1 \
   --label "Arch Linux" \
   --loader "vmlinuz-linux" \
   --unicode "root=UUID= initrd=\\initramfs-linux.img rw quiet"
   
efibootmgr --create --disk /dev/m/root --part 1 \
   --label "Arch Linux (LTS)" \
   --loader "vmlinuz-linux" \
   --unicode "root=UUID= initrd=\\initramfs-linux-lts.img rw quiet"
