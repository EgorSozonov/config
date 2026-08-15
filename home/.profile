export EDITOR=nvim
export CC=gcc
export VIMRUNTIME=~/.config/nvim
export TERM=foot
readonly PATH="/opt/bin:/usr/local/bin:/usr/bin"
export LS_COLORS='di=1:fi=0:st=1:tw=1:ln=33:ex=\033[38;5;46:pi=0:so=0:bd=0:cd=0:or=31:ow=0'
export HISTFILE="~/.local/state/.bash_history"
export PSQL_HISTORY="~/.local/state/.psql_history"
export GNUPGHOME="~/.config/gnupg"

if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -n "$XDG_VTNR" ]] && [[ "$XDG_VTNR" -eq 1 ]] ; then
    exec sway
fi
