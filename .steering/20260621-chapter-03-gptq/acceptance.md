# 受け入れレポート（acceptance.md）

- 作業名: chapter-03-gptq（第3章 GPTQ）
- 実施日: （実装後に更新）／ ブランチ: `feat/chapter-03-gptq`
- ステータス: 計画／並行作成中。各 AC の検証方法と期待分類を定義。
- 判定方針（継承）: 検証できる範囲を誠実に締める。3分類で記録。
  - ✅ **ローカル/作者で検証済** … devコンテナで確認できたもの
  - ⚠️ **push後に確認** … CI/Pages で確認
  - ⏳ **GPU実機で確認** … 無料Colab T4 でのみ確認（GPTQ量子化はGPU必須）

> 第2章(CPU)と異なり、第3章は **GPTQ量子化が GPU 必須**のため、Notebook実完走は **⏳GPU実機（学習者がColabで確認）**＝第1章と同じ分担。作者はローカルで重い処理を回さない（[[project-wsl2-host-resource-limit]]）。

## AC 別の計画（検証方法 / 期待分類）

| AC | 内容 | 期待分類 | 検証方法 / 根拠 |
| :-- | :-- | :-- | :-- |
| AC-1 | トップ/第2章→第3章で「概念→公式リンク集→Colab→理解度確認」へ到達 | ✅ ローカル | build --strict＋nav追記＋概念ページにバッジ/references/Issue導線＋第2章相互リンク。lychee内部 |
| AC-2 | 第3章Notebookが**Colab GPU(T4)でRun all完走**（量子化→保存→推論） | ⏳ GPU実機 | 作者=nbformat妥当＋pythonセル構文＋**API/公式doc整合**検証。**T4実機のRun all完走は学習者が確認**（Notebook冒頭明示）。GPTQ量子化はGPU必須でローカル実行不可 |
| AC-3 | 既定モデルは `SmolLM2-1.7B`（Apache-2.0/非ゲート/safetensors）でT4完走 | ✅ ローカル(属性) / ⏳ GPU(完走) | 属性は公式カードで確認 ✅。完走は AC-2 に同じ（⏳GPU） |
| AC-4 | 量子化前後で**サイズ差**が出力され、推論出力も前後で確認できる | ⏳ GPU実機 | Notebookに元(fp16)vs GPTQ(4bit)のサイズ比較＋同一プロンプト出力を実装。実値は学習者の実行で確認 |
| AC-5 | 第3章追加後 `build --strict` 警告ゼロ＋`link-check` green | ✅ ローカル＋⚠️push後 | ローカルで build --strict／lychee 0エラー。CI green は ⚠️push後 |
| AC-6 | 第2章↔第3章の相互リンクと `learn/index.md` ロードマップの第3章行 | ✅ ローカル | nav・ロードマップ・第2章リンクを build --strict＋lychee で確認 |

## 検証ログ（2026-06-21）
- `mkdocs build --strict` … 警告ゼロ（第3章ページ生成）✅
- `lychee --offline`（内部）… 0エラー ✅／ フル（外部含む）第3章md 16 OK・0エラー ✅
- Notebook … `nbformat.validate` OK＋各pythonセル構文 OK ✅（14セル）／ **GPU実完走** …⏳学習者(Colab)
- 公式URL（transformers GPTQ doc / GPTQModel / 論文arXiv:2210.17323 / SmolLM2）… WebFetch 実在確認 ✅
- Codexレビュー … **API レベルは「現行(gptqmodel)で正しい」と確認**（GPTQConfig引数・from_pretrained量子化フロー・to('cpu')→save・再ロード/generate・pip手順・list[str]校正）。指摘の **max_memory(OOM耐性)** と **--no-build-isolation の理由** を反映済み。※Codexサンドボックス(bwrap)制約でファイル引用つき(B)文書整合は未実施→作者が自己照合（AC対応・座学/Notebook整合を確認）
- gitleaks …（Phase 6 終盤・`site/`削除後に実施）

## 残作業（想定）
1. ⚠️push後: PRで `link-check` CI green ＋ マージ後 `deploy-docs` でサイト公開。
2. ⏳GPU実機: 学習者が Colab T4 で Notebook 完走（AC-2/3/4 の実完走）。作者は静的＋ロジック＋doc整合まで。

## 結論（実装後に記入）
（AC-1〜6 の最終判定を記す。第1章同様、⏳GPU実機完走のみ学習者確認として残る見込み。）
