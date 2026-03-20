# Claude Code インストール & 設定同梱 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dotfilesにClaude Codeのネイティブインストールと設定ファイル管理を追加し、Stow全パッケージ対象のドリフト検知を導入する

**Architecture:** claude/ Stowパッケージで設定ファイルをシムリンク管理。install_claude.shでネイティブインストーラーを実行。check_drift.shで全Stowパッケージの未管理ファイルを検知。install.shにstow_with_backup()関数を追加し競合を安全に解決。

**Tech Stack:** Bash, GNU Stow, curl

**Spec:** `docs/superpowers/specs/2026-03-20-claude-code-dotfiles-design.md`

---

### Task 1: claude/ Stowパッケージの作成

既存の `~/.claude/` から管理対象ファイルをdotfilesリポジトリにコピーし、Stowパッケージを構築する。

**Files:**
- Create: `claude/.claude/settings.json`
- Create: `claude/.claude/rules/**/*.md` (23ファイル)
- Create: `claude/.claude/plugins/installed_plugins.json`
- Create: `claude/.claude/plugins/known_marketplaces.json`
- Create: `claude/.claude/plugins/blocklist.json`

- [ ] **Step 1: ディレクトリ構造を作成**

```bash
cd ~/dotfiles
mkdir -p claude/.claude/rules/common
mkdir -p claude/.claude/rules/typescript
mkdir -p claude/.claude/plugins
```

- [ ] **Step 2: 設定ファイルをコピー**

```bash
cp ~/.claude/settings.json claude/.claude/settings.json
cp ~/.claude/plugins/installed_plugins.json claude/.claude/plugins/installed_plugins.json
cp ~/.claude/plugins/known_marketplaces.json claude/.claude/plugins/known_marketplaces.json
cp ~/.claude/plugins/blocklist.json claude/.claude/plugins/blocklist.json
```

- [ ] **Step 3: ルールファイルをコピー**

```bash
# トップレベル
for f in agents coding-style development-workflow git-workflow hooks patterns performance security testing; do
  cp ~/.claude/rules/${f}.md claude/.claude/rules/${f}.md
done

# common/
for f in agents coding-style development-workflow git-workflow hooks patterns performance security testing; do
  cp ~/.claude/rules/common/${f}.md claude/.claude/rules/common/${f}.md
done

# typescript/
for f in coding-style hooks patterns security testing; do
  cp ~/.claude/rules/typescript/${f}.md claude/.claude/rules/typescript/${f}.md
done
```

- [ ] **Step 4: コピー結果を確認**

Run: `find claude/ -type f | sort`
Expected: settings.json 1件 + rules 23件 + plugins 3件 = 27ファイル

- [ ] **Step 5: コミット**

```bash
git add claude/
git commit -m "feat: add claude stow package with settings, rules, and plugins config"
```

---

### Task 2: install_claude.sh の作成

ネイティブインストーラーでClaude Codeをインストールするスクリプト。既存スクリプトのパターンに従う。

**Files:**
- Create: `scripts/install_claude.sh`

- [ ] **Step 1: スクリプトを作成**

```bash
#!/bin/bash

set -e

# Prevent running as root.
if [ "$(id -u)" = "0" ]; then
   echo "This script cannot be run as root"
   exit 1
fi

################################################################################
### Install Claude Code (native installer).
### Node.js不要。~/.claude/bin/ に直接インストールされ、PATHは自動設定される。
################################################################################
if command -v claude &>/dev/null; then
    echo "Claude Code is already installed: $(claude --version)"
    exit 0
fi

curl -fsSL https://claude.ai/install.sh | bash

echo "Claude Code installed: $(claude --version)"
```

- [ ] **Step 2: 実行権限を付与**

```bash
chmod +x scripts/install_claude.sh
```

- [ ] **Step 3: コミット**

```bash
git add scripts/install_claude.sh
git commit -m "feat: add install_claude.sh for native Claude Code installation"
```

---

### Task 3: install.sh の更新（stow_with_backup + claude統合）

install.shにStow競合解決関数を追加し、claudeパッケージとインストールステップを統合する。

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: stow_with_backup() 関数を追加**

`run_step()` 関数の後、Step 1の前に以下を追加:

```bash
stow_with_backup() {
    local pkg="$1"

    # ドライランで競合を確認
    local conflicts
    conflicts=$(stow -d "$SCRIPT_DIR" -n "$pkg" 2>&1 | grep "existing target" || true)

    if [ -z "$conflicts" ]; then
        stow -d "$SCRIPT_DIR" "$pkg"
        return
    fi

    # 競合ファイルをバックアップ
    local backup_dir="$HOME/.stow-backup.$(date +%Y%m%d%H%M%S)"
    log "Conflicts detected for '$pkg'. Backing up to $backup_dir"

    while read -r line; do
        # "existing target is neither a link nor a directory: .claude/settings.json" の形式からパスを抽出
        local target
        target=$(echo "$line" | sed 's/.*existing target is neither a link nor a directory: //')
        if [ -n "$target" ] && [ -e "$HOME/$target" ]; then
            mkdir -p "$backup_dir/$(dirname "$target")"
            mv "$HOME/$target" "$backup_dir/$target"
        fi
    done < <(echo "$conflicts")

    stow -d "$SCRIPT_DIR" "$pkg"
    log "Backup saved to $backup_dir"
}
```

