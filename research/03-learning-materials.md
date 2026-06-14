# 03. 学習教材・ドキュメント・コースの調査

調査日: 2026-06-13 ／ 手段: Gemini（Web検索裏取り）

## 結論（3行）

- 入口は **Hugging Face 公式ドキュメント（Transformers の量子化ガイド）** が最適。実装に直結し更新も速い。
- 各手法は **公式リポジトリ/論文**（GPTQ/AWQ/QLoRA/llama.cpp/AutoRound）で裏取りできる。
- 理論の地ならしには無料のブログ・動画・日本語記事を併用すると効率的。

## 1. Hugging Face 公式（最優先の一次情報）

| リソース | URL | 用途 |
| :-- | :-- | :-- |
| Transformers Quantization（量子化総合ガイド） | https://huggingface.co/docs/transformers/main/en/quantization | bitsandbytes/GPTQ/AWQ等の使い分けと実装 |
| Optimum（量子化の概念ガイド） | https://huggingface.co/docs/optimum/main/en/concept_guides/quantization | 概念整理・HW最適化 |
| bitsandbytes（Accelerate連携） | https://huggingface.co/docs/accelerate/usage_guides/quantization | 4bit/8bitロードの実務 |

> 注: HF公式のURL構成は改定されることがある。リンク切れ時はサイト内検索で「quantization」を辿る。

## 2. 各ライブラリの公式ドキュメント/論文

| 手法/ツール | 論文(arXiv) | 公式リポジトリ |
| :-- | :-- | :-- |
| GPTQ | https://arxiv.org/abs/2210.17323 | https://github.com/IST-DASLab/gptq |
| AWQ | https://arxiv.org/abs/2306.00978 | https://github.com/mit-han-lab/llm-awq |
| QLoRA / NF4 | https://arxiv.org/abs/2305.14314 | https://github.com/bitsandbytes-foundation/bitsandbytes |
| SmoothQuant | https://arxiv.org/abs/2211.10438 | https://github.com/mit-han-lab/smoothquant |
| AutoRound (Intel) | https://arxiv.org/abs/2309.05516 ※番号要確認 | https://github.com/intel/auto-round |
| HQQ | （論文の有無は要確認/主にブログ＋実装） | https://github.com/mobiusml/hqq |
| llama.cpp / GGUF | — | https://github.com/ggml-org/llama.cpp |
| vLLM | — | https://github.com/vllm-project/vllm |
| TensorRT-LLM | — | https://github.com/NVIDIA/TensorRT-LLM |

> AutoRound の arXiv 番号は調査ソース間で食い違いがあり、Step3で検証対象とした（[99-sources.md](99-sources.md) 参照）。

## 3. 理論を固める無料教材（補助）

- 解説ブログ: Hugging Face Blog の量子化関連記事、各種まとめ記事（AssemblyAI 等）。※具体URLは変動するため一次情報優先。
- 動画: YouTube の量子化解説（視覚的理解向き）。体系性は弱いので入門の補助に。
- 日本語: Zenn / Qiita に bitsandbytes・GPTQ・AWQ の実践記事が多数。用語の橋渡しに有用。

> ブログ/動画/日本語記事は品質・鮮度にばらつきがあるため、**必ず公式ドキュメント/論文で裏取り**する前提で使う。

## 学習ツールへの示唆

- 座学は「自作の薄い解説＋公式ドキュメントへのリンク集」が最もメンテしやすい（公式が更新されても追従しやすい）。
- 手法ごとに「概念→公式doc→ハンズオンNotebook」の3点セットで章を構成すると初学者が迷わない。

出典は [99-sources.md](99-sources.md) を参照。
