# Claude Code dotfiles for GitHub Codespaces

GitHub Codespaces の dotfiles 機能を使って、ローカルで使っている Claude Code のサブエージェントとグローバル `CLAUDE.md` を、新規作成される全 Codespace に自動配置するためのリポジトリ。

## 1. 概要

`new-proto` スキルで作られた Codespace を含む、自分のアカウントで作成される全 Codespace に、以下を自動で配置する:

- `~/.claude/agents/tech-researcher.md` — Web 検索専用サブエージェント
- `~/.claude/CLAUDE.md` — 言語ポリシー / Research 委譲ポリシー / Mermaid 指針 / Bash スタイル

Codespace 側で `claude` 起動時に、これらがグローバル設定として効く。

## 2. 配置されるもの / 配置しないもの

### 配置するもの

| ファイル | 役割 |
|---|---|
| `~/.claude/agents/tech-researcher.md` | `/tech-researcher` サブエージェント(Web 調査委譲用) |
| `~/.claude/CLAUDE.md` | ユーザーグローバル指針 |

### 配置しないもの(意図的除外)

| 除外対象 | 理由 |
|---|---|
| `~/.claude/settings.json` | プロジェクト側 `.claude/settings.json` とスコープが被る |
| `~/.claude/.credentials.json` | `CLAUDE_CODE_OAUTH_TOKEN` env var 認証と二重化を避ける |
| `~/.claude/skills/` | `new-proto` は Codespace 内で使う意味が薄く、他スキルも今はスコープ外 |
| `~/.claude.json` | テンプレ `postCreateCommand` が onboarding skip 用に管理済み |

## 3. 初回セットアップ(1 回だけ)

1. このリポジトリを GitHub にプッシュ済みであることを確認
2. https://github.com/settings/codespaces を開く
3. **Automatically install dotfiles** セクションで、このリポジトリを選択して ON
4. 保存

これ以降、新規作成される Codespace に自動適用される。

## 4. 日常運用(ローカル編集 → sync → push)

編集はローカルの `~/.claude/` 側で普通に行う。Codespace に反映したい時だけ以下を実行:

```powershell
# ~/.claude/ 側で編集後
cd C:\Users\rotte\Documents\Claude_WorkSpace\dotfiles
powershell -NoProfile -ExecutionPolicy Bypass -File .\sync-from-local.ps1
git add -A
git commit -m "sync: update from local ~/.claude/"
git push
```

(PowerShell 7+ がインストールされていれば `pwsh .\sync-from-local.ps1` でも可)

以降の新規 Codespace は最新版を受け取る。既存 Codespace に反映したい場合:

```bash
gh codespace rebuild -c <codespace_name>
```

## 5. 適用範囲

- **有効化以降に作成される全 Codespace にリポジトリ横断で適用**(ユーザー単位設定)
- **本人のアカウントのみ** — 共同作業者の Codespace には影響しない
- **既存 Codespace は対象外** — rebuild で再適用する必要あり
- **個別 opt-out 可能** — Codespace 作成時に "Don't install dotfiles" を選ぶとスキップ

## 6. Private 化した場合の運用

### ケース A: このリポ自体を Private にする(同一アカウント所有)

GitHub Codespaces は本人の認証で自動 clone するため、**追加の PAT は原則不要**。リポジトリ設定で Private に切り替えるだけでよい。

Codespace 起動時に dotfiles の clone が失敗する場合は、GitHub → Settings → Codespaces → Dotfiles のログで 403/404 を確認。

### ケース B: install.sh から追加で他の Private リソースを clone したい場合

1. Codespaces user secret を作成: Settings → Codespaces → Secrets で `DOTFILES_PAT` を追加し、`repo:read` スコープ付きの PAT を格納
2. secret の Repository access でこの dotfiles リポを allowlist に追加
3. `install.sh` に以下のパターンを追加:

```bash
if [ -n "${DOTFILES_PAT:-}" ]; then
  git clone "https://x-access-token:${DOTFILES_PAT}@github.com/<owner>/<private-repo>.git" /tmp/extra
  # /tmp/extra から追加資産を ~/.claude/ 配下にコピー
fi
```

セキュリティ注意:

- PAT は最小スコープで発行
- dotfiles リポのコードに PAT を直書きしない(env var 経由のみ)
- 期限を 90 日等で区切り、定期ローテート

### ケース C: 組織所有の Private dotfiles を使う場合

Settings → Codespaces → Access and security で該当組織を許可し、組織側でも Codespaces 向け dotfiles 利用を許可するポリシーが必要。

## 7. トラブルシュート

- **dotfiles が適用されていない**
  - Codespace 内で `ls -la ~/.claude/` を確認
  - `/workspaces/.codespaces/.persistedshare/creation.log` に install.sh のログが残る
  - clone 先 `/workspaces/.codespaces/.persistedshare/dotfiles/` の存在を確認
- **install.sh が CRLF エラーで落ちる**
  - `.gitattributes` で `*.sh text eol=lf` を指定済み。既存ファイルが CRLF の場合は再保存
- **`/tech-researcher` が候補に出ない**
  - `~/.claude/agents/tech-researcher.md` の frontmatter(`name:`, `description:`, `tools:`, `model:`)を検証

## ファイル構成

```
dotfiles/
├── README.md             # このファイル
├── install.sh            # Codespace 側で実行される dotfiles install script (LF)
├── sync-from-local.ps1   # ローカル Windows で実行する一方向同期スクリプト
├── .gitattributes        # 改行コード制御
└── claude/
    ├── agents/
    │   └── tech-researcher.md
    └── CLAUDE.md
```
