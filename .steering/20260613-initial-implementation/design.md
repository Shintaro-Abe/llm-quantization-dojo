# 初回実装 設計（design.md）

- 作業名: initial-implementation（MVP=第1章 bitsandbytes NF4/QLoRA）
- 作成日: 2026-06-13
- ステータス: 承認済み（実装中・grilling反映済み）。最終更新: 2026-06-20
- 上位文書: [requirements.md](requirements.md) ／ [docs/architecture.md](../../docs/architecture.md) ／ [docs/repository-structure.md](../../docs/repository-structure.md) ／ [docs/development-guidelines.md](../../docs/development-guidelines.md)

## 1. 実装アプローチ

「**空でも公開されるサイトの土台を最初に確立し、以後は内容を足すだけ**」にする。土台（Phase 3+4）→ 挫折回避の導線（environment-setup）→ 第1章座学 → Notebook → 進捗テンプレ → 品質CI の順で、各成果物が単体で検証可能な粒度で積み上げる。

```
Phase3 サイト足場 ──▶ Phase4 Pages公開CI ──▶ 公開される空サイト（最初の検証点）
                                              │
            ┌─────────────────────────────────┘
            ▼
Phase5 第1章座学（概念 index.md ＋ references.md）
            ▼
Phase6 第1章 Notebook（Colab完走）
            ▼
Phase7 進捗テンプレ＋手順書（Issue/PR/Projects）
            ▼
Phase8 品質CI（lychee）＋ build --strict ＋ 受け入れ通し
```

## 2. 変更・追加するコンポーネント

| # | パス | 種別 | 役割 | 対応AC |
| :-- | :-- | :-- | :-- | :-- |
| 1 | `requirements-docs.txt` | 新規 | MkDocs Material 等をpin（ローカルbuild/CI共用） | AC-4 |
| 2 | `mkdocs.yml` | 新規 | `docs_dir: learn`・Material・`language: ja`・nav・code highlight | AC-1, AC-4 |
| 3 | `learn/index.md` | 新規 | トップ（学習ロードマップ・4点セットの進め方） | AC-1 |
| 4 | `.gitignore` | 変更 | `site/` を追記 | AC-4 |
| 5 | `.github/workflows/deploy-docs.yml` | 新規 | `mkdocs build --strict`→Pages公開（Actionsソース） | AC-4 |
| 6 | `learn/getting-started/environment-setup.md` | 新規 | Colab/Kaggle導線・GPU確認・無料枠注意 | AC-2, AC-3 |
| 7 | `learn/chapters/01-bitsandbytes-qlora/index.md` | 新規 | NF4/QLoRA概念（薄い自作解説） | AC-1 |
| 8 | `learn/chapters/01-bitsandbytes-qlora/references.md` | 新規 | 公式リンク集（最終確認日付き） | AC-1 |
| 9 | `notebooks/01_bitsandbytes_qlora.ipynb` | 新規 | 第1章ハンズオン（Colabバッジ・Run all完走） | AC-2, AC-3 |
| 10 | `.github/ISSUE_TEMPLATE/chapter-task.yml` | 新規 | 章タスク用Issueフォーム | AC-6 |
| 11 | `.github/ISSUE_TEMPLATE/content-fix.yml` | 新規 | 内容修正・リンク切れ報告フォーム | AC-5, AC-6 |
| 12 | `.github/PULL_REQUEST_TEMPLATE.md` | 新規 | PRチェックリスト（build/link-check/Notebook完走） | AC-6 |
| 13 | `learn/getting-started/progress-tracking.md` | 新規 | Issues/Projects v2 運用手順 | AC-6 |
| 14 | `.github/workflows/link-check.yml` | 新規 | lychee リンク切れ検査 | AC-5 |

> 既存の `docs/`（ガバナンス6点）・`research/` は変更しない。`docs/` はMkDocs公開対象外（`docs_dir: learn` のため自動的に除外）。

## 3. 主要な設計判断

