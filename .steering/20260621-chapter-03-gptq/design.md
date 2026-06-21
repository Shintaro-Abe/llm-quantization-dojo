# 第3章 設計（design.md）

- 作業名: chapter-03-gptq（第3章 GPTQ）
- 作成日: 2026-06-21
- ステータス: ドラフト（grilling反映済み・並行作成）
- 上位文書: [requirements.md](requirements.md) ／ [docs/architecture.md](../../docs/architecture.md) ／ [第2章 design](../20260620-chapter-02-gguf/design.md)

## 1. 実装アプローチ

第1・2章の型（座学 index/references ＋ Notebook ＋ nav/ロードマップ）を踏襲。サイト土台・CIは構築済みのため内容追加のみ。

**進め方（grilling 決定A）**：grilling 結論を反映しつつ **steering 4文書と座学/Notebook を並行作成 → 最後に Codex レビュー（技術＋整合）→ 反映**。第2章のような「ローカル実完走」フェーズは**無い**（GPTQ量子化はGPU必須・ローカル実行不可）。

```
調査(現行API確定) ─▶ steering＋座学＋Notebook を並行作成 ─▶ build --strict / lychee / nbformat 静的検証
                                                          ─▶ Codexレビュー → 反映 ─▶ PR
```

## 2. 変更・追加するコンポーネント

| # | パス | 種別 | 役割 | 対応AC |
| :-- | :-- | :-- | :-- | :-- |
| 1 | `learn/chapters/03-gptq/index.md` | 新規 | GPTQ概念・パラメータ・3章の使い分け・橋渡し・発展コラム・トラブルシュート・Colabバッジ | AC-1, AC-6 |
| 2 | `learn/chapters/03-gptq/references.md` | 新規 | 公式doc/論文/実装/モデルカード（最終確認日付き） | AC-1 |
| 3 | `notebooks/03_gptq.ipynb` | 新規 | 第3章ハンズオン（Colab GPU・量子化→保存→推論・前後比較） | AC-2,3,4 |
| 4 | `mkdocs.yml` | 変更 | nav に「第3章 GPTQ」追記 | AC-1, AC-5 |
| 5 | `learn/index.md` | 変更 | ロードマップ表に第3章行 | AC-6 |
| 6 | `learn/chapters/02-gguf-llama-cpp/index.md` | 変更 | 第3章への相互リンク追記 | AC-6 |

## 3. 主要な設計判断

### 3.1 量子化スタック＝transformers ＋ `gptqmodel`（grilling 決定A）
- 現行推奨：**AutoGPTQ は非推奨・Transformers 非対応**。**`gptqmodel`（ModelCloud）が公式バックエンド**で transformers/optimum/peft に統合。
- インストール：`pip install -U accelerate optimum transformers` ＋ `pip install gptqmodel --no-build-isolation`。
- **量子化 API（transformers 統合・第1章と同系統）**：
  ```python
  from transformers import AutoModelForCausalLM, AutoTokenizer, GPTQConfig
  tok = AutoTokenizer.from_pretrained(MODEL)
  gptq_config = GPTQConfig(bits=4, dataset=calib_texts, tokenizer=tok, group_size=128)
  qmodel = AutoModelForCausalLM.from_pretrained(MODEL, device_map="auto", quantization_config=gptq_config)
  ```
- 保存/再ロード：`qmodel.save_pretrained(path)` / `AutoModelForCausalLM.from_pretrained(path, device_map="auto")`（device_map使用時は保存前に `to("cpu")`）。

### 3.2 校正データ＝直書き文字列リスト本筋＋座学で公開DS補足（grilling 決定C）
- **`GPTQConfig(dataset=...)` は「文字列のリスト」を直接受け付ける**（HF doc 明記）。→ 第1章「直書き」と同じ思想で、Notebook内に**校正用テキストを十数〜数十件直書き**。外部依存ゼロ・即再現・著作権安全。
- 座学・発展で「実務では `c4`/`wikitext` など公開データセットを多めに使う」「GPTQ論文も公開データ推奨」と補足（正直注記）。
- サンプル数は無料T4で現実的な範囲（数十件・短文）に絞る。

