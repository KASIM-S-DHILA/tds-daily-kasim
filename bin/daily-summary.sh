#!/usr/bin/env bash
set -euo pipefail

REPO="."
OUT="./daily-summaries"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --out)  OUT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

REPO="$(cd "$REPO" && pwd)"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

TODAY="$(date +%Y-%m-%d)"
OUT_FILE="$OUT/$TODAY.md"

cd "$REPO"
COUNT=$(git log --since="24 hours ago" --oneline | wc -l | tr -d ' ')

{
  echo "# Daily Summary — $TODAY"
  echo ""
  echo "Generated: $(date -Iseconds)"
  echo "Commits in last 24h: $COUNT"
  echo ""
  git log --since="24 hours ago" --pretty=format:'- `%h` · %s (%an)'
  echo ""
} > "$OUT_FILE"

echo "Wrote $OUT_FILE"
