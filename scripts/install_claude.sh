#!/bin/bash

set -e

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Install Claude Code (native installer).
### Node.js不要。~/.claude/bin/ に直接インストールされ、PATHは自動設定される。
################################################################################
if command -v claude &>/dev/null; then
    echo "Claude Code is already installed: $(claude --version)"
    exit 0
fi

curl -fsSL https://claude.ai/install.sh | bash

echo "Claude Code installed: $(claude --version)"
