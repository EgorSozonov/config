All my Linux configs for easy synchronizations between computers.

Deploy them from this repo to the system. WARNING: this will overwrite your local files (but
also will save the old versions to a backup dir).

    ./sync.sh
    
Machine-specific files (which override ordinary files) should be placed in the _$HOSTNAME dir. 
They will automatically be applied on the machine with the corresponding host name.


Prerequisites:

sway
waybar
wofi
otf-font-awesome
