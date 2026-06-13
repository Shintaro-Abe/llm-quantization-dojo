#!/usr/bin/env bash
set -euo pipefail

RAW_MODEL="${1:-flash}"
case "$RAW_MODEL" in
  flash) MODEL="gemini-2.5-flash" ;;
  pro)   MODEL="gemini-2.5-pro" ;;
  *)     MODEL="$RAW_MODEL" ;;
esac

if command -v gemini >/dev/null 2>&1; then
  GEMINI=(gemini)
else
  GEMINI=(npx --yes @google/gemini-cli)
fi

GEM_DIR="${HOME}/.gemini"
authed=0
if [ -f "${GEM_DIR}/oauth_creds.json" ]; then authed=1; fi
if [ -f "${GEM_DIR}/settings.json" ] && grep -q 'selectedAuthType' "${GEM_DIR}/settings.json" 2>/dev/null; then authed=1; fi

if [ "$authed" -ne 1 ]; then
  cat >&2 <<'EOF'
[gemini-ask] OAuth ログインが未設定です。
VS Code の統合ターミナルで `gemini` を対話起動し "Login with Google" でログインしてください。
（Claude の "! " 経由では OAuth を完了できません）
ログイン後に再実行してください。
EOF
  exit 3
fi

PROMPT="$(cat)"
if [ -z "${PROMPT//[[:space:]]/}" ]; then
  echo "[gemini-ask] プロンプトが空です。" >&2
  exit 2
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR"

exec "${GEMINI[@]}" \
  --skip-trust \
  --approval-mode plan \
  -m "$MODEL" \
  -o text \
  -p "$PROMPT"
