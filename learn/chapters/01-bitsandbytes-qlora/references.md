# 第1章 公式リンク集（references）

- **最終確認日：2026-06-20**
- このページは「一次情報への入口」です。仕様やAPIは更新されるため、本文より**こちらのリンク先を正**としてください。
- リンク切れに気づいたら、内容修正用のIssue（後続の手順書で案内）から報告してください。

!!! note "鮮度について"
    各リンクは上記の最終確認日時点で到達・内容一致を確認済みです。Hugging Face のドキュメントURLは構成が変わることがあります。切れていたら、サイト内検索で「quantization」「bitsandbytes」「LoRA」をたどってください。

## 1. 公式ドキュメント（最優先の一次情報）

| リソース | URL | 用途 |
| :-- | :-- | :-- |
| Transformers｜Quantization（総合ガイド） | https://huggingface.co/docs/transformers/main/en/quantization | 各量子化手法の比較・使い分け |
| Transformers｜bitsandbytes | https://huggingface.co/docs/transformers/main/en/quantization/bitsandbytes | 4bit/8bitロード（NF4・二重量子化）の実装 |
| Accelerate｜Model quantization | https://huggingface.co/docs/accelerate/usage_guides/quantization | `BnbQuantizationConfig`（`nf4`・`double_quant`）の実例 |
| PEFT（LoRA/QLoRA） | https://huggingface.co/docs/peft | LoRAアダプタの学習・適用・保存 |

## 2. 論文（概念の根拠）

| 論文 | URL | 用途 |
| :-- | :-- | :-- |
| QLoRA: Efficient Finetuning of Quantized LLMs | https://arxiv.org/abs/2305.14314 | NF4・二重量子化・QLoRAの理論（Dettmers et al.） |

## 3. 公式実装（リポジトリ）

| ツール | URL | 備考 |
| :-- | :-- | :-- |
| bitsandbytes | https://github.com/bitsandbytes-foundation/bitsandbytes | 4bit/8bit量子化の本体。旧 `TimDettmers/bitsandbytes` から `bitsandbytes-foundation` へ移管済み |
| PEFT | https://github.com/huggingface/peft | LoRA/QLoRA の実装 |

## 4. 補助教材（任意・必ず一次情報で裏取り）

| リソース | URL | 備考 |
| :-- | :-- | :-- |
| HF Blog｜4-bit quantization (bitsandbytes) | https://huggingface.co/blog/4bit-transformers-bitsandbytes | 4bit量子化の解説記事（背景理解に） |
| DeepLearning.AI｜Quantization Fundamentals | https://www.deeplearning.ai/short-courses/quantization-fundamentals-with-hugging-face/ | HF公式協力の無料入門コース |

## 5. 第1章で使うモデル（公式モデルカード）

いずれも **Apache-2.0・非ゲート・safetensors・`trust_remote_code` 不要**（2026-06-20 確認）。選定理由は[概念ページの「モデルを選ぶときの安全チェック」](index.md)を参照。

| モデル | URL | 位置づけ |
| :-- | :-- | :-- |
| SmolLM2-1.7B（既定） | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B | 主役。HF公式・T4でQLoRA余裕 |
| TinyLlama-1.1B-Chat | https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0 | フォールバック（最軽量） |
| Qwen2.5-1.5B | https://huggingface.co/Qwen/Qwen2.5-1.5B | 発展（他モデルでも同手順が通る例） |

!!! warning "ブログ・動画・第三者記事について"
    解説記事や動画は理解の補助に有用ですが、品質・鮮度にばらつきがあります。**実装の正は必ず上記1〜3（公式doc・論文・公式実装）で確認**してください。

---

- 出典の調査経緯は、リポジトリ内の `research/03-learning-materials.md` ／ `research/99-sources.md` を参照（公開サイトには含めていません）。
- 概念の解説に戻る：[第1章 概念](index.md)
