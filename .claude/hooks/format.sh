#!/usr/bin/env bash
# PostToolUse hook: format the file Claude just edited with Prettier.
set -euo pipefail

# jq parses the hook's JSON input; warn loudly instead of failing silently.
if ! command -v jq >/dev/null 2>&1; then
  echo "format.sh: jq is not installed, skipping Prettier." >&2
  exit 1
fi

file_path=$(jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

cd "$CLAUDE_PROJECT_DIR"
# --ignore-unknown: skip files Prettier can't parse instead of failing.
npx --no-install prettier --write --ignore-unknown "$file_path" >/dev/null 2>&1 || true
