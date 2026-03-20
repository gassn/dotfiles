# wezterm 設定 双方向同期スクリプト

## 概要

Windows側の `.wezterm.lua` と dotfiles リポジトリ内の `wezterm/.wezterm.lua` をコマンド一発で双方向同期するシェルスクリプト。

## パス定義

| 場所 | パス | 備考 |
|------|------|------|
| Windows側 | `$WIN_WEZTERM` (デフォルト: `/mnt/c/Users/itisa/.wezterm.lua`) | スクリプト上部で変数定義 |
| dotfiles側 | `$DOT_WEZTERM` (デフォルト: `~/dotfiles/wezterm/.wezterm.lua`) | スクリプト上部で変数定義 |

## 前提条件

- `#!/bin/bash` + `set -euo pipefail`
- WSL2環境で `/mnt/c` がマウントされていること（スクリプト冒頭でチェック）

## 動作フロー

1. `/mnt/c` マウント確認（なければエラー終了）
2. 両ファイルの存在チェック
   - 片方のみ存在 → 差分を表示し `Copy X to Y? [y/n]` で確認後コピー
   - 両方なし → エラー終了
3. `diff` で比較（exit code 2 はエラーとして処理）
4. 差分なし → 「同期済みです」と表示して終了
5. 差分あり → `diff --color` で差分を表示し、ユーザーに選択を求める:
   - `[w]` Windows → dotfiles にコピー
   - `[d]` dotfiles → Windows にコピー
   - `[q]` 何もしない
6. コピー前に上書き先の `.bak` バックアップを作成
7. `cp` 実行後、成功を確認して報告

## ファイル構成

- `scripts/sync_wezterm.sh` — 同期スクリプト本体
- `bash/.bash_aliases` — `alias sync-wezterm='~/dotfiles/scripts/sync_wezterm.sh'` を追加

## 設計判断

- 依存なし（`diff`, `cp` のみ使用）
- 既存の `scripts/` ディレクトリのパターンに合致
- タイムスタンプではなく差分表示+手動選択で安全性を確保
- パスは変数定義で変更容易にする
- コピー前にバックアップで安全性を担保
