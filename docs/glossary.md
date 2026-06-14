# ユビキタス言語定義（glossary.md）

- 最終更新日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 関連: [product-requirements.md](product-requirements.md) ／ [research/01 量子化手法](../research/01-quantization-methods.md)
- 方針: 用語は英語表記を正とし、日本語の読み/意味を併記する。コード上の識別子は英語（snake_case）。正確な仕様は各章の公式リンク集を参照。

## 1. 量子化の基礎用語

| 英語(正) | 日本語 | 意味（初学者向け） |
| :-- | :-- | :-- |
| Quantization | 量子化 | モデルの重み等を低ビットで表し、サイズと計算を軽くする技術 |
| Precision (FP32/FP16/BF16) | 精度 | 数値のビット幅。低精度ほど軽いが誤差が増えうる |
| Bit-width (4bit/8bit) | ビット幅 | 1値を何ビットで表すか。小さいほど高圧縮 |
| PTQ (Post-Training Quantization) | 事後量子化 | 学習済みモデルを後から量子化する方式 |
| QAT (Quantization-Aware Training) | 量子化を考慮した学習 | 学習中に量子化を織り込む方式（本ツールでは発展） |
| Calibration data | 校正データ | 量子化の誤差を抑えるために使う少量データ |
| Weight | 重み | モデルが学習したパラメータ |
| Activation | 活性化 | 推論中に流れる中間出力の値 |
| Outlier | 外れ値 | 量子化を難しくする極端に大きい値 |
| Perplexity (PPL) | パープレキシティ | 言語モデルの品質指標（低いほど良い、量子化の劣化確認に使う） |

## 2. 手法・フォーマット

| 英語(正) | 読み/別名 | 意味 |
| :-- | :-- | :-- |
| NF4 (NormalFloat4) | エヌエフ4 | 4bit量子化用のデータ型。QLoRAで使う |
| QLoRA | キューロラ | 4bitで載せLoRAで微調整する省メモリ学習法 |
| LoRA (Low-Rank Adaptation) | ローラ | 少数の追加パラメータだけ学習する軽量微調整 |
| GPTQ | ジーピーティーキュー | 校正データで誤差最小化するPTQ（GPU推論向け） |
| AWQ (Activation-aware Weight Quantization) | エーダブリューキュー | 活性化を考慮し重要な重みを守るPTQ |
| GGUF | ジーガフ | llama.cpp用の単一ファイル量子化フォーマット |
| HQQ (Half-Quadratic Quantization) | エイチキューキュー | 校正データ不要の高速量子化 |
| AutoRound | オートラウンド | 重みの丸め方を学習するPTQ（Intel） |
| SmoothQuant | スムースクオント | 重みと活性化を共にINT8化(W8A8) |
| FP8 / MXFP4 / NVFP4 | — | ハードウェアネイティブの低精度浮動小数点 |
| KV cache | KVキャッシュ | 生成時に再利用する中間データ。長文で肥大化しやすい |

## 3. ライブラリ・ツール

| 名称 | 用途 | 備考（現行/移管） |
| :-- | :-- | :-- |
| Hugging Face Transformers | モデルのロード/微調整の中心 | 量子化ライブラリと連携 |
| bitsandbytes | NF4/QLoRAの実体 | 開発: `bitsandbytes-foundation`（旧 `TimDettmers`） |
| PEFT | LoRA/QLoRAの実装 | Transformersと連携 |
| Accelerate | 学習/推論の実行補助 | デバイス配置など |
| Datasets | データセット取得/加工 | 微調整デモ用 |
| llama.cpp | GGUFをCPU等で実行 | リポジトリ: `ggml-org`（旧 `ggerganov`） |
| vLLM | 高スループット推論サーバ | AWQ/GPTQ/FP8対応 |
| GPTQModel | GPTQの後継実装 | 旧 `AutoGPTQ` から移行 |
| AutoAWQ | AWQ実装 | 開発終了方向（章着手時に最新確認） |

## 4. 実行環境・運用

| 英語(正) | 日本語 | 意味 |
| :-- | :-- | :-- |
| Colab | コラボ | ブラウザで使える無料GPU実行環境（既定T4） |
| Kaggle Notebooks | カグル | 無料GPU環境（T4×2が使える） |
| VRAM | ブイラム | GPUのメモリ。モデルが載るかを左右する |
| GPU (T4) | ジーピーユー | 計算用プロセッサ。無料Colabの既定はNVIDIA T4(約15GB) |
| Gated model | ゲートモデル | 利用に申請/トークンが要るモデル（初学者は非ゲートを推奨） |
| Open in Colab badge | Colab起動バッジ | NotebookをColabで開くボタン |

## 5. 学習ツール内の用語（ドメイン語）

| 用語 | 定義 | 対応するコード/配置 |
| :-- | :-- | :-- |
| 座学 | 概念を学ぶWebドキュメント | `learn/**/*.md`（MkDocs） |
| ハンズオン | 手を動かす実習教材 | `notebooks/NN_*.ipynb` |
| 章 (Chapter) | 学習の単位（手法ごと） | `learn/chapters/NN-スラッグ/` |
| 4点セット | 章の必須構成 | 概念→公式リンク→Notebook→理解度確認(Issue) |
| 公式リンク集 | 章の一次情報リンク（最終確認日付き） | `references.md` |
| 理解度確認 | 学習後の確認とタスク化 | 章タスクIssue |
| 定着度 | 復習要否の自己評価(1–5) | Projects フィールド |
| 最終確認日 | 公式情報を確認した日付 | 各 `references.md` 冒頭 |

## 6. コード命名の指針

- 識別子は英語の snake_case（例: `model_id`, `quant_config`, `max_seq_len`）。
- 量子化設定は `bnb_config` / `quant_config` のように手法を示す接頭辞を付ける。
- 章番号は2桁ゼロ埋め（`01`,`02`,…）でディレクトリ・Notebook名と一致させる。
