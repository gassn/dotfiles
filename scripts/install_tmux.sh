#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

# Init linuxbrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

################################################################################
### Install tmux.
################################################################################
brew install tmux

################################################################################
### Install TPM and plugins.
################################################################################
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install plugins defined in .tmux.conf (works without a running tmux session).
"$TPM_DIR/bin/install_plugins"
