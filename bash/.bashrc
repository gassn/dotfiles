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

# Enable fzf (Ctrl+R is handled by atuin, so unbind fzf's).
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --exclude __pycache__"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
bind -m vi-insert -r '\C-r' 2>/dev/null
bind -m vi-command -r '\C-r' 2>/dev/null
bind -m emacs -r '\C-r' 2>/dev/null

# Enable completion.
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# Enable asdf completion.
. <(asdf completion bash)

# Enable GitHub CLI completion.
. <(gh completion bash)

# Enable uv/uvx completion.
. <(uv generate-shell-completion bash)
. <(uvx --generate-shell-completion bash)

# Enable starship prompt.
eval "$(starship init bash)"

# Enable atuin (shell history).
# atuin adds to precmd_functions/preexec_functions arrays (not PROMPT_COMMAND).
eval "$(atuin init bash)"

# Enable zoxide.
eval "$(zoxide init bash)"

# Ctrl+G: jump to directory from zoxide history via fzf.
__zoxide_fzf() {
    local dir
    dir=$(zoxide query -l | fzf --height 40% --reverse) && cd "$dir"
}
bind -x '"\C-g": __zoxide_fzf'

# Enable bash-preexec (required by atuin for precmd/preexec hooks).
# Must be sourced AFTER all tools that modify PROMPT_COMMAND (starship, zoxide).
# bash-preexec defers __bp_install to the first PROMPT_COMMAND execution.
# If other commands run after __bp_install, the DEBUG trap consumes the
# interactive mode flag, causing the first command's preexec to be skipped.
[[ -f /home/linuxbrew/.linuxbrew/etc/profile.d/bash-preexec.sh ]] && . /home/linuxbrew/.linuxbrew/etc/profile.d/bash-preexec.sh
