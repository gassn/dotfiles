# Dotfiles Reorganization Design

## Overview

Reorganize the dotfiles repository: clean up unused configurations, migrate to GNU Stow for symlink management, and improve install automation with dependency ordering.

## Context

- WSL2 environment, Bash shell
- Active tools: asdf, Erlang/Elixir, Linuxbrew, fzf, Starship, GitHub CLI
- Inactive tools (to remove): Rust, ESP-IDF, Matter SDK, oh-my-posh
- Current symlink management: manual `make_link.sh`
- Uncommitted changes in `.bash_asdf` and `.bashrc` for over a year

## Phase 1: Cleanup

### Files to Delete

| File | Reason |
|------|--------|
| `install_rust.sh` | Rust no longer used |
| `install_esp32_idf.sh` | ESP-IDF no longer used |
| `install_matter.sh` | Matter SDK no longer used |

### Configuration Changes

#### `.bashrc`

- Remove all oh-my-posh lines (commented out, replaced by Starship)
- Remove `~/.cargo/env` source line (Rust removed)
- Remove any ESP-IDF/Matter related settings

#### `.bash_aliases`

- Remove `get_idf` alias (ESP-IDF removed)

#### `.bash_asdf`

- Accept the new completion script (147 lines replacing the old 3-line source)

### Files to Keep

- `install_asdf.sh`, `install_elixir.sh`, `install_common.sh`
- `git_settings.sh`, `no_sudo_password.sh`
- All bash config files (`.bashrc`, `.bash_aliases`, `.bash_logout`, `.fzf.bash`)

## Phase 2: Stow Migration

### Target Directory Structure

```
dotfiles/
├── bash/                      # Stow package
│   ├── .bashrc
│   ├── .bash_asdf
│   ├── .bash_aliases
│   ├── .bash_logout
│   └── .fzf.bash
├── scripts/                   # Not a stow package
│   ├── install_asdf.sh
│   ├── install_elixir.sh
│   ├── install_common.sh
│   ├── git_settings.sh
│   └── no_sudo_password.sh
├── install.sh                 # Master script
├── .stow-local-ignore         # Ignore patterns for stow
└── README.md
```

### Stow Usage

```bash
cd ~/dotfiles
stow bash   # Creates symlinks: ~/.bashrc -> dotfiles/bash/.bashrc, etc.
```

### Changes

- Move install scripts to `scripts/` directory
- Delete `make_link.sh` (replaced by Stow)
- Create `.stow-local-ignore` to exclude `scripts/`, `README.md`, `docs/`, `install.sh`

## Phase 3: Install Automation

### `install.sh` Master Script

Execution order (dependency-based):

1. `scripts/install_common.sh` — base packages (Linuxbrew, stow, CLI tools)
2. `stow bash` — create shell config symlinks
3. `scripts/install_asdf.sh` — asdf version manager
4. `scripts/install_elixir.sh` — Elixir via asdf (depends on asdf)
5. `scripts/git_settings.sh` — Git configuration

### Requirements

- Idempotent: safe to run multiple times
- Root execution prevention (inherited from existing scripts)
- Success/failure logging per step
- Add `stow` to `install_common.sh` package list

### `install_elixir.sh` Improvements

- Resolve or remove TODO comments about version pinning

### Out of Scope

- `no_sudo_password.sh` — security-sensitive, no changes

## Commit Strategy

- Conventional commits in English (`feat:`, `chore:`, `refactor:`)
- One commit per logical change within each phase
- Phase branches optional (can commit directly to master)

## Success Criteria

- All unused files and config lines removed
- `stow bash` creates correct symlinks to `$HOME`
- `install.sh` runs end-to-end on a clean system
- No broken references in any config file
