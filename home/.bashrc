export PS1="\e[32;40m\W @\[\e[0m\] "

HISTCONTROL=ignoreboth
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options

shopt -s histappend
# append to the history file, don't overwrite it

shopt -s globstar # the /**/ pattern to select files from all depths
shopt -s extglob # extended globbing like !(*.jpg|*.gif)

HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%Y-%m-%d %T "

stty -ixon # Disable XON/XOFF crap (terminal freezing)


setxkbmap -layout us,ru -option 'grp:nocaps,grp:lctrl_toggle'
#export TERM=alacritty
#export FZF_DEFAULT_COMMAND=

alias pkBySize="expac -H M '%m\t%n' | sort -h -r | less" # list installed packages sorted by size
alias battery="acpi -b"
alias zzz="aplay -q ~/music/xpMus/shutdown.wav; systemctl suspend"
alias openEyr="v --cmd 'cd ~/proj/eyr' ~/proj/eyr/*.c ~/proj/eyr/test/parserTest.c ~/proj/eyr/libeyr.h" 
alias openAz="nvim --cmd 'cd ~/proj/azimuth/src/azimuth' ~/proj/azimuth/src/azimuth/tick/ship.c" 

#aliases in ~/.config/aliases, shell functions in ~/.config/utils
#OS-specific aliases here:

alias pkInstall="doas pacman -S"
alias pkRemove="doas pacman -Rn"
alias pkRefresh="doas pacman -Syu"
alias pkUpdate="doas pacman -Sy archlinux-keyring && doas pacman -Su"
alias pkInfo="pacman -Qi"
alias pkUnused="pacman -Qqdt"
alias pkOptional="pacman -Qqttd" # packages that were installed only as optional dependencies
alias pkMakeExplicit="doas pacman -D --asexplicit"
alias pkExplicit="pacman -Qqe"
alias pkWhichFiles="pacman -Ql"
alias pkWhichPackage="pacman -Qo"
alias pkAur="pacman -Qme"

umask 077

source ~/.config/utils
source ~/.config/aliases
clear
