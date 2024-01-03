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
### Install Rust.
################################################################################
asdf plugin add rust
asdf install rust latest
asdf global rust $(asdf latest rust)
asdf reshim rust

# TODOs
# バージョン指定、スコープ指定
