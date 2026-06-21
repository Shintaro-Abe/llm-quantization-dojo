# 第2章 要求内容（requirements.md）

- 作業名: chapter-02-gguf（第2章 GGUF / llama.cpp）
- 作成日: 2026-06-20
- ステータス: 承認済み（grilling反映済み）。承認日: 2026-06-21
- 上位文書: [docs/product-requirements.md](../../docs/product-requirements.md) ／ [第1章 requirements](../20260613-initial-implementation/requirements.md)

## 1. 今回のスコープ

第1章（GPU前提の QLoRA）に続く第2章として、**GGUF / llama.cpp による CPU/ローカル推論**を学習者が環境構築なしで完走できる状態までを作る。
第2章の核は「**HF モデルを自分の手で GGUF 化し、量子化して、llama.cpp で動かす**」フルパイプラインの体験。

### 追加する機能
1. **第2章 座学**: GGUF とは何か／なぜ CPU 推論に向くか／llama.cpp の位置づけ／量子化タイプ（Q4_K_M 等の K-quant の読み方）／第1章 bitsandbytes(NF4) との違いと使い分けを解説（`learn/chapters/02-gguf-llama-cpp/index.md`）。**第1章との橋渡し段落**（「GPUで訓練 → CPUで配布・推論」の流れ）と、**発展コラム「第1章で微調整したモデルを GGUF 化してみよう」**（LoRAマージ→変換の誘導。手順詳細は本章スコープ外）を含む。
2. **第2章 公式リンク集**: llama.cpp（`ggml-org/llama.cpp`）・GGUF 仕様・量子化ツールの一次情報を最終確認日付きでまとめる（`references.md`）。
3. **第2章 ハンズオン**: Colab（**CPUランタイム**）で完走する Notebook。**llama.cpp をソースからビルド（動作確認済みコミットに固定）→ `convert_hf_to_gguf.py` で HF モデル(SmolLM2-1.7B)を GGUF(f16)化 → `llama-quantize` で Q4_K_M に量子化 → llama.cpp で推論**。量子化前後の **①ファイルサイズ ②生成出力 ③推論速度(tok/s)** を比較する（`notebooks/02_gguf_llama_cpp.ipynb`）。
4. **導線の更新**: `learn/index.md` の学習ロードマップに第2章を追加。`mkdocs.yml` の nav に第2章セクションを追加。第1章 ↔ 第2章の相互リンク。

### スコープ外（今回やらない）
- 第3章以降（GPTQ/AWQ/発展手法）。
- llama.cpp の CUDA(GPU)ビルドによる GPU オフロードの本格解説（座学でオプションとして1〜2文触れる程度。Notebook の必須経路にはしない）。
- 自作 GGUF の HuggingFace へのアップロード／配布手順。
- `llama-server` を使った OpenAI 互換 API サーバの常駐運用（概念紹介のみ可）。
- imatrix を用いた高度な量子化キャリブレーション（用語紹介に留める）。

## 2. ユーザーストーリー（今回分）

- US-1: 学習者として、GGUF が「何のための形式か」と「llama.cpp で何ができるか」を理解したい。
- US-2: 学習者として、HF モデルを自分で GGUF 化・量子化する一連の手順を、環境構築なしで一度通したい。
- US-3: 学習者として、Q4_K_M などの量子化タイプの読み方と、サイズ／品質のトレードオフを体感したい。
- US-4: 学習者として、第1章(bitsandbytes/NF4)と第2章(GGUF)の使い分け（学習向け vs 配布・CPU推論向け）を判断できるようになりたい。

## 3. 受け入れ条件（今回分）

- AC-1: トップ／第1章から「第2章 概念 → 公式リンク集 → Colab Notebook → 理解度確認(Issue)」へ迷わず到達できる（第1章と同じ4ステップ導線）。
- AC-2: 第2章Notebookに「Open in Colab」バッジがあり、**CPUランタイムで Run all が完走**する（llama.cpp入手[ビルド済バイナリ] → GGUF変換 → Q4_K_M量子化 → 推論まで）。GPUは不要。**完走は作者(devコンテナ・CPU)で実機検証して保証する**（第1章のT4依存と異なり実機確認可能なため）。llama.cpp はソースビルドせず**公式ビルド済バイナリ**を使い（design §3.1）、無料Colabセッションのタイムアウト内・軽量に収める。
- AC-3: 既定モデルは第1章と同じ `HuggingFaceTB/SmolLM2-1.7B`（Apache-2.0 / 非ゲート / safetensors）。CPUでも実用的な時間で量子化・推論まで完走するサイズ。
- AC-4: 量子化の前後で、**①ファイルサイズ（f16 GGUF vs Q4_K_M GGUF）②生成出力 ③推論速度(tok/s)** の3点が並んで出力され、量子化のトレードオフが目で見える。所要時間・速度は **2コア環境を想定して控えめに見積もって明記**（作者環境=20コアの計測値をそのまま載せない）。
- AC-5: サイトに第2章が追加され `mkdocs build --strict` が警告ゼロ、`link-check`（lychee）が green。
- AC-6: 第1章 ↔ 第2章の相互リンクと、`learn/index.md` ロードマップの第2章行が存在する。

## 4. 制約事項

- 無料運用（MkDocs/GitHub Pages/Actions/Colab の無料枠）。CPUランタイムで完走する範囲で設計。
- llama.cpp はビルドが必要なツール。Notebook では**ソース取得 → ビルド**（または pip 配布物）の手順を固定し、再現性を担保する。バージョン（コミット/タグ）を固定して記録する。
- リポジトリはPublic。座学言語は日本語（コード/用語は英語）。
- 使用モデルは **safetensors・非ゲート・Apache-2.0/MIT・`trust_remote_code` 不要**を既定とする（第1章の安全チェック方針を継承）。
- 公式情報は薄い自作解説＋リンク集＋最終確認日で追従（[development-guidelines](../../docs/development-guidelines.md) §4）。
- `docs/`（ガバナンス）と `learn/`（公開座学）を混同しない（docs_dir=learn）。命名は既存規約（`chapters/NN-スラッグ/`・`notebooks/NN_スラッグ.ipynb`）に従う。
- シークレット/PIIをコミットしない（gitleaks。`site/` 生成物はスキャン前に削除）。

## 5. 完了の定義（DoD）

- 上記 AC-1〜6 を満たす。
- `docs/` の規約（命名・座学4点導線・Notebook規約）に準拠している。
- 変更が PRブランチで、品質チェック（build --strict / link-check）を通過している。
- Notebook は静的検証（nbformat妥当・各コードセルのPython構文）＋ロジック検証に加え、**CPU実機での Run all 完走を作者(devコンテナ)で実施して保証する**（第1章と異なりGPU不要のため作者検証が可能）。所要時間の目安のみ2コア環境向けに控えめ補正して記載する。
