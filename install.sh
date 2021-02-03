#!/bin/bash

# Usual.
sudo apt-get update
sudo apt-get upgrade -y

# Install Linuxbrew.
eval "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#echo '"eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
#echo '"eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc

# Install misc tools using brew.
brew install git
brew install vim
brew install curl
brew install wget
brew install exa
brew install bat
brew install ripgrep
brew install fd

# Install Zsh
brew install zsh
brew install zsh-completions
eval "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# For programming language env.
brew install anyenv
anyenv install --init
echo 'eval "$(anyenv init -)"' >> ~/.zprofile

# Node.js
anyenv install nodenv

# AWS CLI tool.
brew install awscli

# Git settings.
git config --global user.email "it.is.all.over.1126@gmail.com"
git config --global user.name "gassn"

