#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

# Init linuxbrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Check asdf installed.
if ! command -v asdf &> /dev/null
then
    echo "asdf is not installed."
    exit 1
fi

################################################################################
### Build dependencies.
################################################################################
sudo apt-get update && sudo apt-get upgrade -y

# Erlang build dependencies.
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev \
  libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev \
  libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop \
  libxml2-utils libncurses-dev openjdk-11-jdk

################################################################################
### Install languages via asdf.
################################################################################

install_language() {
    local name="$1"
    echo "Installing $name..."
    asdf plugin add "$name" 2>/dev/null || true
    asdf install "$name" latest
    asdf set --home "$name" "$(asdf latest "$name")"
    echo "Done: $name $(asdf latest "$name")"
}

# Order matters: erlang before elixir.
install_language erlang
install_language elixir
install_language nodejs
