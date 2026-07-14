export EDITOR=nvim
export CC=gcc
export VIMRUNTIME=~/.config/vim
export TERM=foot
readonly PATH="/usr/local/sbin:/usr/local/bin:/usr/bin"
export LS_COLORS='di=1:fi=0:st=1:tw=1:ln=33:ex=32:pi=0:so=0:bd=0:cd=0:or=31'

if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -n "$XDG_VTNR" ]] && [[ "$XDG_VTNR" -eq 1 ]] ; then
    exec sway
fi
