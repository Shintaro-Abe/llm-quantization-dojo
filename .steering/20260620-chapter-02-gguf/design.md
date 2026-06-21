# 第2章 設計（design.md）

- 作業名: chapter-02-gguf（第2章 GGUF / llama.cpp）
- 作成日: 2026-06-21
- ステータス: 承認済み（grilling反映済み・書式整合済み）。承認日: 2026-06-21
- 上位文書: [requirements.md](requirements.md) ／ [docs/architecture.md](../../docs/architecture.md) ／ [docs/repository-structure.md](../../docs/repository-structure.md) ／ [docs/development-guidelines.md](../../docs/development-guidelines.md) ／ [第1章 design.md](../20260613-initial-implementation/design.md)

## 1. 実装アプローチ

第1章で確立した「**章の単位＝座学(index/references)＋Notebook＋nav/ロードマップ追記**」の型をそのまま踏襲する。サイト土台・CI（deploy-docs/link-check）は第1章で構築済みのため、**第2章は内容を足すだけ**。各成果物は単体で検証可能な粒度で積む。

```
P1 技術検証（devコンテナ）  ── llama.cpp を実ビルド→SmolLM2をf16変換→Q4_K_M量子化→推論
                              → 動作する固定コミット/タグと所要時間・サイズ実測値を確定
            │
            ▼
P2 第2章 座学（index.md ＋ references.md）  ── 概念＋第1章橋渡し＋発展コラム＋公式リンク集
            ▼
P3 第2章 Notebook（02_gguf_llama_cpp.ipynb）  ── P1で確定した手順をセル化（CPUで完走）
            ▼
P4 導線更新（mkdocs.yml nav ＋ learn/index.md ロードマップ ＋ 第1章→第2章リンク）
            ▼
P5 品質検証  ── devコンテナで Notebook 実完走（AC-2保証）＋ build --strict ＋ lychee ＋ 受け入れ通し → PR
```

> **P1 を先頭に置くのが今回の肝**。grilling で「フルビルド」「動くコミットに固定」「作者がCPU実完走を保証」と決めたため、**まず実機で通してから**座学・Notebookの数値（サイズ/時間/tok\_s）を書く。当て推量の値を載せない。

## 2. 変更・追加するコンポーネント

| # | パス | 種別 | 役割 | 対応AC |
| :-- | :-- | :-- | :-- | :-- |
| 1 | `learn/chapters/02-gguf-llama-cpp/index.md` | 新規 | GGUF/llama.cpp概念（薄い自作解説）＋第1章橋渡し＋発展コラム＋安全チェック継承 | AC-1, AC-6 |
| 2 | `learn/chapters/02-gguf-llama-cpp/references.md` | 新規 | 公式リンク集（最終確認日付き） | AC-1 |
| 3 | `notebooks/02_gguf_llama_cpp.ipynb` | 新規 | 第2章ハンズオン（Colabバッジ・CPUでRun all完走・前後比較） | AC-2, AC-3, AC-4 |
| 4 | `mkdocs.yml` | 変更 | nav に「第2章 GGUF / llama.cpp」セクションを追記 | AC-1, AC-5 |
| 5 | `learn/index.md` | 変更 | 学習ロードマップ表に第2章行を追加（状態更新） | AC-6 |
| 6 | `learn/chapters/01-bitsandbytes-qlora/index.md` | 変更 | 「GGUF＝第2章」予告箇所を**実リンク**に更新（相互リンク） | AC-6 |

> 既存の `docs/`・`research/`・CI（deploy-docs/link-check）は変更しない。CI は `learn/**`・`mkdocs.yml` 変更で自動発火するため設定追加不要（[第1章 design](../20260613-initial-implementation/design.md) §3.2/3.3）。

## 3. 主要な設計判断

### 3.1 llama.cpp 入手＝**ビルド済バイナリ**（2026-06-21 方針変更／旧: フルビルド）
- **当初（grilling 決定1）はソースからのフルビルドを採用**したが、P1 検証で次が判明したため**ビルド済バイナリ方式へ変更**：
  - フルビルド（`cmake --build -j`）は **WSL2＝ローカル Windows ホストのリソースを共有**するため、`-j20` 並列コンパイル＋torch変換で**ホストごとダウン**した（[[project-wsl2-host-resource-limit]]）。Colab(2コア)でも数分〜十数分かかり Codex A-3 のタイムアウト懸念が残る。
