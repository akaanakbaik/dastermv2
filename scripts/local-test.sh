#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

green() {
  printf "\033[0;32m%s\033[0m\n" "$*"
}

red() {
  printf "\033[0;31m%s\033[0m\n" "$*"
}

yellow() {
  printf "\033[1;33m%s\033[0m\n" "$*"
}

run() {
  local name="$1"
  shift
  printf "→ %s\n" "$name"
  if "$@"; then
    green "✓ $name"
  else
    red "✗ $name"
    FAILED=$((FAILED + 1))
  fi
}

cd "$ROOT_DIR"

run "bash syntax install.sh" bash -n install.sh
run "bash syntax bin/dasterm" bash -n bin/dasterm

while IFS= read -r -d '' file; do
  run "bash syntax $file" bash -n "$file"
done < <(find lib -type f -name "*.sh" -print0)

if command -v shellcheck >/dev/null 2>&1; then
  run "shellcheck" shellcheck -x install.sh bin/dasterm lib/*.sh
else
  yellow "⚠ shellcheck not installed, skipped"
fi

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

mkdir -p "$TMP_HOME/.config/dasterm" "$TMP_HOME/.cache/dasterm" "$TMP_HOME/.local/share/dasterm/logs"
cat > "$TMP_HOME/.config/dasterm/config.env" <<EOF
DASTERM_VERSION="2.0.0"
DASTERM_LANG="en"
DASTERM_MODE="lite"
DASTERM_THEME="mono"
DASTERM_USERHOST="test@local"
DASTERM_SHOW="manual"
DASTERM_PROMPT="off"
DASTERM_SLASH="off"
DASTERM_TELEMETRY="off"
DASTERM_REPO_OWNER="akaanakbaik"
DASTERM_REPO_NAME="dastermv2"
DASTERM_REPO_BRANCH="main"
EOF

if [ "${DASTERM_LOCAL_SYSTEM_TEST:-0}" = "1" ]; then
  sudo mkdir -p /usr/local/share/dasterm/lib
  sudo cp lib/*.sh /usr/local/share/dasterm/lib/
  sudo install -m 755 bin/dasterm /usr/local/bin/dasterm
  run "dasterm version" env HOME="$TMP_HOME" dasterm version
  run "dasterm help" env HOME="$TMP_HOME" dasterm help
  run "dasterm doctor" env HOME="$TMP_HOME" dasterm doctor
else
  yellow "⚠ set DASTERM_LOCAL_SYSTEM_TEST=1 to test installed /usr/local binary"
fi

if [ "$FAILED" -eq 0 ]; then
  green "All tests passed"
else
  red "$FAILED test(s) failed"
  exit 1
fi