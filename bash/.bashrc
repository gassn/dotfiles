# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings.
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=100000
HISTFILESIZE=200000

# Shell options.
shopt -s globstar

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# vi like keybind
set -o vi

# Enable fzf.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Enable completion.
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# Enable asdf completion.
. <(asdf completion bash)

# Enable GitHub CLI completion.
. <(gh completion bash)

# Enable zoxide.
eval "$(zoxide init bash)"

# Enable starship prompt.
eval "$(starship init bash)"
