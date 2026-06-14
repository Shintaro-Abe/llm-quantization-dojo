# 事前調査サマリ — LLM量子化 学習ツール構築

- 作成日: 2026-06-13
- 目的: 初学者AIエンジニアが「LLM量子化手法」を迷わず学び、学習後に現場の即戦力になるための**個人学習ツール**を新規構築する。その事前調査。
- 調査手段: Gemini（Web検索による裏取り）
- 構成要件: ①座学ドキュメント ②ハンズオン教材 ③ハンズオン実行環境 ④学習内容/進捗管理の外部連携。できる限り無料・公式最新情報。

## このディレクトリの読み方

| ファイル | 内容 |
| :-- | :-- |
| [01-quantization-methods.md](01-quantization-methods.md) | 量子化手法・ライブラリの最新/公式調査（座学・教材の中身になる技術） |
| [02-execution-environments.md](02-execution-environments.md) | 無料ハンズオン実行環境（GPU/VRAM/制限の比較） |
| [03-learning-materials.md](03-learning-materials.md) | 公式・準公式の学習教材/ドキュメント/コース |
| [04-progress-management.md](04-progress-management.md) | 学習内容/進捗管理の外部連携サービス比較 |
| [05-market-research.md](05-market-research.md) | 市場・競合調査（既存の学習リソースと空白） |
| [06-options-and-recommendation.md](06-options-and-recommendation.md) | **結論：構成の選択肢5つ（推奨度・理由・メリット/デメリット・比較表）** |
| [99-sources.md](99-sources.md) | 全出典リスト |

## 3行サマリ

1. 量子化の主流は **GPTQ / AWQ / GGUF(llama.cpp) / bitsandbytes(QLoRA・NF4)** の4本柱。学習の入口は **Hugging Face Transformers** に集約され、実行は **Google Colab(無料T4)** と **Kaggle(無料T4×2)** で7B〜13B規模が現実的に回せる。
2. 「座学＋ハンズオン＋実行環境＋進捗管理」を統合した学習ツールは既に存在する（DeepLearning.AI 等）が、**無料・初学者向け・完全統合**を同時に満たすものは少なく、個人で自作する価値がある。
3. 構成は **GitHub一体型（MkDocs＋Colab＋GitHub Projects）** を最有力に推奨。全工程を無料・Git管理で完結でき、初学者が最も詰まる「環境構築」をColabで回避できる。詳細と他4案は [06](06-options-and-recommendation.md)。

## 注意（情報の鮮度・不確実性）

- 量子化技術と無料サービスの規約は変化が速い。VRAM目安・無料枠・GPU種類は時期により変動する。
- 一部の競合コースのURL（Udemy/Maven/一部YouTube）は調査時点で確定できず、ソースに「URL未確定」と明記している。
- 本サマリ内の技術的事実は Step3（Codexレビュー）でハルシネーション検査を実施済み。検査結果は [99-sources.md](99-sources.md) 末尾に記録。
