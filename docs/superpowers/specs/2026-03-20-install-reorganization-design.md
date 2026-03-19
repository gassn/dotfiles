# Install Packages Reorganization Design

## Overview

Reorganize installed packages: remove unused tools, add missing brew packages to `install_common.sh`, and consolidate asdf-managed languages into a single `install_languages.sh` script.

## Context

- Dotfiles repo uses `install_common.sh` for brew packages and `install_elixir.sh` for asdf-managed languages
- Several brew packages are installed on the system but not tracked in dotfiles
- Some unused packages remain from previous shell configurations (fish, zsh, powerlevel10k, sheldon)

## Changes

### 1. Remove Unused Brew Packages

Uninstall from current system (one-time cleanup, not scripted):
- `fish` — unused shell
- `sheldon` — unused plugin manager (no references in .bashrc)
- `zsh` — unused shell
- `powerlevel10k` — zsh theme, unused after switching to bash + starship

### 2. Update `install_common.sh`

Add to the `brew install` line:
- `jq` — JSON processing
- `inotify-tools` — file watching
- `aws-cdk` — AWS CDK CLI

### 3. Consolidate asdf Languages: `scripts/install_languages.sh`

Rename `install_elixir.sh` → `install_languages.sh` and expand to manage all asdf-managed languages:

| Language | asdf plugin | Notes |
|----------|-------------|-------|
| erlang | erlang | Existing (elixir dependency) |
| elixir | elixir | Existing |
| nodejs | nodejs | New — migrate from brew |
| python | python | New — migrate from brew |
| awscli | awscli | New — migrate from brew |

Each language follows the same pattern:
1. `asdf plugin add <name>` (idempotent — no-op if exists)
2. `asdf install <name> latest`
3. `asdf set --home <name> "$(asdf latest <name>)"`

The Erlang build dependencies (`apt-get install ...`) remain at the top of the script since Erlang requires system libraries for compilation.

Node.js and Python may also require build dependencies — include them if needed.

Delete `install_elixir.sh` after creating `install_languages.sh`.

### 4. Update `install.sh`

Change step 5 from:
```
run_step "Install Elixir" "$SCRIPT_DIR/scripts/install_elixir.sh"
```
To:
```
run_step "Install languages" "$SCRIPT_DIR/scripts/install_languages.sh"
```

## Out of Scope

- Adding new tools (deferred to a separate discussion)
- Uninstall scripting (unused packages are removed manually once)
