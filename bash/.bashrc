# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# vi like keybind
set -o vi

# Init linuxbrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Enable completion.
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# Enable fzf.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Enable oh-my-posh.
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/atomic.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/blue-owl.omp.json)"
### eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/clean-detailed.omp.json)"
## eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/lambdageneration.omp.json)"
## eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/montys.omp.json)"
## eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/microverse-power.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/paradox.omp.json)"
eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/quick-term.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/sonicboom_light.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/wholespace.omp.json)"

# Enable asdf.
. /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh
. /home/linuxbrew/.linuxbrew/etc/bash_completion.d/asdf.bash

# Rust.
# source "/home/gassn/.asdf/installs/rust/1.75.0/env"

# Todos

. $HOME/esp/esp-idf/export.sh > /dev/null 2>&1 || true
. $HOME/.cargo/env
