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

stow_with_backup() {
    local pkg="$1"

    # ドライランで競合を確認
    local conflicts
    conflicts=$(stow -d "$SCRIPT_DIR" -n "$pkg" 2>&1 | grep "existing target" || true)

    if [ -z "$conflicts" ]; then
        stow -d "$SCRIPT_DIR" "$pkg"
        return
    fi

    # 競合ファイルをバックアップ
    local backup_dir="$HOME/.stow-backup.$(date +%Y%m%d%H%M%S)"
    log "Conflicts detected for '$pkg'. Backing up to $backup_dir"

    while read -r line; do
        # "existing target is neither a link nor a directory: .claude/settings.json" の形式からパスを抽出
        local target
        target=$(echo "$line" | sed 's/.*existing target is neither a link nor a directory: //')
        if [ -n "$target" ] && [ -e "$HOME/$target" ]; then
            mkdir -p "$backup_dir/$(dirname "$target")"
            mv "$HOME/$target" "$backup_dir/$target"
        fi
    done < <(echo "$conflicts")

    stow -d "$SCRIPT_DIR" "$pkg"
    log "Backup saved to $backup_dir"
}

# Step 1: Base packages (Linuxbrew, stow, CLI tools)
run_step "Install base packages" "$SCRIPT_DIR/scripts/install_common.sh"

# Step 2: Create symlinks via Stow
log "Creating symlinks via stow..."
stow_with_backup bash
stow_with_backup tmux
stow_with_backup claude
log "Done: symlinks created"

# Step 3: tmux + TPM + plugins
run_step "Install tmux" "$SCRIPT_DIR/scripts/install_tmux.sh"

# Step 4: asdf version manager
run_step "Install asdf" "$SCRIPT_DIR/scripts/install_asdf.sh"

# Step 5: Languages via asdf (erlang, elixir, nodejs, python, awscli)
run_step "Install languages" "$SCRIPT_DIR/scripts/install_languages.sh"

# Step 6: Claude Code (native installer)
run_step "Install Claude Code" "$SCRIPT_DIR/scripts/install_claude.sh"

# Step 7: Git settings
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
