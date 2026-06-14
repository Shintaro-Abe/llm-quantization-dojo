# 機能設計書（functional-design.md）

- 最終更新日: 2026-06-13
- ステータス: ドラフト（承認待ち）
- 関連: [product-requirements.md](product-requirements.md) ／ [architecture.md](architecture.md)

## 1. システム構成

学習者はブラウザだけで完結する。座学はGitHub Pages、ハンズオンはColab、進捗はGitHubで管理する。すべて1つのPublicリポジトリが供給源となる。

```mermaid
flowchart LR
    L[学習者/ブラウザ]
    subgraph GH[GitHub リポジトリ Public]
      LEARN[learn/ 座学Markdown]
      NB[notebooks/ .ipynb]
      TPL[.github Issue/PR テンプレ]
      CI[Actions: deploy-docs / link-check]
    end
    PAGES[GitHub Pages 公開サイト]
    COLAB[Google Colab 無料GPU T4]
    ISSUES[GitHub Issues 章タスク]
    PROJ[GitHub Projects ロードマップ/定着度]

    LEARN -->|mkdocs build| CI --> PAGES
    L -->|閲覧| PAGES
    PAGES -->|Open in Colab バッジ| COLAB
    NB -->|github→colab で起動| COLAB
    L -->|実行| COLAB
    TPL --> ISSUES
    L -->|進捗記録| ISSUES --> PROJ
    PAGES -->|手順リンク| ISSUES
```

## 2. 機能ごとのアーキテクチャ

| 機能 | 実体 | 供給/公開経路 |
| :-- | :-- | :-- |
| 座学ドキュメント | `learn/**/*.md`（MkDocs Material） | Actions で build → GitHub Pages |
| ハンズオン教材 | `notebooks/NN_*.ipynb`（Python） | リポジトリ → Colab起動バッジ |
| 実行環境 | Google Colab（無料T4）/ 発展でローカル llama.cpp | バッジURLでgithubパスを直接Colabに展開 |
| 進捗管理 | GitHub Issues / Projects | Issueテンプレ＋手順書から学習者が運用 |
| 鮮度管理 | references.md（最終確認日）＋ link-check CI | Actions（lychee） |

## 3. コンポーネント設計

```mermaid
flowchart TD
    subgraph Site[座学サイト learn/]
      IDX[index.md ロードマップ概要]
      ENV[getting-started/environment-setup.md]
      PRG[getting-started/progress-tracking.md]
      subgraph CH[chapters/NN-xxx/]
        C_IDX[index.md 概念解説]
        C_REF[references.md 公式リンク集+最終確認日]
      end
    end
    subgraph Hands[ハンズオン notebooks/]
      N1[NN_topic.ipynb]
    end
    IDX --> ENV --> CH
    C_IDX --> C_REF
    C_IDX -->|Colabバッジ| N1
    N1 -->|理解度確認の導線| PRG
```

各章コンポーネントは必ず「概念(index.md)・公式リンク(references.md)・ハンズオン(.ipynb)・進捗(Issue)」の4点を1セットで持つ。

## 4. ユースケース

```mermaid
flowchart LR
    U((学習者))
    U --> UC1[全体像/学習順序を知る]
    U --> UC2[環境構築なしでハンズオン開始]
    U --> UC3[手法の概念を理解する]
    U --> UC4[公式ドキュメントで裏取りする]
    U --> UC5[理解度を確認しIssue化する]
    U --> UC6[進捗/定着度を管理する]
```

### 主要ユースケースフロー（1章の学習体験 = 4点セット）

```mermaid
sequenceDiagram
    participant U as 学習者
    participant P as GitHub Pages(座学)
    participant C as Colab(Notebook)
    participant I as GitHub Issues/Projects
    U->>P: 章ページを開く（概念を読む）
    P->>U: 概念解説 + 公式リンク集（最終確認日）
    U->>C: 「Open in Colab」を押す
    C->>U: Notebookを Run all（4bitロード→QLoRA→推論比較）
    U->>I: 章タスクIssueを作成し学習ステップをチェック
    I->>U: Projectで進捗/定着度を可視化
```

## 5. 画面遷移（サイトナビ）

```mermaid
flowchart LR
    A[トップ index] --> B[はじめに: 環境構築]
    A --> C[はじめに: 進捗管理の始め方]
    A --> D[第1章 NF4/QLoRA 概念]
    D --> E[第1章 公式リンク集]
    D --> F[(Colab: 第1章Notebook)]
    A -. 将来 .-> G[第2章 GGUF ...]
```

## 6. データモデル（進捗管理）

進捗は GitHub の Issue と Projects(v2) のフィールドで表現する。DBは持たない。

```mermaid
erDiagram
    CHAPTER ||--o{ ISSUE : "学習タスク"
    ISSUE ||--|| PROJECT_ITEM : "Projectに追加"
    PROJECT ||--o{ PROJECT_ITEM : "保持"

    CHAPTER {
        string id "例: 01-bitsandbytes-qlora"
        string title
        string notebook_path
        string references_url
    }
    ISSUE {
        int number
        string title
        string chapter "ラベル/フォーム値"
        bool 座学読了
        bool 公式doc確認
        bool Notebook完走
        bool 理解度確認
        string 詰まった点
        number 所要時間_分
    }
    PROJECT_ITEM {
        string status "Backlog/学習中/復習/完了"
        string 章 "single select"
        string 難易度
        date 開始日
        date 完了日
        number 所要時間
        number 定着度 "1-5"
    }
```

| 項目 | 表現場所 | 用途 |
| :-- | :-- | :-- |
| 学習タスク | Issue（chapter-task フォーム） | 章ごとの学習チェックリスト |
| ステータス | Project: Status | Board列（Backlog/学習中/復習/完了） |
| 章 | Project: 章(single select) | 章別フィルタ |
| 定着度 | Project: 定着度(1–5) | 復習要否の判断 |
| ロードマップ | Project: Roadmap ビュー | 学習計画の時間軸表示 |

## 7. API設計（将来連携）

現時点では外部APIを実装しない。将来の後付け候補のみ定義する。

| 連携先 | 方式 | 用途 | 状態 |
| :-- | :-- | :-- | :-- |
| Anki(AnkiConnect) | localhost HTTP | glossary用語のSRSカード化 | 後付け（設計余地のみ） |
| Notion API | REST | 進捗ダッシュボードのリッチ表示 | 後付け（任意） |
| Google Sheets API | REST/GAS | 学習時間の集計/可視化 | 後付け（任意） |

> いずれもMVP対象外。導線・拡張余地のみ確保する（[product-requirements.md](product-requirements.md) スコープ外参照）。
