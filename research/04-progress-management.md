# 04. 学習内容/進捗管理の外部連携 調査

調査日: 2026-06-13 ／ 手段: Gemini（Web検索裏取り）

## 結論（3行）

- 汎用性・自動連携なら **Notion（API）** と **Obsidian（ローカル＋Git）** が二大候補。
- 開発系の進捗は **GitHub（Issues/Projects）** がコードと一体管理できて好相性。
- 知識の**定着**には **Anki（SRS）** を併用。数値集計は **Google Sheets** が手軽。

## 1. 候補サービス比較

| サービス | 無料枠 | API | 自動連携のしやすさ | 個人学習での向き |
| :-- | :-- | :-- | :-- | :-- |
| **Notion** | 個人はほぼ無制限（ブロック/ファイル上限あり） | あり（レート制限あり） | 高（公式API/Zapier/Make） | 知識・進捗管理の汎用ダッシュボード |
| **Obsidian** | 完全無料（ローカル保存） | 公式RESTは無。プラグイン/CLIで可 | 高（Obsidian Gitで版管理・同期） | ノート/セカンドブレイン/学習ログ |
| **GitHub (Issues/Projects)** | プライベート無制限。Actions 月2,000分無料 ※要確認 | あり（Issues/Projects） | 非常に高（Actionsで自動化） | 開発学習・タスク・ロードマップ |
| **Google Sheets** | 十分な無料枠 | あり(v4) | 非常に高（GAS/各種ライブラリ） | 学習時間・正答率など数値の集計/可視化 |
| **Anki** | デスクトップ/Android無料、iOSは有料 | 公式APIは無。AnkiConnectで可 | 中（要設定/プログラミング） | SRSによる用語・概念の暗記定着 |
| **Todoist** | プロジェクト/タスク数に制限 | あり（v1）+ Webhooks | 高 | 期日管理・習慣化 |

> 無料枠の数値（GitHub Actions分数など）は変更され得る。導入時に各社の最新の料金/制限を確認すること。

## 2. 学習管理に向く構成パターン

- **(A) 汎用型**: Obsidian（流動的なノート）＋ Notion（構造化した進捗DB）＋ Google Sheets（時間/正答率の集計）。定着は Anki。
- **(B) 開発特化型**: GitHub Issues（学習タスク）/Projects（ロードマップ）を核に、Obsidian で技術ノート、Notion で全体俯瞰。定着は Anki。

## 3. 無料で組める自動連携の例

- **学習ログ集計**: Obsidian のデイリーノートを Git push → GitHub Actions が起動 → スクリプトで `学習時間::` 等を抽出 → Google Sheets API に追記 → 集計/グラフ化。
- **タスク同期**: GitHub Issue の open/close を Actions で検知 → Notion API でロードマップDBのステータス更新。
- **SRS連携**: AnkiConnect（`http://localhost:8765`）からレビュー数/正答率を取得 → Notion/Sheets に記録（実行はローカルcron等）。

> AnkiConnect の外部安全アクセスや最新動向は**不確実**。ローカル実行前提で設計するのが無難。

## 学習ツールへの示唆

- 「進捗の外部連携」は、**ツール本体をGitHubに置くなら GitHub Projects が最小構成で完結**（追加サービス不要）。
- 「知識の定着」を重視するなら Anki(SRS)、ダッシュボードの見栄え重視なら Notion を足す、という積み増しが現実的。
- 本ユーザー環境には Obsidian 連携（MCP）が既にあるため、Obsidian を知識ベースに据える構成も低コストで実現できる。

出典は [99-sources.md](99-sources.md) を参照。
