#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

REPO_OWNER="akaanakbaik"
REPO_NAME="dastermv2"
REPO_BRANCH="${DASTERM_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}"
TMP_DIR="${TMPDIR:-/tmp}/dasterm-install-$$"
LOCK="${TMPDIR:-/tmp}/dasterm-install.lock"
PREFIX="/usr/local"
BIN_DIR="${PREFIX}/bin"
SHARE_DIR="${PREFIX}/share/dasterm"
LIB_DIR="${SHARE_DIR}/lib"
CONFIG_DIR="${HOME}/.config/dasterm"
CACHE_DIR="${HOME}/.cache/dasterm"
DATA_DIR="${HOME}/.local/share/dasterm"
LOG_DIR="${DATA_DIR}/logs"
CONFIG_FILE="${CONFIG_DIR}/config.env"
BASHRC="${HOME}/.bashrc"
ZSHRC="${HOME}/.zshrc"
MARK_BEGIN="### DASTERM_V2_BEGIN ###"
MARK_END="### DASTERM_V2_END ###"
VERSION="2.0.0"

G='\033[0;32m'
R='\033[0;31m'
Y='\033[1;33m'
C='\033[0;36m'
M='\033[0;35m'
B='\033[1m'
N='\033[0m'

exec 9>"$LOCK"
flock -n 9 || { echo "Dasterm installer is already running."; exit 0; }

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

say() {
  printf "%b\n" "$*"
}

line() {
  printf "%b\n" "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
}

ok() {
  say "${G}✓${N} $*"
}

warn() {
  say "${Y}⚠${N} $*"
}

err() {
  say "${R}✗${N} $*"
}

info() {
  say "${C}ℹ${N} $*"
}

pause_enter() {
  printf "\n"
  read -r -p "Press Enter to continue..."
}

has() {
  command -v "$1" >/dev/null 2>&1
}

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    if has sudo; then
      sudo "$0" "$@"
      exit $?
    fi
    err "This action needs root access. Run with sudo."
    exit 1
  fi
}

detect_user() {
  TARGET_USER="${SUDO_USER:-${USER:-root}}"
  TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || echo "$HOME")"
  [ -n "$TARGET_HOME" ] || TARGET_HOME="$HOME"
  CONFIG_DIR="${TARGET_HOME}/.config/dasterm"
  CACHE_DIR="${TARGET_HOME}/.cache/dasterm"
  DATA_DIR="${TARGET_HOME}/.local/share/dasterm"
  LOG_DIR="${DATA_DIR}/logs"
  CONFIG_FILE="${CONFIG_DIR}/config.env"
  BASHRC="${TARGET_HOME}/.bashrc"
  ZSHRC="${TARGET_HOME}/.zshrc"
}

detect_pkgmgr() {
  for p in apt-get dnf yum pacman zypper apk; do
    if has "$p"; then
      echo "$p"
      return
    fi
  done
  echo "none"
}

net_ok() {
  timeout 3 bash -c 'exec 3<>/dev/tcp/1.1.1.1/53' >/dev/null 2>&1 || timeout 3 ping -c1 -W2 1.1.1.1 >/dev/null 2>&1
}

spinner() {
  local pid="$1"
  local text="$2"
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % 10 ))
    printf "\r%b %s" "${C}${spin:$i:1}${N}" "$text"
    sleep 0.08
  done
  printf "\r"
}

run_step() {
  local text="$1"
  shift
  (
    "$@"
  ) &
  local pid=$!
  spinner "$pid" "$text"
  wait "$pid"
  ok "$text"
}

banner() {
  clear 2>/dev/null || true
  say "${M}${B}"
  say "╔══════════════════════════════════════════════════════════════╗"
  say "║                         DASTERM V2                          ║"
  say "║            Interactive Linux Terminal Dashboard              ║"
  say "╚══════════════════════════════════════════════════════════════╝"
  say "${N}"
}

choose_language() {
  line
  say "${B}Choose language / Pilih bahasa${N}"
  say "1) Indonesia"
  say "2) English"
  printf "Select [1/2]: "
  read -r x
  case "${x:-1}" in
    2) DASH_LANG="en" ;;
    *) DASH_LANG="id" ;;
  esac
}

