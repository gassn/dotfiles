#!/bin/bash

# Stow管理対象のドリフト検知スクリプト
# dotfilesリポジトリで管理されていないファイルを検出する
#
# パターンマッチング: 完全一致とディレクトリプレフィックス一致のみ対応
# （globパターンは未対応）

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIFTIGNORE="$DOTFILES_DIR/.driftignore"
TARGET_DIR="${HOME%/}"
drift_found=0

# .driftignoreのパターンをグローバル配列に読み込み（起動時に1回だけ）
IGNORE_PATTERNS=()
load_ignore_patterns() {
    if [ -f "$DRIFTIGNORE" ]; then
        while IFS= read -r line; do
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
            IGNORE_PATTERNS+=("$line")
        done < "$DRIFTIGNORE"
    fi
}

# パスが.driftignoreパターンに一致するか確認
is_ignored() {
    local rel_path="$1"

    for pattern in "${IGNORE_PATTERNS[@]}"; do
        # ディレクトリパターン（末尾に/）
        if [[ "$pattern" == */ ]]; then
            if [[ "$rel_path" == ${pattern}* || "$rel_path/" == "$pattern" ]]; then
                return 0
            fi
        else
            # ファイルパターン（完全一致）
            if [[ "$rel_path" == "$pattern" ]]; then
                return 0
            fi
        fi
    done
    return 1
}

# Stowパッケージ一覧を検出（ドットファイル/ドットディレクトリを含むディレクトリ）
detect_packages() {
    for dir in "$DOTFILES_DIR"/*/; do
        local pkg_name
        pkg_name=$(basename "$dir")
        # .[!.]* で . と .. を除外したドットファイルの存在を確認
        if compgen -G "$dir"'.[!.]*' > /dev/null 2>&1; then
            PACKAGES+=("$pkg_name")
        fi
    done
}

# パッケージの種類を判定
# サブディレクトリ型: パッケージ直下にドットディレクトリがある（例: claude/.claude/）
# ホームディレクトリ型: パッケージ直下にドットファイルのみ（例: bash/.bashrc）
get_package_type() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    for entry in "$pkg_dir"/.[!.]*; do
        [ -e "$entry" ] || continue
        if [ -d "$entry" ]; then
            echo "subdir"
            return
        fi
    done
    echo "homedir"
}

# サブディレクトリ型パッケージのドリフト検知
check_subdir_package() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    for dot_dir in "$pkg_dir"/.[!.]*; do
        [ -d "$dot_dir" ] || continue
        local dir_name
        dir_name=$(basename "$dot_dir")

        local target="$TARGET_DIR/$dir_name"
        [ ! -d "$target" ] && continue

        # ターゲットディレクトリを再帰的に走査
        while IFS= read -r -d '' file; do
            local rel_path
            rel_path="${file#$TARGET_DIR/}"

            # Stow管理ファイルか確認
            if [ -e "$pkg_dir/$rel_path" ]; then
                continue
            fi

            # .driftignoreに一致するか確認
            if is_ignored "$rel_path"; then
                continue
            fi

            printf "[%-8s] %s\n" "$pkg" "$file"
            drift_found=1
        done < <(find "$target" -type f -print0 2>/dev/null)
    done
}

# ホームディレクトリ型パッケージのドリフト検知（シムリンク状態確認のみ）
check_homedir_package() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    for file in "$pkg_dir"/.[!.]*; do
        [ -e "$file" ] || continue
        local name
        name=$(basename "$file")

        local target="$TARGET_DIR/$name"

        if [ ! -e "$target" ]; then
            printf "[%-8s] %s (missing)\n" "$pkg" "$target"
            drift_found=1
        elif [ ! -L "$target" ]; then
            printf "[%-8s] %s (not a symlink)\n" "$pkg" "$target"
            drift_found=1
        else
            local link_target
            link_target=$(readlink -f "$target")
            local expected
            expected=$(readlink -f "$file")
            if [ "$link_target" != "$expected" ]; then
                printf "[%-8s] %s (wrong target: %s)\n" "$pkg" "$target" "$link_target"
                drift_found=1
            fi
        fi
    done
}

# メイン処理
main() {
    load_ignore_patterns

    PACKAGES=()
    detect_packages

    if [ ${#PACKAGES[@]} -eq 0 ]; then
        echo "No stow packages found in $DOTFILES_DIR"
        exit 0
    fi

    for pkg in "${PACKAGES[@]}"; do
        local pkg_type
        pkg_type=$(get_package_type "$pkg")

        case "$pkg_type" in
            subdir)  check_subdir_package "$pkg" ;;
            homedir) check_homedir_package "$pkg" ;;
        esac
    done

    if [ "$drift_found" -eq 0 ]; then
        echo "No drift detected."
    fi

    exit "$drift_found"
}

main