### 3.1 サイト構成（mkdocs.yml）
- `docs_dir: learn`（[repository-structure.md](../../docs/repository-structure.md) §3-1 の `docs/`/`learn/` 分離に準拠）。
- `theme: material`・`language: ja`・nav は「はじめに（環境構築/進捗管理）→ 第1章（概念/公式リンク集）」の順。
- `pymdownx`（コードハイライト・admonition・タブ）を有効化。リンク健全性のため**絶対URL**を基本とする。
- `mkdocs build --strict` を通すため、nav未掲載ページ・リンク切れを残さない。

### 3.2 Pages公開（deploy-docs.yml）※実装済み
- トリガ: `main` への push（`learn/**`・`mkdocs.yml`・`requirements-docs.txt`・ワークフロー自身の変更時）＋手動 `workflow_dispatch`。
- ジョブ: `pip install -r requirements-docs.txt` → `mkdocs build --strict` → `actions/upload-pages-artifact@v3` → `actions/deploy-pages@v4`。
- `gh-pages` ブランチは作らない（ビルドと履歴を分離）。`concurrency: pages` で多重実行を抑制。Pagesソースを「GitHub Actions」に切替える**手順**は **progress-tracking.md（Phase 7）** に記載予定（設定操作自体は手動）。
- 権限は `pages: write`・`id-token: write` を最小付与。
- ※CI green と Pages 閲覧可否は **`main` への push 後**に確認（ローカルでは YAML 妥当性と `build --strict` を検証済み）。

### 3.3 リンク検査（link-check.yml）
- lychee で `learn/**/*.md` と Notebook内URLを検査。トリガ: PR＋`main` push＋月次cron。
- 検出は自動・修正は手動（[development-guidelines.md](../../docs/development-guidelines.md) §4 の方針に準拠）。一時的な失敗を拾わないようリトライ/除外設定を持つ。

### 3.4 第1章コンテンツ（座学）※実装済み
- index.md は「何のため・いつ使う・NF4とQLoRAの関係」を**平易な日本語**で薄く解説（陳腐化を避けるため詳細仕様は書かない）。加えて grilling 反映として **NF4とQLoRAの混同防止記述**・**トラブルシュート小表**（§5.5）・**コラム「モデルを選ぶときの安全チェック」**（§5.4）を含む。
- references.md は公式doc/論文/公式実装/モデルカードへ**絶対URL＋最終確認日（2026-06-20）**で集約（§5 マッピング参照。全URLを WebFetch で実在確認済み）。

### 3.5 ハンズオンNotebook（完走保証）
- 既定モデルは **`HuggingFaceTB/SmolLM2-1.7B`（Apache-2.0/非ゲート/safetensors）**（§5.4 で確定）。無料T4(15GB)でRun all完走を最優先。OOM時は `TinyLlama-1.1B-Chat` にフォールバック。7B級・`Qwen2.5-1.5B` は発展として案内。
- 依存は**バージョンpin**（transformers/bitsandbytes/peft/accelerate/datasets）。`seed` 固定で再現性確保。
- 出力ノイズはコミット前に最小化（nbstripout は任意）。
- 構成は §6 のテンプレートに従う。

### 3.6 進捗管理（テンプレ＋手順書のみ）
- MVPは **Issue/PRテンプレ＋Projects運用手順書まで**。gh CLI/Actionsでの自動生成はスコープ外（[requirements.md](requirements.md) §1）。
- Projects v2 のフィールド定義は [functional-design.md](../../docs/functional-design.md) のデータモデルに準拠（章/難易度/開始日/完了日/所要時間/定着度）。

## 4. データ構造（進捗管理スキーマ）

| 項目 | 型 | 用途 |
| :-- | :-- | :-- |
| 章 (chapter) | Single select | どの章のタスクか |
| Status | Single select | Backlog / 学習中 / 復習 / 完了 |
| 学習ステップ | Checklist（Issue本文） | 座学 / 公式doc / Notebook完走 / 理解度確認 |
| 難易度 | Single select | 体感難度 |
| 開始日・完了日 | Date | 学習期間 |
| 所要時間 | Number | 実績時間 |
| 定着度 | Number(1–5) | 復習要否の判断 |

