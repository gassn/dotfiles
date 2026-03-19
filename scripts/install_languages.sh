#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

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

# Python build dependencies.
sudo apt-get -y install make libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

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

# Order matters: erlang before elixir, python before awscli.
install_language erlang
install_language elixir
install_language nodejs
install_language python
install_language awscli
