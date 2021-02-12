#!/bin/bash

# Usual.
sudo apt-get update
sudo apt-get upgrade -y


# Install tools for compile.
sudo apt-get install build-essential zlib1g-dev autoconf libffi-dev -y


# Install Linuxbrew.
eval "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc


# Locale settings.
sudo localedef -f UTF-8 -i ja_JP ja_JP


# Install misc tools using brew.
brew install git
brew install nvim
brew install curl
brew install wget
brew install exa
brew install bat
brew install ripgrep
brew install fd

# Git settings.
git config --global user.email "it.is.all.over.1126@gmail.com"
git config --global user.name "gassn"
git config --global color.ui auto
git config --global core.editor nvim


# Install Zsh
brew install zsh
brew install zsh-completions
# zinit
eval "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"


# tmux
brew install tmux
# tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# For programming language env.
brew install anyenv
anyenv install --init
anyenv install nodenv
anyenv install pyenv
anyenv install rbenv


# AWS CLI tool.
brew install awscli