- **採用方式（プレビルド）**：
  - **量子化・推論ツール**：公式 GitHub Releases の `llama-<TAG>-bin-ubuntu-x64.tar.gz`（CPU版）を `wget` でDL→`tar` 展開。`llama-quantize`／`llama-completion`／同梱 `.so` が得られる（rpath で動く）。**コンパイル不要・約15MB・数秒**。
  - **変換スクリプト**：`git clone --depth 1 --branch <TAG>`（**ビルドはしない**）で `convert_hf_to_gguf.py` と requirements を取得。
  - 変換の Python 依存はリポジトリ同梱 requirements（`gguf`/`numpy`/`torch`/`transformers`/`sentencepiece` 等）を `pip install`。
- **メリット**：requirements のフルパイプライン（変換→量子化→推論）を維持しつつ、ビルドの重さ・時間・ホスト負荷を排除。作者が devコンテナで安全に実完走検証できる（AC-2）。
- **パスは固定値を書かず動的探索する（Codex A-1/A-2）**：`convert_hf_to_gguf.py` は版で配置が変わり（root↔`tools/`）、配布物の構成も変わりうる。よって `find` で実パス解決（`find_one(name, *roots)`：CONVERT は `llama.cpp`、QUANTIZE/COMPLETION は `prebuilt` を探索）。
- **ローカル実行の注意**：Notebook は **Colab CPU（隔離環境）前提**。手元PCで直接 Run all すると変換でメモリを使うため非力機では重い旨を座学トラブルシュートに明記。

### 3.2 固定コミット/タグ＝**`b9743`**（devコンテナで実証した known-good／grilling 決定1）
- llama.cpp は更新が速く、`convert_hf_to_gguf.py` の版依存で SmolLM2 変換が転ぶ報告も存在（例: ggml-org/llama.cpp issue #13603）。
- **P1 で devコンテナ上で「クローン→ビルド→SmolLM2変換→Q4量子化→推論」を一気通貫で実証し、リリースタグ `b9743` に固定**（2026-06-21 実施）。Notebook・座学・references すべてで**同一タグ `b9743`** を参照する（再現性の単一基準）。

#### Phase 1 実測（タグ `b9743` / 2026-06-21）
| 項目 | 実測 | 備考 |
| :-- | :-- | :-- |
| ビルド（フル・20コア） | 216 秒 | Notebook は `--target llama-cli llama-completion llama-quantize` に絞り Colab(2コア)時間を短縮 |
| f16 変換 | 25 秒 | `convert_hf_to_gguf.py`（**ルート直下**）`--outtype f16` |
| Q4_K_M 量子化 | 約 20 秒 | `llama-quantize ... Q4_K_M` |
| f16 サイズ | 3,424,735,424 B（3.19 GiB） | 比較基準 |
| Q4_K_M サイズ | 1,055,609,024 B（0.98 GiB） | **縮小 69.2%・3.24倍小** |
| 推論 f16（4スレッド・temp0） | 生成 7.95 t/s（prompt 33.1 t/s） | 出力: 「Paris…」正しく一貫 |
| 推論 Q4_K_M（4スレッド・temp0） | 生成 17.14 t/s（prompt 55.8 t/s） | **約2.2倍速**・出力も一貫 |

#### 版依存の確定事項（Notebook 実装で必ず踏襲＝Codex A-1/A-2/A-4 の実地確認）
- `convert_hf_to_gguf.py` は **リポジトリ root 直下**（b9743）。フラグは **`--outtype f16`**（`--out-type` ではない）。
- **`llama-cli` の `-no-cnv`（完了モード）は b9743 で廃止**。非対話の決定的生成は新バイナリ **`llama-completion`** を使う（`-m -p -n -s --temp -t --no-display-prompt`、**stdin は `</dev/null` で閉じる**）。`llama-cli` を completion 用途で使うと対話モードに落ちて停止/暴走する（実際に踏んだ）。
- ビルド済バイナリは `build/bin/` 配下（環境差吸収のため Notebook では `find` で実パス解決）。
- **cmake は Colab にプリインストール済み**（devコンテナには無く apt 導入が必要だった＝学習者環境では不要）。
- tokenizer（Codex A-6）：SmolLM2 は `tokenizer.json`（fast/BPE）のみだが b9743 の変換は **BPE merges で正常処理**（`tokenizer.model` 不要）。`--vocab-type` 等の回避は不要だった。
- 出力の堅牢性：base モデル＋temp0 は回答後に空白/反復へ流れるため、Notebook では **`-n` で必ず上限**を掛け、`--no-display-prompt` で整形する。

