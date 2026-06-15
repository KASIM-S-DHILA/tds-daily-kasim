#!/usr/bin/env bash
set -euo pipefail

# List of repos to summarize: "<git-url> <display-name>"
REPOS=(
  "https://github.com/KASIM-S-DHILA/tds-hello-kasim  tds-hello"
  "https://github.com/KASIM-S-DHILA/tds-csv-kasim    tds-csv"
)

OUT_DIR="${OUT_DIR:-./daily-summaries}"
TODAY="$(date +%Y-%m-%d)"
TMP=$(mktemp -d)

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
OUT_FILE="$OUT_DIR/$TODAY-all.md"

{
  echo "# Daily Summary (All Repos) — $TODAY"
  echo ""
  echo "Generated: $(date -Iseconds)"
  echo ""
} > "$OUT_FILE"

for entry in "${REPOS[@]}"; do
  read -r url name <<< "$entry"
  echo "## $name" >> "$OUT_FILE"

  if git clone --quiet --depth 200 "$url" "$TMP/$name" 2>/dev/null; then
    COUNT=$(cd "$TMP/$name" && git log --since="24 hours ago" --oneline | wc -l | tr -d ' ')
    echo "Commits: $COUNT" >> "$OUT_FILE"
    echo "" >> "$OUT_FILE"
    (cd "$TMP/$name" && git log --since="24 hours ago" --pretty=format:'- `%h` · %s (%an)') >> "$OUT_FILE" || true
    echo "" >> "$OUT_FILE"
  else
    echo "_Could not clone $url (check URL or access)._" >> "$OUT_FILE"
    echo "" >> "$OUT_FILE"
  fi

  echo "" >> "$OUT_FILE"
done

rm -rf "$TMP"
echo "Wrote $OUT_FILE"
