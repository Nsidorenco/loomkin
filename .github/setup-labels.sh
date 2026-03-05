#!/usr/bin/env bash
# Creates GitHub labels from labels.json. Idempotent (--force overwrites existing).
# Usage: .github/setup-labels.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABELS_FILE="$SCRIPT_DIR/labels.json"

if ! command -v gh &> /dev/null; then
  echo "Error: gh CLI is not installed. Install it from https://cli.github.com"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed."
  exit 1
fi

count=$(jq length "$LABELS_FILE")

for i in $(seq 0 $((count - 1))); do
  name=$(jq -r ".[$i].name" "$LABELS_FILE")
  color=$(jq -r ".[$i].color" "$LABELS_FILE")
  description=$(jq -r ".[$i].description" "$LABELS_FILE")

  echo "Creating label: $name"
  gh label create "$name" --color "$color" --description "$description" --force
done

echo "Done. Created $count labels."
