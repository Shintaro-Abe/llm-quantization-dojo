# 第2章 タスクリスト（tasklist.md）

- 作業名: chapter-02-gguf（第2章 GGUF / llama.cpp）
- 作成日: 2026-06-21
- ステータス: 未着手（steering承認済み・実装前）
- 上位文書: [requirements.md](requirements.md) ／ [design.md](design.md) ／ [acceptance.md](acceptance.md)
- 実装ブランチ（予定）: `feat/chapter-02-gguf`

## 進捗記法

- `[ ]` 未着手 ／ `[~]` 着手中 ／ `[x]` 完了
- 各フェーズ末尾に「完了条件（DoD）」を記載。`main` 直push不可のため PRブランチで作業する（Git規約）。

---

## Phase 1: 技術検証（devコンテナ）🔲 最初の関門 / [design.md](design.md) §3.1-3.2, §8

> ここで**実機の事実**（動くタグ・実サイズ・所要時間・tok/s）を確定してから座学/Notebookを書く。当て推量の値を載せない。

- [ ] T1-1 `ggml-org/llama.cpp` を `--depth 1` で取得し CMake ビルド（`cmake -B build && cmake --build build --config Release -j`）。`llama-quantize`/`llama-cli` の生成を確認。**生成バイナリの実パスを `find` で解決して記録**（出力先が `build/bin/`↔`build/`↔`build/Release/` と環境依存のため＝Codex A-2）。**ビルド所要を計測**し、2コア相当で30分超ならフォールバック（design §3.1）の要否を判断。
- [ ] T1-2 変換用 Python 依存を導入（リポジトリ同梱 requirements: `gguf`/`numpy`/`torch`/`transformers`/`sentencepiece` 等）。**同梱 requirements ファイルのパスを記録し、`pip install -r` で使うか個別pin指定かを決定**（独立pipとのバージョン衝突回避＝Codex A-7）。
- [ ] T1-3 `huggingface_hub.snapshot_download("HuggingFaceTB/SmolLM2-1.7B")` でモデル取得（トークン不要）。
- [ ] T1-4 `convert_hf_to_gguf.py` の**実パスを `find` で解決**（版で配置が変わる＝Codex A-1）。`--help` 出力を保存して**フラグ名を確定**（`--outtype` 揺れ＝Codex A-4）した上で f16 GGUF を生成し、変換が通ることを確認＋ファイルサイズ採取。**変換時の tokenizer 認識ログ（`Using ... tokenizer`）を確認**（失敗時は `--vocab-type bpe` 等の代替を試す＝Codex A-6）。
- [ ] T1-5 `llama-quantize`（**実パスを find で解決**）で `Q4_K_M` 量子化 GGUF を生成＋サイズ・縮小率採取。**固定タグの quantize README で型名表記（`Q4_K_M`）を確認**（古い版の小文字揺れ＝Codex A-5）。
- [ ] T1-6 `llama-cli` で f16 / Q4_K_M を同条件（同プロンプト・`--seed`・`-n` 固定）推論し、出力と tok/s を採取。**eval timing は stderr のため `2>&1` 等で必ずキャプチャ**（Codex A-8）。
- [ ] T1-7 **動作した版（リリースタグ `bXXXX`）を確定**し、design.md §3.2 の `<P1で確定>` を実値へ差し替え。所要時間は **2コア環境向けに保守補正**した目安に換算してメモ。**採取した実測値（f16/Q4サイズ・縮小率・tok/s・所要時間目安）を [acceptance.md](acceptance.md) の検証ログにも転記**（Codex B-4）。

**DoD**: 🔲 devコンテナで clone→build→convert→quantize→inference が一気通貫で成功。固定タグ・各実行ファイル実パス・実サイズ・tok/s・所要時間目安が確定し design.md／acceptance.md に反映済み。

## Phase 2: 第2章 座学コンテンツ 🔲 / [design.md](design.md) §6, §5

- [ ] T2-1 `learn/chapters/02-gguf-llama-cpp/index.md`（GGUF/llama.cpp概念・K-quant読み方小表・第1章との使い分け・**橋渡し段落**・**発展コラム[第1章モデルのGGUF化]**・トラブルシュート小表・「Open in Colab」バッジ）。**index.md に直接置くリンクも `build --strict`＋lychee で到達確認**（公式リンクは原則 references.md に集約し、index.md には最小限＝Codex B-2）。
- [ ] T2-2 `learn/chapters/02-gguf-llama-cpp/references.md`（公式doc/GGUF仕様/quantize README/convert script/モデルカードへ**絶対URL＋最終確認日 2026-06-21**で集約。**references.md の全URLを WebFetch で実在・内容一致確認**＝Codex B-2 の責務分担：到達確認は index/references 両方、内容一致確認は references.md が担当）。
- [ ] T2-3 一次情報の分界（[design.md](design.md) §6）を遵守：コマンド詳細はNotebook、量子化タイプ全選択肢は公式README、トラブル対処は座学小表。

