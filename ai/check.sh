#!/bin/sh
set -u

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

failures=0

pass() {
  echo "  [x] $1"
}

fail() {
  echo "  [ ] $1"
  echo "      Fix: $2"
  failures=$((failures + 1))
}

has_files() {
  [ -d "$1" ] && [ -n "$(ls -A "$1" 2>/dev/null)" ]
}

echo "The Monday test, the parts a script can check:"
echo ""

wanted=$(awk '/^apm[[:space:]]/ { print $2; exit }' .tool-versions 2>/dev/null)
install_apm="curl -sSL https://aka.ms/apm-unix | sh -s -- @v${wanted:-0.31.0}"

if command -v apm >/dev/null 2>&1; then
  pass "apm is installed"
else
  fail "apm is installed" "$install_apm"
fi

installed=$(apm --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
if [ -n "$wanted" ] && [ "$wanted" = "$installed" ]; then
  pass "apm $installed matches .tool-versions"
else
  fail "apm version matches .tool-versions (want ${wanted:-?}, have ${installed:-none})" "$install_apm"
fi

if command -v jq >/dev/null 2>&1; then
  pass "jq is installed, so the hooks can run"
else
  fail "jq is installed, so the hooks can run" "brew install jq"
fi

if [ "$(git config core.hooksPath)" = ".githooks" ]; then
  pass "every pull deploys the AI config"
else
  fail "every pull deploys the AI config" "make setup"
fi

for target in .claude/skills .agents/skills .cursor/rules; do
  if has_files "$target"; then
    pass "$target is deployed"
  else
    fail "$target is deployed" "make setup"
  fi
done

echo ""
if [ "$failures" -eq 0 ]; then
  echo "All automatic checks pass. Now do the manual ones in the README."
else
  echo "$failures check(s) failed."
  exit 1
fi