### 3.3 既定モデル＝`HuggingFaceTB/SmolLM2-1.7B`（base）を継承（AC-3）
- 第1章と同一モデルで章間の一貫性を確保。`LlamaForCausalLM` アーキのため `convert_hf_to_gguf.py` が正式サポート（公式 `HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF` の存在で変換実績も確認済み）。
- 取得は `huggingface_hub.snapshot_download`（safetensors・非ゲートのためトークン不要。第1章の安全チェック方針を継承）。
- **既定モデルは base SmolLM2-1.7B で確定済み（Codex B-3）**：可読性で勝る Instruct への差し替えは行わず、§6 のプロンプト設計（seed固定の短い継続生成）で base でも前後比較が成立する形にして吸収する。
- **tokenizer 依存の予防線（Codex A-6）**：SmolLM2 は Llama 系だが `tokenizer.model`（sentencepiece）ではなく `tokenizer.json`（fast）配布のことがあり、変換スクリプトの版によっては sentencepiece パスで失敗し得る。P1 で変換時の tokenizer 認識ログ（`Using ... tokenizer`）を確認し、失敗時は `--vocab-type bpe` 等の代替を採る（固定タグ確定時に手順を確定）。

### 3.4 量子化タイプ＝`Q4_K_M` を主役、`f16` を比較基準（AC-4）
- 変換は `--outtype f16` で f16 GGUF を作り、これを**比較の基準（量子化前）**にする（※フラグ名は版で `--outtype`/`--out-type` 等の揺れがあり得るため、固定タグの `--help` で確定する＝T1-4・Codex A-4）。
- 量子化は **`Q4_K_M`**（K-quant の実用既定。サイズ/品質バランスの定番）を主役に。
- 座学では K-quant の読み方（`Q4_K_M` = 4bit・K-quant・Mサイズ等）と、`Q4_0`/`Q5_K_M`/`Q8_0` の位置づけを**表で軽く**示す（詳細仕様は書かず公式へ誘導）。
- imatrix キャリブレーションは**用語紹介のみ**（requirements スコープ外）。

### 3.5 前後比較の三点セット＝サイズ＋出力＋速度（grilling 決定3 / AC-4）
- **①サイズ**：f16 GGUF と Q4\_K\_M GGUF のバイト数を並べ、縮小率(%)を表示。
- **②出力**：同一プロンプト・同一 seed で `llama-cli` 実行し、f16 と Q4 の生成テキストを並置（量子化で破綻しないことを目視）。
- **③速度**：`llama-cli` が出力する eval timing（tok/s）を拾って並置。
- **数値の扱い（grilling 決定2の派生）**：作者環境＝**20コア**。学習者の Colab CPU＝**2コア**。よって**実測値はそのまま載せず**、「2コア環境ではこの程度（◯倍遅い想定）」と**控えめに丸めて**注記。サイズは環境非依存なので実測をそのまま掲載可。

### 3.6 検証分担＝作者(devコンテナ)が CPU 実完走を保証（grilling 決定2 / AC-2）
- 第2章は GPU 不要のため、**devコンテナ（20コア/12GiB空き/854GB空き）で Notebook を Run all 実完走**させ、**AC-2 を作者保証で ✅** にする（第1章の T4 丸投げを脱却）。
- 完走の定義：clone→build→download→convert→quantize→inference(前後) まで**エラーなく最後のセルまで到達**し、サイズ/出力/速度が出ること。
- ただし**所要時間の目安のみ** 2コア環境向けに保守補正して記載（§3.5）。スペック差で「ここで通った＝Colabでも同時間」とは言わない。

### 3.7 第1章との物語の橋渡し＋発展コラム（grilling 決定4）
- **素の SmolLM2 を変換**（学習の重さを本章に持ち込まない）。
- 座学に**橋渡し段落**：「第1章は GPU で訓練する話。第2章は訓練済みモデルを **CPU で配布・推論**できる形（GGUF）にする話」。
- 座学に**発展コラム**「第1章で微調整した『〜だミャ』モデルを GGUF 化してみよう」＝ LoRA を base にマージ→本章と同じ手順で変換、という**誘導のみ**（手順詳細は本章スコープ外）。
- 第1章 index.md の「GGUF＝名前だけ予告・第2章」を**実リンク化**して相互参照を閉じる。

## 4. ハンズオンNotebookテンプレート設計（実装ファイル: `notebooks/02_gguf_llama_cpp.ipynb`）

CPU ランタイム前提・想定 14〜16 セル。第1章のメタ/検証注記の様式を踏襲。

