# 第3章 要求内容（requirements.md）

- 作業名: chapter-03-gptq（第3章 GPTQ）
- 作成日: 2026-06-21
- ステータス: ドラフト（grilling反映済み・並行作成中）
- 上位文書: [docs/product-requirements.md](../../docs/product-requirements.md) ／ [第2章 requirements](../20260620-chapter-02-gguf/requirements.md)

## 1. 今回のスコープ

カリキュラム第3章として、**GPTQ（校正データを使う PTQ）で HF モデルを自分の手で 4bit 量子化し、推論する**フルパイプラインを学習者が無料 Colab(GPU) で完走できる状態にする。第1章(QLoRA=学習向け)・第2章(GGUF=CPU配布向け)に続き、**GPTQ＝GPU推論向けの高精度PTQ**を扱う。

### 追加する機能
1. **第3章 座学**: GPTQ とは何か（校正データで誤差最小化する PTQ）／なぜ校正データが要るか／group_size 等の主要パラメータ／第1章(NF4)・第2章(GGUF)との違いと使い分け／**ライブラリ事情（AutoGPTQ 非推奨 → `GPTQModel` 推奨）**／第2章との橋渡し／**発展コラム（公開校正データセット・既存GPTQモデルの活用）**（`learn/chapters/03-gptq/index.md`）。
2. **第3章 公式リンク集**: transformers GPTQ doc・GPTQModel・GPTQ論文・モデルカードを最終確認日付きで集約（`references.md`）。
3. **第3章 ハンズオン**: Colab(**GPU**) で完走する Notebook。**`GPTQConfig(bits=4, dataset=<直書き校正文字列>, tokenizer)` ＋ `AutoModelForCausalLM.from_pretrained(..., quantization_config=...)` で SmolLM2-1.7B を自分で GPTQ 量子化 → 保存 → 推論**。量子化前後のサイズ・出力を比較（`notebooks/03_gptq.ipynb`）。
4. **導線の更新**: ロードマップ・nav・第2章 ↔ 第3章 相互リンク。

### スコープ外（今回やらない）
- 第4章以降（AWQ・発展手法）。
- 量子化済み GPTQ モデルのアップロード/配布運用（座学で軽く触れる程度）。
- Marlin 等の高速カーネル詳細・vLLM 連携（用語紹介のみ）。
- 大規模モデル（7B超）の量子化（無料Colab枠外）。
- imatrix 等は GGUF(第2章)の話題のため扱わない。

## 2. ユーザーストーリー（今回分）

- US-1: 学習者として、GPTQ が「何のため・なぜ校正データが要るか」を理解したい。
- US-2: 学習者として、HF モデルを自分で GPTQ 量子化する一連の手順を、環境構築なしで一度通したい。
- US-3: 学習者として、第1章(NF4/QLoRA)・第2章(GGUF)・第3章(GPTQ)の使い分けを判断できるようになりたい。
- US-4: 学習者として、AutoGPTQ→GPTQModel のような**ライブラリ移行の現状**を一次情報で把握したい。

## 3. 受け入れ条件（今回分）

- AC-1: 第2章/トップから「第3章 概念 → 公式リンク集 → Colab Notebook → 理解度確認(Issue)」へ迷わず到達できる（4ステップ導線）。
- AC-2: 第3章Notebookに「Open in Colab」バッジがあり、**無料 Colab（GPU=T4）で Run all が完走**する（GPTQ量子化 → 保存 → 推論まで）。**GPUが必要**（GPTQ量子化はGPU前提）。
- AC-3: 既定モデルは第1・2章と同じ `HuggingFaceTB/SmolLM2-1.7B`（Apache-2.0 / 非ゲート / safetensors）。無料T4で量子化・推論まで完走するサイズ。
- AC-4: 量子化の前後で **元(fp16)と GPTQ(4bit) のモデルサイズ差**が出力され、推論出力も前後で確認できる（量子化の効果が見える）。
- AC-5: サイトに第3章が追加され `mkdocs build --strict` 警告ゼロ、`link-check`（lychee）が green。
- AC-6: 第2章 ↔ 第3章の相互リンクと、`learn/index.md` ロードマップの第3章行が存在する。

## 4. 制約事項

- 無料運用（MkDocs/GitHub Pages/Actions/Colab の無料枠）。Notebook は無料 Colab T4 で完走する範囲で設計。
- **検証分担（第1章方式）**: GPTQ量子化は **GPU 必須**でローカル(CPU専用 devコンテナ/WSL2)では実行不可・重い処理はローカルで回さない（[[project-wsl2-host-resource-limit]]）。よって作者は **静的検証（nbformat妥当・各pythonセル構文）＋ロジック/ドキュメント整合検証**まで。**GPU実機の Run all 完走は学習者が Colab で確認**（Notebook冒頭に明示）。
- ライブラリは現行の推奨に従う：**`gptqmodel`（ModelCloud）＋ transformers/optimum 統合**。AutoGPTQ は使わない（非推奨・Transformers非対応）。バージョンは可能な範囲で pin/下限指定。
- 使用モデルは **safetensors・非ゲート・Apache-2.0/MIT・`trust_remote_code` 不要**を既定（第1章の安全チェック方針を継承）。
- 公式情報は薄い自作解説＋リンク集＋最終確認日で追従（[development-guidelines](../../docs/development-guidelines.md) §4。GPTQ/AWQは着手時に最新状況を再確認＝本章で実施済み）。
- `docs/`/`learn/` 分離（docs_dir=learn）。命名は既存規約（`chapters/NN-スラッグ/`・`notebooks/NN_スラッグ.ipynb`）。
- シークレット/PIIをコミットしない（gitleaks。`site/` はスキャン前に削除）。

## 5. 完了の定義（DoD）

- 上記 AC-1〜6 を満たす。
- `docs/` の規約（命名・座学4点導線・Notebook規約）に準拠。
- 変更が PRブランチで、品質チェック（build --strict / link-check）を通過。
- Notebook は**静的検証＋ロジック/ドキュメント整合検証**まで作者が実施。**GPU実機完走は学習者確認**（第1章と同じ分担）。
