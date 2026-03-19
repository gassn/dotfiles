# Dotfiles Reorganization Design

## Overview

Reorganize the dotfiles repository: clean up unused configurations, migrate to GNU Stow for symlink management, and improve install automation with dependency ordering.

## Context

- WSL2 environment, Bash shell
- Repository location: `~/dotfiles` (Stow relies on this assumption)
- Active tools: asdf, Erlang/Elixir, Linuxbrew, fzf, Starship, GitHub CLI
- Inactive tools (to remove): Rust, ESP-IDF, Matter SDK, oh-my-posh
- Current symlink management: manual `make_link.sh` + `install_asdf.sh`
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
- Remove `~/.cargo/env` source line (from a separate rustup install, no longer needed)
- Remove any ESP-IDF/Matter related settings
- Remove duplicate `bash_completion.sh` sourcing (appears twice)

#### `.bash_aliases`

- Remove `get_idf` alias (ESP-IDF removed)

#### `.bash_asdf`

- `.bashrc` currently does NOT source `.bash_asdf`. The file is only reachable via the `install_asdf.sh` symlink (`~/.bash_asdf`), which will be removed in Phase 2.
- Evaluate whether this file is still needed: `.bashrc` now inlines asdf setup via `asdf completion bash`. If that provides equivalent completions, delete `.bash_asdf`. If `.bash_asdf` provides richer subcommand completions, add `source ~/.bash_asdf` to `.bashrc` and keep the file in the `bash/` Stow package.

#### `install_common.sh`

- Remove `oh-my-posh` from `brew install` list
- Add `starship` to `brew install` list
- Add `stow` to `brew install` list
- Add `gh` (GitHub CLI) to `brew install` list

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
│   ├── .bash_aliases
│   ├── .bash_logout
│   └── .fzf.bash
├── docs/                      # Documentation (not a stow package)
│   └── superpowers/specs/
├── scripts/                   # Install scripts (not a stow package)
│   ├── install_asdf.sh
│   ├── install_elixir.sh
│   ├── install_common.sh
│   ├── git_settings.sh
│   └── no_sudo_password.sh
├── install.sh                 # Master script
└── README.md
```

Note: `.bash_asdf` is included in `bash/` only if Phase 1 determines it is still needed.

### Stow Usage

```bash
cd ~/dotfiles
stow bash   # Creates symlinks in ~ (parent of dotfiles dir)
```

Stow's default target is the parent directory of the stow dir. Since the repo is at `~/dotfiles`, `stow bash` targets `~` correctly.

### Changes

- Move install scripts to `scripts/` directory
- Delete `make_link.sh` (replaced by Stow)
- Remove manual symlink creation from `install_asdf.sh` (lines that `rm -f` and `ln -sf` `.bash_asdf`)
- No `.stow-local-ignore` needed: Stow only processes contents of package directories (e.g., `bash/`), so `scripts/`, `docs/`, `README.md`, `install.sh` are naturally excluded

## Phase 3: Install Automation

### `install.sh` Master Script

Execution order (dependency-based):

1. `scripts/install_common.sh` — base packages (Linuxbrew, stow, starship, gh, eza, bat, ripgrep, fd, fzf, vim)
2. `stow bash` — create shell config symlinks
3. `scripts/install_asdf.sh` — asdf version manager
4. `scripts/install_elixir.sh` — Elixir via asdf (depends on asdf)
5. `scripts/git_settings.sh <email> <username>` — Git configuration (requires email and username as CLI arguments)

### Requirements

- Idempotent: safe to run multiple times
- Root execution prevention (inherited from existing scripts)
- Success/failure logging per step
- `git_settings.sh` requires email and username as CLI arguments; `install.sh` should prompt the user and pass them

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
- `install.sh` runs end-to-end (with interactive git_settings step)
- No broken references in any config file
