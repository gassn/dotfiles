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

# Enable uv/uvx completion.
. <(uv generate-shell-completion bash)
. <(uvx --generate-shell-completion bash)

# Enable starship prompt (must be before atuin; atuin uses precmd_functions
# which bypasses PROMPT_COMMAND where starship_precmd is registered).
eval "$(starship init bash)"

# Enable atuin (shell history).
eval "$(atuin init bash)"

# Enable zoxide.
eval "$(zoxide init bash)"
