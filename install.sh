#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

REPO_OWNER="akaanakbaik"
REPO_NAME="dastermv2"
REPO_BRANCH="${DASTERM_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}"
INSTALL_URL="${RAW_BASE}/install.sh"
TMP_DIR="${TMPDIR:-/tmp}/dasterm-install-$$"
LOCK="${TMPDIR:-/tmp}/dasterm-install.lock"
PREFIX="/usr/local"
BIN_DIR="${PREFIX}/bin"
SHARE_DIR="${PREFIX}/share/dasterm"
LIB_DIR="${SHARE_DIR}/lib"
MARK_BEGIN="### DASTERM_V2_BEGIN ###"
MARK_END="### DASTERM_V2_END ###"
VERSION="2.0.0"
ACTION=""

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
  printf "%b\n" "${Y}⚠${N} $*" >&2
}

err() {
  printf "%b\n" "${R}✗${N} $*" >&2
}

info() {
  printf "%b\n" "${C}ℹ${N} $*" >&2
}

has() {
  command -v "$1" >/dev/null 2>&1
}

abort_invalid() {
  err "Input salah 3 kali. Installer dibatalkan."
  exit 1
}

detect_user() {
  TARGET_USER="${SUDO_USER:-${USER:-root}}"
  TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || echo "${HOME:-/root}")"
  TARGET_GROUP="$(id -gn "$TARGET_USER" 2>/dev/null || echo "$TARGET_USER")"
  [ -n "$TARGET_HOME" ] || TARGET_HOME="${HOME:-/root}"
  CONFIG_DIR="${TARGET_HOME}/.config/dasterm"
  CACHE_DIR="${TARGET_HOME}/.cache/dasterm"
  DATA_DIR="${TARGET_HOME}/.local/share/dasterm"
  LOG_DIR="${DATA_DIR}/logs"
  CONFIG_FILE="${CONFIG_DIR}/config.env"
  BASHRC="${TARGET_HOME}/.bashrc"
  ZSHRC="${TARGET_HOME}/.zshrc"
}

load_existing_language() {
  if [ -f "${CONFIG_FILE:-}" ]; then
    DASTERM_OLD_LANG="$(awk -F= '/^DASTERM_LANG=/{gsub(/"/,"",$2); print $2; exit}' "$CONFIG_FILE" 2>/dev/null || true)"
    case "${DASTERM_OLD_LANG:-}" in
      id|en) DASH_LANG="$DASTERM_OLD_LANG" ;;
    esac
  fi
}

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    err "Root access is required for this action."
    say ""
    say "Recommended:"
    say "  curl -fsSL ${INSTALL_URL} -o /tmp/dasterm-install.sh && sudo bash /tmp/dasterm-install.sh"
    say ""
    exit 1
  fi
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
    i=$(((i + 1) % 10))
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
  if wait "$pid"; then
    ok "$text"
  else
    err "$text failed."
    exit 1
  fi
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
    id:reload) echo "Muat ulang tampilan sekarang dan buka shell baru?" ;;
    en:reload) echo "Reload display now and open a new shell?" ;;
    id:invalid) echo "Pilihan tidak valid. Coba lagi." ;;
    en:invalid) echo "Invalid choice. Try again." ;;
    *) echo "$key" ;;
  esac
}

read_choice() {
  local prompt="$1"
  local default="$2"
  local choices="$3"
  local ans attempt
  for attempt in 1 2 3; do
    read -r -p "$prompt" ans
    ans="${ans:-$default}"
    case " $choices " in
      *" $ans "*) echo "$ans"; return 0 ;;
      *)
        warn "$(t invalid) (${attempt}/3)"
        ;;
    esac
  done
  abort_invalid
}

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local ans attempt
  for attempt in 1 2 3; do
    if [ "$default" = "y" ]; then
      read -r -p "$prompt [Y/n]: " ans
      ans="${ans:-y}"
    else
      read -r -p "$prompt [y/N]: " ans
      ans="${ans:-n}"
    fi

    case "$ans" in
      y|Y|yes|YES|Yes) return 0 ;;
      n|N|no|NO|No) return 1 ;;
      *)
        warn "$(t invalid) (${attempt}/3)"
        ;;
    esac
  done
  abort_invalid
}

choose_language() {
  local x
  line
  say "${B}Choose language / Pilih bahasa${N}"
  say "1) Indonesia"
  say "2) English"
  x="$(read_choice "Select [1/2]: " "1" "1 2")"
  case "$x" in
    2) DASH_LANG="en" ;;
    *) DASH_LANG="id" ;;
  esac
}

