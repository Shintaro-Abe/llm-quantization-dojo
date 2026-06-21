# 第3章 タスクリスト（tasklist.md）

- 作業名: chapter-03-gptq（第3章 GPTQ）
- 作成日: 2026-06-21
- ステータス: 進行中（並行作成・grilling決定A）
- 上位文書: [requirements.md](requirements.md) ／ [design.md](design.md) ／ [acceptance.md](acceptance.md)
- 実装ブランチ（予定）: `feat/chapter-03-gptq`

## 進捗記法
- `[ ]` 未着手 ／ `[~]` 着手中 ／ `[x]` 完了

---

## Phase 1: 現行API調査 ✅ / [design.md](design.md) §3.1
- [x] T1-1 GPTQ ライブラリ事情を確認：**AutoGPTQ 非推奨 → `gptqmodel` 推奨**（transformers/optimum統合）。
- [x] T1-2 量子化API確定：`GPTQConfig(bits=4, dataset=list[str], tokenizer, group_size)` ＋ `from_pretrained(..., quantization_config=...)`。校正データは**文字列リスト可**。保存=`save_pretrained`、再ロード=`from_pretrained`。
- [x] T1-3 所要目安：opt-350mで約5分（無料Colab GPU）→ 1.7Bでも数分。T4で完走見込み。

## Phase 2: steering 4文書（並行作成）✅
- [x] T2-1 requirements.md（スコープ・AC・制約・検証分担）
- [x] T2-2 design.md（API・校正データ・モデル・設定・検証分担・教材マッピング・Notebookテンプレ）
- [x] T2-3 tasklist.md（本ファイル）
- [ ] T2-4 acceptance.md（AC別の検証方法・期待分類）

## Phase 3: 座学 🔲 / [design.md](design.md) §6
- [ ] T3-1 `learn/chapters/03-gptq/index.md`（GPTQ概念・bits/group_size・3章使い分け・橋渡し・発展コラム・トラブルシュート・Colabバッジ）。
- [ ] T3-2 `learn/chapters/03-gptq/references.md`（transformers GPTQ doc / GPTQModel / 論文 / モデルカードを**絶対URL＋最終確認日2026-06-21**で集約。**全URL WebFetch 確認**）。

## Phase 4: Notebook 🔲 / [design.md](design.md) §4
- [ ] T4-1 `notebooks/03_gptq.ipynb` を §4 テンプレ（13〜15セル）で作成。先頭md＝Colabバッジ＋メタ（**ランタイム=GPU**）＋検証状況明示。
- [ ] T4-2 セットアップ（accelerate/optimum/transformers＋gptqmodel）＋GPU確認＋seed。
- [ ] T4-3 直書き校正データ → `GPTQConfig` で 4bit量子化 → `save_pretrained` ＋サイズ比較 → 推論（前後比較）。
- [ ] T4-4 nbformat妥当＋各pythonセル構文OK。**API は公式doc準拠で正確に**（ローカル実行不可のため）。
- [ ] T4-5 Colabバッジ URL を実slugで差し込み（座学にも同バッジ）。

## Phase 5: 導線 🔲 / [design.md](design.md) §2
- [ ] T5-1 `mkdocs.yml` nav に「第3章 GPTQ」追記。
- [ ] T5-2 `learn/index.md` ロードマップ表に第3章行（GPTQ=公開中）。
- [ ] T5-3 `learn/chapters/02-gguf-llama-cpp/index.md` に第3章への相互リンク追記。

## Phase 6: 品質検証＋Codexレビュー＋PR 🔲 / [design.md](design.md) §8
- [ ] T6-1 `mkdocs build --strict` 警告ゼロ。
- [ ] T6-2 lychee：内部（offline）＋フル（外部含む）0エラー。
- [ ] T6-3 Notebook：`nbformat.validate` ＋各code セル構文OK。
- [ ] T6-4 **Codexレビュー**（技術フィージビリティ＝GPTQ API/コマンド正しさ・版依存／文書整合）→ 反映。
- [ ] T6-5 acceptance.md を結果で更新。
- [ ] T6-6 `rm -rf site/` → gitleaks → 第3章関連のみコミット → PR（`feat/chapter-03-gptq`→`main`）→ link-check green → マージ後 deploy-docs green。

---

## 横断ルール
- [ ] 命名・座学4点導線・Notebook規約を [docs/development-guidelines.md](../../docs/development-guidelines.md) に準拠。
- [ ] 公式リンクは references.md に集約＋最終確認日。
- [ ] コミット前 `rm -rf site/` ＋ gitleaks。`main`直push不可＝PR経由。
- [ ] **重い処理（GPTQ量子化）をローカルで実行しない**（[[project-wsl2-host-resource-limit]]）。GPU実完走は学習者(Colab)。

## 着手順
1. ✅ Phase 1（API調査）→ ✅ Phase 2（steering、acceptance除き）
2. Phase 2 T2-4（acceptance）＋ Phase 3（座学）＋ Phase 4（Notebook）＋ Phase 5（導線）を並行
3. Phase 6（静的検証 → Codex → PR）
