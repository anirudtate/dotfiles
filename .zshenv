# Default programs:
export EDITOR="nvim"
export TERMINAL="footclient"
export BROWSER="firefox"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="-"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"

# Other program settings:
export FZF_DEFAULT_OPTS="--layout=reverse --height 40%"
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
export LESS=-R
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
export QT_QPA_PLATFORMTHEME="gtk2"	# Have QT use gtk2 theme.
export MOZ_USE_XINPUT2="1"		# Mozilla smooth scrolling/touchpads.
export AWT_TOOLKIT="MToolkit wmname LG3D"	#May have to install wmname
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

# set PATH variable
path=(
    $path
    $HOME/.local/bin
    $PNPM_HOME
)
# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))
export PATH
