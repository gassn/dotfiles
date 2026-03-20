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
_userprofile="$(cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')" || {
    echo "エラー: USERPROFILE の取得に失敗しました" >&2
    exit 1
}
WIN_HOME="$(wslpath "$_userprofile")" || {
    echo "エラー: wslpath の変換に失敗しました" >&2
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
        if cp -- "$DOT_WEZTERM" "$WIN_WEZTERM"; then
            echo "コピーしました: $DOT_WEZTERM → $WIN_WEZTERM"
        else
            echo "エラー: コピーに失敗しました" >&2
            exit 1
        fi
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
        if cp -- "$WIN_WEZTERM" "$DOT_WEZTERM"; then
            echo "コピーしました: $WIN_WEZTERM → $DOT_WEZTERM"
        else
            echo "エラー: コピーに失敗しました" >&2
            exit 1
        fi
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
