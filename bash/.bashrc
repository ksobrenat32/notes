# Ksobrenatural .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

PATH="$HOME/.local/bin:$PATH"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000000
HISTFILESIZE=2000000
HISTTIMEFORMAT="%y-%m-%d-%T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

alias ls='ls -A --color=auto'
alias cp='cp --reflink=auto'

SELECTED_EDITOR="/usr/bin/vim"
EDITOR="/usr/bin/vim"

bind 'set completion-ignore-case on'

## Some aliases
alias pind='ping debian.org'
alias rand='cat /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 32 && echo'
alias hig='history | grep'

## My desktop specific
alias cmus='flatpak run io.github.cmus.cmus'
alias mpv='flatpak run io.mpv.Mpv'
alias update='sudo dnf upgrade && flatpak update'

