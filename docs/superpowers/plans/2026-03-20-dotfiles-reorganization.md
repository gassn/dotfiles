# Dotfiles Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up unused dotfiles configurations, migrate to GNU Stow, and improve install automation.

**Architecture:** Three-phase approach — cleanup first, then Stow migration, then install automation. Each phase produces a working state and is committed independently.

**Tech Stack:** Bash, GNU Stow, Linuxbrew, asdf

**Spec:** `docs/superpowers/specs/2026-03-20-dotfiles-reorganization-design.md`

---

### Task 1: Delete Unused Install Scripts

**Files:**
- Delete: `install_rust.sh`
- Delete: `install_esp32_idf.sh`
- Delete: `install_matter.sh`

- [ ] **Step 1: Delete the three unused install scripts**

```bash
git rm install_rust.sh install_esp32_idf.sh install_matter.sh
```

- [ ] **Step 2: Verify no other files reference them**

```bash
grep -r "install_rust\|install_esp32\|install_matter" --include="*.sh" --include="*.md" .
```

Expected: No matches (or only in docs/specs which is fine).

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove unused install scripts (rust, esp-idf, matter)"
```

---

### Task 2: Clean Up `.bashrc`

**Files:**
- Modify: `bash/.bashrc`

Current `.bashrc` has these issues to fix:
- Lines 99-109: oh-my-posh commented-out lines
- Line 118: duplicate `bash_completion.sh` sourcing (same as line 96)
- Line 121: `~/.cargo/env` source (Rust removed)
- Lines 99-109 header comment can go too

- [ ] **Step 1: Remove oh-my-posh lines (99-109)**

Remove the entire block:
```
# Enable oh-my-posh theme.
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/atomic.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/blue-owl.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/clean-detailed.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/lambdageneration.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/montys.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/microverse-power.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/paradox.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/quick-term.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/sonicboom_light.omp.json)"
# eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/wholespace.omp.json)"
```

- [ ] **Step 2: Remove duplicate bash_completion sourcing (line 118)**

Remove the second occurrence:
```
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"
```

Keep only the first one at line 96.

- [ ] **Step 3: Remove Rust cargo env line (line 121)**

Remove:
```
. "$HOME/.cargo/env"
```

- [ ] **Step 4: Clean up blank lines**

Remove excessive blank lines left by deletions. The final `.bashrc` should have single blank lines between sections.

- [ ] **Step 5: Verify the resulting `.bashrc` is valid**

```bash
bash -n bash/.bashrc
```

Expected: No syntax errors.

- [ ] **Step 6: Commit**

```bash
git add bash/.bashrc
git commit -m "chore: clean up .bashrc — remove oh-my-posh, rust, duplicate completion"
```

---

### Task 3: Clean Up `.bash_aliases`

**Files:**
- Modify: `bash/.bash_aliases`

- [ ] **Step 1: Remove the `get_idf` alias (line 27-28)**

Remove:
```
# ESP IDF
alias get_idf='. $HOME/esp/esp-idf/export.sh'
```

- [ ] **Step 2: Commit**

```bash
git add bash/.bash_aliases
git commit -m "chore: remove get_idf alias (esp-idf no longer used)"
```

---

### Task 4: Evaluate and Resolve `.bash_asdf`

**Files:**
- Evaluate: `bash/.bash_asdf`
- Possibly modify: `bash/.bashrc`

The current `.bashrc` line 113 runs `. <(asdf completion bash)` which generates completions at runtime. `.bash_asdf` is a static 147-line completion script. We need to determine if they are equivalent.

- [ ] **Step 1: Compare the two completion sources**

```bash
# Generate runtime completion and compare with static file
asdf completion bash > /tmp/asdf_runtime_completion.bash 2>/dev/null
diff /tmp/asdf_runtime_completion.bash ~/dotfiles/bash/.bash_asdf
```

- [ ] **Step 2a: If equivalent — delete `.bash_asdf`**

```bash
git rm bash/.bash_asdf
git commit -m "chore: remove redundant .bash_asdf (asdf completion bash provides same)"
```

- [ ] **Step 2b: If `.bash_asdf` provides richer completions — keep it and source from `.bashrc`**

Replace `. <(asdf completion bash)` in `.bashrc` with:
```bash
# Enable asdf completion.
[ -f ~/.bash_asdf ] && . ~/.bash_asdf
```

Then commit:
```bash
git add bash/.bashrc bash/.bash_asdf
git commit -m "refactor: source .bash_asdf for richer asdf completions"
```

---

### Task 5: Update `install_common.sh`

**Files:**
- Modify: `install_common.sh`

- [ ] **Step 1: Update the brew install line**

Change line 28 from:
```bash
brew install gcc git curl wget fzf eza bat ripgrep fd vim oh-my-posh
```

To:
```bash
brew install gcc git curl wget fzf eza bat ripgrep fd vim starship stow gh
```

Changes: remove `oh-my-posh`, add `starship`, `stow`, `gh`.

- [ ] **Step 2: Remove the trailing TODO comment (line 36)**

Remove:
```
# TODOs
```

- [ ] **Step 3: Commit**

```bash
git add install_common.sh
git commit -m "chore: update brew packages — replace oh-my-posh with starship, add stow and gh"
```

---

### Task 6: Update `install_elixir.sh`

**Files:**
- Modify: `install_elixir.sh`

- [ ] **Step 1: Remove TODO comments (lines 30-31)**

Remove:
```
# TODOs
# バージョン指定、スコープ指定
```

- [ ] **Step 2: Replace deprecated `asdf global` with `asdf set`**

Change lines 27-28 from:
```bash
asdf global erlang $(asdf latest erlang)
asdf global elixir $(asdf latest elixir)
```

To:
```bash
asdf set --home erlang "$(asdf latest erlang)"
asdf set --home elixir "$(asdf latest elixir)"
```

- [ ] **Step 3: Commit**

```bash
git add install_elixir.sh
git commit -m "chore: clean up install_elixir.sh — remove TODOs, use asdf set"
```

---

### Task 7: Move Install Scripts to `scripts/` Directory

**Files:**
- Move: `install_common.sh` → `scripts/install_common.sh`
- Move: `install_asdf.sh` → `scripts/install_asdf.sh`
- Move: `install_elixir.sh` → `scripts/install_elixir.sh`
- Move: `git_settings.sh` → `scripts/git_settings.sh`
- Move: `no_sudo_password.sh` → `scripts/no_sudo_password.sh`

- [ ] **Step 1: Create `scripts/` directory and move files**

```bash
mkdir -p scripts
git mv install_common.sh scripts/
git mv install_asdf.sh scripts/
git mv install_elixir.sh scripts/
git mv git_settings.sh scripts/
git mv no_sudo_password.sh scripts/
```

- [ ] **Step 2: Commit**

```bash
git commit -m "refactor: move install scripts to scripts/ directory"
```

---

### Task 8: Remove Manual Symlink Management

**Files:**
- Delete: `make_link.sh`
- Modify: `scripts/install_asdf.sh`

- [ ] **Step 1: Delete `make_link.sh`**

```bash
git rm make_link.sh
```

- [ ] **Step 2: Remove symlink lines from `scripts/install_asdf.sh`**

Remove lines 14-15:
```bash
rm -f ~/.bash_asdf
ln -sf ~/dotfiles/bash/.bash_asdf ~/.bash_asdf
```

The resulting `scripts/install_asdf.sh` should be:
```bash
#!/bin/bash

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Install asdf.
################################################################################
brew install asdf
```

- [ ] **Step 3: Verify Stow works correctly**

```bash
cd ~/dotfiles
stow --simulate bash
```

Expected: No errors. Shows which symlinks would be created.

If existing symlinks from `make_link.sh` cause conflicts:
```bash
stow --adopt bash
```

This adopts existing files into the Stow package, then restores from git if needed.

- [ ] **Step 4: Commit**

```bash
git add scripts/install_asdf.sh
git commit -m "refactor: remove manual symlink management, replaced by stow"
```

---

### Task 9: Create Master `install.sh` Script

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Create `install.sh`**

```bash
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
```

- [ ] **Step 2: Make executable**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Verify syntax**

```bash
bash -n install.sh
```

Expected: No syntax errors.

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add master install.sh with dependency-ordered execution"
```

---

### Task 10: Final Verification

- [ ] **Step 1: Verify directory structure matches spec**

```bash
ls -la bash/
ls -la scripts/
ls install.sh
```

Expected structure:
```
bash/.bashrc, .bash_aliases, .bash_logout, .fzf.bash (and optionally .bash_asdf)
scripts/install_common.sh, install_asdf.sh, install_elixir.sh, git_settings.sh, no_sudo_password.sh
install.sh
```

- [ ] **Step 2: Verify no references to deleted tools remain**

```bash
grep -r "oh-my-posh\|cargo/env\|esp-idf\|matter\|get_idf\|install_rust\|install_esp32\|install_matter" --include="*.sh" --include=".bash*" bash/ scripts/ install.sh
```

Expected: No matches.

- [ ] **Step 3: Verify Stow symlinks are correct**

```bash
stow --simulate bash 2>&1
```

Expected: No errors or conflicts.

- [ ] **Step 4: Verify all scripts have no syntax errors**

```bash
bash -n bash/.bashrc
bash -n bash/.bash_aliases
bash -n scripts/install_common.sh
bash -n scripts/install_asdf.sh
bash -n scripts/install_elixir.sh
bash -n scripts/git_settings.sh
bash -n install.sh
```

Expected: No errors for any file.
