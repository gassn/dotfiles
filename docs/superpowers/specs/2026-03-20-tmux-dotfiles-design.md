# Tmux Dotfiles Integration Design

## Overview

Add tmux configuration and plugin auto-setup to the dotfiles repository, following the existing Stow-based structure.

## Context

- tmux 3.6a installed via Linuxbrew
- Existing `.tmux.conf` at `~/.tmux.conf` with custom settings (prefix C-t, vim-style bindings, status bar)
- TPM (Tmux Plugin Manager) with tmux-resurrect and tmux-continuum plugins already installed at `~/.tmux/plugins/`
- Dotfiles repo uses GNU Stow for symlink management (`bash/` package exists)

## Changes

### 1. New Stow Package: `tmux/`

Create `tmux/.tmux.conf` containing the current `.tmux.conf` content (unchanged).

`stow tmux` creates symlink: `~/.tmux.conf` → `dotfiles/tmux/.tmux.conf`

### 2. New Install Script: `scripts/install_tmux.sh`

Responsibilities:
1. Install tmux via `brew install tmux`
2. Clone TPM to `~/.tmux/plugins/tpm` (skip if already exists)
3. Run `~/.tmux/plugins/tpm/bin/install_plugins` to auto-install plugins defined in `.tmux.conf`

Guards:
- Root execution prevention (consistent with other scripts)
- Idempotent (safe to re-run)

### 3. Update `install.sh`

Add two steps after `stow bash`:
1. `stow tmux` — create `.tmux.conf` symlink
2. `scripts/install_tmux.sh` — install tmux + TPM + plugins

Order: stow tmux must run before install_tmux.sh so that `.tmux.conf` is in place when TPM reads plugin definitions.

## Out of Scope

- Modifying `.tmux.conf` content
- Including plugin source code in the repo (TPM handles this at install time)
- The `~/.tmux/plugins/` directory is not managed by Stow (TPM manages it)
