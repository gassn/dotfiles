# atuin Integration Design

## Overview

シェル履歴管理をatuinに移行し、SQLiteベースの高機能な履歴検索を導入する。

## Motivation

- ディレクトリ別、終了コード別、時間帯別での履歴フィルタが可能になる
- 履歴がSQLiteに保存され、実行時刻・終了コード・実行時間・ディレクトリも記録される
- fzfと併用し、`Ctrl+R` はatuinが担当する

## Changes

### 1. `scripts/install_common.sh`

brew install行に `atuin` を追加。

### 2. `bash/.bashrc`

atuinの初期化を追加。fzfより後、starshipより前に配置することで `Ctrl+R` をatuinが上書きする。

```bash
# Enable atuin (shell history).
eval "$(atuin init bash)"
```

### 3. `.driftignore`

atuinのランタイムデータを除外に追加。

```
# Atuin ランタイム
.local/share/atuin/
```

## Not Changed

- fzfの設定 — `Ctrl+R` 以外のfzf機能（`Ctrl+T`, `Alt+C`）はそのまま
- `.bash_profile` — 変更不要