**DoD**: 🔲 第2章「概念→公式リンク集」へ到達でき（AC-1）、index/references の全リンクが lychee OK、`build --strict` 警告ゼロ。

## Phase 3: 第2章 ハンズオンNotebook 🔲 / [design.md](design.md) §4

- [ ] T3-1 `notebooks/02_gguf_llama_cpp.ipynb` を design.md §4 テンプレ（14〜16セル）で作成。先頭md＝Colabバッジ＋メタ（**ランタイム=CPU**/既定モデル/最終確認日）＋**検証状況の明示**。
- [ ] T3-2 セットアップ/ビルドセル：llama.cpp を **固定タグ（T1-7）** で clone＋CMakeビルド＋変換用 pip（バージョン下限/固定）。
- [ ] T3-3 本編：snapshot_download → f16変換（サイズ表示）→ Q4_K_M量子化（サイズ・縮小率）→ `llama-cli` で前後推論。
- [ ] T3-4 比較まとめ：**サイズ＋出力＋速度(tok/s)** の三点表＋**2コア環境の速度注記**（[design.md](design.md) §3.5）。速度取得失敗時もサイズ＋出力は必ず出す（堅牢性）。
- [ ] T3-5 末尾に理解度確認設問＋chapter-task Issue導線＋発展コラム再掲。
- [ ] T3-6 Colabバッジ URL を実slug `Shintaro-Abe/llm-quantization-dojo`＋`notebooks/02_gguf_llama_cpp.ipynb` で差し込み（座学 index.md にも同バッジ）。

**DoD**: 🔲 Notebook が nbformat 妥当＋各pythonセル構文OK。実完走は Phase 5 で確認。

## Phase 4: 導線更新（nav / ロードマップ / 相互リンク）🔲 / [design.md](design.md) §2

- [ ] T4-1 `mkdocs.yml` の nav に「第2章 GGUF / llama.cpp」（概念/公式リンク集）を追記。
- [ ] T4-2 `learn/index.md` 学習ロードマップ表に第2章行を追加（第1章=公開中・第2章=公開中・第3章以降=今後）。
- [ ] T4-3 `learn/chapters/01-bitsandbytes-qlora/index.md` の「GGUF＝第2章」予告を**実リンク化**（相互参照を閉じる）。

**DoD**: 🔲 nav・ロードマップ・第1章→第2章リンクが揃い `build --strict` 警告ゼロ。

## Phase 5: 品質検証＆受け入れ 🔲 / [design.md](design.md) §8 ／ [acceptance.md](acceptance.md)

- [ ] T5-1 `mkdocs build --strict` 警告ゼロ。
- [ ] T5-2 lychee：内部（`--offline`）OK ＋ フル（外部含む）0エラーをローカル確認。
- [ ] T5-3 Notebook 静的検証：`nbformat.validate` OK＋各 code セル構文OK。
- [ ] T5-4 **AC-2 実完走**：devコンテナ（CPU）で Notebook を Run all 実完走（papermill/jupyter）し最後のセルまで到達を確認 → **AC-2 を作者保証 ✅**（[design.md](design.md) §3.6）。
- [ ] T5-5 受け入れ AC-1〜6 をウォークスルーし [acceptance.md](acceptance.md) を更新（実行後に分類確定）。
- [ ] T5-6 PR 作成（`feat/chapter-02-gguf`→`main`）→ `link-check` green → マージ後 `deploy-docs` green でサイトに第2章が出ることを確認。

**DoD**: 🔲 AC-1〜6 を満たす。build --strict / lychee / Notebook実完走 / CI green。

---

## 横断ルール（全フェーズ共通）

- [ ] 命名・座学4点導線・Notebook規約は [docs/development-guidelines.md](../../docs/development-guidelines.md) に準拠。章番号2桁・`chapters/NN-スラッグ/`・`notebooks/NN_スラッグ.ipynb`。
- [ ] 公式リンクは本文直書きせず references.md に集約し最終確認日を記録（[repository-structure.md](../../docs/repository-structure.md) §3-5）。
- [ ] コミット前に gitleaks（pre-commit-secret-scan）を実行。**コミット前に `rm -rf site/`**（既知の誤検知回避）。Notebook出力に PII を残さない。
- [ ] `main` へ直接コミットせず PRブランチ `feat/chapter-02-gguf` で作業（Git規約）。

## 着手順

1. **Phase 1**（技術検証＝事実確定。ここが全ての前提）
2. Phase 2（座学・P1の実値を反映）
3. Phase 3（Notebook・固定タグでセル化）
4. Phase 4（導線更新）
5. Phase 5（品質検証＋CPU実完走＋受け入れ→PR）
