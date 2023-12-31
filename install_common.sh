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
# Install tools.
sudo apt-get install git curl build-essential -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" NONINTERACTIVE=1
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc

################################################################################
### Install tools.
################################################################################
# Install tools using brew.
brew install git curl wget fzf exa bat ripgrep fd bash-completion vim oh-my-posh

################################################################################
### Settings.
################################################################################

# TODOs
# brewのbash-completionのインストールに失敗するのを修正。