## 5. 教材調達先マッピング（公式doc / 論文 / 公式実装 / 非ゲート小型モデル）

第1章の座学（references.md）とNotebookの一次情報は以下に限定し、いずれも**最終確認日 2026-06-20**で記録する（全URLを WebFetch で到達・内容一致を確認済み）。出典の根拠は [research/03-learning-materials.md](../../research/03-learning-materials.md) ／ [research/99-sources.md](../../research/99-sources.md)。

### 5.1 公式ドキュメント（一次情報・最優先）
| リソース | URL | 用途 |
| :-- | :-- | :-- |
| Transformers Quantization（総合ガイド） | https://huggingface.co/docs/transformers/main/en/quantization | bitsandbytes 4bitロードの使い分け・実装 |
| bitsandbytes × Accelerate | https://huggingface.co/docs/accelerate/usage_guides/quantization | 4bit/8bitロードの実務 |
| PEFT（LoRA/QLoRA） | https://huggingface.co/docs/peft | QLoRAアダプタの学習・適用 |

### 5.2 論文（概念の根拠）
| 論文 | arXiv | 用途 |
| :-- | :-- | :-- |
| QLoRA / NF4 | https://arxiv.org/abs/2305.14314 | NF4・二重量子化・QLoRAの理論 |

### 5.3 公式実装（リポジトリ）
| ツール | リポジトリ | 備考 |
| :-- | :-- | :-- |
| bitsandbytes | https://github.com/bitsandbytes-foundation/bitsandbytes | 旧 TimDettmers から foundation へ移管済み（[glossary.md](../../docs/glossary.md) 参照） |
| PEFT | https://github.com/huggingface/peft | LoRA/QLoRA 実装 |

### 5.4 既定モデルの確定（grilling 反映 / 2026-06-20）

`/grill-me`（テーマ：中華系モデルのセキュリティ懸念）の結論として、**方針X＝既定を西側 Apache-2.0 モデルに差し替え**を採用。技術的には Qwen2.5-1.5B も安全（safetensors／非ゲート／`trust_remote_code` 不要）に使えるが、Public公開教材としての心理的・対外的配慮から既定にはしない。すべて 2026-06-20 に公式モデルカードで確認済み。

| モデル | パラメータ | ライセンス | ゲート | 形式 | 位置づけ |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `HuggingFaceTB/SmolLM2-1.7B` | ~1.7B | Apache-2.0 | なし | safetensors | **既定（主役）**。HF公式・保守活発・T4でQLoRA余裕 |
| `TinyLlama/TinyLlama-1.1B-Chat-v1.0` | ~1.1B | Apache-2.0 | なし | safetensors | **フォールバック**（OOM時に差し替え・最軽量） |
| `Qwen/Qwen2.5-1.5B` | ~1.5B | Apache-2.0 | なし | safetensors | **発展**：同手順が他モデルでも通る例として任意言及 |
| 7B級 | ~7B | Apache-2.0系 | — | — | 発展課題（Kaggle T4×2 向け） |

#### モデル選定の安全チェック（座学コラムとして追加する）
grilling で「国籍より運用」と整理した内容を、初学者が再利用できる**チェックリスト**として座学（第1章 index.md）に追加する。

1. **safetensors 形式か**（pickle `.bin` は読み込み時にコード実行の恐れ）
2. **`trust_remote_code=True` が不要か**（必要＝モデル作者のPythonを実行する）
3. **公式org から取得しているか**（偽フォーク回避）
4. **ライセンス・ゲートの確認**（Apache-2.0/MIT・非ゲート）
5. （出力品質/思想が重要な用途なら）検閲・バイアスの確認 ※第1章の目的＝手法習得には影響しない

## 5.5 第1章 座学設計の確定事項（grilling 反映 / 2026-06-20）

