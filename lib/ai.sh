# AskGPT5 is a service name. Display the model returned by the service.
dasterm_ai_request() (
  local prompt="$1" endpoint tmp http rc answer
  endpoint="${DASTERM_AI_ENDPOINT:-https://prexzyapis.com/ai/askgpt5}"
  if ! [[ "$prompt" =~ [^[:space:]] ]]; then
    dasterm_error "$(dasterm_t ai_empty)" >&2; return 1
  fi
  if [ "$(printf '%s' "$prompt" | wc -c)" -gt 4000 ]; then
    dasterm_error "$(dasterm_t ai_long)" >&2; return 1
  fi
  if ! dasterm_has curl || ! dasterm_has jq; then
    dasterm_error "$(dasterm_t ai_deps)" >&2; return 1
  fi
  case "$endpoint" in
    https://*) ;;
    *) dasterm_error "$(dasterm_t ai_https)" >&2; return 1 ;;
  esac
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/dasterm-ai.XXXXXX")" || return 1
  # This function has its own subshell: traps cannot replace the caller's traps.
  trap 'rm -rf -- "$tmp"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  if http="$(curl --silent --show-error --connect-timeout 8 --max-time 45 \
    --max-filesize 1048576 --get "$endpoint" --data-urlencode "prompt=$prompt" \
    --output "$tmp/body" --write-out '%{http_code}' 2>"$tmp/error")"; then
    :
  else
    rc=$?
    rm -rf "$tmp"
    case "$rc" in
      28) dasterm_error "$(dasterm_t ai_timeout)" >&2 ;;
      60) dasterm_error "$(dasterm_t ai_tls)" >&2 ;;
      63) dasterm_error "$(dasterm_t ai_large_response)" >&2 ;;
      *) dasterm_error "$(dasterm_t ai_network) (curl $rc)" >&2 ;;
    esac
    return 1
  fi
  case "$http" in
    2[0-9][0-9]) ;;
    429) rm -rf "$tmp"; dasterm_error "$(dasterm_t ai_rate)" >&2; return 1 ;;
    *) rm -rf "$tmp"; dasterm_error "$(dasterm_t ai_http) ($http)" >&2; return 1 ;;
  esac
  if [ ! -f "$tmp/body" ] || [ "$(wc -c < "$tmp/body")" -gt 1048576 ]; then
    rm -rf "$tmp"; dasterm_error "$(dasterm_t ai_large_response)" >&2; return 1
  fi
  # Never print raw HTTP bodies or provider state tokens. Remove terminal controls.
  if ! answer="$(jq -ces '
    if length == 1 then .[0] else error("expected one JSON object") end
    |
    select(type == "object" and .status == true)
    | select((.statusCode | if . == null then 200 else . end) | type == "number" and . >= 200 and . < 300)
    | select(.response | type == "string" and test("[^\\s]"))
    | {answer:(.response | gsub("[\u0000-\u0008\u000b-\u001f\u007f-\u009f]";"")),
       model:(if (.model | type) == "string" then .model else "unknown" end
         | gsub("[\u0000-\u001f\u007f-\u009f]";""))}
    | select(.answer | test("[^\\s]"))
  ' "$tmp/body" 2>/dev/null)"; then
    rm -rf "$tmp"; dasterm_error "$(dasterm_t ai_invalid)" >&2; return 1
  fi
  rm -rf "$tmp"
  printf '%s\n' "$answer"
)

dasterm_ai_answer() {
  local result="$1" decorated="${2:-off}"
  if [ "$decorated" = on ]; then
    dasterm_title "$(dasterm_t ai_answer)"
    dasterm_kv "Model" "$(printf '%s' "$result" | jq -r .model)"
    printf '\n'
  fi
  if [ "$decorated" = on ]; then
    printf '%s' "$result" | jq -r .answer | dasterm_ui_text
  else
    printf '%s' "$result" | jq -r .answer
  fi
}

dasterm_ai_chat() {
  local input result candidate previous_user="" previous_answer="" failed="" retry_user=""
  dasterm_ui_banner "$(dasterm_t ai_chat_title)" "AskGPT5 · Prexzy APIs"
  dasterm_ui_text "$(dasterm_t ai_privacy)"
  dasterm_ui_text "$(dasterm_t ai_chat_help)"
  while true; do
    printf '\n%s > ' "$(dasterm_t ai_you)" >&2
    IFS= read -r input || { printf '\n'; return 0; }
    case "$input" in
      /exit|/quit|/back) return 0 ;;
      /help) dasterm_ui_text "$(dasterm_t ai_chat_help)"; continue ;;
      /clear)
        previous_user=""; previous_answer=""; failed=""; retry_user=""
        dasterm_success "$(dasterm_t ai_cleared)"; continue ;;
      /retry)
        if [ -z "$failed" ]; then dasterm_info "$(dasterm_t ai_no_retry)"; continue; fi
        candidate="$failed" ;;
      //*) input="${input#/}"; candidate="$input" ;;
      /*) dasterm_warn "$(dasterm_t ai_chat_help)"; continue ;;
      *)
        [[ "$input" =~ [^[:space:]] ]] || continue
        candidate="$input"
        if [ -n "$previous_user" ]; then
          candidate="$(printf 'Previous user:\n%s\nPrevious assistant:\n%s\nUser:\n%s' "$previous_user" "$previous_answer" "$input")"
          if [ "$(printf '%s' "$candidate" | wc -c)" -gt 4000 ]; then
            candidate="$input"
            dasterm_info "$(dasterm_t ai_context_omitted)"
          fi
        fi
        ;;
    esac
    dasterm_info "$(dasterm_t ai_wait)" >&2
    if result="$(dasterm_ai_request "$candidate")"; then
      dasterm_ai_answer "$result" on
      # Retain only the preceding successful exchange, in this process's memory.
      if [ "$input" != /retry ]; then previous_user="$input"; else previous_user="$retry_user"; fi
      previous_answer="$(printf '%s' "$result" | jq -r .answer)"
      failed=""
    else
      failed="$candidate"
      if [ "$input" != /retry ]; then retry_user="$input"; fi
      dasterm_info "$(dasterm_t ai_retry_hint)" >&2
    fi
  done
}

dasterm_ai_run() {
  local prompt result decorated=off
  case "${1:-}" in
    --help|-h)
      dasterm_title "Dasterm AI · AskGPT5"
      dasterm_ui_text "$(dasterm_t ai_usage)"
      dasterm_ui_text "$(dasterm_t ai_privacy)"
      return 0 ;;
    chat) shift; [ "$#" -eq 0 ] || { dasterm_error "$(dasterm_t ai_usage)" >&2; return 1; }; dasterm_ai_chat; return $? ;;
    --stdin) shift; [ "$#" -eq 0 ] || return 1; prompt="$(head -c 4001)" ;;
    --) shift; prompt="$*" ;;
    '')
      if [ -t 0 ]; then dasterm_ai_chat; return $?; fi
      prompt="$(head -c 4001)" ;;
    -*) dasterm_error "$(dasterm_t ai_usage)" >&2; return 1 ;;
    *) prompt="$*" ;;
  esac
  if [ -t 1 ]; then decorated=on; dasterm_info "$(dasterm_t ai_wait)" >&2; fi
  result="$(dasterm_ai_request "$prompt")" || return 1
  dasterm_ai_answer "$result" "$decorated"
}
