#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Settings.
################################################################################
# main user don't need sudo password.
echo "`whoami` ALL=NOPASSWD: ALL" | sudo tee /etc/sudoers.d/main_user
