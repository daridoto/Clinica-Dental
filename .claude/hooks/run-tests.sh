#!/usr/bin/env bash
# Stop hook: run the test suite before Claude finishes.
# Exit code 2 blocks the stop and shows the failure to Claude.
set -uo pipefail

# Without jq we can't read stop_hook_active (loop guard), so don't block.
if ! command -v jq >/dev/null 2>&1; then
  echo "run-tests.sh: jq is not installed, skipping tests." >&2
  exit 0
fi

# Avoid infinite loops: if we already blocked once, let Claude stop.
if [ "$(jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Only run tests when there are uncommitted changes (e.g. not after a plain answer).
if [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

if ! output=$(npm test 2>&1); then
  echo "Tests are failing. Fix them before finishing:" >&2
  echo "$output" | tail -n 40 >&2
  exit 2
fi
exit 0
