# 技術仕様書（architecture.md）

- 最終更新日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 関連: [functional-design.md](functional-design.md) ／ [採用構成A案](../research/06-options-and-recommendation.md) ／ [実行環境調査](../research/02-execution-environments.md)

## 1. テクノロジースタック

| レイヤ | 採用技術 | 役割 |
| :-- | :-- | :-- |
| 座学サイト | **MkDocs ＋ Material for MkDocs** | Markdownから静的サイト生成（検索・ナビ・日本語対応） |
| サイト言語設定 | `language: ja` | 日本語UI |
| ハンズオン | **Jupyter Notebook (.ipynb) / Python** | 手を動かす教材 |
| 実行環境 | **Google Colab（無料T4 15GB）** 主軸／Kaggle(T4×2)／ローカル llama.cpp（発展） | GPU実行（環境構築不要） |
| 量子化ライブラリ（第1章） | transformers / bitsandbytes / peft / accelerate / datasets | NF4/QLoRA |
| ホスティング | **GitHub Pages** | 座学サイトの無料公開 |
| CI/CD | **GitHub Actions** | サイトビルド＆デプロイ、リンク切れ検査 |
| 進捗管理 | **GitHub Issues / Projects(v2)** | 章タスク・ロードマップ・定着度 |
| 鮮度管理 | **lychee**（リンクチェッカ）＋ 最終確認日 | 公式情報の追従 |
| 開発環境 | devcontainer（bookworm + Node/GitHub CLI） | ローカルでの執筆・ビルド確認 |

> ローカルでの重い量子化計算は行わない（GPUはColab/Kaggleに委譲）。devcontainerはドキュメント執筆・MkDocsビルド確認・gh操作のための環境。

## 2. 技術選定理由とトレードオフ

| 論点 | 採用 | 理由 | 不採用案 / トレードオフ |
| :-- | :-- | :-- | :-- |
| 座学基盤 | MkDocs Material | Markdownネイティブ・Python親和・軽量・検索が強力・導入が容易 | Docusaurus（React/Node、高機能だが重い・JS学習コスト） |
| docs_dir | `learn/`（`docs/`と分離） | CLAUDE.mdが`docs/`をガバナンス6文書に予約。学習者向け公開座学と混在させない | `docs/`をそのままdocs_dirにする案（ガバナンス文書まで公開され混乱）。やや非慣習→repository-structure.mdで明文化 |
| 公開方式 | Actions + `upload-pages-artifact`/`deploy-pages` | ビルドを分離し`gh-pages`ブランチを汚さない・履歴が綺麗 | `mkdocs gh-deploy`（手軽だがブランチ分岐・成果物がGit履歴に混入） |
| 教材形式 | Jupyter Notebook | Colab/Kaggleでそのまま動く・解説とコードを同居 | .pyスクリプト（実行体験が弱い）。出力ノイズ対策にnbstripoutを任意採用 |
| 基準モデル | 1〜3B級（既定）＋7B（発展） | 無料T4で**完走保証**を優先 | 7B既定（VRAM上限に近く環境揺らぎで失敗余地） |
| 進捗管理 | GitHub Projects/Issues | 追加サービス不要・Git一元管理・無料 | Notion（UIは綺麗だが別サービス・二重管理） |
| 依存管理 | バージョンpin（requirements/Notebook） | 再現性確保・ライブラリ移管の影響を局所化 | 未固定（最新追従だが破壊的変更で完走不能リスク） |

## 3. 技術的制約と要件

- **無料枠前提**: Colab無料はT4(約15GB)・割当保証なし・無操作で切断。Kaggleは30時間/週・T4×2(32GB)。教材はこの範囲で完走する設計とする（[research/02](../research/02-execution-environments.md)）。
- **VRAM目安**（4bit/QLoRA, 概算）: 7B QLoRA ≈ 7〜10GB、7B GPTQ/AWQ推論 ≈ 5〜8GB。第1章の既定モデルは安全側の1〜3B級。
- **GitHub Pages**: Publicリポジトリで無料公開。ソースは「GitHub Actions」を選択（手順は development-guidelines に記載）。
- **GitHub Actions**: 無料枠の実行時間に留意（Publicリポジトリは比較的潤沢だが無駄な実行は避ける）。
- **セキュリティ**: 認証情報・PIIをコミットしない。`.gitleaks.toml` による検査を運用（コミット前スキャン）。
- **ライブラリ移管リスク**: bitsandbytes→bitsandbytes-foundation、llama.cpp→ggml-org、AutoGPTQ→GPTQModel、AutoAWQの開発終了方向。第1章はbitsandbytesのみで影響小。GPTQ/AWQ章は着手時に最新状況を再確認する（[research/01](../research/01-quantization-methods.md)）。

## 4. パフォーマンス要件

| 対象 | 目標 |
| :-- | :-- |
| サイト表示 | 静的サイトのため即時。MkDocsビルドは数秒〜数十秒 |
| CIデプロイ | push後、数分以内にPages反映 |
| 第1章Notebook | 無料T4でRun all完走（目安: セットアップ含め概ね15〜30分以内、モデルサイズに依存） |
| 再現性 | 依存pin＋seed固定で、同条件なら同手順で完走 |

## 5. 環境構成（開発 / 学習者）

| 環境 | 用途 | 主なツール |
| :-- | :-- | :-- |
| 開発（devcontainer） | 執筆・MkDocsビルド確認・gh操作 | Python(MkDocs)/Node/GitHub CLI |
| 学習者（ブラウザ） | 座学閲覧・ハンズオン実行・進捗記録 | ブラウザ / Google Colab / GitHubアカウント |
| 発展（ローカル） | GGUF/llama.cppのローカル推論 | llama.cpp（第2章以降） |
