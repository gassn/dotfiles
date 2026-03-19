# Install Packages Reorganization Design

## Overview

Reorganize installed packages: remove unused tools, add missing brew packages to `install_common.sh`, and consolidate asdf-managed languages into a single `install_languages.sh` script.

## Context

- Dotfiles repo uses `install_common.sh` for brew packages and `install_elixir.sh` for asdf-managed languages
- Several brew packages are installed on the system but not tracked in dotfiles
- Some unused packages remain from previous shell configurations (fish, zsh, powerlevel10k, sheldon)

## Changes

### 1. Remove Unused Brew Packages

One-time manual cleanup (not scripted):
- `fish` — unused shell
- `sheldon` — unused plugin manager (no references in .bashrc)
- `zsh` — unused shell
- `powerlevel10k` — zsh theme, unused after switching to bash + starship
- `node` — migrating to asdf (unlink first if aws-cdk depends on it)
- `python@3.13`, `python@3.14` — migrating to asdf
- `awscli` — migrating to asdf

Note: `node` and `python` may be retained as brew dependencies for `aws-cdk`. Use `brew unlink` to prevent PATH conflicts with asdf versions. Brew's dependency management will keep them installed but unlisted from PATH.

### 2. Update `install_common.sh`

Add to the `brew install` line:
- `jq` — JSON processing
- `inotify-tools` — file watching
- `aws-cdk` — AWS CDK CLI (Note: this pulls in `node` and `python` as brew dependencies. These are kept but unlinked so asdf versions take precedence on PATH. Add `brew unlink node python@3.14` after the install line.)

### 3. Consolidate asdf Languages: `scripts/install_languages.sh`

Rename `install_elixir.sh` → `install_languages.sh` and expand to manage all asdf-managed languages.

**Install order matters** — dependencies must be installed first:

| Order | Language | asdf plugin | Notes |
|-------|----------|-------------|-------|
| 1 | erlang | erlang | Elixir dependency, requires system build libs |
| 2 | elixir | elixir | Depends on erlang |
| 3 | nodejs | nodejs | Pre-built binaries, no build deps needed |
| 4 | python | python | Built from source, requires system build libs |
| 5 | awscli | awscli | Requires python to be installed and set first |

Each language follows the same pattern:
1. `asdf plugin add <name>` (idempotent — no-op if exists)
2. `asdf install <name> latest`
3. `asdf set --home <name> "$(asdf latest <name>)"`

**Build dependencies:**

Erlang (existing):
```bash
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev \
  libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev \
  libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop \
  libxml2-utils libncurses-dev openjdk-11-jdk
```

Python (new):
```bash
sudo apt-get -y install make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev
```

Node.js: no build deps needed (uses pre-built binaries).

awscli: requires asdf python to be set on PATH before `asdf install awscli latest`.

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
