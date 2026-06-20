# 01. 量子化手法・ライブラリの調査（公式/最新）

調査日: 2026-06-13 ／ 手段: Gemini（Web検索裏取り）

## 結論（3行）

- 推論用途は **AWQ / GPTQ** が主流。**vLLM / TensorRT-LLM** などの推論エンジンで強力にサポートされる。
- ファインチューニングや手軽な試用は **QLoRA（bitsandbytes / NF4）** が事実上の標準。Hugging Face と密結合。
- CPU/Mac など多様な環境での実行は **llama.cpp ＋ GGUF** がデファクト。

## 1. 主要な量子化手法（初学者向けの要点）

| 手法 | 一言でいうと | 主な用途 | 長所 | 短所 |
| :-- | :-- | :-- | :-- | :-- |
| **bitsandbytes (NF4 / QLoRA)** | 4bitで載せてLoRAで微調整 | 低VRAMでの**学習**・試用 | 24GB級GPUでも大型モデルを微調整可／HFと密結合で最も簡単 | 推論速度はGPTQ/AWQより遅め／NVIDIA依存 |
| **GPTQ** | 校正データで誤差最小化する事後量子化(PTQ) | GPU推論 | 4bitでも高精度・高速／量子化後は単体配布可 | 量子化に時間とVRAM・校正データが必要 |
| **AWQ** | 活性化を考慮して重要な重みを保護 | GPU推論 | GPTQより速く量子化でき同等以上の精度／命令調整モデルで安定 | 専用カーネルが必要／校正データに多少依存 |
| **GGUF / llama.cpp** | CPU/Mac向け単一ファイル形式 | ローカル/エッジ推論 | 幅広いHWで動く／2〜8bitを選べる／依存が少ない | 推論専用（学習不可）／変換作業が必要 |
| **HQQ** | 校正データ不要の高速量子化 | データ準備が困難な場面 | 非常に高速／データ不要 | 活性化を考慮しない分モデルにより精度が劣る場合 |
| **AutoRound (Intel)** | 重みの丸め方を学習するPTQ | 高精度な超低ビット | 2/3/4bitでGPTQ/AWQを上回る場合／多形式エクスポート可 | 勾配計算を伴い量子化コストが高い |
| **SmoothQuant** | 重みと活性化を共にINT8化(W8A8) | INT8最適化HWでの高スループット | INT8 Tensor Coreをフル活用 | 主に8bitで圧縮率は4bitに劣る |
| **FP8 / MXFP4・NVFP4** | HWネイティブの低精度浮動小数点 | 最新GPUでの高効率推論/学習 | ほぼ精度を保ちメモリ削減・高速化 | 対応する最新HW（Hopper/Blackwell等）が必須 |

> 初学者の学習順序の目安: **bitsandbytes(NF4/QLoRA) → GGUF/llama.cpp → GPTQ → AWQ → （発展）HQQ/AutoRound/SmoothQuant/FP8**。

## 2. 代表的なライブラリ/ツールと推奨状況

| ツール | 役割 | 推奨状況・注意 |
| :-- | :-- | :-- |
| **Hugging Face Transformers** | 量子化モデルのロード/微調整の中心 | 第一選択。bitsandbytes/GPTQ/AWQ等と連携 |
| **Hugging Face Optimum** | ハードウェア最適化拡張 | 特定HWで性能を引き出す場合 |
| **bitsandbytes** | NF4/QLoRAの実体 | 現在は `bitsandbytes-foundation/bitsandbytes` で開発（旧 `TimDettmers/bitsandbytes`）※要確認 |
| **GPTQ系** | GPTQの実装 | 旧 `AutoGPTQ` は保守縮小し、後継 `GPTQModel` への移行が進む ※要確認 |
| **AWQ系** | AWQの実装 | `AutoAWQ` は2025年に開発終了/アーカイブ方向、`llm-compressor`/vLLM側へ移行 ※要確認 |
| **vLLM** | 高スループット推論サーバ | 強く推奨。AWQ/GPTQ/FP8等に対応 |
| **TensorRT-LLM (NVIDIA)** | NVIDIA向け最高性能推論 | 本番でNVIDIA最適化を求める場合 |
| **llama.cpp** | GGUFをCPU等で実行 | ローカル/エッジのデファクト。現在は `ggml-org/llama.cpp`（旧 `ggerganov/llama.cpp`）※要確認 |

> 「※要確認」は移管・改廃が起きている領域。ツール選定時に公式リポジトリの最新READMEを必ず確認すること。

## 3. 2025-2026のトレンド

- **4bit以下の超低ビット化**: NVIDIA Blackwell の NVFP4 など HW 側の低ビット浮動小数点対応が加速。アルゴリズム側も HQQ/AutoRound 等で精度維持の研究が進む。ただし汎用タスクでの精度確保は依然難しく限定利用にとどまる可能性（不確実）。
- **活性化量子化・KVキャッシュ量子化**: 長コンテキスト化でKVキャッシュがメモリを圧迫。FP8/INT8によるKVキャッシュ量子化が vLLM / TensorRT-LLM で実用化しつつある。
- **混合精度・動的量子化**: 層ごとに最適ビット/手法を変える方向。探索コストが高く現状は研究段階（不確実）。

出典は [99-sources.md](99-sources.md) を参照。