t() {
  local key="$1"
  case "${DASH_LANG:-id}:$key" in
    id:main_menu) echo "Pilih tindakan" ;;
    en:main_menu) echo "Choose action" ;;
    id:install) echo "Install / Update" ;;
    en:install) echo "Install / Update" ;;
    id:reconfigure) echo "Reconfigure" ;;
    en:reconfigure) echo "Reconfigure" ;;
    id:uninstall) echo "Uninstall" ;;
    en:uninstall) echo "Uninstall" ;;
    id:repair) echo "Repair" ;;
    en:repair) echo "Repair" ;;
    id:exit) echo "Keluar" ;;
    en:exit) echo "Exit" ;;
    id:mode) echo "Pilih mode dashboard" ;;
    en:mode) echo "Choose dashboard mode" ;;
    id:mode_lite) echo "Lite - cepat, ringkas, logo kecil" ;;
    en:mode_lite) echo "Lite - fast, compact, small logo" ;;
    id:mode_full) echo "Full - lengkap, logo terbaik, data detail" ;;
    en:mode_full) echo "Full - complete, best logo, detailed data" ;;
    id:userhost) echo "Custom User@Host" ;;
    en:userhost) echo "Custom User@Host" ;;
    id:theme) echo "Pilih tema warna" ;;
    en:theme) echo "Choose color theme" ;;
    id:show) echo "Tampilkan dashboard setiap login?" ;;
    en:show) echo "Show dashboard on every login?" ;;
    id:prompt) echo "Ubah prompt terminal menjadi User@Host custom?" ;;
    en:prompt) echo "Change terminal prompt to custom User@Host?" ;;
    id:alias) echo "Aktifkan command slash seperti /help, /ai, /update?" ;;
    en:alias) echo "Enable slash commands like /help, /ai, /update?" ;;
    id:speed) echo "Jalankan speedtest awal dan simpan hasilnya?" ;;
    en:speed) echo "Run initial speedtest and save result?" ;;
    id:telemetry) echo "Izinkan statistik anonim untuk badge README? Default tidak." ;;
    en:telemetry) echo "Allow anonymous statistics for README badges? Default no." ;;
    *) echo "$key" ;;
  esac
}

main_menu() {
  line
  say "${B}$(t main_menu)${N}"
  say "1) $(t install)"
  say "2) $(t reconfigure)"
  say "3) $(t uninstall)"
  say "4) $(t repair)"
  say "5) $(t exit)"
  printf "Select [1/2/3/4/5]: "
  read -r action
  case "${action:-1}" in
    1) ACTION="install" ;;
    2) ACTION="reconfigure" ;;
    3) ACTION="uninstall" ;;
    4) ACTION="repair" ;;
    5) exit 0 ;;
    *) ACTION="install" ;;
  esac
}

choose_mode() {
  line
  say "${B}$(t mode)${N}"
  say "1) $(t mode_lite)"
  say "2) $(t mode_full)"
  printf "Select [1/2]: "
  read -r x
  case "${x:-1}" in
    2) DASH_MODE="full" ;;
    *) DASH_MODE="lite" ;;
  esac
}

choose_theme() {
  line
  say "${B}$(t theme)${N}"
  say "1) Pastel"
  say "2) Cyber"
  say "3) Ocean"
  say "4) Mono"
  printf "Select [1/2/3/4]: "
  read -r x
  case "${x:-1}" in
    2) DASH_THEME="cyber" ;;
    3) DASH_THEME="ocean" ;;
    4) DASH_THEME="mono" ;;
    *) DASH_THEME="pastel" ;;
  esac
}

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local ans
  if [ "$default" = "y" ]; then
    read -r -p "$prompt [Y/n]: " ans
    case "${ans:-y}" in [Yy]*) return 0 ;; *) return 1 ;; esac
  else
    read -r -p "$prompt [y/N]: " ans
    case "${ans:-n}" in [Yy]*) return 0 ;; *) return 1 ;; esac
  fi
}

