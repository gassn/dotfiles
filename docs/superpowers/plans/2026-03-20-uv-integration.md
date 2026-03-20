# uv Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Python開発ツールuvをdotfilesに統合し、asdfからPython/awscli管理を移行する

**Architecture:** brewでuv/awscliをインストールし、asdfからPython/awscliを削除。uvはプロジェクト内でのみPythonを管理する。bash補完を追加。

**Tech Stack:** GNU Stow, Linuxbrew, uv, bash

**Spec:** `docs/superpowers/specs/2026-03-20-uv-integration-design.md`

---

### Task 1: install_common.sh に uv と awscli を追加

**Files:**
- Modify: `scripts/install_common.sh:28`

- [ ] **Step 1: brew install行に uv と awscli を追加**

```bash
brew install gcc git curl wget fzf eza bat ripgrep fd vim starship stow gh jq inotify-tools aws-cdk zoxide tldr git-delta dust duf procs uv awscli
```

- [ ] **Step 2: 変更を確認**

Run: `grep 'brew install' scripts/install_common.sh`
Expected: 行末に `uv awscli` が含まれる

- [ ] **Step 3: Commit**

```bash
git add scripts/install_common.sh
git commit -m "feat: add uv and awscli to brew install"
```

---

### Task 2: install_languages.sh から Python と awscli を削除

**Files:**
- Modify: `scripts/install_languages.sh:30-33,48-53`

- [ ] **Step 1: Pythonビルド依存のapt-getブロックを削除**

削除対象（30-33行目）:
```bash
# Python build dependencies.
sudo apt-get -y install make libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

- [ ] **Step 2: コメントとinstall_language呼び出しを更新**

変更前:
```bash
# Order matters: erlang before elixir, python before awscli.
install_language erlang
install_language elixir
install_language nodejs
install_language python
install_language awscli
```

変更後:
```bash
# Order matters: erlang before elixir.
install_language erlang
install_language elixir
install_language nodejs
```

- [ ] **Step 3: 変更を確認**

Run: `grep -n 'python\|awscli' scripts/install_languages.sh`
Expected: マッチなし（python/awscliへの参照がすべて消えている）

- [ ] **Step 4: Commit**

```bash
git add scripts/install_languages.sh
git commit -m "feat: remove python and awscli from asdf management"
```

---

### Task 3: .bashrc に uv/uvx 補完を追加

**Files:**
- Modify: `bash/.bashrc:36` (gh completion の後に追加)

- [ ] **Step 1: gh completion の後に uv/uvx 補完を追加**

```bash
# Enable uv/uvx completion.
. <(uv generate-shell-completion bash)
. <(uvx --generate-shell-completion bash)
```

- [ ] **Step 2: 変更を確認**

Run: `grep -n 'uv' bash/.bashrc`
Expected: uv generate-shell-completion と uvx --generate-shell-completion の2行が表示される

- [ ] **Step 3: Commit**

```bash
git add bash/.bashrc
git commit -m "feat: add uv/uvx shell completion to bashrc"
```

---

### Task 4: install.sh のコメントを更新

**Files:**
- Modify: `install.sh:94`

- [ ] **Step 1: Step 5 のコメントを更新**

変更前:
```bash
# Step 5: Languages via asdf (erlang, elixir, nodejs, python, awscli)
```

変更後:
```bash
# Step 5: Languages via asdf (erlang, elixir, nodejs)
```

- [ ] **Step 2: 変更を確認**

Run: `grep 'Step 5' install.sh`
Expected: `# Step 5: Languages via asdf (erlang, elixir, nodejs)`

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "docs: update install.sh comment to reflect asdf changes"
```
