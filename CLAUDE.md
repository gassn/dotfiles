# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GNU Stow ベースの dotfiles 管理リポジトリ。WSL2 (Linux) 環境向け。

## Stow パッケージ構造

各トップレベルディレクトリがStowパッケージ（`docs/`, `scripts/` を除く）:

- **Home-level**: `bash/`, `tmux/` — ホームディレクトリ直下にシンボリンクを作成
- **Subdirectory**: `claude/`, `starship/`, `git/`, `vscode/` — サブディレクトリ構造ごとシンボリンクを作成
- **未管理**: `wezterm/` — リポジトリに保管のみ、stow展開はしていない

新しいパッケージを追加する場合: `<name>/<dotfile_or_dotdir>` 構造で作成し、`install.sh` の `stow_with_backup` 呼び出しに追加する。

## 主要コマンド

```bash
# 全体インストール（新規環境セットアップ）
./install.sh

# ドリフト検出（stowパッケージの整合性チェック）
./scripts/check_drift.sh

# 個別パッケージのstow適用
stow -v -d /home/gassn/dotfiles -t ~ <package_name>
```

## インストールフロー (install.sh)

7ステップの順次実行:
1. Linuxbrew + CLI ツール群 (`install_common.sh`)
2. Stow シンボリンク作成 (`stow_with_backup()`)
3. Tmux + TPM (`install_tmux.sh`)
4. asdf バージョン管理 (`install_asdf.sh`)
5. 言語: erlang, elixir, nodejs via asdf (`install_languages.sh`)
6. Claude Code (`install_claude.sh`)
7. Git 設定 (`git_settings.sh`)

Python は uv でプロジェクトごとに管理。awscli は brew でインストール。

## 重要な仕組み

### stow_with_backup()

`install.sh` 内の関数。`stow -n` でドライラン → 競合ファイルをタイムスタンプ付きバックアップ → stow 適用。

### ドリフト検出 (check_drift.sh)

全Stowパッケージを自動検出し、シンボリンクの整合性を検証。`.driftignore` でランタイム生成ファイル（履歴、キャッシュ等）を除外。パッケージはsubdir型とhomedir型の2種類を自動判別。

## コミットメッセージ

```
<type>: <description>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Co-Authored-By 行は不要（settings.json で無効化済み）。
