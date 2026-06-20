# 開発ガイドライン（development-guidelines.md）

- 最終更新日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 関連: [repository-structure.md](repository-structure.md) ／ [architecture.md](architecture.md) ／ [glossary.md](glossary.md)

## 1. コーディング規約

### 1.1 Python（Notebook内）
- Python 3.10+ 想定。PEP 8 準拠。変数・関数は `snake_case`、定数は `UPPER_SNAKE`。
- 依存は**バージョン固定（pin）**して再現性を確保（例: `transformers==x.y.z`）。
- 乱数 `seed` を固定し、結果が再現できるようにする。
- 重い処理の前に `nvidia-smi` でGPU/VRAMを確認するセルを置く。
- シークレット（HFトークン等）は**コードに直書きしない**。Colabの環境変数/シークレット機能を案内する。

### 1.2 Markdown（座学）
- 本文は日本語、コード・専門用語は英語。1文を短く、初学者向けに平易に。
- 概念の正確な仕様は本文に長く書かず、`references.md` の公式リンクに委ねる。
- 見出しは `#` から階層を飛ばさない。表・Mermaidを活用して視認性を上げる。

## 2. 命名規則

| 対象 | 規則 | 例 |
| :-- | :-- | :-- |
| 章ディレクトリ | `NN-kebab-case` | `01-bitsandbytes-qlora` |
| Notebook | `NN_snake_case.ipynb` | `01_bitsandbytes_qlora.ipynb` |
| 座学Markdown | `kebab-case.md` | `environment-setup.md` |
| ブランチ | `種別/短い説明` | `feat/ch01-qlora`, `docs/architecture` |
| ステアリング | `YYYYMMDD-kebab-case/` | `20260613-initial-implementation/` |

## 3. ドキュメント/教材の品質規約

### 3.1 章の構成（必須4点セット）
各章は「**概念(index.md) → 公式ドキュメント(references.md) → ハンズオン(.ipynb) → 理解度確認/タスク(Issue)**」を必ず揃える。

> 背景: 「理解→裏取り→実践→定着」を一直線にし、初学者が次に何をすべきか迷わないようにするため。

### 3.2 Notebook規約
Notebookは「上から順に実行するだけで終わる」状態にする。具体的には次を守る。

> 背景: 初学者が最もつまずく「環境構築・手順の詰まり」をなくし、誰でも完走できるようにするため。

- **最初のセル**に「Open in Colab」バッジ（起動ボタン）と、目安情報（所要時間・必要VRAM・使うモデル・最終確認日）を書く。
- **セルは次の順に並べる**: ①タイトルと目安 → ②インストール（バージョン固定） → ③GPU確認とseed設定 → ④本編（手順ごとに説明） → ⑤理解度チェックとIssueへのリンク。
- **使うモデルは無料GPU（Colab T4）で必ず終わるサイズ**にする（1〜3B級・ログイン不要なApache/MITを推奨）。7Bは「発展課題」と明記する。
- **保存（コミット）前に実行結果を消す**（`nbstripout`の利用は任意）。差分が見やすくなる。

### 3.3 教材の分量・調達・著作権

> 背景: 本文を薄く保つと公式更新による情報の陳腐化を防げる。実習の完全性はNotebookで担保し、著作権・ライセンスも守るため。

- **ハンズオン（Notebook）は「完結・実行可能」にする**: 初学者が写経せず順に実行するだけで **Run all 完走** できる、欠落のない完全なコードを自作する。「最小コード例」ルールはNotebookには適用しない（完走保証＝受け入れ条件AC-2を優先）。
- **座学（Markdown）は「薄く」保つ**: 本文中のコードは概念理解を助ける**最小コード例**（挿絵的スニペット）に留め、正確な仕様・全手順は公式ドキュメントとハンズオンNotebookに委ねる。
- **「転載しない」の意味**: 公式の文章や長いコードブロックを丸写ししない、ということ。標準的なAPI呼び出しや短いイディオムを参照して**自作のNotebookに書く**ことは問題ない（API利用例は自作の範囲）。
- モデル/データセットはライセンスを確認。ゲートモデルを使う場合はトークン取得手順を別途案内。

> 要点: 「最小コード例＝座学ページ」「完全な実行可能コード＝ハンズオンNotebook」。初学者の実習体験はNotebook側で担保する。

## 4. 公式情報への追従ルール（鮮度管理）

- 各章の公式リンク集の冒頭に **最終確認日** を記載する。
- 公式リンクは**絶対URL**で書き、リンクチェッカ（lychee）CIでリンク切れを検出する。
- **四半期に一度**（または章着手時）に公式情報をレビューし、最終確認日を更新する。

### 更新の進め方（方式）
情報の鮮度は「自動検知」と「定期の目視」の二段構えで保つ。

- **自動検知（リンク切れ）**: リンク切れを定期実行（月1回）とpush時に自動チェックする。検知したら該当リンクを修正する。
- **検知時の更新フロー**: リンク・本文・Notebookのうち影響箇所を修正 → 最終確認日を更新 → レビュー（PR）を経て反映する。
- **中身の陳腐化（自動検知できない変更）**: リンクが生きていてもAPI名・引数・推奨手順が変わることがある。これは自動検知できないため、**章着手時と四半期レビューで公式情報を目視確認**して対応する。
- **影響の局所化**: 依存はバージョン固定し、手法・ライブラリの乗り換えは該当章の作業として切り出して反映する。
- **ライブラリ移管に注意**（[research/01](../research/01-quantization-methods.md)）:
  - bitsandbytes → `bitsandbytes-foundation/bitsandbytes`
  - llama.cpp → `ggml-org/llama.cpp`
  - GPTQ: AutoGPTQ → `GPTQModel` への移行
  - AWQ: AutoAWQ は開発終了方向（vLLM/llm-compressor系へ）
  - **GPTQ/AWQ章の着手時に最新状況を必ず再確認**してから執筆する。

## 5. Git規約

- **ブランチ運用**: `main` へ直接コミットしない。`種別/説明` ブランチを切り、PRでマージ。
- **コミットメッセージ**: Conventional Commits 準拠（`feat:`, `docs:`, `fix:`, `chore:`, `ci:`）。日本語可。
- **PR**: `PULL_REQUEST_TEMPLATE.md` のチェックリスト（リンク切れ確認・Notebook実行確認・公式doc最終確認日更新）を満たす。
- **コミット前**: `.gitleaks.toml` でシークレット/PIIを検査（pre-commit-secret-scan 運用）。
- **生成物**: `site/` 等のビルド成果物はコミットしない。

## 6. CI/CD 運用

| ワークフロー | トリガ | 内容 |
| :-- | :-- | :-- |
| `deploy-docs.yml` | `main` push | `mkdocs build --strict` → Pages へデプロイ |
| `link-check.yml` | push / 定期 | lychee で内部・外部リンク切れ検査 |

- Pages ソースは GitHub リポジトリ設定で **「GitHub Actions」** を選択する（初回のみ手動設定）。
- `mkdocs build --strict` は警告をエラー扱いにし、リンク切れ・nav不整合を早期検出する。

## 7. 品質チェック（マージ前）

- [ ] `mkdocs build --strict` が警告ゼロ
- [ ] `link-check` がgreen（リンク切れなし）
- [ ] 追加/変更したNotebookが無料T4で Run all 完走
- [ ] `references.md` の最終確認日を更新
- [ ] シークレット/PIIを含まない（gitleaks）