| セル | 種別 | 内容 |
| :-- | :-- | :-- |
| 1 | md | タイトル＋Colabバッジ＋メタ表（所要時間/**ランタイム=CPU**/既定モデル/最終確認日）＋**検証状況の明示**（作者がCPU実完走を確認済み） |
| 2 | md | このNotebookでやること（convert→quantize→run の3ステップ＋デモのねらい）＋**ランタイムをCPUにする手順**の一言 |
| 3 | code | 変換スクリプト入手：`git clone --depth 1 --branch b9743 ggml-org/llama.cpp`（**ビルドしない**）＋ 変換用 `pip install`（同梱 requirements）＋ `huggingface_hub` |
| 4 | code | **ビルド済バイナリ入手**：`wget` で `llama-b9743-bin-ubuntu-x64.tar.gz` をDL→`tar` 展開（`llama-quantize`/`llama-completion`）。コンパイル不要・軽量 |
| 4b | code | パス解決：`find_one()` で CONVERT(`llama.cpp`)／QUANTIZE・COMPLETION(`prebuilt`) を動的解決 |
| 5 | md | ステップ1：モデル取得（base SmolLM2-1.7B・非ゲート/トークン不要） |
| 6 | code | `snapshot_download("HuggingFaceTB/SmolLM2-1.7B")` |
| 7 | md | ステップ2：GGUF(f16)へ変換（量子化前の基準を作る） |
| 8 | code | `python $(find ... convert_hf_to_gguf.py) <dir> --outtype f16 --outfile smollm2-f16.gguf` ＋ f16サイズ表示（スクリプトパスは動的探索＝§3.1。フラグ名は固定タグの `--help` で確認＝T1-4） |
| 9 | md | ステップ3：Q4\_K\_M へ量子化（K-quant の読み方を1段落） |
| 10 | code | `$(find ... llama-quantize) smollm2-f16.gguf smollm2-Q4_K_M.gguf Q4_K_M` ＋ Q4サイズ＋縮小率表示（バイナリパスは動的探索＝§3.1。型名表記は固定タグの quantize README で確認＝T1-5） |
| 11 | md | ステップ4：推論で前後比較（出力＋速度） |
| 12 | code | **`llama-completion`**（b9743 で `llama-cli -no-cnv` は廃止）で f16 を実行（`-p -n 48 -s 42 --temp 0 -t N --no-display-prompt`・**stdin は `</dev/null`**）。出力と tok/s を取得。**common_perf の timing は stderr 出力のため `2>&1` 等で必ずキャプチャ（Codex A-8）** |
| 13 | code | `llama-completion` で Q4\_K\_M を実行（同条件・stderrキャプチャ同様） |
| 14 | md/code | 比較まとめ（サイズ/出力/tok\_s の三点表）＋**2コア環境での速度注記** |
| 15 | md | まとめと振り返り → 理解度確認 Issue 導線（chapter-task）＋**発展コラム（第1章モデルのGGUF化）** |

### 確定したデモ設計（grilling 反映）
- **プロンプト**：base モデルでも前後比較が成立するよう、短い継続生成プロンプト＋`--seed` 固定・`-n` 固定で決定的に。
- **速度の出所**：`llama-completion` の common_perf timing（stderr）から tok/s を拾う。失敗時もサイズ＋出力の二点は必ず出す（堅牢性）。出力は `-n` で必ず上限を掛ける（base＋temp0 は回答後に空白/反復へ流れるため）。
- **依存pin**：変換用 Python パッケージはバージョン下限/固定を付ける（再現性）。llama.cpp はタグ固定（§3.2）。
- **検証分担**：作者＝**静的（nbformat妥当＋各pythonセル構文）＋ロジック＋devコンテナCPU実完走**まで（§3.6）。
- Colabバッジ URL：`https://colab.research.google.com/github/Shintaro-Abe/llm-quantization-dojo/blob/main/notebooks/02_gguf_llama_cpp.ipynb`（座学 index.md にも同バッジ）。

## 5. 教材調達先マッピング（公式doc / 仕様 / 公式実装 / モデルカード）

第2章 references.md とNotebookの一次情報は以下に限定し、**最終確認日 2026-06-21**で記録する（**実装時に全URLを WebFetch で到達・内容一致を確認**）。

### 5.1 公式ドキュメント / 仕様（一次情報・最優先）
| リソース | URL | 用途 |
| :-- | :-- | :-- |
| llama.cpp リポジトリ（README/ビルド手順） | https://github.com/ggml-org/llama.cpp | ビルド・各ツールの位置づけ |
| GGUF フォーマット仕様 | https://github.com/ggml-org/ggml/blob/master/docs/gguf.md | GGUF が「単一ファイル量子化形式」である根拠 |
| quantize ツール README（量子化タイプ一覧） | https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md | `Q4_K_M` 等の選択肢 |
| convert_hf_to_gguf.py | https://github.com/ggml-org/llama.cpp/blob/master/convert_hf_to_gguf.py | HF→GGUF 変換の入口 |

