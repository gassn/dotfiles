# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lang settings.
export LANG=ja_JP.UTF-8
export LANGUAGE=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
setopt print_eight_bit

# Path settings.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(anyenv init -)"
export PATH=$HOME/.anyenv/envs/phpenv/versions/8.0.12/composer/vendor/bin:$PATH

# Key binding as vim.
bindkey -v

# Allow no cd typing.
setopt auto_cd

# cd completion.
setopt auto_pushd
setopt pushd_ignore_dups

# No beep.
setopt no_beep
setopt nolistbeep

# History files settings.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
#setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

# Set aliases.
alias ls='exa'
alias ll='exa -lhg --time-style long-iso --git -a'
alias la='exa -a'
alias vim='nvim'
alias gs='git status'
alias -g @g='| grep'
alias -g @l='| less'

### Completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
### End of Completion chunk

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

zinit light 'zsh-users/zsh-autosuggestions'
zinit light 'zsh-users/zsh-completions'
zinit light 'zdharma-continuum/fast-syntax-highlighting'
zinit light 'zdharma-continuum/history-search-multi-word'
zinit ice depth=1; zinit light romkatv/powerlevel10k
### End of Zinit's installer chunk

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
