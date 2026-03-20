# uv Integration Design

## Overview

Python開発のパッケージ/プロジェクト管理およびPythonランタイム管理をasdfからuvに移行する。

## Motivation

- uvをPython開発のベースツールとして利用している
- asdfのPython管理を廃止し、uvの `uv python install` でランタイムを管理する

## Approach

アプローチA（シンプル統合）を採用。既存の構造に最小限の変更で統合する。

## Changes

### 1. `scripts/install_common.sh`

brew install行に `uv` を追加。

```bash
brew install gcc git curl wget fzf eza bat ripgrep fd vim starship stow gh jq inotify-tools aws-cdk zoxide tldr git-delta dust duf procs uv
```

### 2. `scripts/install_languages.sh`

- Pythonビルド依存（apt-get）を削除 — uvはプリビルトバイナリを使うため不要
- `install_language python` を削除

asdfで管理する言語: erlang, elixir, nodejs, awscli（変更なし）

### 3. `bash/.bashrc`

uv shell補完を追加:

```bash
# Enable uv completion.
. <(uv generate-shell-completion bash)
```

## Not Changed

- `.bash_profile` — `~/.local/bin` のPATHは既に設定済み
- `install.sh` — 変更不要
- asdfのawscli — そのまま維持
- weztermパッケージ — 現状維持
