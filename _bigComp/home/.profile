export EDITOR=nvim
export CC=gcc
export VIMRUNTIME=~/.config/nvim
export TERM=foot
readonly PATH="/opt/bin:/usr/local/bin:/usr/bin"
export LS_COLORS='di=1:fi=0:st=1:tw=1:ln=33:ex=\033[38;5;46:pi=0:so=0:bd=0:cd=0:or=31:ow=0'
export HISTFILE="$HOME/.local/state/.bash_history"
export PSQL_HISTORY="$HOME/.local/state/.psql_history"
export GNUPGHOME="$HOME/.config/gnupg"
export CGDB_DIR="$HOME/.config/cgdb"
export PARALLEL_HOME="$HOME/.config/parallel"

if [[ $XDG_RUNTIME_DIR == "" ]]; then
   export XDG_RUNTIME_DIR=/tmp/user/$(id -u)
   if ! [[ -d $XDG_RUNTIME_DIR ]]; then
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 0700 "$XDG_RUNTIME_DIR"
   fi
fi


export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export SVDIR=$HOME/.local/sv

if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -n "$XDG_VTNR" ]] && [[ "$XDG_VTNR" -eq 1 ]] ; then
   exec sway
fi