main_menu() {
  local action
  line
  say "${B}$(t main_menu)${N}"
  say "1) $(t install)"
  say "2) $(t reconfigure)"
  say "3) $(t uninstall)"
  say "4) $(t repair)"
  say "5) $(t exit)"
  action="$(read_choice "Select [1/2/3/4/5]: " "1" "1 2 3 4 5")"
  case "$action" in
    1) ACTION="install" ;;
    2) ACTION="reconfigure" ;;
    3) ACTION="uninstall" ;;
    4) ACTION="repair" ;;
    5) exit 0 ;;
  esac
}

choose_mode() {
  local x
  line
  say "${B}$(t mode)${N}"
  say "1) $(t mode_lite)"
  say "2) $(t mode_full)"
  x="$(read_choice "Select [1/2]: " "1" "1 2")"
  case "$x" in
    2) DASH_MODE="full" ;;
    *) DASH_MODE="lite" ;;
  esac
}

choose_theme() {
  local x
  line
  say "${B}$(t theme)${N}"
  say "1) Pastel"
  say "2) Cyber"
  say "3) Ocean"
  say "4) Mono"
  x="$(read_choice "Select [1/2/3/4]: " "1" "1 2 3 4")"
  case "$x" in
    2) DASH_THEME="cyber" ;;
    3) DASH_THEME="ocean" ;;
    4) DASH_THEME="mono" ;;
    *) DASH_THEME="pastel" ;;
  esac
}

valid_userhost_input() {
  local value="$1"
  [ -z "$value" ] && return 0
  [[ "$value" =~ [[:space:]] ]] && return 1
  [[ "$value" == *"/"* ]] && return 1
  [[ "$value" == *":"* ]] && return 1
  if [[ "$value" == *"@"* ]]; then
    local left right
    left="${value%%@*}"
    right="${value#*@}"
    [ -n "$left" ] && [ -n "$right" ] || return 1
  fi
  return 0
}

ask_userhost() {
  line
  say "${B}$(t userhost)${N}"
  local default uh attempt
  default="${TARGET_USER}@$(hostname 2>/dev/null || echo linux)"

  for attempt in 1 2 3; do
    read -r -p "User@Host [$default]: " uh
    if valid_userhost_input "${uh:-}"; then
      if [ -z "${uh:-}" ]; then
        DASH_USERHOST="$default"
      elif [[ "$uh" == *"@"* ]]; then
        DASH_USERHOST="$uh"
      else
        DASH_USERHOST="${TARGET_USER}@${uh}"
      fi
      return 0
    fi
    warn "User@Host tidak valid. Hindari spasi, '/', ':', atau format @ yang kosong. (${attempt}/3)"
  done

  abort_invalid
}

wizard() {
  choose_mode
  ask_userhost
  choose_theme

  if ask_yes_no "$(t show)" y; then
    DASH_SHOW="always"
  else
    DASH_SHOW="manual"
  fi

  if ask_yes_no "$(t prompt)" y; then
    DASH_PROMPT="on"
  else
    DASH_PROMPT="off"
  fi

  if ask_yes_no "$(t alias)" y; then
    DASH_SLASH="on"
  else
    DASH_SLASH="off"
  fi

  if ask_yes_no "$(t speed)" y; then
    DASH_SPEED_INIT="on"
  else
    DASH_SPEED_INIT="off"
  fi

  if ask_yes_no "$(t telemetry)" n; then
    DASH_TELEMETRY="on"
  else
    DASH_TELEMETRY="off"
  fi
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
      if ! has speedtest && ! has speedtest-cli; then
        DEBIAN_FRONTEND=noninteractive apt-get -qqy install speedtest-cli >/dev/null || true
      fi
      ;;
    dnf)
      dnf -qy install curl ca-certificates jq coreutils util-linux procps-ng iproute gawk sed grep pciutils redhat-lsb-core bc >/dev/null
      if ! has speedtest && ! has speedtest-cli; then
        dnf -qy install speedtest-cli >/dev/null || true
      fi
      ;;
    yum)
      yum -qy install curl ca-certificates jq coreutils util-linux procps-ng iproute gawk sed grep pciutils redhat-lsb-core bc >/dev/null
      if ! has speedtest && ! has speedtest-cli; then
        yum -qy install speedtest-cli >/dev/null || true
      fi
      ;;
    pacman)
      pacman -Sy --noconfirm --needed curl ca-certificates jq coreutils util-linux procps-ng iproute2 gawk sed grep pciutils lsb-release bc >/dev/null
      if ! has speedtest && ! has speedtest-cli; then
        pacman -Sy --noconfirm --needed speedtest-cli >/dev/null || true
      fi
      ;;
    zypper)
      zypper -nq install curl ca-certificates jq coreutils util-linux procps gawk sed grep pciutils lsb-release bc >/dev/null
      if ! has speedtest && ! has speedtest-cli; then
        zypper -nq install speedtest-cli >/dev/null || true
      fi
      ;;
    apk)
      apk add --no-cache curl ca-certificates jq coreutils util-linux procps iproute2 gawk sed grep pciutils bc >/dev/null
      if ! has speedtest && ! has speedtest-cli; then
        apk add --no-cache speedtest-cli >/dev/null || true
      fi
      ;;
  esac
}

