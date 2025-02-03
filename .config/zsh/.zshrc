# Prompt
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# remove stacksize limit (for competitive programming)
ulimit -s unlimited

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
set -o vi
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# restore ctrl+p and ctrl+n
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search

# some fuctions
fd() {
  cd "$(find -type d | fzf)"
}

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000

alias \
	pn="pnpm" \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI" \
	bc="bc -ql" \
	mkdir="mkdir -pv" \
	ls="ls -hN --color=auto --group-directories-first" \
	la="ls -lah" \
	grep="grep --color=auto" \
	diff="diff --color=auto" \
	ccat="highlight --out-format=ansi" \
	ip="ip -color=auto" \
	e="$EDITOR" \
	v="$EDITOR" \
	ll="ls -lh" \
	l="ls -lh" \
	la="ls -lah" \
	hx="helix" \
	t="tmux attach || tmux" \
	vim="nvim" \
	v="nvim" 
