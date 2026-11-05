dasterm_ui_text() {
  local text="${1:-}" width
  width="$(dasterm_cols)"
  if [ "$#" -gt 0 ]; then
    printf '%s\n' "$text"
  else
    cat
  fi | {
    local content
    content="$(cat)"
    # Let the terminal wrap UTF-8 text; byte-oriented fold can split characters.
    if dasterm_has fold && ! printf '%s' "$content" | LC_ALL=C grep -q '[^ -~[:space:]]'; then
      printf '%s\n' "$content" | fold -s -w "$width"
    else
      printf '%s\n' "$content"
    fi
  }
}

dasterm_ui_banner() {
  dasterm_title "$1"
  dasterm_ui_text "${2:-}"
  printf '\n'
}

dasterm_ui_clear() {
  if [ -t 1 ] && [ "${TERM:-dumb}" != dumb ] && [ -z "${NO_COLOR:-}" ]; then
    printf '\033[H\033[2J'
  fi
}

# Read into the caller's variable. EOF/cancel never silently saves partial edits.
dasterm_ui_read() {
  local __ui_dest="$1" __ui_label="$2" __ui_default="$3" __ui_value __ui_option __ui_valid
  shift 3
  while true; do
    printf '%s [%s]: ' "$__ui_label" "$__ui_default" >&2
    IFS= read -r __ui_value || return 1
    [ "$__ui_value" != /cancel ] || return 2
    __ui_value="${__ui_value:-$__ui_default}"
    __ui_valid=0
    if [ "$#" -eq 0 ]; then __ui_valid=1; fi
    for __ui_option in "$@"; do
      if [ "$__ui_option" = "$__ui_value" ]; then __ui_valid=1; break; fi
    done
    if [ "$__ui_valid" = 1 ]; then printf -v "$__ui_dest" '%s' "$__ui_value"; return 0; fi
    dasterm_warn "$(dasterm_t invalid_choice)" >&2
  done
}

dasterm_menu() {
  local choice action
  while true; do
    dasterm_ui_clear
    dasterm_ui_banner "D A S T E R M" "$(dasterm_t menu_subtitle)"
    printf '  1  %s\n  2  %s\n  3  %s\n  4  %s\n' "$(dasterm_t menu_lite)" "$(dasterm_t menu_full)" "$(dasterm_t network)" "$(dasterm_t storage)"
    printf '  5  %s\n  6  %s\n  7  Doctor\n  8  AI · AskGPT5\n  9  %s\n  0  %s\n\n' "$(dasterm_t services)" "$(dasterm_t security)" "$(dasterm_t config_title)" "$(dasterm_t exit)"
    printf '%s > ' "$(dasterm_t choose)" >&2
    IFS= read -r choice || return 0
    case "$choice" in
      0|q|quit|exit|/exit) return 0 ;;
      1) action=lite ;; 2) action=full ;; 3) action=network ;; 4) action=storage ;;
      5) action=services ;; 6) action=security ;; 7) action=doctor ;; 8) action=ai ;; 9) action=config ;;
      *) dasterm_warn "$(dasterm_t invalid_choice)"; continue ;;
    esac
    dasterm_ui_clear
    if [ "$action" = ai ]; then
      dasterm_ai_chat
    else
      dasterm_dispatch "$action" || dasterm_warn "$(dasterm_t action_failed)"
      printf '\n%s ' "$(dasterm_t press_enter)" >&2
      IFS= read -r choice || return 0
    fi
  done
}

dasterm_watch() {
  local mode="${1:-${DASTERM_MODE:-lite}}" interval="${2:-3}" key rc
  case "$mode" in lite|full) ;; *) dasterm_error "Mode must be lite or full"; return 1 ;; esac
  if ! [[ "$interval" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! awk -v n="$interval" 'BEGIN {exit !(n>0)}'; then
    dasterm_error "Interval must be greater than zero"; return 1
  fi
  while true; do
    dasterm_ui_clear
    dasterm_render_dashboard "$mode"
    printf '\n%s %ss · q: %s · m: lite/full · Enter: refresh\n' "$(dasterm_t refreshing)" "$interval" "$(dasterm_t exit)"
    if [ -t 0 ] && [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
      key=""
      if IFS= read -r -s -n 1 -t "$interval" key; then
        case "$key" in
          q|Q) printf '\n'; return 0 ;;
          m|M) if [ "$mode" = lite ]; then mode=full; else mode=lite; fi ;;
        esac
      else
        rc=$?
        [ "$rc" -ne 1 ] || return 0
      fi
    else
      sleep "$interval" || return 1
    fi
  done
}
