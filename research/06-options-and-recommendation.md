# 06. 構成の選択肢（5案）と推奨

調査日: 2026-06-13

LLM量子化の個人学習ツール（①座学 ②ハンズオン教材 ③実行環境 ④進捗管理の外部連携）を、無料・公式最新追従・初学者導線の観点で構成する案を5つ提示する。

## 推奨度ランキング（一覧）

| 順位 | 案 | 推奨度 | 一言で |
| :-- | :-- | :-- | :-- |
| 1 | **A. GitHub一体型**（MkDocs + Colab + GitHub Projects） | ★★★★★ | 全工程を無料・Git管理で完結。初学者の環境構築をColabで回避 |
| 2 | **B. Hugging Face集約型**（Markdown/Spaces + Colab + Notion） | ★★★★☆ | 公式量子化情報に最短追従。HF中心の実務に直結 |
| 3 | **C. Obsidian知識ベース型**（Obsidian + Colab + Anki） | ★★★★☆ | 知識定着とセカンドブレイン重視。既存Obsidian環境を活用 |
| 4 | **D. Notionオールインワン型**（Notion + Colab） | ★★★☆☆ | ノーコードで最速構築。コード/Git管理は弱い |
| 5 | **E. 既存コース活用ハイブリッド型**（DeepLearning.AI等 + 補助ノート） | ★★☆☆☆ | 構築コスト最小。ただし一部有料・「自作ツール」要件から逸脱気味 |

---

## A. GitHub一体型 ★★★★★（最有力）

- **構成**: 座学=MkDocs Material→GitHub Pages ／ 教材=Jupyter Notebook(リポジトリ) ／ 実行=Google Colab（"Open in Colab"バッジ）＋ローカルllama.cpp ／ 進捗=GitHub Issues/Projects
- **言語**: Python（教材）＋ Markdown（座学）
- **理由**: 4要件すべてを**1つのGitHubリポジトリ＋無料サービス**で完結できる。座学・教材・進捗が同じGitで版管理され、公式更新への追従（PR運用）もしやすい。初学者が最も詰まる環境構築をColabワンクリックで回避できる。
- **メリット**: 完全無料／オールGitで一元管理・履歴追跡／Colab導線で挫折回避／公開すればポートフォリオにもなる
- **デメリット**: MkDocs/GitHub Actionsの初期設定に少し学習コスト／進捗の「見栄え」はNotionに劣る／GitHub Actions無料枠の上限に留意

## B. Hugging Face集約型 ★★★★☆

- **構成**: 座学=Markdown(repo)またはHF上 ／ 教材=HF/Colab Notebook ／ 実行=Colab＋HF Spaces(ZeroGPU)でデモ ／ 進捗=Notion API
- **言語**: Python ＋ Markdown
- **理由**: 量子化の一次情報はHFに集約しており、教材を**公式エコシステムに密着**させられる。完成物をSpacesでデモ公開できる。
- **メリット**: 公式最新へ最短追従／実務(HF中心)に直結／Spacesで成果を可視化
- **デメリット**: ZeroGPU無料枠は短時間で学習用途に制約（要公式確認）／進捗をNotionに分けると二重管理になりがち

## C. Obsidian知識ベース型 ★★★★☆

- **構成**: 座学・ノート・進捗=Obsidian（Git同期） ／ 教材=Colab Notebook ／ 定着=Anki(SRS, AnkiConnect)
- **言語**: Markdown ＋ Python（教材）
- **理由**: 学習の「知識定着」と「振り返り」に最も強い。本ユーザー環境にObsidian連携(MCP)が既にあり低コスト。
- **メリット**: セカンドブレインで長期定着／完全ローカル＆無料／Ankiで暗記を仕組み化
- **デメリット**: 実行環境(Colab)は外部依存で導線が分かれる／自動連携は自前スクリプトが必要／他者への共有・公開には不向き

## D. Notionオールインワン型 ★★★☆☆