ask_userhost() {
  line
  say "${B}$(t userhost)${N}"
  local default="${TARGET_USER}@$(hostname 2>/dev/null || echo linux)"
  read -r -p "User@Host [$default]: " uh
  if [ -z "${uh:-}" ]; then
    DASH_USERHOST="$default"
  elif [[ "$uh" == *"@"* ]]; then
    DASH_USERHOST="$uh"
  else
    DASH_USERHOST="${TARGET_USER}@${uh}"
  fi
}

wizard() {
  choose_language
  choose_mode
  ask_userhost
  choose_theme
  if ask_yes_no "$(t show)" y; then DASH_SHOW="always"; else DASH_SHOW="manual"; fi
  if ask_yes_no "$(t prompt)" y; then DASH_PROMPT="on"; else DASH_PROMPT="off"; fi
  if ask_yes_no "$(t alias)" y; then DASH_SLASH="on"; else DASH_SLASH="off"; fi
  if ask_yes_no "$(t speed)" y; then DASH_SPEED_INIT="on"; else DASH_SPEED_INIT="off"; fi
  if ask_yes_no "$(t telemetry)" n; then DASH_TELEMETRY="on"; else DASH_TELEMETRY="off"; fi
}

install_deps() {
  local mgr
  mgr="$(detect_pkgmgr)"
  [ "$mgr" = "none" ] && return 0
  net_ok || return 0
  case "$mgr" in
    apt-get)
      DEBIAN_FRONTEND=noninteractive apt-get -qq update
      DEBIAN_FRONTEND=noninteractive apt-get -qqy install curl ca-certificates jq coreutils util-linux procps iproute2 gawk sed grep pciutils lsb-release bc >/dev/null
      ;;
    dnf)
      dnf -qy install curl ca-certificates jq coreutils util-linux procps-ng iproute gawk sed grep pciutils redhat-lsb-core bc >/dev/null
      ;;
    yum)
      yum -qy install curl ca-certificates jq coreutils util-linux procps-ng iproute gawk sed grep pciutils redhat-lsb-core bc >/dev/null
      ;;
    pacman)
      pacman -Sy --noconfirm --needed curl ca-certificates jq coreutils util-linux procps-ng iproute2 gawk sed grep pciutils lsb-release bc >/dev/null
      ;;
    zypper)
      zypper -nq install curl ca-certificates jq coreutils util-linux procps gawk sed grep pciutils lsb-release bc >/dev/null
      ;;
    apk)
      apk add --no-cache curl ca-certificates jq coreutils util-linux procps iproute2 gawk sed grep pciutils bc >/dev/null
      ;;
  esac
}

download_file() {
  local src="$1"
  local dst="$2"
  curl -fsSL "${RAW_BASE}/${src}" -o "$dst"
}

download_sources() {
  mkdir -p "$TMP_DIR/bin" "$TMP_DIR/lib"
  download_file "bin/dasterm" "$TMP_DIR/bin/dasterm"
  for f in core.sh i18n.sh render.sh system.sh network.sh speedtest.sh ai.sh update.sh storage.sh security.sh services.sh doctor.sh telemetry.sh; do
    if curl -fsSL "${RAW_BASE}/lib/${f}" -o "$TMP_DIR/lib/${f}" 2>/dev/null; then
      :
    else
      touch "$TMP_DIR/lib/${f}"
    fi
  done
}

write_config() {
  mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$LOG_DIR"
  cat > "$CONFIG_FILE" <<EOF
DASTERM_VERSION="$VERSION"
DASTERM_LANG="${DASH_LANG:-id}"
DASTERM_MODE="${DASH_MODE:-lite}"
DASTERM_THEME="${DASH_THEME:-pastel}"
DASTERM_USERHOST="${DASH_USERHOST:-${TARGET_USER}@$(hostname)}"
DASTERM_SHOW="${DASH_SHOW:-always}"
DASTERM_PROMPT="${DASH_PROMPT:-on}"
DASTERM_SLASH="${DASH_SLASH:-on}"
DASTERM_TELEMETRY="${DASH_TELEMETRY:-off}"
DASTERM_REPO_OWNER="$REPO_OWNER"
DASTERM_REPO_NAME="$REPO_NAME"
DASTERM_REPO_BRANCH="$REPO_BRANCH"
EOF
  chmod 600 "$CONFIG_FILE"
  chown -R "$TARGET_USER":"$TARGET_USER" "$CONFIG_DIR" "$CACHE_DIR" "$DATA_DIR" 2>/dev/null || true
}

