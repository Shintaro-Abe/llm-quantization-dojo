# 初回実装 タスクリスト（tasklist.md）

- 作業名: initial-implementation（MVP=第1章 bitsandbytes NF4/QLoRA）
- 作成日: 2026-06-13
- ステータス: 実装中（Phase 3〜5 完了 / Phase 6 着手前）。最終更新: 2026-06-20
- 上位文書: [requirements.md](requirements.md) ／ [design.md](design.md)
- 実装ブランチ: `feat/mvp-chapter-01`

## 進捗記法

- `[ ]` 未着手 ／ `[~]` 着手中 ／ `[x]` 完了
- 各フェーズ末尾に「完了条件（DoD）」を記載。フェーズ単位でPR・品質チェックを行う。

---

## Phase 3: サイト足場（公開される空サイトの確立）✅ 完了

- [x] T3-1 `requirements-docs.txt` を作成し依存をpin（`mkdocs==1.6.1` / `mkdocs-material==9.7.6` / `pymdown-extensions==10.21.3`）。
- [x] T3-2 `mkdocs.yml` を作成（`docs_dir: learn`・`theme: material`・`language: ja`・nav・pymdownx コードハイライト/admonition/タブ/details）。
- [x] T3-3 `learn/index.md` を作成（学習ロードマップ概要・4点セットの進め方）。
- [x] T3-4 `.gitignore` に `site/` を追記。
- [x] T3-5 ローカル検証: `mkdocs build --strict` が警告ゼロ。

**DoD**: ✅ `mkdocs build --strict` 警告ゼロを確認（ローカルbuild成功）。

## Phase 4: Pages公開CI ✅ 実装完了（CI green は push 後に確認）

- [x] T4-1 `.github/workflows/deploy-docs.yml` を作成（push[`main`]＋`workflow_dispatch`、`build --strict`→`upload-pages-artifact`→`deploy-pages`、権限 `pages: write`/`id-token: write` 最小付与、`gh-pages`は作らない、`concurrency` 設定）。
- [~] T4-2 Pagesソースを「GitHub Actions」に切替える**手順**は **Phase 7 の `progress-tracking.md`** に記載予定（deploy-docs.yml のコメントから参照済み）。
- [x] T4-3 トリガパス（`learn/**`・`mkdocs.yml`・`requirements-docs.txt`・ワークフロー自身）を絞り込み。

**DoD**: 🔲 `main` push で `deploy-docs` green＋Pages閲覧可能（AC-4）は **push 後に確認**。YAML妥当性はローカル検証済み。

## Phase 5: 第1章 座学コンテンツ ✅ 完了

- [x] T5-1 `learn/getting-started/environment-setup.md`（Colab/Kaggleの開き方・GPU確認・無料枠注意・環境構築不要の導線）。
- [x] T5-2 `learn/chapters/01-bitsandbytes-qlora/index.md`（NF4/QLoRA概念・**NF4とQLoRAの混同防止**・**トラブルシュート表**）。
- [x] T5-3 `learn/chapters/01-bitsandbytes-qlora/references.md`（公式doc/論文/公式実装/モデルカードへ**絶対URL＋最終確認日 2026-06-20**で集約。全URLを WebFetch で実在確認）。
- [x] T5-4 nav に「はじめに」「第1章」を追加し、`build --strict` で未掲載/リンク切れがないことを確認。
- [x] T5-5 （grilling 追加）座学にコラム「**モデルを選ぶときの安全チェック**」を追加（safetensors/`trust_remote_code`/公式org/ライセンス・ゲート/検閲・バイアス）。

**DoD**: ✅ トップ→第1章で「概念→公式リンク集」へ到達でき（AC-1）、`build --strict` 警告ゼロ。

## Phase 6: 第1章 ハンズオンNotebook 🔲 次に着手