### 3.3 既定モデル＝`HuggingFaceTB/SmolLM2-1.7B`（base）継承（AC-3）
- 第1・2章と一貫。Llama系アーキで gptqmodel/transformers が対応。`device_map="auto"` で T4(15GB) に収まる。
- safetensors・非ゲート・トークン不要（第1章の安全チェック継承）。

### 3.4 量子化設定＝`bits=4, group_size=128`（AC-4）
- 4bit・group_size=128 は GPTQ の実用既定（精度/サイズのバランス）。座学で bits/group_size の意味を平易に。
- 前後比較：**元(fp16)保存サイズ vs GPTQ(4bit)保存サイズ**（ディレクトリ容量）＋**同一プロンプトの生成出力**を並置（量子化で破綻しないことを目視）。
- ※速度比較は GGUF章(第2章)で扱ったため、第3章は**サイズ＋出力**を主軸（GPU推論速度はノイズが多く環境依存のため必須にしない）。

### 3.5 検証分担＝作者は静的＋ロジック、GPU実完走は学習者（第1章方式 / requirements §4）
- GPTQ量子化は **GPU 必須**。devコンテナはCPU専用（WSL2・ローカルで重い処理を回さない方針）。
- よって作者＝**nbformat妥当＋各pythonセル構文＋API/ドキュメント整合**まで。**T4実機の Run all 完走は学習者が Colab で確認**（Notebook冒頭に明示）。
- API はローカル実行できないぶん**公式doc準拠で正確に**書く（本章で HF GPTQ doc・GPTQModel README を確認済み）。

### 3.6 第2章との橋渡し＋3章の使い分け（grilling）
- 橋渡し段落：「第2章は CPU 配布向け(GGUF)。第3章は **GPU 推論向けの高精度PTQ(GPTQ)**」。
- 3手法の使い分け表（第1章 NF4/QLoRA＝学習向け・第2章 GGUF＝CPU配布・第3章 GPTQ＝GPU高精度推論）。
- ライブラリ移行（AutoGPTQ→GPTQModel）の現状を明記（情報鮮度QA）。

## 4. ハンズオンNotebookテンプレート設計（実装ファイル: `notebooks/03_gptq.ipynb`）

Colab **GPU** 前提・想定 13〜15 セル。第1・2章のメタ/検証注記様式を踏襲。

| セル | 種別 | 内容 |
| :-- | :-- | :-- |
| 1 | md | タイトル＋Colabバッジ＋メタ表（所要時間/**ランタイム=GPU(T4)**/既定モデル/最終確認日）＋**検証状況の明示**（作者=静的/ロジック、GPU実完走は学習者） |
| 2 | md | このNotebookでやること（quantize→save→推論）＋**ランタイムをGPUにする手順**＋デモのねらい |
| 3 | code | セットアップ：`pip install -U accelerate optimum transformers` ＋ `pip install gptqmodel --no-build-isolation` |
| 4 | code | GPU確認（`nvidia-smi`）＋ seed 固定 |
| 5 | md | ステップ1：校正データ（直書き）を用意（なぜ校正が要るか1段落） |
| 6 | code | 校正テキストを直書き（list[str]・数十件） |
| 7 | md | ステップ2：GPTQ で 4bit 量子化（GPTQConfig の説明） |
| 8 | code | `GPTQConfig(bits=4, dataset=calib, tokenizer, group_size=128)` → `from_pretrained(..., quantization_config=...)`（数分かかる旨コメント） |
| 9 | md | ステップ3：保存してサイズを見る |
| 10 | code | `save_pretrained` ＋ 量子化前後のディレクトリ容量比較（元モデルDLサイズ vs GPTQ保存サイズ） |
| 11 | md | ステップ4：推論で確認（前後比較） |
| 12 | code | 量子化モデルで生成（同一プロンプト・seed）。必要なら fp16 元モデルの出力も並置 |
| 13 | md | まとめ（サイズ/出力）＋2コア注記不要・GPU前提の所要時間目安 |
| 14 | md | 振り返り＋理解度確認Issue導線＋発展コラム（公開校正DS・既存GPTQモデル活用） |