### 5.2 概念の根拠（補助）
| リソース | URL | 用途 |
| :-- | :-- | :-- |
| llama.cpp k-quants 解説（PR/Discussion） | https://github.com/ggml-org/llama.cpp/discussions | K-quant の背景（※論文ではなく実装ベース。一次情報は実装/議論） |

> GGUF/k-quant は単一の決定的論文を持たない**実装駆動**の技術。第3/4章(GPTQ/AWQ)と違い「論文」節は薄く、**公式実装＋仕様＋議論**を一次情報とする。

### 5.3 既定モデル（公式モデルカード）
| モデル | URL | 位置づけ |
| :-- | :-- | :-- |
| `HuggingFaceTB/SmolLM2-1.7B` | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B | 本章で変換する base モデル（Apache-2.0/非ゲート/safetensors） |
| `HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF` | https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF | 公式GGUFの実例（変換実績の裏付け・参考） |

## 6. 第2章 座学設計（index.md の必須トピック）

`docs/development-guidelines.md` §4 に従い**薄い自作解説＋公式リンク＋最終確認日**。詳細仕様は書かず陳腐化を避ける。

### 第2章の約束（章の背骨・1文）
> **第2章を終えると、Hugging Face のモデルを自分の手で GGUF に変換・量子化し、GPU 無しの CPU だけで llama.cpp で動かせるようになる。量子化前後でサイズ・出力・速度のトレードオフを体感する。**

### index.md 必須トピック
1. GGUF とは何か（単一ファイル量子化形式・メタデータ同梱）／なぜ CPU 推論に向くか
2. llama.cpp の位置づけ（C/C++実装・ggml・CPU/各種バックエンド）
3. 量子化タイプの読み方（`Q4_K_M` 等の K-quant・サイズ/品質トレードオフを小表で）
4. 第1章(bitsandbytes/NF4) との違いと使い分け（**学習向けの実行時量子化** vs **配布・CPU推論向けのファイル形式**）
5. **第1章との橋渡し段落**（GPUで訓練 → CPUで配布・推論）
6. ハンズオン（Colabバッジ）→ 理解度確認（Issue）
7. **発展コラム**：第1章の微調整モデルを GGUF 化してみよう（誘導のみ）
8. トラブルシュート小表（ビルド失敗/メモリ不足/変換が版依存で転ぶ→固定タグ参照）

### 一次情報の分界（第1章 §5.5 の方針を継承・ドリフト防止）
| 項目 | 一次情報 | 座学側の扱い |
| :-- | :-- | :-- |
| ビルド/変換/量子化の具体コマンド | **Notebook** | 「どんな流れか」を3ステップで概説＋セルへ誘導 |
| 量子化タイプの全選択肢 | **公式 quantize README** | 代表だけ小表、残りはリンク |
| トラブル対処 | **座学のトラブルシュート小表** | Notebook 各セルは一言警告に留める |

## 7. 影響範囲

- **新規2＋変更3**。第1章 index.md の予告リンク更新以外は破壊的変更なし。
- `mkdocs.yml` nav 追記で deploy-docs が自動再ビルド、`learn/**` 追加で link-check が自動走査（CI 設定変更不要）。
- `docs_dir: learn` により `docs/`・`.steering/` はサイト非公開のまま。
- gitleaks：コミット前に `rm -rf site/`（既知の誤検知回避）。Notebook出力に PII を残さない。

## 8. 検証方法

- **P1（最初の関門）**: devコンテナで clone→build→convert→quantize→inference を実通し。固定タグ・実サイズ・所要時間・tok/s を採取。
- ローカル: `mkdocs build --strict` 警告ゼロ、`lychee`（offline）で内部リンク、Notebook は `nbformat` 妥当＋各 code セルの `python -m py_compile` 相当で構文確認。
- **AC-2 実完走**: devコンテナで Notebook を Run all（papermill か Jupyter 実行）し最後のセルまで到達を確認 → AC-2 を作者保証 ✅。
- CI: PR → `link-check` green、`main` 反映後 `deploy-docs` green → サイトに第2章が出る。
- 受け入れ: [requirements.md](requirements.md) AC-1〜6 を手動ウォークスルー（acceptance への追記は tasklist 側で）。
