#!/bin/sh
set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
root="$PWD"
failures=0

hook_command() {
  file="${1%%#*}"
  entry=0
  case "$1" in *#bash) entry=1 ;; esac
  jq -r --argjson i "$entry" '.hooks.PreToolUse[$i].hooks[0].command' "ai/.apm/hooks/$file.json"
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

patch() {
  jq -n --arg p "$1" '{tool_name:"apply_patch",tool_input:{command:$p}}'
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
expect block-generated-edits $BLOCK "$(patch "*** Begin Patch
*** Update File: .claude/rules/web-testing.md
@@
+hook test
*** End Patch")" "blocks a Codex patch on a generated file"
expect block-generated-edits $BLOCK "$(patch "*** Begin Patch
*** Update File: web/src/Button.tsx
@@
+x
*** Add File: .agents/skills/new/SKILL.md
+x
*** End Patch")" "blocks a Codex patch when any file in it is generated"
expect block-generated-edits $ALLOW "$(patch "*** Begin Patch
*** Update File: web/src/Button.tsx
@@
+x
*** End Patch")" "allows a Codex patch on a source file"

expect block-generated-edits#bash $BLOCK "$(run "printf '%s\\n' 'x' >> .claude/rules/web-testing.md")" "blocks appending to a generated file from the shell"
expect block-generated-edits#bash $BLOCK "$(run "echo x | tee -a ./.cursor/rules/web-testing.mdc")" "blocks tee into a generated file"
expect block-generated-edits#bash $BLOCK "$(run "sed -i '' 's/a/b/' .agents/skills/release/SKILL.md")" "blocks sed -i on a generated file"
expect block-generated-edits#bash $BLOCK "$(run "rm -r .codex")" "blocks removing a generated folder"
expect block-generated-edits#bash $BLOCK "$(run "cp notes.md $root/.claude/skills/x.md")" "blocks copying into a generated folder by absolute path"
expect block-generated-edits#bash $ALLOW "$(run "ls .claude/skills 2>/dev/null")" "allows listing a generated folder"
expect block-generated-edits#bash $ALLOW "$(run "cat .claude/rules/web-testing.md 2>&1")" "allows reading a generated file"
expect block-generated-edits#bash $ALLOW "$(run "echo x >> ~/.claude/CLAUDE.md")" "allows writing personal files in the home folder"
expect block-generated-edits#bash $ALLOW "$(run "echo '{}' > .cursor/environment.json")" "allows writing the tracked Cursor bootstrap"
expect block-generated-edits#bash $ALLOW "$(run "ai/sync.sh")" "allows the sync script"
expect block-generated-edits#bash $ALLOW "$(run "echo done > build.log")" "allows writing other files"

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
