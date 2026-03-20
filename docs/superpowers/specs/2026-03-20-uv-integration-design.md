# uv Integration Design

## Overview

Python開発のパッケージ/プロジェクト管理をuvに移行する。uvはプロジェクト内でのみPythonを管理し、グローバルなPythonインストールは行わない。

## Motivation

- uvをPython開発のベースツールとして利用している
- asdfのPython管理を廃止し、プロジェクトごとにuvでPythonを管理する
- awscliもasdfからbrewに移行し、Python依存を解消する

## Approach

アプローチA（シンプル統合）を採用。既存の構造に最小限の変更で統合する。

## Changes

### 1. `scripts/install_common.sh`

brew install行に `uv` と `awscli` を追加。

```bash
brew install gcc git curl wget fzf eza bat ripgrep fd vim starship stow gh jq inotify-tools aws-cdk zoxide tldr git-delta dust duf procs uv awscli
```

### 2. `scripts/install_languages.sh`

- Pythonビルド依存（apt-get）を削除 — uvはプロジェクト内でプリビルトバイナリを使うため不要
- `install_language python` を削除
- `install_language awscli` を削除（brewに移行）
- コメントを更新

変更後:
```bash
# Order matters: erlang before elixir.
install_language erlang
install_language elixir
install_language nodejs
```

### 3. `bash/.bashrc`

uv および uvx の shell補完を追加:

```bash
# Enable uv/uvx completion.
. <(uv generate-shell-completion bash)
. <(uvx --generate-shell-completion bash)
```

### 4. `install.sh`

コメントを更新:

```bash
# Step 5: Languages via asdf (erlang, elixir, nodejs)
```

## Not Changed

- `.bash_profile` — 変更不要
- weztermパッケージ — 現状維持
