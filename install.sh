#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

run_step() {
    local description="$1"
    shift
    log "Starting: $description"
    if "$@"; then
        log "Done: $description"
    else
        log "FAILED: $description"
        exit 1
    fi
}

# Step 1: Base packages (Linuxbrew, stow, CLI tools)
run_step "Install base packages" "$SCRIPT_DIR/scripts/install_common.sh"

# Step 2: Create symlinks via Stow
log "Creating symlinks via stow..."
cd "$SCRIPT_DIR"
stow bash
log "Done: symlinks created"

# Step 3: asdf version manager
run_step "Install asdf" "$SCRIPT_DIR/scripts/install_asdf.sh"

# Step 4: Elixir (depends on asdf)
run_step "Install Elixir" "$SCRIPT_DIR/scripts/install_elixir.sh"

# Step 5: Git settings
if [ "$#" -eq 2 ]; then
    run_step "Configure git" "$SCRIPT_DIR/scripts/git_settings.sh" "$1" "$2"
else
    echo ""
    read -rp "Git email: " git_email
    read -rp "Git username: " git_username
    if [ -n "$git_email" ] && [ -n "$git_username" ]; then
        run_step "Configure git" "$SCRIPT_DIR/scripts/git_settings.sh" "$git_email" "$git_username"
    else
        log "Skipped: git settings (no email/username provided)"
    fi
fi

log "All done!"