download_file() {
  local src="$1"
  local dst="$2"
  local url="${RAW_BASE}/${src}"

  info "Downloading ${src}"

  if ! curl -fsSL "$url" -o "$dst"; then
    err "Failed to download: $src"
    err "URL: $url"
    err "Pastikan file ini ada di repo, path benar, branch benar, dan repo public."
    exit 1
  fi
}

download_sources() {
  mkdir -p "$TMP_DIR/bin" "$TMP_DIR/lib"
  download_file "bin/dasterm" "$TMP_DIR/bin/dasterm"

  local f
  for f in core.sh i18n.sh render.sh system.sh network.sh speedtest.sh ai.sh update.sh storage.sh security.sh services.sh doctor.sh telemetry.sh; do
    download_file "lib/${f}" "$TMP_DIR/lib/${f}"
  done
}

write_config() {
  mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$LOG_DIR"

  cat > "$CONFIG_FILE" <<EOF
DASTERM_VERSION="$VERSION"
DASTERM_LANG="${DASH_LANG:-id}"
DASTERM_MODE="${DASH_MODE:-lite}"
DASTERM_THEME="${DASH_THEME:-pastel}"
DASTERM_USERHOST="${DASH_USERHOST:-${TARGET_USER}@$(hostname 2>/dev/null || echo linux)}"
DASTERM_SHOW="${DASH_SHOW:-always}"
DASTERM_PROMPT="${DASH_PROMPT:-on}"
DASTERM_SLASH="${DASH_SLASH:-on}"
DASTERM_TELEMETRY="${DASH_TELEMETRY:-off}"
DASTERM_REPO_OWNER="$REPO_OWNER"
DASTERM_REPO_NAME="$REPO_NAME"
DASTERM_REPO_BRANCH="$REPO_BRANCH"
EOF

  chmod 600 "$CONFIG_FILE"
  chown -R "$TARGET_USER":"$TARGET_GROUP" "$CONFIG_DIR" "$CACHE_DIR" "$DATA_DIR" 2>/dev/null || true
}

install_files() {
  mkdir -p "$BIN_DIR" "$LIB_DIR"
  install -m 755 "$TMP_DIR/bin/dasterm" "$BIN_DIR/dasterm"
  cp -f "$TMP_DIR/lib/"*.sh "$LIB_DIR/"
  chmod 755 "$BIN_DIR/dasterm"
  chmod 644 "$LIB_DIR/"*.sh
}

slash_command_names() {
  cat <<'EOF'
help:help
status:status
lite:lite
full:full
speedtest:speedtest
respeedtest:respeedtest
network:network
storage:storage
services:services
security:security
doctor:doctor
ai:ai
brain-ai:brain-ai
clear-brain-ai:clear-brain-ai
ai-provider:ai-provider
ai-reset-provider:ai-reset-provider
ai-test:ai-test
config:config
update:update
uninstall:uninstall
version:version
about:about
EOF
}

install_slash_commands() {
  [ "${DASH_SLASH:-on}" = "on" ] || return 0

  local name target
  while IFS=: read -r name target; do
    [ -n "$name" ] || continue
    cat > "/$name" <<SCRIPT
#!/usr/bin/env bash
exec /usr/local/bin/dasterm "$target" "\$@"
SCRIPT
    chmod 755 "/$name"
  done < <(slash_command_names)
}

remove_slash_commands() {
  local name target
  while IFS=: read -r name target; do
    [ -n "$name" ] || continue
    rm -f "/$name"
  done < <(slash_command_names)
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

  local rc
  for rc in "$BASHRC" "$ZSHRC"; do
    [ -f "$rc" ] || touch "$rc"
    sed -i "/^${MARK_BEGIN}$/,/^${MARK_END}$/d" "$rc" 2>/dev/null || true
    printf "\n%s\n" "$block" >> "$rc"
    chown "$TARGET_USER":"$TARGET_GROUP" "$rc" 2>/dev/null || true
  done
}

run_initial_speedtest() {
  [ "${DASH_SPEED_INIT:-off}" = "on" ] || return 0

  if [ -x "$BIN_DIR/dasterm" ]; then
    sudo -u "$TARGET_USER" env HOME="$TARGET_HOME" "$BIN_DIR/dasterm" respeedtest --quiet || true
  fi
}

send_install_telemetry() {
  if [ -x "$BIN_DIR/dasterm" ]; then
    sudo -u "$TARGET_USER" env HOME="$TARGET_HOME" "$BIN_DIR/dasterm" telemetry-send install >/dev/null 2>&1 || true
  fi
}

