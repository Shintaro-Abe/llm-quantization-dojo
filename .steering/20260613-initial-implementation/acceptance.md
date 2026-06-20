# 受け入れレポート（acceptance.md）

- 作業名: initial-implementation（MVP=第1章 bitsandbytes NF4/QLoRA）
- 実施日: 2026-06-20 ／ ブランチ: `feat/mvp-chapter-01`
- 判定方針（grilling）: 検証できる範囲を誠実に締める。3分類で記録する。
  - ✅ **ローカルで検証済** … この環境で確認できたもの
  - ⚠️ **push後に確認** … GitHub 上でCI/Pagesが動いて初めて確認できるもの
  - ⏳ **実機で確認** … 無料T4の実機でのみ確認できるもの（作者は静的＋ロジックまで）

## AC 別の結果

| AC | 内容 | 分類 | 根拠 / 残作業 |
| :-- | :-- | :-- | :-- |
| AC-1 | トップ→第1章で「概念→公式リンク集→Colab→理解度確認(Issue)」へ迷わず到達 | ✅ ローカル | `mkdocs build --strict` 警告ゼロ。nav: ホーム→はじめに(環境構築/進捗管理)→第1章(概念/公式リンク集)。概念ページに Colabバッジ＋references＋Issue導線。lychee内部リンク27件OK |
| AC-2 | 第1章NotebookがT4でRun all完走（NF4→QLoRA→前後比較） | ⏳ 実機 | 作者=nbformat妥当＋pythonセル構文＋ロジック検証済。**T4実機のRun all完走は利用者が確認**（Notebook冒頭に明示） |
| AC-3 | 既定モデルは無料T4で確実に完走するサイズ（1〜3B・非ゲートApache/MIT） | ✅ ローカル＋⏳ 実機 | 選定=`SmolLM2-1.7B`（Apache-2.0/非ゲート/safetensors、公式カードで確認済）✅。実完走の確認は⏳実機 |
| AC-4 | サイトが GitHub Pages で公開され `build --strict` 警告ゼロ | ✅(build) ＋ ⚠️(公開) | `build --strict` 警告ゼロ✅。`deploy-docs.yml` はYAML妥当。**Pages公開は push後**＋Settings→Pages を「GitHub Actions」に切替（手順は progress-tracking.md） |
| AC-5 | `link-check`（lychee）が green | ✅ ローカル ＋ ⚠️(CI) | ローカルで lychee 内部27件OK／フル41件OK・0エラー。**CIのgreenは push後**に確認 |
| AC-6 | 章タスクIssueテンプレ＋Projectで進捗管理を始める手順書 | ✅ ローカル | `chapter-task.yml`／`content-fix.yml` はYAML妥当。`progress-tracking.md` に Board(進捗一覧)＋Roadmap(ガント)＋Pages切替手順 |

## ローカル検証ログ（要約）

- `mkdocs build --strict` … 警告ゼロ（複数回）
- `lychee --offline`（内部） … 27 Unique / 27 OK / 0 Errors
- `lychee`（フル・外部含む） … 41 OK / 0 Errors / 3 Redirects（無害）
- Issue フォーム2点 … `yaml.safe_load` OK
- Notebook … `nbformat.validate` OK＋pythonセル構文OK
- gitleaks … no leaks（各コミット）

## 残作業（このMVPの「完了」外＝push/実機が前提）

1. **push後**: `main` へ push → `deploy-docs` green → Settings→Pages を「GitHub Actions」に切替 → Pages URL 閲覧（AC-4）。`link-check` CI green（AC-5）。
2. **実機**: Colab T4 で Notebook を Run all 完走確認（AC-2 / AC-3 の実完走）。
3. 確認後、本レポートの ⚠️/⏳ を ✅ に更新。

## 結論

ローカルで検証可能な範囲（AC-1・AC-6、`build --strict`、lychee 内部/フル）は**すべて green**。AC-2/3（実機）・AC-4/5（push後）は上記「残作業」として明示し、誠実に未確定として残す。
