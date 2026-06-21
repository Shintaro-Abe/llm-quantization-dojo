# 第2章 公式リンク集（references）

- **最終確認日：2026-06-21**
- このページは「一次情報への入口」です。仕様やAPIは更新されるため、本文より**こちらのリンク先を正**としてください。
- リンク切れに気づいたら、内容修正用のIssue（手順書で案内）から報告してください。

!!! note "鮮度について"
    各リンクは上記の最終確認日時点で到達・内容一致を確認済みです。`llama.cpp` は更新が速く、ツールの場所やコマンドのフラグが変わることがあります。本教材のハンズオンは**動作確認済みのタグ `b9743`** に固定しています。

## 1. 公式ドキュメント / 仕様（最優先の一次情報）

| リソース | URL | 用途 |
| :-- | :-- | :-- |
| llama.cpp（本体リポジトリ・README） | https://github.com/ggml-org/llama.cpp | ビルド方法・各ツールの位置づけ |
| GGUF フォーマット仕様 | https://github.com/ggml-org/ggml/blob/master/docs/gguf.md | GGUF が「単一ファイル形式」である根拠と中身 |
| llama-quantize README（量子化タイプ一覧） | https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md | `Q4_K_M` など使えるタイプの正 |
| convert_hf_to_gguf.py | https://github.com/ggml-org/llama.cpp/blob/master/convert_hf_to_gguf.py | HF → GGUF 変換スクリプト本体 |

## 2. 概念の根拠（補助）

| リソース | URL | 用途 |
| :-- | :-- | :-- |
| llama.cpp Discussions | https://github.com/ggml-org/llama.cpp/discussions | K-quant の背景・各量子化方式の議論 |

!!! info "GGUF / K-quant は「実装駆動」の技術です"
    第1章の QLoRA（論文 arXiv:2305.14314）と違い、GGUF・K-quant は単一の決定的な論文を持ちません。**一次情報は公式実装・仕様・議論**にあります。

## 3. この章で使うモデル（公式モデルカード）

いずれも **Apache-2.0・非ゲート・safetensors**（2026-06-21 確認）。モデル選定の考え方は[第1章「モデルを選ぶときの安全チェック」](../01-bitsandbytes-qlora/index.md)を参照。

| モデル | URL | 位置づけ |
| :-- | :-- | :-- |
| SmolLM2-1.7B（既定・変換元） | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B | 本章で GGUF 化する base モデル |
| SmolLM2-1.7B-Instruct-GGUF（参考） | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF | 公式が配布する GGUF の実例（変換実績の裏付け） |

!!! warning "ブログ・動画・第三者記事について"
    解説記事や動画は理解の補助に有用ですが、品質・鮮度にばらつきがあります。**コマンドやフラグの正は必ず上記1（公式リポジトリ・仕様）で確認**してください。

---

- 概念の解説に戻る：[第2章 概念](index.md)
- 前の章：[第1章 bitsandbytes / NF4・QLoRA](../01-bitsandbytes-qlora/index.md)
