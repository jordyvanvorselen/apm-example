#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

APM_INSTALL_DIR="${APM_INSTALL_DIR:-$HOME/.local/bin}"
PATH_LINE="export PATH=\"${APM_INSTALL_DIR}:\$PATH\""

log() {
  printf '[cloud-agent-setup] %s\n' "$*"
}

die() {
  printf '[cloud-agent-setup] ERROR: %s\n' "$*" >&2
  exit 1
}

put_apm_on_path() {
  mkdir -p "$APM_INSTALL_DIR"
  export PATH="$APM_INSTALL_DIR:$PATH"
  for profile in "$HOME/.bashrc" "$HOME/.profile"; do
    touch "$profile"
    grep -Fqx "$PATH_LINE" "$profile" || printf '\n%s\n' "$PATH_LINE" >>"$profile"
  done
}

pinned_apm_version() {
  awk '/^apm[[:space:]]/ { print $2; exit }' .tool-versions
}

installed_apm_version() {
  apm --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true
}

put_apm_on_path

wanted="$(pinned_apm_version)"
[[ -n "$wanted" ]] || die "No apm version in .tool-versions"

if [[ "$(installed_apm_version)" != "$wanted" ]]; then
  log "Installing APM $wanted into $APM_INSTALL_DIR"
  curl -fsSL https://aka.ms/apm-unix | APM_INSTALL_DIR="$APM_INSTALL_DIR" sh -s -- "@v${wanted}"
fi

command -v apm >/dev/null 2>&1 || die "apm is not on PATH after install"

log "Deploying the team's AI config"
bash ./ai/sync.sh

[[ -d .cursor/rules ]] || die "No .cursor/rules after deploy. The cloud agent would run without team rules."
log "Done. The cloud agent has the same rules, skills and hooks as the team."
