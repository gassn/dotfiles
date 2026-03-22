# atuin リアルタイムヒストリー共有 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** atuin の config.toml を dotfiles で Stow 管理し、tmux セッション/ペイン/ウインドウ間でリアルタイムにヒストリーを共有する

**Architecture:** 新規 Stow パッケージ `atuin/` を作成し `~/.config/atuin/config.toml` を管理。bash-preexec を導入して atuin のフックを有効化。fzf の Ctrl+R を解除して atuin に委譲。

**Tech Stack:** GNU Stow, atuin, bash-preexec, bash

**Spec:** `docs/superpowers/specs/2026-03-22-atuin-realtime-history-design.md`

---

### Task 1: bash-preexec のインストール

**Files:**
- Modify: `scripts/install_common.sh:28`

- [x] brew install 行に `bash-preexec` を追加

### Task 2: bash/.bashrc の更新

**Files:**
- Modify: `bash/.bashrc`

- [x] fzf 読み込み直後に Ctrl+R バインドを解除（vi-insert, vi-command, emacs）
- [x] atuin init の前に bash-preexec を source

### Task 3: atuin Stow パッケージの作成

**Files:**
- Create: `atuin/.config/atuin/config.toml`

- [x] config.toml を作成（auto_sync=false, filter_mode=global, search_mode=fuzzy, enter_accept=false）

### Task 4: install.sh に atuin パッケージを追加

**Files:**
- Modify: `install.sh:85`

- [x] `stow_with_backup atuin` を追加

### Task 5: 動作確認

- [x] `stow -v -d . -t ~ atuin` でシンボリンク作成
- [x] `exec bash` で新しいシェルを起動
- [x] tmux の別ペインで実行したコマンドが Ctrl+R で検索できることを確認
- [x] 選択時にコマンドラインに配置されること（即時実行されない）を確認