- [ ] **Step 2: Step 2のstowコマンドをstow_with_backup()に置き換え、claude追加**

変更前:
```bash
# Step 2: Create symlinks via Stow
log "Creating symlinks via stow..."
cd "$SCRIPT_DIR"
stow bash
stow tmux
log "Done: symlinks created"
```

変更後:
```bash
# Step 2: Create symlinks via Stow
log "Creating symlinks via stow..."
stow_with_backup bash
stow_with_backup tmux
stow_with_backup claude
log "Done: symlinks created"
```

- [ ] **Step 3: Claude Codeインストールステップを追加**

Step 5（languages）とStep 6（git settings）の間に追加:

```bash
# Step 6: Claude Code (native installer)
run_step "Install Claude Code" "$SCRIPT_DIR/scripts/install_claude.sh"
```

既存のStep 6（git settings）のコメントを `# Step 7` に変更。

- [ ] **Step 4: コミット**

```bash
git add install.sh
git commit -m "feat: add stow_with_backup function and claude installation step"
```

---

### Task 4: .driftignore の作成

ドリフト検知で無視するパターンを定義するファイル。

**Files:**
- Create: `.driftignore`

- [ ] **Step 1: .driftignore を作成**

```
# Claude Code ランタイムデータ
.claude/.credentials.json
.claude/history.jsonl
.claude/stats-cache.json
.claude/backups/
.claude/cache/
.claude/debug/
.claude/file-history/
.claude/homunculus/
.claude/ide/
.claude/metrics/
.claude/plans/
.claude/projects/
.claude/session-env/
.claude/sessions/
.claude/shell-snapshots/
.claude/skills/
.claude/statsig/
.claude/tasks/
.claude/telemetry/
.claude/todos/
.claude/plugins/cache/
.claude/plugins/marketplaces/
.claude/plugins/data/
.claude/plugins/install-counts-cache.json

# Bash ランタイム
.bash_history
.bashrc.bak

# Tmux ランタイム
.tmux/
```

- [ ] **Step 2: コミット**

```bash
git add .driftignore
git commit -m "feat: add .driftignore for stow drift detection exclusions"
```

---

### Task 5: check_drift.sh の作成

全Stowパッケージを対象としたドリフト検知スクリプト。

**Files:**
- Create: `scripts/check_drift.sh`

- [ ] **Step 1: スクリプトを作成**

```bash
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
```

- [ ] **Step 2: 実行権限を付与**

```bash
chmod +x scripts/check_drift.sh
```

- [ ] **Step 3: 動作確認**

Run: `./scripts/check_drift.sh`
Expected: スクリプトがエラーなく動作すること。まだstow未適用のため、bash/tmuxパッケージのシムリンク状態チェック結果が出る。

- [ ] **Step 4: コミット**

```bash
git add scripts/check_drift.sh
git commit -m "feat: add check_drift.sh for stow drift detection across all packages"
```

---

### Task 6: Stow適用 & 統合テスト

stow_with_backup()を使ってclaude設定をシムリンク化し、全体の動作を確認する。

**Files:**
- 変更なし（動作確認のみ）

- [ ] **Step 1: stow_with_backup関数を使ってStow適用**

install.shのstow_with_backup関数をsourceして使用する:

```bash
cd ~/dotfiles
# install.shから関数を読み込んで使う代わりに、直接stowを実行
# 競合がある場合は手動で退避

# まずドライランで確認
stow -n claude 2>&1

# 競合がある場合、該当ファイルを退避
backup_dir="$HOME/.stow-backup.$(date +%Y%m%d%H%M%S)"
# （競合ファイルがあれば mkdir -p "$backup_dir" && mv ... ）

# 競合ファイル退避後、stow実行
stow claude
```

- [ ] **Step 2: シムリンクを確認**

Run: `ls -la ~/.claude/settings.json && ls -la ~/.claude/rules/agents.md && ls -la ~/.claude/plugins/installed_plugins.json`
Expected: 各ファイルが `../../dotfiles/claude/.claude/...` へのシムリンクになっている

- [ ] **Step 3: check_drift.sh で確認**

Run: `./scripts/check_drift.sh`
Expected: `.driftignore`に含まれるランタイムファイルは報告されず、未知の新規ファイルがあれば報告される。報告されたファイルを確認し、無視すべきものは`.driftignore`に追加する。

- [ ] **Step 4: バックアップ不要なら削除**

```bash
# シムリンクが正常に動作していることを確認後
rm -rf "$HOME"/.stow-backup.* 2>/dev/null
```
