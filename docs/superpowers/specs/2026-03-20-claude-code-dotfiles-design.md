# Claude Code インストール & 設定同梱 設計書

## 概要

dotfilesリポジトリにClaude Codeのネイティブインストールと設定ファイルの同梱を追加する。
加えて、Stow管理対象全体のドリフト検知スクリプトを導入する。

## 背景

- Claude Codeは2026年2月よりネイティブインストーラーが公式推奨（npm非推奨）
- 現在 `~/.claude/` 配下に蓄積された設定ファイル（settings.json, rules/, plugins設定）をdotfilesで管理したい
- Stow管理ファイルに対して、新規追加ファイルのドリフト検知が必要

## ディレクトリ構成

```
dotfiles/
├── claude/                          # Stowパッケージ
│   └── .claude/
│       ├── settings.json            # メイン設定
│       ├── rules/                   # ルールファイル群
│       │   ├── agents.md
│       │   ├── coding-style.md
│       │   ├── development-workflow.md
│       │   ├── git-workflow.md
│       │   ├── hooks.md
│       │   ├── patterns.md
│       │   ├── performance.md
│       │   ├── security.md
│       │   ├── testing.md
│       │   ├── common/
│       │   │   ├── agents.md
│       │   │   ├── coding-style.md
│       │   │   ├── development-workflow.md
│       │   │   ├── git-workflow.md
│       │   │   ├── hooks.md
│       │   │   ├── patterns.md
│       │   │   ├── performance.md
│       │   │   ├── security.md
│       │   │   └── testing.md
│       │   └── typescript/
│       │       ├── coding-style.md
│       │       ├── hooks.md
│       │       ├── patterns.md
│       │       ├── security.md
│       │       └── testing.md
│       └── plugins/
│           ├── installed_plugins.json
│           ├── known_marketplaces.json
│           └── blocklist.json
├── scripts/
│   ├── install_claude.sh            # ネイティブインストーラー実行
│   └── check_drift.sh              # ドリフト検知（全Stowパッケージ対象）
├── .driftignore                     # ドリフト検知の除外パターン
└── install.sh                       # マスターインストーラー（claude追加）
```

## コンポーネント設計

### 1. claude/ Stowパッケージ

`stow claude` で `~/.claude/` 配下にシムリンクを作成する。

**管理対象ファイル:**

| ファイル | 用途 |
|---------|------|
| `settings.json` | パーミッション、プラグイン有効化、言語、思考モード等 |
| `rules/**/*.md` | コーディングスタイル、ワークフロー、セキュリティ等のルール |
| `plugins/installed_plugins.json` | インストール済みプラグイン定義 |
| `plugins/known_marketplaces.json` | マーケットプレースソース定義 |
| `plugins/blocklist.json` | ブロックリスト |

**除外（ランタイムデータ）:**
- `.credentials.json` — 認証情報
- `history.jsonl` — コマンド履歴
- `stats-cache.json` — 統計キャッシュ
- `backups/`, `cache/`, `debug/`, `file-history/`, `homunculus/`, `ide/`, `metrics/`, `plans/`, `projects/`, `session-env/`, `sessions/`, `shell-snapshots/`, `skills/`, `statsig/`, `tasks/`, `telemetry/`, `todos/`
- `plugins/cache/`, `plugins/marketplaces/`, `plugins/data/`, `plugins/install-counts-cache.json`

### 2. install_claude.sh

ネイティブインストーラーでClaude Codeをインストールする。

**仕様:**
- `set -e` でエラー時停止、root実行チェックを含む（既存スクリプトと統一）
- `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"` でPATH確保（既存パターン踏襲）
- `claude` コマンドが既に存在する場合はスキップ（冪等性）
- `curl -fsSL https://claude.ai/install.sh | bash` を実行
- インストール後、`claude --version` で確認

### 3. install.sh への統合

既存のインストールフローに2箇所追加:

1. **Step 2（Stow symlinks）**: `stow claude` を追加
2. **新規Step（asdf/languages後、git設定前）**: `install_claude.sh` を呼び出し

### 4. check_drift.sh

Stow管理対象全体のドリフト検知スクリプト。

**動作仕様:**
- dotfilesリポジトリ内のStowパッケージ一覧を自動検出（bash, tmux, claude等）
- 各パッケージのターゲットディレクトリを特定
  - `claude/` → `~/.claude/`
  - `bash/` → `~/`（ドットファイルのみ）
  - `tmux/` → `~/`（ドットファイルのみ）
- ターゲットディレクトリ内のファイルを走査
- dotfilesリポジトリに存在せず、`.driftignore` にも該当しないファイルを報告

**ドリフト検知アルゴリズム:**

パッケージの種類に応じて走査範囲を決定する:

1. **サブディレクトリ型パッケージ**（claude → `~/.claude/`）:
   - パッケージ内の最上位ディレクトリ（例: `.claude/`）をターゲットとする
   - ターゲットディレクトリ配下の全ファイル・ディレクトリを再帰的に走査
   - Stow管理ファイルと `.driftignore` パターンに一致しないものを報告

2. **ホームディレクトリ型パッケージ**（bash, tmux → `~/`）:
   - パッケージ内のファイル一覧を列挙（例: `.bashrc`, `.bash_aliases`, `.bash_logout`, `.fzf.bash`）
   - ホームディレクトリの走査は行わない（ノイズが多すぎるため）
   - 代わに、管理ファイルのシムリンク状態のみを確認（リンク切れ、非シムリンク化の検知）

**出力例:**
```
[claude] ~/.claude/keybindings.json
[bash]   ~/.bash_profile
```

**終了コード:**
- 0: ドリフトなし
- 1: ドリフト検出

### 5. .driftignore

`.gitignore` と同じ構文でドリフト検知の除外パターンを管理する。

**初期内容:**
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

## Stow競合時の対処

`stow claude` 実行時、`~/.claude/` に既存ファイルがあるとStowが競合エラーを出す。

**解決手順（install.sh内で実行）:**

1. `stow -n claude 2>&1` でドライラン、競合ファイルを特定
2. 競合がなければそのまま `stow claude` を実行
3. 競合がある場合:
   a. 競合ファイルを `~/.claude.bak.<timestamp>/` にバックアップ（ディレクトリ構造を保持）
   b. 競合ファイルを削除
   c. `stow claude` を実行
   d. バックアップの存在をログに表示（ユーザーが確認・削除できるよう）
4. バックアップディレクトリにタイムスタンプを含めることで、複数回実行時も上書きしない

**適用範囲:** この競合解決ロジックは `stow_with_backup()` 関数として実装し、全Stowパッケージ（bash, tmux, claude）に共通で使用する。

## ステップ順序の設計判断

`install.sh` では `stow claude`（Step 2）を `install_claude.sh`（後続Step）より先に実行する。
これにより、Claude Code初回起動時に既に設定ファイルが配置された状態になる。
Claude Codeは既存の設定ファイルを読み込んで動作するため、この順序で問題ない。
逆順（install → stow）にすると、インストール時にClaude Codeがデフォルト設定ファイルを生成し、stow時に競合が必ず発生するため非効率。

## 注意事項

- `plugins/installed_plugins.json` 内の `installPath` はマシン固有パスを含むが、Claude Codeが起動時に自動解決するため問題なし
- `plugins/cache/` と `plugins/marketplaces/` はgitクローンされたリポジトリであり、Claude Codeがプラグインロード時に自動取得するため管理不要
- ルールファイルとプラグイン設定の整理は後続タスクとして別途実施
