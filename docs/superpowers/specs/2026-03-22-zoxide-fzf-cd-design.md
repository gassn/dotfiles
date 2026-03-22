# zoxide + fzf ディレクトリジャンプ Design

## Overview

Ctrl+G で zoxide の訪問履歴を fzf で検索し、選択したディレクトリに cd する。

## Motivation

- ディレクトリ移動時に過去の訪問履歴から素早く選択したい
- `cd` のホームディレクトリ移動は維持したい
- 既存の Alt+C（fzf）や `z`（zoxide）とは独立した機能

## Design

### `bash/.bashrc` に追加

```bash
# Ctrl+G: zoxide history with fzf
__zoxide_fzf() {
    local dir
    dir=$(zoxide query -l | fzf --height 40% --reverse) && cd "$dir"
}
bind -x '"\C-g": __zoxide_fzf'
```

- `zoxide query -l`: frecency 順で全訪問ディレクトリを一覧
- `fzf --height 40% --reverse`: 画面上部 40% で選択UI表示
- 選択で cd、Esc キャンセルで何もしない

### vi モードとの互換性

`bind -x` は vi-insert モードにバインドされる。`set -o vi` 環境で Ctrl+G は未使用のため競合なし。

## Not Changed

- `cd` 単体のホームディレクトリ移動
- Alt+C（fzf のディレクトリ検索）
- `z` / `zi`（zoxide のコマンド）
