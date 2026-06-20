# 99. 出典一覧

調査日: 2026-06-13 ／ 手段: Gemini CLI（Web検索による裏取り）

URLは調査時点のもの。公式ドキュメントは構成変更でリンクが変わる場合がある。検索グラウンディング由来の出典は元ドメインを併記する。

## A. 量子化手法・論文（一次情報）

| 項目 | URL |
| :-- | :-- |
| GPTQ 論文 | https://arxiv.org/abs/2210.17323 |
| GPTQ 公式実装 | https://github.com/IST-DASLab/gptq |
| AWQ 論文 | https://arxiv.org/abs/2306.00978 |
| AWQ 公式実装 | https://github.com/mit-han-lab/llm-awq |
| QLoRA 論文 | https://arxiv.org/abs/2305.14314 |
| bitsandbytes 実装 | https://github.com/bitsandbytes-foundation/bitsandbytes （旧 https://github.com/TimDettmers/bitsandbytes） |
| SmoothQuant 論文 | https://arxiv.org/abs/2211.10438 |
| SmoothQuant 実装 | https://github.com/mit-han-lab/smoothquant |
| AutoRound 論文 | https://arxiv.org/abs/2309.05516 ※番号は要検証（下記 検証メモ参照） |
| AutoRound 実装 | https://github.com/intel/auto-round |
| HQQ 実装 | https://github.com/mobiusml/hqq （論文の有無は要確認） |
| llama.cpp / GGUF | https://github.com/ggml-org/llama.cpp （旧 https://github.com/ggerganov/llama.cpp） |
| NVIDIA TransformerEngine (FP8) | https://github.com/NVIDIA/TransformerEngine |
| OCP Microscaling (MXFP4/MX) 仕様 | OCP "Microscaling Formats (MX) Specification"（公開元: opencompute.org）。※具体URL/GitHubリポジトリ名は未確定のため、"OCP Microscaling Formats" で公式を再検索すること |

## B. ライブラリ/推論エンジン 公式

| 項目 | URL |
| :-- | :-- |
| HF Transformers 量子化ガイド | https://huggingface.co/docs/transformers/main/en/quantization |
| HF Optimum 量子化概念 | https://huggingface.co/docs/optimum/main/en/concept_guides/quantization |
| HF Accelerate × bitsandbytes | https://huggingface.co/docs/accelerate/usage_guides/quantization |
| HF Optimum リポジトリ | https://github.com/huggingface/optimum |
| vLLM | https://github.com/vllm-project/vllm |
| TensorRT-LLM | https://github.com/NVIDIA/TensorRT-LLM |

## C. 実行環境（検索グラウンディング由来。元ドメインを記載）

- Google Colab 無料枠 / Kaggle Notebooks: medium.com, iotbyhvm.ooo, reddit.com 他
- Hugging Face Spaces (ZeroGPU): huggingface.co, medium.com
- Lightning AI: lightning.ai, reddit.com
- Paperspace Gradient: spheron.network, computeprices.com
- VRAM/RAM 目安: runpod.io, promptquorum.com, mljourney.com, plugable.com, localllm.in, reddit.com

> 実行環境の数値（GPU種類/VRAM/時間枠）は変動が大きく、各社公式での再確認が前提。

## D. 進捗管理サービス（検索グラウンディング由来）

- Notion: notion.com, checkthat.ai, apis.io
- Obsidian: obsidian.md, libhunt.com, medium.com, habr.com
- Google Sheets API: google.com（developers.google.com）
- GitHub Issues/Projects/Actions: github.com（docs.github.com）, wikipedia.org
- Anki / AnkiConnect: obsidian.md（関連）, ※AnkiConnect最新動向は不確実
- Todoist: todoist.com, baizaar.tools, reddit.com

## E. 市場・競合（検索グラウンディング由来）

| 項目 | URL（確定分） |
| :-- | :-- |
| DeepLearning.AI: Quantization Fundamentals with Hugging Face | https://www.deeplearning.ai/short-courses/quantization-fundamentals-hugging-face/ |
| DeepLearning.AI: Quantization in Depth | https://www.deeplearning.ai/short-courses/quantization-in-depth/ |
| HF Docs: Quantization | https://huggingface.co/docs/transformers/main_classes/quantization |
| Kaggle: GPTQ vs AWQ vs BitsAndBytes | https://www.kaggle.com/code/simranjeetsingh1430/gptq-vs-awq-vs-bitsandbytes-in-llm-quantization ※実在要確認 |
| Awesome-LLM-Quantization | https://github.com/ZHITENGLI/awesome-LLM-Quantization ※実在要確認 |
| NVIDIA TensorRT-LLM examples | https://github.com/NVIDIA/TensorRT-LLM |

**URL未確定（調査で確定できず）**: Udemy各コース、Maven各コース、NVIDIA DLI個別コース、一部YouTube動画（検索結果でプレースホルダ/変動と判明）。これらは実装時に名称で再検索すること。

---

## 検証メモ（Step3: Codexによるハルシネーション・チェック結果）

実施日: 2026-06-13 ／ 手段: Codex（codex-rescue 経由）

### 総合判定
重大な誤りなし（軽微な指摘のみ）。主要なarXiv番号・GitHubリポジトリ名・ライブラリ移管状況・無料環境スペックは概ね正確と確認。

### 明確な誤り → 対応済み
- **AutoRound のarXiv番号**: 正は `2309.05516`。別ソースの `2309.07955` は誤り。
  → 本ドキュメント群は当初から `2309.05516` を採用しており修正不要（誤番号は不採用）。
- **OCP MXFP4 のGitHubリポジトリ名**（`opencomputeproject/ocp-microscaling-formats`）が不確か。
  → 推測URLを削除し、「OCP Microscaling Formats (MX) 仕様（opencompute.org）」の再検索指示に修正済み（上記 A表）。

### 要確認/不確実（記載済みで据え置き）
- HQQ の arXiv 論文番号（実在/番号とも未断定。実装リポジトリは妥当）。
- HF公式ドキュメントの個別URLパス、DeepLearning.AIのコースslugの完全一致。
- VRAM/RAM目安はモデル/系列長/実装/CPUオフロード有無で変動するため「概算」である旨を各所に明記済み。

### 問題なしと確認された主な項目
- arXiv: GPTQ=2210.17323 / AWQ=2306.00978 / QLoRA=2305.14314 / SmoothQuant=2211.10438 / AutoRound=2309.05516。
- リポジトリ: bitsandbytes-foundation/bitsandbytes、ggml-org/llama.cpp、intel/auto-round、mobiusml/hqq、IST-DASLab/gptq、mit-han-lab/llm-awq、mit-han-lab/smoothquant。
- 移管/改廃: AutoGPTQ→GPTQModel、AutoAWQの開発終了方向、llama.cppのggml-org移管、bitsandbytesのfoundation移管。
- 無料環境: Colab無料T4(約15GB・割当保証なし)、Kaggle 30時間/週・T4×2(32GB)、HF Spaces ZeroGPUの短時間/日枠、GitHub Actions 2,000分/月。
