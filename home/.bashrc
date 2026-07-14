export PS1="\e[38;5;46m\e[4m\W\[\e[0m\] "

HISTCONTROL=ignoreboth
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s globstar # the /**/ pattern to select files from all depths
shopt -s extglob # extended globbing like !(*.jpg|*.gif)
set -o mark-directories

HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%Y-%m-%d %T "

stty -ixon # Disable XON/XOFF crap (terminal freezing)


setxkbmap -layout us,ru -option 'grp:nocaps,grp:lctrl_toggle'
#export TERM=alacritty
#export FZF_DEFAULT_COMMAND=


#aliases in ~/.config/aliases, shell functions in ~/.config/utils

umask 077

source ~/.config/utils
source ~/.config/aliases
clear