- **構成**: 座学・教材リンク・進捗=Notion DB ／ 実行=Colab
- **言語**: Markdown相当（Notion）＋ Python（教材はColab）
- **理由**: ノーコードで**最速に**ダッシュボードを構築でき、進捗可視化が美しい。
- **メリット**: 構築が速い／進捗管理UIが優秀／API連携も容易
- **デメリット**: コード/Notebookの版管理に弱い（Gitと二重化）／無料枠のブロック/ファイル制限／教材本体はColab任せ

## E. 既存コース活用ハイブリッド型 ★★☆☆☆

- **構成**: 座学・実行=既存コース(DeepLearning.AI短期講座, HF, NVIDIA DLI 等) ／ 自作=補助ノート＋進捗管理（任意）
- **理由**: 自作範囲を最小化でき、立ち上げが最速。
- **メリット**: 構築コスト最小／専門家監修の体系性
- **デメリット**: 一部**有料**で「できる限り無料」要件に反する／カリキュラムを自由に組み替えにくい／**「ツールを自作する」要件から逸脱**気味／公式最新への追従はコース提供側依存

---

## 比較表1: 構成要素 × 案

| 要素 | A. GitHub一体型 | B. HF集約型 | C. Obsidian型 | D. Notion型 | E. 既存コース型 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 座学ドキュメント | MkDocs→GitHub Pages | Markdown/HF | Obsidian | Notion | 既存コース教材 |
| ハンズオン教材 | Jupyter(repo) | HF/Colab Notebook | Colab Notebook | Colab Notebook | コース付属 |
| 実行環境 | Colab＋ローカル | Colab＋HF Spaces | Colab | Colab | コースの環境 |
| 進捗の外部連携 | GitHub Projects | Notion API | Obsidian＋Anki | Notion | 任意 |
| 一元管理性 | ◎(全部Git) | ○ | ○(ローカル) | △(Git弱い) | △ |

## 比較表2: サービス/言語/実行環境/進捗連携先の粒度比較

| 観点 | 推奨候補 | 無料? | 初学者の易しさ | 公式最新追従 | 備考 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 座学基盤 | MkDocs Material / Docusaurus / Notion / Obsidian | 無料 | MkDocs:中 / Notion:高 / Obsidian:高 | リンク集運用で高 | MkDocsはGitと相性◎ |
| 教材形式 | Jupyter Notebook(.ipynb) | 無料 | 高 | 高 | Colab/Kaggleでそのまま動く |
| 言語 | **Python**（必須）＋ Markdown | 無料 | 高 | 高 | 量子化系ライブラリは全てPython |
| 実行環境 | Google Colab(T4) / Kaggle(T4×2) / HF Spaces / ローカルllama.cpp | 無料 | Colab:最高 | — | 7B×4bitを基準に設計 |
| 進捗連携先 | GitHub Projects / Notion / Obsidian+Anki / Google Sheets | 無料 | GitHub:中 / Notion:高 | — | GitHub中心なら追加サービス不要 |

## 比較表3: 評価サマリ（◎○△）

| 案 | 無料度 | 初学者導線 | 公式最新追従 | 一元管理 | 実務直結 | 構築の手軽さ | 総合 |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| A. GitHub一体型 | ◎ | ◎ | ◎ | ◎ | ○ | ○ | ★★★★★ |
| B. HF集約型 | ○ | ○ | ◎ | ○ | ◎ | ○ | ★★★★☆ |
| C. Obsidian型 | ◎ | ○ | ○ | ○ | ○ | ○ | ★★★★☆ |
| D. Notion型 | ○ | ◎ | ○ | △ | ○ | ◎ | ★★★☆☆ |
| E. 既存コース型 | △ | ◎ | △ | △ | ◎ | ◎ | ★★☆☆☆ |

## 最終推奨

**A. GitHub一体型** を推奨する。理由は、(1)4要件を完全無料で一元管理でき、(2)初学者が挫折しやすい環境構築をColab導線で回避でき、(3)座学をMkDocsの薄い解説＋公式ドキュメントへのリンク集で構成すれば公式最新への追従が容易、なため。
- **知識定着を重視**するなら A＋Anki(SRS)（C案の良い所取り）。
- **進捗UIの見栄え**を重視するなら A＋Notion連携（D案の良い所取り）。

> 本案のサービス無料枠・GPU割当・ライブラリの移管状況は変動する。実装着手時に各公式を再確認すること。
