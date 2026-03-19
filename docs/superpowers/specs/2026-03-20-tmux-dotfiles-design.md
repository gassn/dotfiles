# Tmux Dotfiles Integration Design

## Overview

Add tmux configuration and plugin auto-setup to the dotfiles repository, following the existing Stow-based structure.

## Context

- tmux 3.6a installed via Linuxbrew
- Existing `~/.tmux.conf` as a regular file (not a symlink) — must be handled before Stow
- TPM (Tmux Plugin Manager) with tmux-resurrect and tmux-continuum plugins already installed at `~/.tmux/plugins/`
- Dotfiles repo uses GNU Stow for symlink management (`bash/` package exists)
- `~/.tmux/` directory is managed by TPM, not by Stow (no conflict)

## Changes

### 1. New Stow Package: `tmux/`

Directory structure:
```
dotfiles/
└── tmux/              # Stow package
    └── .tmux.conf     # tmux configuration (current content, unchanged)
```

`stow tmux` creates symlink: `~/.tmux.conf` → `dotfiles/tmux/.tmux.conf`

**Pre-existing file handling:** Before running `stow tmux`, the existing `~/.tmux.conf` regular file must be removed (or backed up). On initial setup, `install.sh` should use `stow --adopt tmux` to adopt the existing file into the Stow package, or remove it first if the dotfiles version is canonical.

### 2. New Install Script: `scripts/install_tmux.sh`

Responsibilities:
1. Initialize Linuxbrew PATH (`eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"`) — required since brew may not be on PATH in a fresh shell
2. Install tmux via `brew install tmux`
3. Clone TPM to `~/.tmux/plugins/tpm` (skip if already exists)
4. Run `~/.tmux/plugins/tpm/bin/install_plugins` to auto-install plugins defined in `.tmux.conf` — this command works without a running tmux server session

Guards:
- Root execution prevention (consistent with other scripts)
- Idempotent (safe to re-run: brew install is a no-op if already installed, TPM clone is skipped if dir exists, install_plugins re-checks plugin state)

### 3. Update `install.sh`

Add two steps after `stow bash`:
1. `stow tmux` — create `.tmux.conf` symlink (handles pre-existing file)
2. `scripts/install_tmux.sh` — install tmux + TPM + plugins

Order: `stow tmux` must run before `install_tmux.sh` so that `.tmux.conf` is in place when TPM reads plugin definitions.

## Out of Scope

- Modifying `.tmux.conf` content
- Including plugin source code in the repo (TPM handles this at install time)
- The `~/.tmux/plugins/` directory is not managed by Stow (TPM manages it independently)
