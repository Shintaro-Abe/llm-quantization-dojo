# リポジトリ構造定義書（repository-structure.md）

- 最終更新日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 関連: [architecture.md](architecture.md) ／ [functional-design.md](functional-design.md)

## 1. ディレクトリ構成（全体）

```
llm-quantization-dojo/
├─ docs/                       # 永続ドキュメント（ガバナンス6点）※公開サイトに含めない
│  ├─ product-requirements.md
│  ├─ functional-design.md
│  ├─ architecture.md
│  ├─ repository-structure.md
│  ├─ development-guidelines.md
│  └─ glossary.md
├─ learn/                      # MkDocs docs_dir（座学＝公開サイト本体）
│  ├─ index.md                 # トップ（学習ロードマップ概要・進め方）
│  ├─ getting-started/
│  │  ├─ environment-setup.md  # Colab/Kaggle 導線（環境構築不要）
│  │  └─ progress-tracking.md  # Issues/Projects 進捗管理の始め方
│  └─ chapters/
│     └─ 01-bitsandbytes-qlora/
│        ├─ index.md           # 第1章 概念（薄い自作解説）
│        └─ references.md      # 公式リンク集（最終確認日付き）
├─ notebooks/                  # ハンズオン教材（.ipynb）
│  └─ 01_bitsandbytes_qlora.ipynb
├─ research/                   # 事前調査（既存・出典）
├─ .steering/                  # 作業単位ドキュメント（日付-タイトル）
│  └─ 20260613-initial-implementation/{requirements,design,tasklist}.md
├─ .github/
│  ├─ workflows/
│  │  ├─ deploy-docs.yml       # MkDocs build → GitHub Pages
│  │  └─ link-check.yml        # lychee リンク切れ検査
│  ├─ ISSUE_TEMPLATE/
│  │  ├─ chapter-task.yml      # 章タスク用フォーム
│  │  └─ content-fix.yml       # 内容修正・リンク切れ報告
│  └─ PULL_REQUEST_TEMPLATE.md
├─ mkdocs.yml                  # docs_dir: learn / Material / nav / language: ja
├─ requirements-docs.txt       # mkdocs-material 等（ローカルbuild用・pin）
├─ CLAUDE.md                   # プロジェクトメモリ（開発プロセス規約）
├─ .gitignore                  # site/ を無視
├─ .gitleaks.toml              # シークレット検査設定（既存）
└─ .devcontainer/              # 開発環境（既存）
```

## 2. ディレクトリの役割

| パス | 役割 | 公開 | 編集頻度 |
| :-- | :-- | :-- | :-- |
| `docs/` | プロジェクトのガバナンス文書（北極星） | ✕（サイト非公開） | 低（大きな設計変更時） |
| `learn/` | 学習者向け座学（公開サイト本体） | ○（GitHub Pages） | 中（章追加で増える） |
| `notebooks/` | ハンズオン教材 | ○（Colabで開く） | 中 |
| `research/` | 事前調査・出典 | △（リポジトリ内に保持） | 低 |
| `.steering/` | 作業単位の要求/設計/タスク | △ | 作業ごとに新規作成 |
| `.github/` | CI・Issue/PRテンプレ | n/a | 低〜中 |

## 3. ファイル配置ルール

1. **`docs/` と `learn/` を混同しない**:
   - `docs/` = 「何を/どう作るか」を定義するガバナンス文書。MkDocsの公開対象外。
   - `learn/` = 学習者が読む座学。MkDocsの `docs_dir`。
   - ※MkDocs既定の`docs_dir`は`docs/`だが、本プロジェクトはCLAUDE.md規約を優先し`learn/`に変更している（[architecture.md](architecture.md) §2 のトレードオフ参照）。
2. **章の単位**: `learn/chapters/NN-スラッグ/` に `index.md`（概念）と `references.md`（公式リンク集）を必ず置く。
3. **Notebookの命名**: `notebooks/NN_スラッグ.ipynb`（章番号と対応、スネークケース）。章ページからColabバッジでリンクする。
4. **章番号**: 2桁ゼロ埋め（`01`,`02`,…）。学習順序＝番号順。
5. **公式リンク**: 本文に直書きせず章の `references.md` に集約し、最終確認日を記録する。
6. **生成物**: `site/`（MkDocsビルド出力）はコミットしない（`.gitignore`）。
7. **作業ドキュメント**: 新しい作業は `.steering/[YYYYMMDD]-[タイトル]/` を新規作成（既存を上書きしない）。
8. **秘匿情報**: 認証情報・PII・APIキーをコミットしない（`.gitleaks.toml` で検査）。

## 4. 命名規則（要約）

| 対象 | 規則 | 例 |
| :-- | :-- | :-- |
| 章ディレクトリ | `NN-ケバブケース` | `01-bitsandbytes-qlora` |
| Notebook | `NN_スネークケース.ipynb` | `01_bitsandbytes_qlora.ipynb` |
| 座学ファイル | ケバブケース `.md` | `environment-setup.md` |
| ステアリング | `YYYYMMDD-ケバブケース/` | `20260613-initial-implementation/` |

詳細な規約は [development-guidelines.md](development-guidelines.md) を参照。
