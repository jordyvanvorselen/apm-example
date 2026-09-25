#!/bin/sh
set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
root="$PWD"
failures=0

hook_command() {
  jq -r '.hooks.PreToolUse[0].hooks[0].command' "ai/.apm/hooks/$1.json"
}

expect() {
  hook="$1"
  wanted="$2"
  input="$3"
  name="$4"
  printf '%s' "$input" | CLAUDE_PROJECT_DIR="$root" sh -c "$(hook_command "$hook")" >/dev/null 2>&1
  actual=$?
  if [ "$actual" -eq "$wanted" ]; then
    echo "  ok    $hook: $name"
  else
    echo "  FAIL  $hook: $name (exit $actual, want $wanted)"
    failures=$((failures + 1))
  fi
}

edit() {
  printf '{"tool_input":{"file_path":"%s"}}' "$1"
}

run() {
  jq -n --arg c "$1" '{tool_input:{command:$c}}'
}

BLOCK=2
ALLOW=0

expect block-generated-edits $BLOCK "$(edit "$root/.claude/skills/create-pr/SKILL.md")" "blocks a deployed Claude skill"
expect block-generated-edits $BLOCK "$(edit ".cursor/rules/web-testing.mdc")" "blocks a relative Cursor rule path"
expect block-generated-edits $BLOCK "$(edit "$root/.agents/skills/release/SKILL.md")" "blocks a shared skill"
expect block-generated-edits $ALLOW "$(edit "$root/ai/.apm/skills/create-pr/SKILL.md")" "allows the source file"
expect block-generated-edits $ALLOW "$(edit "$root/.cursor/environment.json")" "allows the tracked Cursor bootstrap"
expect block-generated-edits $ALLOW "$(edit "$root/.claude/settings.local.json")" "allows personal Claude settings"
expect block-generated-edits $ALLOW "$(edit "$HOME/.claude/CLAUDE.md")" "allows personal files in the home folder"

expect block-destructive-commands $BLOCK "$(run "rm -rf /")" "blocks wiping the root"
expect block-destructive-commands $BLOCK "$(run "rm -rf .")" "blocks wiping the repo"
expect block-destructive-commands $BLOCK "$(run "rm -fr ~")" "blocks wiping the home folder"
expect block-destructive-commands $BLOCK "$(run 'psql -c "drop table users"')" "blocks DROP TABLE"
expect block-destructive-commands $BLOCK "$(run "git push --force origin main")" "blocks force-push to main"
expect block-destructive-commands $BLOCK "$(run "git push -f origin HEAD:main")" "blocks force-push to main by refspec"
expect block-destructive-commands $ALLOW "$(run "rm -rf ./build")" "allows removing a build folder"
expect block-destructive-commands $ALLOW "$(run "git push -f origin feature/checkout")" "allows force-push to a feature branch"
expect block-destructive-commands $ALLOW "$(run "git push origin main")" "allows a normal push to main"

echo ""
if [ "$failures" -eq 0 ]; then
  echo "All hook tests pass."
else
  echo "$failures hook test(s) failed."
  exit 1
fi
