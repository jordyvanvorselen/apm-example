#!/bin/sh
set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if ! command -v apm >/dev/null 2>&1; then
  echo "" >&2
  echo "  WARNING: apm is not installed." >&2
  echo "  Your AI tools have NO team rules, skills, agents or hooks." >&2
  echo "" >&2
  version=$(awk '/^apm[[:space:]]/ { print $2; exit }' .tool-versions 2>/dev/null)
  echo "  Fix: curl -sSL https://aka.ms/apm-unix | sh -s -- @v${version:-0.31.0}" >&2
  echo "       make setup" >&2
  echo "" >&2
  exit 0
fi

deployed_paths() {
  grep -E '^[[:space:]]*- \.(agents|claude|codex|cursor)/' "$1" 2>/dev/null |
    sed 's/^[[:space:]]*- //' | sort -u
}

restore_cursor_environment() {
  git checkout-index -f -- .cursor/environment.json 2>/dev/null || true
}
trap restore_cursor_environment EXIT

git_dir=$(git rev-parse --git-dir 2>/dev/null || true)
last_sync=""
if [ -n "$git_dir" ]; then
  last_sync="$git_dir/apm-last-sync.lock.yaml"
fi

echo "[apm] Deploying the team's AI config..."
(
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_PREFIX \
    GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
  apm install
) || {
  status=$?
  echo "[apm] Deploy FAILED (exit $status)" >&2
  exit "$status"
}

if [ -n "$last_sync" ] && [ -f "$last_sync" ] && [ -f apm.lock.yaml ]; then
  old_paths=$(mktemp)
  new_paths=$(mktemp)
  deployed_paths "$last_sync" >"$old_paths"
  deployed_paths apm.lock.yaml >"$new_paths"
  comm -23 "$old_paths" "$new_paths" | while IFS= read -r dropped; do
    case "$dropped" in
      "" | *..*) continue ;;
      .agents/* | .claude/* | .codex/* | .cursor/*) ;;
      *) continue ;;
    esac
    [ -e "$dropped" ] || continue
    rm -rf "$dropped"
    echo "[apm] Removed, no longer deployed: $dropped"
  done
  rm -f "$old_paths" "$new_paths"
fi

if [ -n "$last_sync" ] && [ -f apm.lock.yaml ]; then
  cp apm.lock.yaml "$last_sync"
fi

echo "[apm] Done"
