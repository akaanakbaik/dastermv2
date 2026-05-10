DASTERM_VERSION="${DASTERM_VERSION:-2.0.0}"
DASTERM_CONFIG_DIR="${DASTERM_CONFIG_DIR:-$HOME/.config/dasterm}"
DASTERM_CACHE_DIR="${DASTERM_CACHE_DIR:-$HOME/.cache/dasterm}"
DASTERM_DATA_DIR="${DASTERM_DATA_DIR:-$HOME/.local/share/dasterm}"
DASTERM_LOG_DIR="${DASTERM_LOG_DIR:-$DASTERM_DATA_DIR/logs}"
DASTERM_CONFIG="${DASTERM_CONFIG:-$DASTERM_CONFIG_DIR/config.env}"

dasterm_mkdirs() {
  mkdir -p "$DASTERM_CONFIG_DIR" "$DASTERM_CACHE_DIR" "$DASTERM_LOG_DIR"
}

dasterm_now() {
  TZ=Asia/Jakarta date '+%Y-%m-%d %H:%M:%S WIB'
}

dasterm_date() {
  TZ=Asia/Jakarta date '+%Y-%m-%d'
}

dasterm_log() {
  dasterm_mkdirs
  printf "[%s] %s\n" "$(dasterm_now)" "$*" >> "$DASTERM_LOG_DIR/dasterm.log"
}

dasterm_has() {
  command -v "$1" >/dev/null 2>&1
}

dasterm_is_tty() {
  [ -t 1 ]
}

dasterm_cols() {
  local c
  c="$(tput cols 2>/dev/null || echo 80)"
  [ "$c" -lt 40 ] && c=40
  echo "$c"
}

dasterm_timeout() {
  local sec="$1"
  shift
  timeout "$sec" "$@" 2>/dev/null
}

dasterm_safe_read_file() {
  local file="$1"
  [ -f "$file" ] && cat "$file"
}

dasterm_json_get() {
  local key="$1"
  jq -r "$key // empty" 2>/dev/null
}

dasterm_percent() {
  local used="$1"
  local total="$2"
  awk -v u="$used" -v t="$total" 'BEGIN{if(t>0) printf "%.1f", (u/t)*100; else print "0.0"}'
}

dasterm_bar() {
  local percent="${1:-0}"
  local width="${2:-18}"
  awk -v p="$percent" -v w="$width" 'BEGIN{
    if(p<0)p=0;if(p>100)p=100;
    f=int((p/100)*w);
    printf "[";
    for(i=0;i<f;i++)printf "█";
    for(i=f;i<w;i++)printf "░";
    printf "] %.1f%%", p;
  }'
}

dasterm_human_bytes() {
  local bytes="${1:-0}"
  awk -v b="$bytes" 'BEGIN{
    split("B KB MB GB TB PB",u," ");
    i=1;
    while(b>=1024 && i<6){b=b/1024;i++}
    printf "%.2f %s", b, u[i]
  }'
}

dasterm_trim() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

dasterm_urlencode() {
  local s="${1:-}"
  local out=""
  local i c
  for ((i=0;i<${#s};i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      ' ') out+="+" ;;
      *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
    esac
  done
  printf "%s" "$out"
}

dasterm_load_config() {
  dasterm_mkdirs
  [ -f "$DASTERM_CONFIG" ] && . "$DASTERM_CONFIG"
}

dasterm_save_config_value() {
  local key="$1"
  local value="$2"
  dasterm_mkdirs
  if [ ! -f "$DASTERM_CONFIG" ]; then
    touch "$DASTERM_CONFIG"
    chmod 600 "$DASTERM_CONFIG"
  fi
  if grep -q "^${key}=" "$DASTERM_CONFIG"; then
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$DASTERM_CONFIG"
  else
    printf '%s="%s"\n' "$key" "$value" >> "$DASTERM_CONFIG"
  fi
}

dasterm_theme_load() {
  case "${DASTERM_THEME:-pastel}" in
    cyber)
      D_C1='\033[38;2;0;255;255m'
      D_C2='\033[38;2;255;0;255m'
      D_C3='\033[38;2;0;255;128m'
      D_C4='\033[38;2;255;255;0m'
      ;;
    ocean)
      D_C1='\033[38;2;80;180;255m'
      D_C2='\033[38;2;120;220;255m'
      D_C3='\033[38;2;150;255;220m'
      D_C4='\033[38;2;180;220;255m'
      ;;
    mono)
      D_C1='\033[1;37m'
      D_C2='\033[0;37m'
      D_C3='\033[1;30m'
      D_C4='\033[1;37m'
      ;;
    *)
      D_C1='\033[38;2;255;184;108m'
      D_C2='\033[38;2;108;197;255m'
      D_C3='\033[38;2;200;255;108m'
      D_C4='\033[38;2;255;108;184m'
      ;;
  esac
  D_OK='\033[0;32m'
  D_WARN='\033[1;33m'
  D_ERR='\033[0;31m'
  D_BOLD='\033[1m'
  D_NC='\033[0m'
  if [ -n "${NO_COLOR:-}" ] || ! dasterm_is_tty; then
    D_C1='' D_C2='' D_C3='' D_C4='' D_OK='' D_WARN='' D_ERR='' D_BOLD='' D_NC=''
  fi
}

dasterm_title() {
  dasterm_theme_load
  local title="$1"
  printf "%b\n" "${D_BOLD}${D_C2}${title}${D_NC}"
  printf "%b\n" "${D_C2}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D_NC}"
}

dasterm_kv() {
  dasterm_theme_load
  local k="$1"
  local v="$2"
  printf "%b%-18s%b : %s\n" "$D_C1" "$k" "$D_NC" "$v"
}

dasterm_success() {
  dasterm_theme_load
  printf "%b✓%b %s\n" "$D_OK" "$D_NC" "$*"
}

dasterm_warn() {
  dasterm_theme_load
  printf "%b⚠%b %s\n" "$D_WARN" "$D_NC" "$*"
}

dasterm_error() {
  dasterm_theme_load
  printf "%b✗%b %s\n" "$D_ERR" "$D_NC" "$*"
}

dasterm_info() {
  dasterm_theme_load
  printf "%bℹ%b %s\n" "$D_C2" "$D_NC" "$*"
}

dasterm_footer() {
  dasterm_theme_load
  printf "%b\n" "${D_C2}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D_NC}"
  printf "%b\n" "$(dasterm_t footer_tip)"
}

dasterm_confirm() {
  local prompt="$1"
  local ans
  read -r -p "$prompt [y/N]: " ans
  case "${ans:-n}" in [Yy]*) return 0 ;; *) return 1 ;; esac
}

dasterm_cache_valid() {
  local file="$1"
  local ttl="$2"
  [ -f "$file" ] || return 1
  local now mod age
  now="$(date +%s)"
  mod="$(stat -c %Y "$file" 2>/dev/null || echo 0)"
  age=$((now - mod))
  [ "$age" -le "$ttl" ]
}

dasterm_spinner_run() {
  local text="$1"
  shift
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  "$@" &
  local pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % 10 ))
    printf "\r%b %s" "${spin:$i:1}" "$text"
    sleep 0.08
  done
  wait "$pid"
  local rc=$?
  printf "\r"
  return "$rc"
}

dasterm_public_ip() {
  if dasterm_has curl; then
    timeout 4 curl -fsSL https://api.ipify.org 2>/dev/null || true
  fi
}

dasterm_write_json_atomic() {
  local file="$1"
  local tmp="${file}.tmp.$$"
  cat > "$tmp"
  mv "$tmp" "$file"
}