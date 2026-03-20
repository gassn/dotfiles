# wezterm 設定 双方向同期スクリプト

## 概要

Windows側の `.wezterm.lua` と dotfiles リポジトリ内の `wezterm/.wezterm.lua` をコマンド一発で双方向同期するシェルスクリプト。

## パス定義

| 場所 | パス |
|------|------|
| Windows側 | `/mnt/c/Users/itisa/.wezterm.lua` |
| dotfiles側 | `~/dotfiles/wezterm/.wezterm.lua` |

## 動作フロー

1. 両ファイルの存在チェック
   - 片方のみ存在 → その旨を表示し、一方向コピーを提案
   - 両方なし → エラー終了
2. `diff` で比較
3. 差分なし → 「同期済みです」と表示して終了
4. 差分あり → `diff --color` で差分を表示し、ユーザーに選択を求める:
   - `[w]` Windows → dotfiles にコピー
   - `[d]` dotfiles → Windows にコピー
   - `[q]` 何もしない

## ファイル構成

- `scripts/sync_wezterm.sh` — 同期スクリプト本体
- `bash/.bash_aliases` — `alias sync-wezterm='~/dotfiles/scripts/sync_wezterm.sh'` を追加

## 設計判断

- 依存なし（`diff`, `cp` のみ使用）
- 既存の `scripts/` ディレクトリのパターンに合致
- タイムスタンプではなく差分表示+手動選択で安全性を確保
