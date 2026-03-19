#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Install asdf.
################################################################################
brew install asdf

rm -f ~/.bash_asdf
ln -sf ~/dotfiles/bash/.bash_asdf ~/.bash_asdf
