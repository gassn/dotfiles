# eza (ls replacement)
alias ls='eza --icons'
alias ll='eza --icons -alF --git'
alias la='eza --icons -a'
alias tree='eza --icons -T'

# bat (cat replacement)
alias cat='bat --paging=never --style=plain'
alias catn='bat --paging=never'
alias less='bat --paging=always'

# ripgrep
alias rg='rg --smart-case'

# grep color support
alias grep='grep --color=auto'

# git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gm='git merge'
alias grb='git rebase'
alias gl='git log --oneline'
alias glg='git log --oneline --graph --all'
alias gla='git log --oneline --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gcl='git clone'

# zoxide (cd replacement)
alias cd='z'

# dust (du replacement)
alias du='dust'

# duf (df replacement)
alias df='duf'

# procs (ps replacement)
alias ps='procs'

# general
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias h='history'
alias c='clear'
