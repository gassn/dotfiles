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
brew install gcc git curl wget fzf eza bat ripgrep fd vim oh-my-posh
brew unlink util-linux
brew install bash-completion

################################################################################
### Settings.
################################################################################

# TODOs
