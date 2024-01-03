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
### Install Erlang and Elixir.
################################################################################
# Prerequirements.
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

asdf plugin add erlang
asdf plugin add elixir
asdf install erlang latest
asdf install elixir latest
asdf global erlang $(asdf latest erlang)
asdf global elixir $(asdf latest elixir)

# TODOs
# バージョン指定、スコープ指定
