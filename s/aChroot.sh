#!/usr/bin/bash
# Universal chroot helper script for Linux system recovery.

# Ensure the script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run this script as root (doas)" >&2
    exit 1
fi

# Set the target directory from the first argument or default to /mnt
tgt="${1:-/mnt}"

# Validate that the target directory exists and is a valid folder
if [[ ! -d "$tgt" ]]; then
   echo "ERROR: Target directory '$tgt' does not exist" >&2
   exit 1
fi

# Step 1: Bind essential API filesystems required for a fully functional terminal
vfsDirs=("proc" "sys" "dev" "dev/pts" "run")

function cleanup() {
   echo "========================================="
   echo "Exiting chroot. Cleaning up mounts..."

   for ((i = ${#MOUNTS[@]} - 1; i >= 0; i--)); do
      local currPath="$tgt/vfsDirs[$i]"
      if mountpoint -q "$currPath"; then
         umount -l "$currPath"
      fi
   done

   # Step 4: Clean up network config updates
   if (( "$backedUpResolv" == 1 )); then
      /usr/bin/mv "${resolvConf}.bak" "$resolvConf"
   else
      /usr/bin/rm -f "$resolvConf"
   fi

   # Step 5: Safely unmount all pseudo-filesystems in reverse order
   if [[ -d "$tgt/dev/pts" ]]; then
       umount -l "$tgt/dev/pts" 2>/dev/null
   fi

   for ((i=${#vfsDirs[@]}-1; i>=0; i--)); do
       dir="${vfsDirs[$i]}"
       if mountpoint -q "$tgt/$dir"; then
           echo " -> Unmounting /$dir..."
           umount -l "$tgt/$dir"
       fi
   done

   echo "Done! Environment is clean."
}
trap cleanup EXIT

for dir in "${vfsDirs[@]}"; do
   echo " -> Mounting /$dir..."
   /usr/bin/mount --mkdir --bind "/$dir" "$tgt/$dir"
done
#Enable devpts specifically inside /dev for interactive terminal sessions
mount --bind /dev/pts "$tgt/dev/pts"

# Step 2: Backup existing resolv.conf and copy host networking to ensure internet access
resolvConf="$tgt/etc/resolv.conf"
backedUpResolv=0

if [[ -f /etc/resolv.conf ]]; then
    if [[ -f "$resolvConf" ]] || [[ -L "$resolvConf" ]]; then
        /usr/bin/mv "$resolvConf" "$resolvConf.bak"
        backedUpResolv=1
    fi
    echo " -> Copying network configurations (/etc/resolv.conf)..."
    /usr/bin/cp /etc/resolv.conf "$resolvConf"
fi

echo "Entering chroot. Type 'exit' or press Ctrl_D to leave."
echo "========================================="

chroot "$tgt" /usr/bin/bash --login

