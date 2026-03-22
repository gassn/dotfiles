# atuin リアルタイムヒストリー共有 Design

## Overview

tmuxのセッション間・ペイン間・ウインドウ間で、atuin の Ctrl+R 検索時にリアルタイムにコマンド履歴を共有する。また、履歴から選択したコマンドを実行前に編集でき、実行後に最新の履歴として扱えるようにする。

## Motivation

- atuin の config.toml が dotfiles で管理されていない
- `filter_mode` はデフォルトで `global`（全セッション対象）だが、明示的に設定して意図を文書化したい
- 履歴から選択して実行したコマンドを、実行前に確認・編集してから実行したい（`enter_accept` のデフォルトは即時実行）
- サーバー同期はローカル完結のため不要だが、デフォルトでは有効になっている
- atuin は `bash-preexec` に依存するが未インストールのため、履歴の記録自体が動作していなかった
- fzf が Ctrl+R をバインドしており、atuin の Ctrl+R を上書きしていた

## Design

### 1. `atuin/.config/atuin/config.toml`（新規 Stow パッケージ）

```toml
# ローカル完結、サーバー同期なし
auto_sync = false

# 全セッションの履歴を検索対象にする（デフォルトと同じだが明示的に設定）
filter_mode = "global"

# 検索モード
search_mode = "fuzzy"

# 選択時にコマンドラインに配置（直接実行しない）
# 実行前にコマンドを確認・編集できる
enter_accept = false
```

### 2. `bash/.bashrc`

- fzf 読み込み直後に Ctrl+R のバインドを解除（atuin に委譲）
- `bash-preexec` を atuin init の前に読み込む（atuin の precmd/preexec フックに必須）

### 3. `scripts/install_common.sh`

brew install 行に `bash-preexec` を追加。

### 4. `install.sh`

`stow_with_backup` 呼び出しに `atuin` を追加。

### 5. 既存 config.toml の取り扱い

atuin は初回起動時にデフォルトの `~/.config/atuin/config.toml` を自動生成する。`stow_with_backup` が既存ファイルをバックアップしてから Stow シンボリンクに置き換える。

## Not Changed

- `.bashrc` の atuin 初期化行 — `eval "$(atuin init bash)"` はそのまま
- fzf の Ctrl+T, Alt+C — 影響なし
- tmux の設定 — 変更不要
