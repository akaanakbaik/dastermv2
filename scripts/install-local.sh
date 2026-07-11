#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_USER="${SUDO_USER:-${USER:-root}}"
TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || echo "${HOME:-/root}")"

if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo bash "$0" "$@"
  fi
  echo "Root access is required."
  exit 1
fi

mkdir -p /usr/local/bin
mkdir -p /usr/local/share/dasterm/lib

install -m 755 "$ROOT_DIR/bin/dasterm" /usr/local/bin/dasterm
cp -f "$ROOT_DIR/lib/"*.sh /usr/local/share/dasterm/lib/
chmod 644 /usr/local/share/dasterm/lib/*.sh

mkdir -p "$TARGET_HOME/.config/dasterm" "$TARGET_HOME/.cache/dasterm" "$TARGET_HOME/.local/share/dasterm/logs"

if [ ! -f "$TARGET_HOME/.config/dasterm/config.env" ]; then
  cat > "$TARGET_HOME/.config/dasterm/config.env" <<EOF
DASTERM_VERSION="2.0.0"
DASTERM_LANG="id"
DASTERM_MODE="lite"
DASTERM_THEME="pastel"
DASTERM_USERHOST="${TARGET_USER}@$(hostname 2>/dev/null || echo linux)"
DASTERM_SHOW="always"
DASTERM_PROMPT="on"
DASTERM_SLASH="on"
DASTERM_TELEMETRY="off"
DASTERM_REPO_OWNER="akaanakbaik"
DASTERM_REPO_NAME="dastermv2"
DASTERM_REPO_BRANCH="main"
EOF
fi

chmod 600 "$TARGET_HOME/.config/dasterm/config.env"
chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.config/dasterm" "$TARGET_HOME/.cache/dasterm" "$TARGET_HOME/.local/share/dasterm" 2>/dev/null || true

[ -f "$TARGET_HOME/.bashrc" ] || touch "$TARGET_HOME/.bashrc"
sed -i "/^### DASTERM_V2_BEGIN ###$/,/^### DASTERM_V2_END ###$/d" "$TARGET_HOME/.bashrc" 2>/dev/null || true
cat >> "$TARGET_HOME/.bashrc" <<'EOF'

### DASTERM_V2_BEGIN ###
if [ -x /usr/local/bin/dasterm ]; then
  eval "$(/usr/local/bin/dasterm shell-init bash 2>/dev/null)"
  if [ -z "${DASTERM_SESSION_DONE:-}" ] && [ -t 1 ]; then
    export DASTERM_SESSION_DONE=1
    /usr/local/bin/dasterm auto 2>/dev/null || true
  fi
fi
### DASTERM_V2_END ###
EOF
chown "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.bashrc" 2>/dev/null || true

if [ -f "$TARGET_HOME/.zshrc" ] || [ -d "$TARGET_HOME/.oh-my-zsh" ]; then
  [ -f "$TARGET_HOME/.zshrc" ] || touch "$TARGET_HOME/.zshrc"
  sed -i "/^### DASTERM_V2_BEGIN ###$/,/^### DASTERM_V2_END ###$/d" "$TARGET_HOME/.zshrc" 2>/dev/null || true
  cat >> "$TARGET_HOME/.zshrc" <<'EOF'

### DASTERM_V2_BEGIN ###
if [ -x /usr/local/bin/dasterm ]; then
  eval "$(/usr/local/bin/dasterm shell-init zsh 2>/dev/null)"
  if [ -z "${DASTERM_SESSION_DONE:-}" ] && [ -t 1 ]; then
    export DASTERM_SESSION_DONE=1
    /usr/local/bin/dasterm auto 2>/dev/null || true
  fi
fi
### DASTERM_V2_END ###
EOF
  chown "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.zshrc" 2>/dev/null || true
fi

echo "Dasterm local install complete."
echo "Run: source ~/.bashrc"
echo "Then: dasterm help"