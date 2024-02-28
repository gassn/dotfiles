#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Install ESP32 IDF.
################################################################################
# Prerequirements.
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

git clone -b v5.1.1 --recursive --depth 1 --shallow-submodule https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh
python3 -m pip install esptool

# TODOs
# バージョン指定