reload_shell_prompt() {
  line

  if ask_yes_no "$(t reload)" y; then
    ok "Reloading shell display..."
    sleep 1
    clear 2>/dev/null || true

    if [ "$TARGET_USER" = "root" ]; then
      cd "$TARGET_HOME" || true
      exec env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" bash -i
    else
      exec sudo -u "$TARGET_USER" -H bash -i
    fi
  else
    say ""
    say "${B}Manual reload:${N}"
    say "  exec bash -i"
    say "  dasterm"
    say "  /help"
  fi
}

do_install() {
  need_root
  detect_user
  [ -n "${DASH_LANG:-}" ] || choose_language
  wizard

  run_step "Installing dependencies" install_deps
  run_step "Downloading Dasterm v2 files" download_sources
  run_step "Installing Dasterm command" install_files
  run_step "Saving configuration" write_config
  run_step "Injecting shell integration" inject_shell
  run_step "Installing slash commands" install_slash_commands
  run_step "Preparing initial speedtest cache" run_initial_speedtest

  send_install_telemetry

  ok "Dasterm v2 installed successfully."
  say ""
  say "${B}Next:${N}"
  say "  exec bash -i"
  say "  dasterm"
  say "  /help"

  reload_shell_prompt
}

do_reconfigure() {
  need_root
  detect_user
  [ -n "${DASH_LANG:-}" ] || choose_language
  wizard

  run_step "Saving new configuration" write_config
  run_step "Refreshing shell integration" inject_shell

  if [ "${DASH_SLASH:-on}" = "on" ]; then
    run_step "Refreshing slash commands" install_slash_commands
  else
    run_step "Removing slash commands" remove_slash_commands
  fi

  run_step "Refreshing speedtest option" run_initial_speedtest

  ok "Dasterm configuration updated."
  reload_shell_prompt
}

do_uninstall() {
  need_root
  detect_user
  line
  warn "This will remove Dasterm files and shell integration."

  if ! ask_yes_no "Continue uninstall?" n; then
    exit 0
  fi

  local rc
  for rc in "$BASHRC" "$ZSHRC"; do
    if [ -f "$rc" ]; then
      sed -i "/^${MARK_BEGIN}$/,/^${MARK_END}$/d" "$rc" 2>/dev/null || true
    fi
  done

  remove_slash_commands
  rm -f "$BIN_DIR/dasterm"
  rm -rf "$SHARE_DIR"
  rm -rf "$CONFIG_DIR"
  rm -rf "$CACHE_DIR"

  ok "Dasterm removed cleanly."
  say ""
  say "Run this if needed:"
  say "  exec bash -i"
}

do_repair() {
  need_root
  detect_user
  load_existing_language
  [ -n "${DASH_LANG:-}" ] || DASH_LANG="id"

  if [ -f "$CONFIG_FILE" ]; then
    DASH_SLASH="$(awk -F= '/^DASTERM_SLASH=/{gsub(/"/,"",$2); print $2; exit}' "$CONFIG_FILE" 2>/dev/null || echo on)"
  else
    DASH_SLASH="on"
  fi

  run_step "Installing dependencies" install_deps
  run_step "Downloading Dasterm files" download_sources
  run_step "Repairing installed files" install_files
  run_step "Repairing shell integration" inject_shell

  if [ "${DASH_SLASH:-on}" = "on" ]; then
    run_step "Repairing slash commands" install_slash_commands
  fi

  ok "Dasterm repaired."
  reload_shell_prompt
}

usage() {
  cat <<EOF
Dasterm installer

Usage:
  sudo bash install.sh
  sudo bash install.sh --install
  sudo bash install.sh --reconfigure
  sudo bash install.sh --uninstall
  sudo bash install.sh --repair
EOF
}

parse_args() {
  case "${1:-}" in
    --install|install) ACTION="install" ;;
    --reconfigure|reconfigure) ACTION="reconfigure" ;;
    --uninstall|uninstall) ACTION="uninstall" ;;
    --repair|repair) ACTION="repair" ;;
    --help|-h|help) usage; exit 0 ;;
    "") ;;
    *) err "Unknown argument: $1"; usage; exit 1 ;;
  esac
}

main() {
  parse_args "${1:-}"
  banner
  detect_user
  load_existing_language

  if [ -z "$ACTION" ]; then
    [ -n "${DASH_LANG:-}" ] || choose_language
    main_menu
  fi

  case "$ACTION" in
    install) do_install ;;
    reconfigure) do_reconfigure ;;
    uninstall) do_uninstall ;;
    repair) do_repair ;;
    *) exit 0 ;;
  esac
}

main "$@"