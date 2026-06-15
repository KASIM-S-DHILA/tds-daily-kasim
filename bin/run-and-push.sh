#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$REPO_ROOT"

git pull --ff-only --quiet || true

TARGET_REPO="${TARGET_REPO:-$REPO_ROOT}"

./bin/daily-summary.sh --repo "$TARGET_REPO" --out "$REPO_ROOT/daily-summaries"
./bin/multi-summary.sh

git add daily-summaries
if git diff --cached --quiet; then
  echo "No changes — not committing."
  exit 0
fi

TODAY="$(date +%Y-%m-%d)"
git -c user.name="TDS Bot" \
    -c user.email="tds-bot@users.noreply.github.com" \
    commit -m "chore: daily summaries for $TODAY"
git push
echo "Committed and pushed summaries for $TODAY."
