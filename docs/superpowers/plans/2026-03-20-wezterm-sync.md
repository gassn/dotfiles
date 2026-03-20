# wezterm設定 双方向同期スクリプト 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Windows側とdotfilesリポジトリ間でwezterm設定を双方向同期するスクリプトを作成する

**Architecture:** `scripts/sync_wezterm.sh` にロジックを実装し、`bash/.bash_aliases` にエイリアスを追加。パスは動的に解決し、コピー前にバックアップを作成する。

**Tech Stack:** Bash, diff, cp

**Spec:** `docs/superpowers/specs/2026-03-20-wezterm-sync-design.md`

---

## ファイル構成

- Create: `scripts/sync_wezterm.sh`
- Modify: `bash/.bash_aliases` (エイリアス1行追加)

---

### Task 1: sync_wezterm.sh を作成

**Files:**
- Create: `scripts/sync_wezterm.sh`

- [ ] **Step 1: スクリプト本体を作成**

```bash
#!/bin/bash

# wezterm設定の双方向同期スクリプト
# Windows側 <-> dotfilesリポジトリ間で .wezterm.lua を同期する

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOT_WEZTERM="$DOTFILES_DIR/wezterm/.wezterm.lua"

# /mnt/c マウント確認
if [ ! -d /mnt/c ]; then
    echo "エラー: /mnt/c がマウントされていません" >&2
    exit 1
fi

# Windows側ホームディレクトリを動的取得
WIN_HOME="$(wslpath "$(cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")" || {
    echo "エラー: Windows ユーザープロファイルの取得に失敗しました" >&2
    exit 1
}
WIN_WEZTERM="$WIN_HOME/.wezterm.lua"

# 両方存在しない場合
if [ ! -f "$WIN_WEZTERM" ] && [ ! -f "$DOT_WEZTERM" ]; then
    echo "エラー: どちらの .wezterm.lua も見つかりません" >&2
    echo "  Windows: $WIN_WEZTERM" >&2
    echo "  dotfiles: $DOT_WEZTERM" >&2
    exit 1
fi

# 片方のみ存在する場合
if [ ! -f "$WIN_WEZTERM" ]; then
    echo "Windows側に .wezterm.lua がありません: $WIN_WEZTERM"
    echo ""
    echo "コピー元の内容 ($DOT_WEZTERM):"
    head -20 -- "$DOT_WEZTERM"
    echo "..."
    echo ""
    read -rp "dotfiles → Windows にコピーしますか? [y/n] " ans
    if [[ "$ans" == "y" ]]; then
        cp -- "$DOT_WEZTERM" "$WIN_WEZTERM"
        echo "コピーしました: $DOT_WEZTERM → $WIN_WEZTERM"
    fi
    exit 0
fi

if [ ! -f "$DOT_WEZTERM" ]; then
    echo "dotfiles側に .wezterm.lua がありません: $DOT_WEZTERM"
    echo ""
    echo "コピー元の内容 ($WIN_WEZTERM):"
    head -20 -- "$WIN_WEZTERM"
    echo "..."
    echo ""
    read -rp "Windows → dotfiles にコピーしますか? [y/n] " ans
    if [[ "$ans" == "y" ]]; then
        cp -- "$WIN_WEZTERM" "$DOT_WEZTERM"
        echo "コピーしました: $WIN_WEZTERM → $DOT_WEZTERM"
    fi
    exit 0
fi

# diff で比較 (exit code: 0=同一, 1=差分あり, 2=エラー)
diff_exit=0
diff --color -u -- "$DOT_WEZTERM" "$WIN_WEZTERM" || diff_exit=$?

if [ "$diff_exit" -eq 2 ]; then
    echo "エラー: diff の実行に失敗しました" >&2
    exit 1
fi

if [ "$diff_exit" -eq 0 ]; then
    echo "同期済みです（差分なし）"
    exit 0
fi

# 差分あり — ユーザーに選択を求める
echo ""
echo "どちらを採用しますか?"
echo "  [w] Windows → dotfiles"
echo "  [d] dotfiles → Windows"
echo "  [q] 何もしない"
read -rp "> " choice

case "$choice" in
    w)
        cp -- "$DOT_WEZTERM" "${DOT_WEZTERM}.bak"
        if cp -- "$WIN_WEZTERM" "$DOT_WEZTERM"; then
            echo "コピーしました: Windows → dotfiles (バックアップ: ${DOT_WEZTERM}.bak)"
        else
            echo "エラー: コピーに失敗しました" >&2
            exit 1
        fi
        ;;
    d)
        cp -- "$WIN_WEZTERM" "${WIN_WEZTERM}.bak"
        if cp -- "$DOT_WEZTERM" "$WIN_WEZTERM"; then
            echo "コピーしました: dotfiles → Windows (バックアップ: ${WIN_WEZTERM}.bak)"
        else
            echo "エラー: コピーに失敗しました" >&2
            exit 1
        fi
        ;;
    q)
        echo "何もしませんでした"
        ;;
    *)
        echo "無効な選択です: $choice" >&2
        exit 1
        ;;
esac
```

- [ ] **Step 2: 実行権限を付与**

```bash
chmod +x scripts/sync_wezterm.sh
```

- [ ] **Step 3: 動作確認**

```bash
./scripts/sync_wezterm.sh
```

Expected: 差分がなければ「同期済みです（差分なし）」と表示

- [ ] **Step 4: コミット**

```bash
git add scripts/sync_wezterm.sh
git commit -m "feat: add wezterm bidirectional sync script"
```

---

### Task 2: bashエイリアスを追加

**Files:**
- Modify: `bash/.bash_aliases` (末尾に追加)

- [ ] **Step 1: エイリアスを追加**

`bash/.bash_aliases` の末尾に以下を追加:

```bash

# wezterm
alias sync-wezterm='~/dotfiles/scripts/sync_wezterm.sh'
```

- [ ] **Step 2: エイリアスの動作確認**

```bash
source ~/.bash_aliases
sync-wezterm
```

Expected: `sync_wezterm.sh` と同じ出力

- [ ] **Step 3: コミット**

```bash
git add bash/.bash_aliases
git commit -m "feat: add sync-wezterm alias"
```