### 確定したデモ設計（grilling 反映）
- **校正データ**：直書き list[str]（外部依存ゼロ）。座学で公開DS補足。
- **量子化設定**：`bits=4, group_size=128`。
- **前後比較**：サイズ（保存容量）＋出力。速度は必須にしない（§3.4）。
- **検証分担**：作者＝静的＋ロジック＋doc整合。GPU実完走は学習者（§3.5）。
- Colabバッジ URL：`https://colab.research.google.com/github/Shintaro-Abe/llm-quantization-dojo/blob/main/notebooks/03_gptq.ipynb`（座学にも同バッジ）。

## 5. 教材調達先マッピング（最終確認日 2026-06-21・全URL WebFetch 確認）

### 5.1 公式ドキュメント / 実装
| リソース | URL | 用途 |
| :-- | :-- | :-- |
| Transformers｜GPTQ | https://huggingface.co/docs/transformers/en/quantization/gptq | GPTQConfig・量子化手順（一次情報） |
| GPTQModel（ModelCloud） | https://github.com/ModelCloud/GPTQModel | 現行バックエンド本体 |
| GPTQModel（PyPI） | https://pypi.org/project/gptqmodel/ | インストール・バージョン |

### 5.2 論文（概念の根拠）
| 論文 | URL | 用途 |
| :-- | :-- | :-- |
| GPTQ: Accurate Post-Training Quantization... | https://arxiv.org/abs/2210.17323 | GPTQ の理論（Frantar et al.） |

### 5.3 モデルカード
| モデル | URL | 位置づけ |
| :-- | :-- | :-- |
| SmolLM2-1.7B（既定・量子化元） | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B | 本章で GPTQ 量子化する base |

## 6. 第3章 座学設計（index.md 必須トピック）

`development-guidelines` §4 に従い薄い自作解説＋公式リンク＋最終確認日。

### 第3章の約束（1文）
> **第3章を終えると、Hugging Face のモデルを校正データを使って自分で GPTQ 4bit 量子化し、GPU で推論できるようになる。GPTQ が「なぜ校正データで精度を保てるのか」を理解する。**

### index.md 必須トピック
1. GPTQ とは（校正データで層ごとに誤差最小化する PTQ）／なぜ校正データが要るか
2. 主要パラメータ（bits・group_size）の読み方
3. ライブラリ事情（**AutoGPTQ 非推奨 → `GPTQModel` 推奨**・transformers統合）＝情報鮮度
4. 第1章(NF4/QLoRA)・第2章(GGUF)との使い分け（学習向け / CPU配布向け / GPU高精度推論向け）
5. 第2章との橋渡し段落
6. ハンズオン（Colabバッジ・**GPU必須**）→ 理解度確認(Issue)
7. 発展コラム（公開校正データセット・Hubの既存GPTQモデル活用・「まずHubに既存GPTQが無いか確認」）
8. トラブルシュート小表（GPU未割当/OOM/gptqmodelインストール/校正データ不足）

### 一次情報の分界（第1・2章の方針を継承）
| 項目 | 一次情報 | 座学側 |
| :-- | :-- | :-- |
| 量子化の具体コード | **Notebook** | 流れを概説＋セル誘導 |
| GPTQConfig 全引数 | **公式 transformers GPTQ doc** | 代表のみ、残りはリンク |
| トラブル対処 | **座学の小表** | Notebook各セルは一言警告 |

## 7. 影響範囲
- 新規2＋変更3。第2章 index.md にリンク追記以外は破壊的変更なし。
- `mkdocs.yml`/`learn/**` 変更で CI（deploy-docs/link-check）自動発火（設定変更不要）。
- gitleaks：コミット前に `rm -rf site/`。

## 8. 検証方法
- 作者：`mkdocs build --strict` 警告ゼロ、`lychee`（内部offline＋フル外部）0エラー、Notebook `nbformat.validate`＋各code セル構文OK、API/doc整合レビュー。
- **GPU実完走（AC-2）は学習者が Colab T4 で確認**（作者は実行しない）。
- CI：PR で `link-check` green、マージ後 `deploy-docs` green。
- 受け入れ：[requirements.md](requirements.md) AC-1〜6 をウォークスルー（[acceptance.md](acceptance.md)）。
