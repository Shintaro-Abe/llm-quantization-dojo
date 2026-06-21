# 受け入れレポート（acceptance.md）

- 作業名: chapter-02-gguf（第2章 GGUF / llama.cpp）
- 実施日: （実装後に記入）／ ブランチ: `feat/chapter-02-gguf`
- ステータス: **計画（実装前）**。各 AC の検証方法と期待分類を事前定義する。実行後に結果へ更新。
- 判定方針（grilling 継承）: 検証できる範囲を誠実に締める。3分類で記録する。
  - ✅ **ローカル/作者で検証済** … この環境（devコンテナ）で確認できたもの
  - ⚠️ **push後に確認** … GitHub 上でCI/Pagesが動いて初めて確認できるもの
  - ⏳ **実機で確認** … 第三者の別環境でのみ確認できるもの

> 第1章との違い：第2章は **GPU不要（CPUで完走）** のため、第1章で⏳だった「Notebook実完走（AC-2）」を **作者がdevコンテナで実通しして ✅ 保証**する（[design.md](design.md) §3.6）。⏳は原則残さない方針。

## AC 別の計画（検証方法 / 期待分類）

| AC | 内容 | 期待分類 | 検証方法 / 根拠 |
| :-- | :-- | :-- | :-- |
| AC-1 | トップ/第1章→第2章で「概念→公式リンク集→Colab→理解度確認(Issue)」へ迷わず到達 | ✅ ローカル | `mkdocs build --strict` 警告ゼロ＋nav追記＋概念ページに Colabバッジ/references/Issue導線＋第1章からの相互リンク。lychee内部リンクOK |
| AC-2 | 第2章Notebookが**CPUでRun all完走**（入手→convert→Q4_K_M→推論） | ✅ 作者（CPU実機・達成） | devコンテナで `jupyter nbconvert --execute` により Run all を実完走（**code 9/9セル実行・エラー NONE**、2026-06-21）。llama.cpp は**ビルド済バイナリ**方式（ソースビルドはWSL2ホストを落とすため不採用＝[[project-wsl2-host-resource-limit]]） |
| AC-3 | 既定モデルは第1章と同じ `SmolLM2-1.7B`（Apache-2.0/非ゲート/safetensors）でCPU完走 | ✅ ローカル(属性) / ✅ 作者(完走はAC-2へ委任) | モデル属性（Apache-2.0/非ゲート/safetensors）はローカルで ✅。`LlamaForCausalLM`で `convert_hf_to_gguf.py` 正式サポート（公式GGUF実在で裏付け）。**CPU実完走は AC-2 の実完走に同じ（重複管理しない）** |
| AC-4 | 量子化前後で **①サイズ ②出力 ③速度(tok/s)** が並んで出力されトレードオフが見える | ✅ 作者 | Notebook比較セルで f16 vs Q4_K_M の三点を採取・並置。速度は2コア向けに控えめ注記。サイズは環境非依存で実測掲載 |
| AC-5 | 第2章追加後 `build --strict` 警告ゼロ＋`link-check`(lychee) green | ✅ ローカル＋⚠️push後 | ローカルで build --strict／lychee（内部・フル）0エラー。CIのgreenは ⚠️push後 |
| AC-6 | 第1章↔第2章の相互リンクと `learn/index.md` ロードマップの第2章行が存在 | ✅ ローカル | nav・ロードマップ表・第1章予告の実リンク化を build --strict ＋ lychee で確認 |

## 検証ログ（実装後に記入）

- `mkdocs build --strict` … （未）
- `lychee --offline`（内部） … （未）
- `lychee`（フル・外部含む） … （未）
- Notebook … `nbformat.validate` OK＋各pythonセル構文 OK ✅／**CPU Run all 実完走 ✅**（`jupyter nbconvert --execute`：code 9/9セル実行・エラー NONE。2026-06-21）
- 量子化・推論実測（**Phase 1・タグ b9743・4スレッド・temp0・非負荷**＝採用値）：
  - f16 サイズ = 3,424,735,424 B（3.19 GiB）／ Q4_K_M サイズ = 1,055,609,024 B（0.98 GiB）／ **縮小 69.2%・3.24倍小**
  - 推論 f16 = 生成 7.95 t/s ／ Q4_K_M = 生成 17.14 t/s ＝ **Q4 約2.2倍速**。両者とも出力一貫（「Paris…」）
  - f16変換 = 25s ／ Q4量子化 = 約20s
  - ※ ビルド済バイナリ採用のためソースビルドは不要（旧フル計測 216s/20コアは参考値）
  - ※ nbconvert 完走時の速度値（f16 1.58 / Q4 1.21 t/s）は**計測がCPU98%負荷・20スレッド過多の最中**で信頼できないため**不採用**（上記の非負荷値が正）
- mkdocs build --strict … 警告ゼロ（第2章ページ生成確認）✅
- lychee … 内部0エラー ✅／フル（外部含む）第2章md 16 OK・0エラー ✅
- gitleaks … （Phase 5 終盤・`site/` 削除後に実施）

## 残作業

1. ⚠️push後: PRで `link-check` CI green ＋ マージ後 `deploy-docs` でサイトに第2章公開（AC-5 のCI分）。

## 結論

- **AC-1・AC-2・AC-3・AC-4・AC-6 は達成（✅）**。AC-2（CPU実完走）は作者が devコンテナで nbconvert により Run all 完走を確認済み（9/9セル・エラーなし）。
- **AC-5** はローカル分（build --strict 警告ゼロ・lychee 0エラー）達成。CI green/Pages公開は ⚠️push後に確認。
- 第1章と異なり **⏳実機（第三者）残しはなし**（GPU不要のため作者がCPU実完走を保証）。
- 設計変更の経緯：ソースビルドは WSL2 ホストを落とすため**ビルド済バイナリ方式へ変更**（[[project-wsl2-host-resource-limit]]）。
