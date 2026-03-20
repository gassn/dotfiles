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
- `install_language python` を `uv python install --default` に置き換え
- コメントを更新（`# Order matters: erlang before elixir, uv python before awscli.`）

awscliはasdf Python shim に依存しているため、uv管理のPythonを awscli インストール前に配置する必要がある。`uv python install --default` により `~/.local/bin/python3` が作成され、PATHに既に含まれているため awscli のインストールに支障なし。

変更後:
```bash
# Order matters: erlang before elixir, uv python before awscli.
install_language erlang
install_language elixir
install_language nodejs
uv python install --default
install_language awscli
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
# Step 5: Languages via asdf (erlang, elixir, nodejs, awscli) and uv (python)
```

## Not Changed

- `.bash_profile` — `~/.local/bin` のPATHは既に設定済み（uv管理のPythonバイナリもここに配置される）
- asdfのawscli — そのまま維持
- weztermパッケージ — 現状維持
