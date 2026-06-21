# 第3章 公式リンク集（references）

- **最終確認日：2026-06-21**
- このページは「一次情報への入口」です。仕様やAPIは更新されるため、本文より**こちらのリンク先を正**としてください。
- リンク切れに気づいたら、内容修正用のIssue（手順書で案内）から報告してください。

!!! note "鮮度について（重要）"
    GPTQ のツールは移行期です。**`AutoGPTQ` は非推奨・Transformers 非対応**となり、現在は **`GPTQModel`（ModelCloud）** が推奨バックエンドです。古い `auto_gptq` ベースの記事は実装の参考にしないでください。

## 1. 公式ドキュメント / 実装（最優先の一次情報）

| リソース | URL | 用途 |
| :-- | :-- | :-- |
| Transformers｜GPTQ | https://huggingface.co/docs/transformers/en/quantization/gptq | `GPTQConfig` での量子化手順（実装の正） |
| GPTQModel（ModelCloud） | https://github.com/ModelCloud/GPTQModel | 現行バックエンド本体・クイックスタート |
| Optimum｜Quantization | https://huggingface.co/docs/optimum/en/llm_quantization/usage_guides/quantization | HF エコシステムでの量子化ガイド |

## 2. 論文（概念の根拠）

| 論文 | URL | 用途 |
| :-- | :-- | :-- |
| GPTQ: Accurate Post-Training Quantization for Generative Pre-trained Transformers | https://arxiv.org/abs/2210.17323 | GPTQ の理論（Frantar, Ashkboos, Hoefler, Alistarh） |

## 3. この章で使うモデル（公式モデルカード）

**Apache-2.0・非ゲート・safetensors**（2026-06-21 確認）。モデル選定の考え方は[第1章「モデルを選ぶときの安全チェック」](../01-bitsandbytes-qlora/index.md)を参照。

| モデル | URL | 位置づけ |
| :-- | :-- | :-- |
| SmolLM2-1.7B（既定・量子化元） | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B | 本章で GPTQ 4bit 量子化する base モデル |

!!! warning "ブログ・動画・第三者記事について"
    解説記事や動画は理解の補助に有用ですが、品質・鮮度にばらつきがあります（特に GPTQ は `auto_gptq` 時代の古い手順が多い）。**コード・APIの正は必ず上記1（公式doc・実装）で確認**してください。

---

- 概念の解説に戻る：[第3章 概念](index.md)
- 前の章：[第2章 GGUF / llama.cpp](../02-gguf-llama-cpp/index.md)
