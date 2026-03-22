#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Usual for initialization.
################################################################################
sudo apt-get update && sudo apt-get upgrade -y
# Locale settings.
sudo localedef -f UTF-8 -i ja_JP ja_JP

################################################################################
# Install Linuxbrew.
################################################################################
# Install prerequirement tools.
sudo apt-get install git curl build-essential -y
yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

################################################################################
### Install tools.
################################################################################
# Install tools using brew.
brew install gcc git curl wget fzf eza bat ripgrep fd vim starship stow gh jq inotify-tools aws-cdk zoxide tldr git-delta dust duf procs uv awscli atuin bash-preexec
brew unlink util-linux
brew unlink node 2>/dev/null || true
brew list --formula | grep '^python@' | xargs -I{} brew unlink {} 2>/dev/null || true
brew install bash-completion@2