`/grill-me` セッションで第1章 `index.md` の設計を詰め、以下を確定した。Phase 5 はこれに従う。

### 第1章の約束（章の背骨・1文）
> **第1章を終えると、非ゲートの Apache-2.0/MIT な 1〜3B モデルを、自分のデータで 4bit ロード→LoRA 微調整→推論まで通せるようになる。ゲート付き/大型モデルや他形式（GGUF 等）は発展課題・後続章で扱う。**

- 成功は「概念を説明できる」ではなく**手を動かして完走できる**ことで定義する。
- requirements の「任意の 1〜3B モデル」は **発展課題に降格**（初学者の完走体験を最優先）。対象は**非ゲート Apache-2.0/MIT に限定**する。

### index.md（薄い座学）の必須トピック
1. なぜ量子化するか（VRAM/コスト）
2. NF4 とは何か
3. LoRA とは何か
4. QLoRA = NF4 + LoRA の関係
5. いつ使う/使わない（QLoRA を**使わない**判断：フル微調整が適す場合／推論を軽くしたいだけなら GGUF＝**名前だけ予告・第2章**／そもそも微調整不要）
- **NF4 と QLoRA の混同を防ぐ明示記述**を入れる（「量子化＝軽量化」と「QLoRA＝微調整」を切り分ける）。
- **トラブルシュート小表**（OOM / Colab T4 切断 / モデル差し替え）を座学側に置く（実行中に別タブで参照でき、T4 が切れても消えないため）。

### 一次情報（Source of Truth）の分界 — 二重記述によるドリフトを避ける
| 項目 | 一次情報 | 座学側の扱い |
| :-- | :-- | :-- |
| (a) データ整形（プロンプト整形/トークナイズ） | **Notebook** | 「整形が必要」と 1〜2 文＋該当セルへ誘導のみ |
| (b) 成否確認 | **Notebook**（推論の前後比較セル） | 「何をもって成功とするか」の考え方だけ短く |
| (c) トラブル対処 | **座学のトラブルシュート小表** | Notebook 各セルは一言警告に留める |

## 6. ハンズオンNotebookテンプレート設計

| セル | 内容 |
| :-- | :-- |
| 先頭(md) | タイトル＋Colabバッジ＋メタ（所要時間/必要VRAM/対象モデル/最終確認日） |
| セットアップ | `!pip install` をpin（transformers/bitsandbytes/peft/accelerate/datasets） |
| 環境確認 | `!nvidia-smi`・GPU/VRAM表示・`seed` 固定 |
| 本編1 | NF4で4bitロード（`BitsAndBytesConfig`） |
| 本編2 | 小データでQLoRA微調整（PEFT） |
| 本編3 | 推論で前後比較（微調整前 vs 後） |
| 末尾(md) | 理解度確認の設問 → chapter-task Issue作成への導線リンク |

- Colabバッジ URL: `https://colab.research.google.com/github/<owner>/<repo>/blob/main/notebooks/01_bitsandbytes_qlora.ipynb`（`<owner>/<repo>` はリポジトリ確定後に差し込む）。

## 7. 影響範囲

- **新規追加が中心**で既存ファイルへの破壊的変更はなし。`.gitignore` のみ追記（`site/`）。
- `docs_dir: learn` により `docs/` はサイトに出ない（ガバナンス文書の非公開を担保）。
- CI追加（deploy-docs / link-check）により、以降のPRで自動的に build/link が検証される。

## 8. 検証方法

- ローカル: `pip install -r requirements-docs.txt && mkdocs serve` → ナビ確認、`mkdocs build --strict` 警告ゼロ、`lychee` ローカル実行。
- Notebook: ColabバッジからT4で Run all 完走（任意でCPU極小モデルのスモーク）。
- CI: `main` push → `deploy-docs` green → Pages閲覧可能、`link-check` green。
- 受け入れ: [requirements.md](requirements.md) AC-1〜6 を順に手動ウォークスルー。
