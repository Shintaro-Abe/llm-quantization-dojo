---
name: gemini
description: >
  Gemini CLI（OAuth認証）を叩く軽量相談スキル。出典付きWeb調査・第二意見・要約・翻訳・ブレストを担う。
  「Geminiで調べて」「/gemini」のときに起動。コード変更はしない（読み取り専用）。
---

# Gemini 相談窓口

Gemini CLI を読み取り専用・隔離cwdで呼び出す軽量スキル。

## 使い方

プロンプトを stdin から渡す。モデルは引数で指定（flash=既定、pro=深掘り）。

```bash
cat <<'PROMPT' | .claude/skills/gemini/scripts/gemini-ask.sh flash
あなたは該当分野の専門家です。次の問いに、Web検索で裏取りして回答してください。
- 結論を先に1〜3行で。続けて要点を箇条書き。各主張に出典URLを併記。
- 不確実な点は「不確実」と明言。

問い：<ここに問い>
PROMPT
```

## 認証

OAuth のみ（APIキーは使わない）。未設定時はヘルパーが exit 3 で案内する。
初回は VS Code 統合ターミナルで `gemini` を起動し "Login with Google" を完了する。

## 安全設計

- `--approval-mode plan`（読み取り専用）+ `--skip-trust` + 隔離 cwd で起動
- リポジトリのファイルは Gemini に渡さない
- PII・資格情報をプロンプトに含めない
