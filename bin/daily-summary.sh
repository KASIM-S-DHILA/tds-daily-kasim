#!/usr/bin/env bash
#
# daily-summary.sh — Generate a Markdown summary of recent Git activity.
#
# Usage: daily-summary.sh [--repo /path/to/repo] [--out /path/to/output/dir]
#

set -euo pipefail

# ----- Defaults -----
REPO_DIR="${REPO_DIR:-$(pwd)}"
OUT_DIR="${OUT_DIR:-./daily-summaries}"
SINCE="24 hours ago"

# ----- Parse args -----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)  REPO_DIR="$2";  shift 2 ;;
    --out)   OUT_DIR="$2";   shift 2 ;;
    --since) SINCE="$2";     shift 2 ;;
    *)       echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$OUT_DIR"
TODAY="$(date +%Y-%m-%d)"
OUT_FILE="$OUT_DIR/$TODAY.md"

# ----- Gather stats -----
cd "$REPO_DIR"

# Make sure we have latest info from origin (don't fail the script if offline)
git fetch --all --quiet || true

COMMITS=$(git log --since="$SINCE" --oneline --all | wc -l | tr -d ' ')

AUTHORS=$(
  git log --since="$SINCE" --all --pretty=format:'%an' \
    | sort | uniq -c | sort -rn \
    | awk '{count=$1; $1=""; sub(/^ /, ""); printf "- %s (%d)\n", $0, count}'
)

RECENT_COMMITS=$(
  git log --since="$SINCE" --all --pretty=format:'- `%h` · %s (%an)' \
    | head -20
)

# Lines changed (single shortstat line): "X files changed, Y insertions(+), Z deletions(-)"
STATS=$(git log --since="$SINCE" --all --shortstat --pretty=format:'' \
  | awk '
    /files? changed/ {
      for (i=1; i<=NF; i++) {
        if ($i ~ /insertion/) ins += $(i-1)
        if ($i ~ /deletion/)  del += $(i-1)
      }
    }
    END { printf "+%d / -%d\n", ins+0, del+0 }'
)

BRANCHES=$(git branch -a --sort=-committerdate \
  | grep -v HEAD \
  | head -5 \
  | sed 's/^[* ] //' \
  | paste -sd "," - \
  | sed 's/,/, /g'
)

# ----- Write output -----
cat > "$OUT_FILE" <<EOF
# Daily Summary — $TODAY

Repository: \`$(basename "$REPO_DIR")\`
Period: last $SINCE
Generated: $(date -Iseconds)

## Commits (last $SINCE): $COMMITS

${RECENT_COMMITS:-_No commits in this window._}

## Lines changed
- $STATS

## Active branches
- $BRANCHES

## Top authors
${AUTHORS:-_No authors in this window._}
EOF

echo "Wrote $OUT_FILE"
