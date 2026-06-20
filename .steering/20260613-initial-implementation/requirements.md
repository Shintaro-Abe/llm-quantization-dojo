# 初回実装 要求内容（requirements.md）

- 作業名: initial-implementation（MVP=第1章 bitsandbytes NF4/QLoRA）
- 作成日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 上位文書: [docs/product-requirements.md](../../docs/product-requirements.md) ／ [採用構成A案](../../research/06-options-and-recommendation.md) ／ [実装計画](承認済みplan参照)

## 1. 今回のスコープ

A案（GitHub一体型）の土台を構築し、**第1章（NF4/QLoRA）を学習者が環境構築なしで完走できる**状態までを作る。

### 追加する機能
1. **公開サイトの土台**: MkDocs Material のサイト雛形＋トップページ。GitHub Actions で GitHub Pages に自動公開。
2. **はじめにページ**: 環境構築不要の導線（Colab/Kaggle）と、進捗管理の始め方。
3. **第1章 座学**: NF4/QLoRA の概念解説（index.md）と公式リンク集（references.md・最終確認日付き）。
4. **第1章 ハンズオン**: Colabで完走する Notebook（4bitロード→QLoRA微調整→推論の前後比較）。
5. **進捗管理テンプレ＋手順書**: 章タスク/内容修正のIssueテンプレート、PRテンプレート、Projects運用手順。
6. **品質CI**: lychee によるリンク切れ検査。

### スコープ外（今回やらない）
- 第2章以降（GGUF/GPTQ/AWQ/発展手法）。
- gh CLI/Actions による Issue/Project の自動生成（テンプレ＋手順書まで）。
- Anki/Notion/Sheets への自動連携（後付け設計のみ）。
- 30B/70B など無料枠外のモデル。

## 2. ユーザーストーリー（今回分）

- US-1: 初学者として、ボタン一つでハンズオンを開始したい。環境構築で挫折しないため。
- US-2: 初学者として、第1章でNF4/QLoRAの「何のため・どう使う」を理解したい。
- US-3: 学習者として、公式の最新情報に正しくたどり着きたい。
- US-4: 学習者として、第1章の学習をタスク化し進捗を記録したい。

## 3. 受け入れ条件（今回分 = docs PRD の AC を具体化）

- AC-1: トップから「第1章 概念 → 公式リンク集 → Colab Notebook → 理解度確認(Issue)」へ迷わず到達できる。
- AC-2: 第1章Notebookに「Open in Colab」バッジがあり、**無料T4でRun allが完走**する（NF4で4bitロード→QLoRA微調整→推論の前後比較まで）。
- AC-3: 既定モデルは無料T4で確実に完走するサイズ（1〜3B級・ログイン不要な非ゲート/Apache・MIT）。7Bは発展課題として案内する。
- AC-4: サイトが GitHub Pages で公開され、`mkdocs build --strict` が警告ゼロ。
- AC-5: `link-check`（lychee）が green（リンク切れなし）。
- AC-6: 章タスクIssueテンプレと、Projectで進捗管理を始める手順書がある。

## 4. 制約事項

- 無料運用（MkDocs/GitHub Pages/Actions/Colab・Kaggleの無料枠）。
- リポジトリはPublic。座学言語は日本語（コード/用語は英語）。
- 教材は無料GPU（Colab T4 15GB / Kaggle T4×2）で完走する範囲で設計。
- 依存はバージョン固定（pin）。シークレット/PIIをコミットしない（gitleaks）。
- `docs/`（ガバナンス）と `learn/`（公開座学）を混同しない（docs_dir=learn）。
- 公式情報は薄い自作解説＋リンク集＋最終確認日で追従（[development-guidelines](../../docs/development-guidelines.md) §4）。

## 5. 完了の定義（DoD）

- 上記 AC-1〜6 を満たす。
- `docs/` の規約（命名・4点セット・Notebook規約）に準拠している。
- 変更が PRブランチで、品質チェック（build/link-check/Notebook完走）を通過している。
