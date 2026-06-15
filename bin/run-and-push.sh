#!/usr/bin/env bash
set -euo pipefail

# Go to the dashboard repo root (the one this script lives in).
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$REPO_ROOT"

# Optional: pull first so we don't race with a teammate.
git pull --ff-only --quiet || true

# Generate the summary for a specific target repo (pass --repo env or flag).
TARGET_REPO="${TARGET_REPO:-$REPO_ROOT}"

./bin/daily-summary.sh --repo "$TARGET_REPO" --out "$REPO_ROOT/daily-summaries"

# Commit only if something changed.
if git diff --quiet daily-summaries; then
  echo "No changes — not committing."
  exit 0
fi

TODAY="$(date +%Y-%m-%d)"
git add daily-summaries
git -c user.name="TDS Bot" \
    -c user.email="tds-bot@users.noreply.github.com" \
    commit -m "chore: daily summary for $TODAY"
git push
echo "Committed and pushed summary for $TODAY."
