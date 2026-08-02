All my Linux configs for easy synchronizations between computers.

Deploy them from this repo to the system. WARNING: this will overwrite your local files (but
also will save the old versions to a backup dir).

    ./sync.sh
    
Machine-specific files (which override ordinary files) should be placed in the _$HOSTNAME dir. 
They will automatically be applied on the machine with the corresponding host name. In fact, the 
script compares the contents of the files and asks before overwriting, and after overwriting
files saves the old versions to a directory it prints. As an additional feature, it updates
GRUB configurations if the file /etc/default/grub is updated or created.


Prerequisites (you need to install those packages):

sway
foot
waybar
wofi
otf-font-awesome
