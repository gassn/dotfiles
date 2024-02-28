#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

# Check brew installed.
if ! command -v brew &> /dev/null
then
    echo "brew is not installed."
    exit 1
fi

################################################################################
### Install Matter SDK.
################################################################################
# Prerequirements.
sudo apt-get install -y git gcc g++ pkg-config libssl-dev libdbus-1-dev \
     libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
     python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev libsdl2-dev

git clone --recurse-submodules git@github.com:project-chip/connectedhomeip.git

# TODOs
