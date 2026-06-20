# 初回実装 タスクリスト（tasklist.md）

- 作業名: initial-implementation（MVP=第1章 bitsandbytes NF4/QLoRA）
- 作成日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 上位文書: [requirements.md](requirements.md) ／ [design.md](design.md)

## 進捗記法

- `[ ]` 未着手 ／ `[~]` 着手中 ／ `[x]` 完了
- 各フェーズ末尾に「完了条件（DoD）」を記載。フェーズ単位でPR・品質チェックを行う。

---

## Phase 3: サイト足場（公開される空サイトの確立）

- [ ] T3-1 `requirements-docs.txt` を作成し `mkdocs-material` 等をpin（バージョン固定）。
- [ ] T3-2 `mkdocs.yml` を作成（`docs_dir: learn`・`theme: material`・`language: ja`・nav・pymdownx コードハイライト/admonition/タブ）。
- [ ] T3-3 `learn/index.md` を作成（学習ロードマップ概要・4点セットの進め方）。
- [ ] T3-4 `.gitignore` に `site/` を追記。
- [ ] T3-5 ローカル検証: `pip install -r requirements-docs.txt && mkdocs build --strict` が警告ゼロ。

**DoD**: ローカルで `mkdocs serve` がトップを表示し、`mkdocs build --strict` が警告ゼロ。

## Phase 4: Pages公開CI

- [ ] T4-1 `.github/workflows/deploy-docs.yml` を作成（push[`main`]＋`workflow_dispatch`、`build --strict`→`upload-pages-artifact`→`deploy-pages`、権限 `pages: write`/`id-token: write` 最小付与、`gh-pages`は作らない）。
- [ ] T4-2 Pagesソースを「GitHub Actions」に切替える**手順**を development-guidelines もしくは progress-tracking に明記（設定操作は手動）。
- [ ] T4-3 トリガパス（`learn/**`・`mkdocs.yml`・`requirements-docs.txt`）を絞り込み。

**DoD**: `main` push で `deploy-docs` が green、Pages URL で空サイトが閲覧可能（AC-4）。

## Phase 5: 第1章 座学コンテンツ

- [ ] T5-1 `learn/getting-started/environment-setup.md`（Colab/Kaggleの開き方・GPU確認・無料枠注意・環境構築不要の導線）。
- [ ] T5-2 `learn/chapters/01-bitsandbytes-qlora/index.md`（NF4/QLoRAの「何のため・いつ使う・両者の関係」を平易に薄く解説）。
- [ ] T5-3 `learn/chapters/01-bitsandbytes-qlora/references.md`（[design.md](design.md) §5 マッピングの公式doc/論文/公式実装へ**絶対URL＋最終確認日 2026-06-13**で集約）。
- [ ] T5-4 nav に「はじめに」「第1章」を追加し、`build --strict` で未掲載/リンク切れがないことを確認。

**DoD**: トップ→第1章で「概念→公式リンク集」へ迷わず到達でき（AC-1）、`build --strict` 警告ゼロ。

## Phase 6: 第1章 ハンズオンNotebook

- [ ] T6-1 `notebooks/01_bitsandbytes_qlora.ipynb` を [design.md](design.md) §6 テンプレで作成（先頭md＋Colabバッジ＋メタ）。
- [ ] T6-2 既定の非ゲート小型モデル（1〜3B・Apache-2.0/MIT）を1つ確定し、ロード可能性とライセンスを再確認。代替モデルも明記。
- [ ] T6-3 セットアップセルで依存をpin、環境確認セルで `nvidia-smi`／`seed` 固定。
- [ ] T6-4 本編「NF4で4bitロード→QLoRA微調整→推論の前後比較」を段階的Markdown解説付きで実装。
- [ ] T6-5 末尾に理解度確認設問＋chapter-task Issue作成への導線リンク。
- [ ] T6-6 章ページ（index.md）からNotebookへColabバッジでリンク。
- [ ] T6-7 完走確認: ColabのT4で Run all（任意でCPU極小モデルのスモーク）。出力ノイズを最小化。

**DoD**: 無料T4で Run all 完走（NF4ロード→QLoRA→前後比較）、Colabバッジ動作（AC-2, AC-3）。

## Phase 7: 進捗管理テンプレ＋手順書

- [ ] T7-1 `.github/ISSUE_TEMPLATE/chapter-task.yml`（章dropdown・学習ステップchecklist[座学/公式doc/Notebook完走/理解度確認]・詰まった点・所要時間・labels）。
- [ ] T7-2 `.github/ISSUE_TEMPLATE/content-fix.yml`（内容修正・リンク切れ報告）。
- [ ] T7-3 `.github/PULL_REQUEST_TEMPLATE.md`（build/link-check/Notebook完走のチェックリスト）。
- [ ] T7-4 `learn/getting-started/progress-tracking.md`（Projects v2 の作成・フィールド設定[章/Status/難易度/開始日/完了日/所要時間/定着度]・Issue紐付け手順）。

**DoD**: chapter-task Issueテンプレと progress-tracking 手順書から、学習者が自分のProjectで進捗管理を開始できる（AC-6）。

## Phase 8: 品質チェック

- [ ] T8-1 `.github/workflows/link-check.yml`（lychee、PR＋`main` push＋月次cron、リトライ/除外設定、検出=自動）。
- [ ] T8-2 全Markdown/Notebook内リンクで `link-check` が green（AC-5）。
- [ ] T8-3 `mkdocs build --strict` 警告ゼロを最終確認（AC-4）。
- [ ] T8-4 受け入れ条件 AC-1〜6 を順に手動ウォークスルーし結果を記録。

**DoD**: AC-1〜6 をすべて満たし、[requirements.md](requirements.md) §5 のDoDを充足。

---

## 横断ルール（全フェーズ共通）

- [ ] 命名・4点セット・Notebook規約は [docs/development-guidelines.md](../../docs/development-guidelines.md) に準拠。
- [ ] 公式リンクは本文直書きせず references.md に集約し最終確認日を記録（[repository-structure.md](../../docs/repository-structure.md) §3-5）。
- [ ] コミット前に gitleaks（pre-commit-secret-scan）を実行。シークレット/PIIをコミットしない。
- [ ] `main` へ直接コミットせず、PRブランチで作業（Git規約）。

## 着手順（MVP最優先）

1. Phase 3 ＋ 4（土台と公開を先に確立）
2. Phase 5 T5-1（environment-setup＝挫折回避の導線）
3. Phase 5 残り（第1章座学）
4. Phase 6（Notebook）
5. Phase 7（進捗テンプレ＋手順書）
6. Phase 8（品質CI → 受け入れ通し）
