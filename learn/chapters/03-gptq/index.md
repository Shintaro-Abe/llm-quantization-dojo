# 第3章：GPTQ

!!! success "この章を終えると（章の約束）"
    **Hugging Face のモデルを、校正データを使って自分で GPTQ 4bit 量子化し、GPU で推論できるようになります。**
    GPTQ が「**なぜ校正データを使うと精度を保ったまま 4bit にできるのか**」を理解します。

この章は次の4ステップで進みます。上から順にどうぞ。

1. **概念**（このページ）— 何のため・どう使うかを理解する
2. [**公式リンク集**](references.md)（references）— 一次情報で裏取りする
3. **ハンズオン Notebook**（Colab）— 実際に動かす（後述）
4. **理解度確認**（GitHub Issue）— 学んだことを記録する

---

## 0. 第2章とのつながり（CPU配布 → GPU高精度推論）

[第1章](../01-bitsandbytes-qlora/index.md)は GPU で**学習しながら**量子化（NF4/QLoRA）、[第2章](../02-gguf-llama-cpp/index.md)は **CPU で配布・推論**するための GGUF でした。

第3章の **GPTQ** は、もう一つの主要な量子化手法で、**GPU での推論を高精度なまま軽くする**ことに向いています。ポイントは「**校正データ（代表的な入力テキスト）を使って、量子化の誤差を最小化する**」ところです。

> ざっくり：**第1章＝学習向け／第2章＝CPU配布向け／第3章＝GPU高精度推論向け**。

## 1. GPTQ とは何か（なぜ校正データが要るのか）

**GPTQ（Post-Training Quantization）** は、**学習済みモデルを後から 4bit に量子化**する手法です。NF4 のように「分布に合わせて一律に丸める」のではなく、**少量の代表テキスト（校正データ）を実際に流し、出力の誤差が最小になるように**重みを 4bit へ落とします。

- **校正データ（calibration data）**：数十〜数百件の代表的なテキスト。これを通して「どう丸めれば誤差が小さいか」を層ごとに最適化する
- だから GPTQ は、ただ丸めるより**精度の劣化が小さい**
- **量子化には GPU が必要**（行列演算を多く回すため）。量子化済みモデルの推論も GPU が前提

## 2. 主要パラメータの読み方

| パラメータ | 意味 |
| :-- | :-- |
| **bits** | 量子化ビット数。本章は **4bit**（`bits=4`） |
| **group_size** | 何個の重みを1グループとしてまとめて量子化するか。**128** が定番（小さいほど精度↑・サイズ微増） |
| **dataset** | 校正データ。**文字列のリスト**を直接渡せる（本章は直書き。実務では公開データを多めに使う） |

## 3. ライブラリ事情（重要：AutoGPTQ → GPTQModel）

GPTQ のツールは移行期にあります。**着手時に必ず最新を確認**してください（本ページは 2026-06-21 時点）。

- **`AutoGPTQ` は非推奨**になり、**Transformers からも外れました**。
- 現在の推奨は **`GPTQModel`（ModelCloud 製）**。Transformers / Optimum / PEFT に統合され、`GPTQConfig` 経由で使えます。
- 本章のハンズオンも `gptqmodel` を使います（`pip install gptqmodel`）。

!!! warning "古い記事に注意"
    ネット上には `auto_gptq` を使う古い手順が多く残っています。**実装の正は[公式 Transformers GPTQ ドキュメント](references.md)**で確認してください。

## 4. 第1章・第2章との使い分け

| | 第1章 NF4/QLoRA | 第2章 GGUF/llama.cpp | 第3章 GPTQ |
| :-- | :-- | :-- | :-- |
| 何のため | **学習（微調整）向け** | **CPU 配布・推論向け** | **GPU 高精度推論向け** |
| 校正データ | 不要 | 不要 | **必要** |
| 動く場所 | GPU | CPU でも可 | GPU |
| 代表ツール | bitsandbytes + peft | llama.cpp | gptqmodel + transformers |

- **微調整したい** → 第1章
- **CPU で軽く動かして配りたい** → 第2章
- **GPU で精度を保ったまま軽くしたい** → 第3章（GPTQ）

---

## トラブルシュート（実行中に詰まったら）

| 症状 | 主な原因 | 対処 |
| :-- | :-- | :-- |
| `nvidia-smi` が出ない / CUDA エラー | GPU 未割り当て | ランタイムのタイプを **T4 GPU** に変更（[環境構築](../../getting-started/environment-setup.md)） |
| `gptqmodel` のインストールに失敗 | ビルド依存 | `pip install gptqmodel --no-build-isolation`。失敗時はランタイム再起動→上から流し直す |
| `CUDA out of memory` | モデル/校正が大きすぎ | より小さいモデル（例：`SmolLM2-360M`）／校正サンプル数を減らす／`from_pretrained` に `max_memory={0:"14GiB","cpu":"8GiB"}` を渡して GPU/CPU の配分を制御する |
| 量子化が遅い | 校正サンプルが多い／モデルが大きい | サンプル数を減らす。1.7B＋数十件なら無料T4で数分が目安 |
| `auto_gptq` のエラー | 古い手順を実行している | **`gptqmodel`** を使う（このページ §3 参照） |

---

## ハンズオン（手を動かす）

概念を読んだら、Colabで実際に動かします。**量子化の具体コードと、校正データの渡し方・サイズ比較の見方は、ノートブック内のコードと解説が一次情報**です。

!!! warning "ランタイムは GPU（T4）にしてください"
    GPTQ の量子化には GPU が必要です。Colab のメニュー →「ランタイムのタイプを変更」→ **T4 GPU** を選んでください。

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Shintaro-Abe/llm-quantization-dojo/blob/main/notebooks/03_gptq.ipynb)

- ノートブック：`notebooks/03_gptq.ipynb`
- 内容：直書きの校正データ → `GPTQConfig` で SmolLM2-1.7B を 4bit 量子化 → 保存 → 推論（前後比較）
- 既定モデルは第1・2章と同じ `HuggingFaceTB/SmolLM2-1.7B`（Apache-2.0・非ゲート）

!!! tip "発展：校正データと既存モデル"
    - 本章は外部依存ゼロのため校正データを**直書き**しますが、**実務では `c4` や `wikitext` などの公開データセットを多めに**使います（GPTQ論文も公開データを推奨）。
    - 量子化は時間がかかります。**まず Hugging Face Hub に「すでに GPTQ 量子化済みのモデル」が無いか確認**するのも実務の定石です。

## 理解度を確認する

- GPTQ が「なぜ校正データを使うのか」を自分の言葉で説明できる
- `SmolLM2-1.7B` を自分で GPTQ 4bit 量子化 → 保存 → 推論まで通せた
- 量子化の前後で「サイズ・出力」がどう変わったかを説明できる
- 第1章(NF4/QLoRA)・第2章(GGUF)・第3章(GPTQ)の使い分けを言える

## 公式情報で裏取りする

このページは薄い地図です。正確な仕様・最新のAPIは必ず一次情報で確認してください。

- [第3章 公式リンク集（references）](references.md)