install_files() {
  mkdir -p "$BIN_DIR" "$LIB_DIR"
  install -m 755 "$TMP_DIR/bin/dasterm" "$BIN_DIR/dasterm"
  cp -f "$TMP_DIR/lib/"*.sh "$LIB_DIR/" 2>/dev/null || true
  chmod 755 "$BIN_DIR/dasterm"
  chmod 644 "$LIB_DIR/"*.sh 2>/dev/null || true
}

inject_shell() {
  local block
  block="$(cat <<'EOF'
### DASTERM_V2_BEGIN ###
if [ -x /usr/local/bin/dasterm ]; then
  eval "$(/usr/local/bin/dasterm shell-init 2>/dev/null)"
  if [ -z "${DASTERM_SESSION_DONE:-}" ] && [ -t 1 ]; then
    export DASTERM_SESSION_DONE=1
    /usr/local/bin/dasterm auto 2>/dev/null || true
  fi
fi
### DASTERM_V2_END ###
EOF
)"
  for rc in "$BASHRC" "$ZSHRC"; do
    [ -f "$rc" ] || touch "$rc"
    sed -i "/^${MARK_BEGIN}$/,/^${MARK_END}$/d" "$rc" 2>/dev/null || true
    printf "\n%s\n" "$block" >> "$rc"
    chown "$TARGET_USER":"$TARGET_USER" "$rc" 2>/dev/null || true
  done
}

run_initial_speedtest() {
  [ "${DASH_SPEED_INIT:-off}" = "on" ] || return 0
  if [ -x "$BIN_DIR/dasterm" ]; then
    sudo -u "$TARGET_USER" "$BIN_DIR/dasterm" respeedtest --quiet || true
  fi
}

do_install() {
  need_root "$@"
  detect_user
  wizard
  run_step "Installing dependencies" install_deps
  run_step "Downloading Dasterm v2 files" download_sources
  run_step "Installing Dasterm command" install_files
  run_step "Saving configuration" write_config
  run_step "Injecting shell integration" inject_shell
  run_step "Preparing initial speedtest cache" run_initial_speedtest
  ok "Dasterm v2 installed successfully."
  say ""
  say "${B}Next:${N}"
  say "  source ~/.bashrc"
  say "  dasterm"
  say "  /help"
}

do_reconfigure() {
  need_root "$@"
  detect_user
  wizard
  run_step "Saving new configuration" write_config
  run_step "Refreshing shell integration" inject_shell
  run_step "Refreshing speedtest option" run_initial_speedtest
  ok "Dasterm configuration updated."
}

do_uninstall() {
  need_root "$@"
  detect_user
  line
  warn "This will remove Dasterm files and shell integration."
  if ! ask_yes_no "Continue uninstall?" n; then
    exit 0
  fi
  for rc in "$BASHRC" "$ZSHRC"; do
    [ -f "$rc" ] && sed -i "/^${MARK_BEGIN}$/,/^${MARK_END}$/d" "$rc" 2>/dev/null || true
  done
  rm -f "$BIN_DIR/dasterm"
  rm -rf "$SHARE_DIR"
  rm -rf "$CONFIG_DIR"
  rm -rf "$CACHE_DIR"
  ok "Dasterm removed cleanly."
}

do_repair() {
  need_root "$@"
  detect_user
  run_step "Installing dependencies" install_deps
  run_step "Downloading Dasterm files" download_sources
  run_step "Repairing installed files" install_files
  run_step "Repairing shell integration" inject_shell
  ok "Dasterm repaired."
}

main() {
  banner
  detect_user
  choose_language
  main_menu
  case "$ACTION" in
    install) do_install "$@" ;;
    reconfigure) do_reconfigure "$@" ;;
    uninstall) do_uninstall "$@" ;;
    repair) do_repair "$@" ;;
  esac
}

main "$@"