#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <email> <username>"
    exit 1
fi

EMAIL=$1
USERNAME=$2

################################################################################
### Settings.
################################################################################
# Git settings.
git config --global user.email "$EMAIL"
git config --global user.name "$USERNAME"
git config --global color.ui auto
git config --global core.editor vim
# delta (git pager)
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global merge.conflictStyle zdiff3