- [ ] T6-1 `notebooks/01_bitsandbytes_qlora.ipynb` を [design.md](design.md) §6 テンプレで作成（先頭md＋Colabバッジ＋メタ）。
- [x] T6-2 既定モデル確定済み（[design.md](design.md) §5.4）: 既定=**`HuggingFaceTB/SmolLM2-1.7B`**（Apache-2.0/非ゲート/safetensors/`trust_remote_code`不要）、フォールバック=`TinyLlama/TinyLlama-1.1B-Chat-v1.0`、発展=`Qwen/Qwen2.5-1.5B`。※Notebook実装時にロード再確認。
- [ ] T6-3 セットアップセルで依存をpin、環境確認セルで `nvidia-smi`／`seed` 固定。
- [ ] T6-4 本編「NF4で4bitロード→QLoRA微調整→推論の前後比較」を段階的Markdown解説付きで実装（データ整形・成否確認は**Notebookが一次情報**）。
- [ ] T6-5 末尾に理解度確認設問＋chapter-task Issue作成への導線リンク。
- [ ] T6-6 章ページ（index.md）からNotebookへ「Open in Colab」バッジでリンク（リポジトリslug差し込み）。
- [ ] T6-7 完走確認: ColabのT4で Run all（任意でCPU極小モデルのスモーク）。出力ノイズを最小化。

**DoD**: 無料T4で Run all 完走（NF4ロード→QLoRA→前後比較）、Colabバッジ動作（AC-2, AC-3）。

## Phase 7: 進捗管理テンプレ＋手順書 🔲

- [ ] T7-1 `.github/ISSUE_TEMPLATE/chapter-task.yml`（章dropdown・学習ステップchecklist[座学/公式doc/Notebook完走/理解度確認]・詰まった点・所要時間・labels）。
- [ ] T7-2 `.github/ISSUE_TEMPLATE/content-fix.yml`（内容修正・リンク切れ報告）。
- [ ] T7-3 `.github/PULL_REQUEST_TEMPLATE.md`（build/link-check/Notebook完走のチェックリスト）。
- [ ] T7-4 `learn/getting-started/progress-tracking.md`（Projects v2 の作成・フィールド設定[章/Status/難易度/開始日/完了日/所要時間/定着度]・Issue紐付け手順＋**PagesソースをActionsに切替える手順=T4-2**）。

**DoD**: chapter-task Issueテンプレと progress-tracking 手順書から、学習者が自分のProjectで進捗管理を開始できる（AC-6）。

## Phase 8: 品質チェック 🔲

- [ ] T8-1 `.github/workflows/link-check.yml`（lychee、PR＋`main` push＋月次cron、リトライ/除外設定、検出=自動）。
- [ ] T8-2 全Markdown/Notebook内リンクで `link-check` が green（AC-5）。
- [ ] T8-3 `mkdocs build --strict` 警告ゼロを最終確認（AC-4）。
- [ ] T8-4 受け入れ条件 AC-1〜6 を順に手動ウォークスルーし結果を記録。

**DoD**: AC-1〜6 をすべて満たし、[requirements.md](requirements.md) §5 のDoDを充足。

---

## 横断ルール（全フェーズ共通）

- [x] 命名・4点セット・Notebook規約は [docs/development-guidelines.md](../../docs/development-guidelines.md) に準拠（Phase 3〜5 で遵守）。
- [x] 公式リンクは本文直書きせず references.md に集約し最終確認日を記録（[repository-structure.md](../../docs/repository-structure.md) §3-5）。
- [x] コミット前に gitleaks（pre-commit-secret-scan）を実行（各コミットで実施）。シークレット/PIIをコミットしない。
- [x] `main` へ直接コミットせず、PRブランチ `feat/mvp-chapter-01` で作業（Git規約）。

## 着手順（MVP最優先）

1. ✅ Phase 3 ＋ 4（土台と公開を先に確立）
2. ✅ Phase 5 T5-1（environment-setup＝挫折回避の導線）
3. ✅ Phase 5 残り（第1章座学＋安全チェックコラム）
4. 🔲 Phase 6（Notebook）← 次
5. 🔲 Phase 7（進捗テンプレ＋手順書）
6. 🔲 Phase 8（品質CI → 受け入れ通し）
