dasterm_ai_memory_file() {
  echo "$DASTERM_CACHE_DIR/ai-memory.json"
}

dasterm_ai_provider_file() {
  echo "$DASTERM_CACHE_DIR/ai-provider-state.json"
}

dasterm_ai_default_provider_state() {
  cat <<'JSON'
{
  "primary": "chocomilk",
  "fallback1": "prexzy_copilot",
  "fallback2": "prexzy_zai",
  "primary_delay_count": 0
}
JSON
}

dasterm_ai_init_provider() {
  local file
  file="$(dasterm_ai_provider_file)"
  dasterm_mkdirs
  if [ ! -f "$file" ]; then
    dasterm_ai_default_provider_state > "$file"
    chmod 600 "$file"
  fi
}

dasterm_ai_provider_show() {
  dasterm_ai_init_provider
  local file
  file="$(dasterm_ai_provider_file)"
  dasterm_title "AI Provider"
  dasterm_kv "Primary" "$(jq -r '.primary' "$file" 2>/dev/null)"
  dasterm_kv "Fallback 1" "$(jq -r '.fallback1' "$file" 2>/dev/null)"
  dasterm_kv "Fallback 2" "$(jq -r '.fallback2' "$file" 2>/dev/null)"
  dasterm_kv "Primary Delay Count" "$(jq -r '.primary_delay_count' "$file" 2>/dev/null)"
  dasterm_footer
}

dasterm_ai_provider_reset() {
  dasterm_ai_default_provider_state > "$(dasterm_ai_provider_file)"
  chmod 600 "$(dasterm_ai_provider_file)"
  dasterm_success "AI provider order reset."
}

dasterm_ai_rotate_provider() {
  local file primary f1 f2
  file="$(dasterm_ai_provider_file)"
  dasterm_ai_init_provider
  primary="$(jq -r '.primary' "$file")"
  f1="$(jq -r '.fallback1' "$file")"
  f2="$(jq -r '.fallback2' "$file")"
  jq -n --arg primary "$f1" --arg fallback1 "$f2" --arg fallback2 "$primary" '{
    primary: $primary,
    fallback1: $fallback1,
    fallback2: $fallback2,
    primary_delay_count: 0
  }' > "$file"
}

dasterm_ai_delay_inc() {
  local file count
  file="$(dasterm_ai_provider_file)"
  dasterm_ai_init_provider
  count="$(jq -r '.primary_delay_count // 0' "$file")"
  count=$((count + 1))
  jq --argjson c "$count" '.primary_delay_count=$c' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  if [ "$count" -ge 3 ]; then
    dasterm_ai_rotate_provider
  fi
}

dasterm_ai_delay_reset() {
  local file
  file="$(dasterm_ai_provider_file)"
  dasterm_ai_init_provider
  jq '.primary_delay_count=0' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

dasterm_ai_memory_init() {
  local file today old
  file="$(dasterm_ai_memory_file)"
  today="$(dasterm_date)"
  dasterm_mkdirs
  if [ ! -f "$file" ]; then
    jq -n --arg date "$today" '{date:$date,summary:"",items:[]}' > "$file"
    chmod 600 "$file"
    return
  fi
  old="$(jq -r '.date // empty' "$file" 2>/dev/null)"
  if [ "$old" != "$today" ]; then
    jq -n --arg date "$today" '{date:$date,summary:"",items:[]}' > "$file"
    chmod 600 "$file"
  fi
}

dasterm_ai_memory_context() {
  local file
  dasterm_ai_memory_init
  file="$(dasterm_ai_memory_file)"
  jq -r '
    "Tanggal memori: " + (.date // "") + "\n" +
    "Ringkasan: " + (.summary // "") + "\n" +
    "Item terbaru:\n" +
    ((.items // []) | map("- Input: " + (.input // "") + "\n  Output: " + (.output // "")) | join("\n"))
  ' "$file" 2>/dev/null
}

dasterm_ai_brain_show() {
  dasterm_ai_memory_init
  local file summary count
  file="$(dasterm_ai_memory_file)"
  dasterm_title "AI Brain"
  summary="$(jq -r '.summary // empty' "$file" 2>/dev/null)"
  count="$(jq -r '.items | length' "$file" 2>/dev/null)"
  if [ -z "$summary" ] && [ "${count:-0}" -eq 0 ]; then
    dasterm_warn "$(dasterm_t ai_memory_empty)"
    return
  fi
  dasterm_kv "Date" "$(jq -r '.date // empty' "$file")"
  dasterm_kv "Items" "$count"
  if [ -n "$summary" ]; then
    echo
    dasterm_title "Summary"
    echo "$summary"
  fi
  echo
  dasterm_title "Recent Items"
  jq -r '(.items // [])[] | "Input : \(.input)\nOutput: \(.output)\n"' "$file" 2>/dev/null
  dasterm_footer
}

dasterm_ai_brain_clear() {
  local file
  file="$(dasterm_ai_memory_file)"
  jq -n --arg date "$(dasterm_date)" '{date:$date,summary:"",items:[]}' > "$file"
  chmod 600 "$file"
  dasterm_success "$(dasterm_t ai_memory_clear)"
}

dasterm_ai_system_prompt() {
  local memory="$1"
  cat <<EOF
Kamu adalah Dasterm AI, asisten terminal Linux/VPS yang membantu user memahami server, menjalankan diagnosis, memberi saran optimasi, dan membuat command aman.

ATURAN OUTPUT WAJIB:
1. Balas hanya dalam format JSON valid.
2. Jangan tulis markdown.
3. Jangan tulis teks di luar JSON.
4. Key utama wajib "hasil".
5. Key "cmd" hanya boleh ada jika permintaan user memang membutuhkan command terminal.
6. Jika tidak perlu command, jangan sertakan key "cmd".
7. Jika ada "cmd", nilainya wajib satu command saja.
8. Jangan membuat lebih dari satu command.
9. Jangan menggabungkan command dengan &&, ||, ;, pipe kompleks, subshell, backtick, redirect file, atau command chaining.
10. Command harus singkat, aman, dan sesuai permintaan user.
11. Jangan membuat command destruktif seperti rm -rf, mkfs, dd overwrite, shutdown, reboot, passwd, userdel, chown/chmod massal, iptables flush, ufw reset, atau command yang bisa merusak sistem.
12. Jika user meminta aksi berbahaya, jangan berikan cmd. Jelaskan risikonya di hasil.
13. Gunakan bahasa yang sama dengan input user.
14. Penjelasan di hasil harus mudah dibaca, ringkas, dan jelas.
15. Jangan mengarang hasil eksekusi command. Jika butuh data server, berikan command untuk dicek.
16. Jika memory tersedia, gunakan sebagai konteks.
17. Jika user meminta speedtest ulang, gunakan cmd "dasterm respeedtest".
18. Jika user meminta lihat speedtest tersimpan, gunakan cmd "dasterm speedtest".
19. Jika user meminta update Dasterm, gunakan cmd "dasterm update".
20. Jika user meminta menu, gunakan cmd "dasterm help".
21. Jika user meminta cek kesehatan server, gunakan cmd "dasterm doctor".
22. Jika user meminta cek storage, gunakan cmd "dasterm storage".
23. Jika user meminta cek network, gunakan cmd "dasterm network".
24. Jika user meminta cek service, gunakan cmd "dasterm services".
25. Jika user meminta cek keamanan, gunakan cmd "dasterm security".
26. Jika user meminta hapus memori AI, gunakan cmd "dasterm clear-brain-ai".

FORMAT TANPA COMMAND:
{"hasil":"isi jawaban"}

FORMAT DENGAN COMMAND:
{"hasil":"isi jawaban dan jelaskan command yang disarankan","cmd":"satu command"}

MEMORY HARI INI:
$memory
EOF
}

dasterm_ai_summary_prompt() {
  local data="$1"
  cat <<EOF
Ringkas percakapan Dasterm AI berikut menjadi memory pendek dan berguna untuk konteks berikutnya.

Aturan:
1. Simpan hanya hal penting.
2. Jangan simpan data sensitif.
3. Jangan simpan command berbahaya.
4. Gunakan bahasa Indonesia ringkas.
5. Maksimal 1200 karakter.
6. Fokus pada preferensi user, masalah server, keputusan, dan hasil penting.
7. Balas hanya teks ringkasan, bukan JSON.

DATA:
$data
EOF
}

dasterm_ai_provider_call() {
  local provider="$1"
  local ask="$2"
  local systemprompt="$3"
  local ask_enc sys_enc url raw combined combined_enc
  ask_enc="$(dasterm_urlencode "$ask")"
  sys_enc="$(dasterm_urlencode "$systemprompt")"
  combined="$(printf "SYSTEM PROMPT:\n%s\n\nUSER REQUEST:\n%s" "$systemprompt" "$ask")"
  combined_enc="$(dasterm_urlencode "$combined")"
  case "$provider" in
    chocomilk)
      url="https://chocomilk.amira.us.kg/v1/llm/chatgpt/completions?ask=${ask_enc}&systempromt=${sys_enc}"
      raw="$(timeout 10 curl -fsSL -H "Accept: application/json" "$url" 2>/dev/null || true)"
      [ -n "$raw" ] || return 1
      echo "$raw" | jq -r '.data.answer // empty' 2>/dev/null
      ;;
    prexzy_copilot)
      url="https://apis.prexzyvilla.site/ai/copilot?text=${combined_enc}"
      raw="$(timeout 10 curl -fsSL -H "Accept: application/json" "$url" 2>/dev/null || true)"
      [ -n "$raw" ] || return 1
      echo "$raw" | jq -r '.response // empty' 2>/dev/null
      ;;
    prexzy_zai)
      url="https://apis.prexzyvilla.site/ai/zai?text=${combined_enc}"
      raw="$(timeout 10 curl -fsSL -H "Accept: application/json" "$url" 2>/dev/null || true)"
      [ -n "$raw" ] || return 1
      echo "$raw" | jq -r '.response // empty' 2>/dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

dasterm_ai_call() {
  local ask="$1"
  local systemprompt="$2"
  local file primary f1 f2 out
  dasterm_ai_init_provider
  file="$(dasterm_ai_provider_file)"
  primary="$(jq -r '.primary' "$file")"
  f1="$(jq -r '.fallback1' "$file")"
  f2="$(jq -r '.fallback2' "$file")"
  out="$(dasterm_ai_provider_call "$primary" "$ask" "$systemprompt" || true)"
  if [ -n "$out" ]; then
    dasterm_ai_delay_reset
    echo "$out"
    return 0
  fi
  dasterm_ai_delay_inc
  out="$(dasterm_ai_provider_call "$f1" "$ask" "$systemprompt" || true)"
  if [ -n "$out" ]; then
    echo "$out"
    return 0
  fi
  out="$(dasterm_ai_provider_call "$f2" "$ask" "$systemprompt" || true)"
  if [ -n "$out" ]; then
    echo "$out"
    return 0
  fi
  return 1
}

dasterm_ai_extract_json() {
  local text="$1"
  if echo "$text" | jq -e . >/dev/null 2>&1; then
    echo "$text"
    return 0
  fi
  echo "$text" | sed -n '/{/,/}/p' | sed '1s/^[^{]*//' | sed '$s/[^}]*$//' | jq -c . 2>/dev/null || return 1
}

dasterm_ai_command_safe() {
  local cmd="$1"
  [ -n "$cmd" ] || return 1
  echo "$cmd" | grep -qE '(&&|\|\||;|\||`|\$\(|>|<|\n)' && return 1
  echo "$cmd" | grep -qiE '(^| )(rm|mkfs|dd|shutdown|reboot|poweroff|halt|passwd|userdel|groupdel|chown|chmod|iptables|nft|ufw reset|curl|wget|bash|sh|sudo|su)( |$)' && return 1
  case "$cmd" in
    "dasterm help"|"dasterm status"|"dasterm lite"|"dasterm full"|"dasterm speedtest"|"dasterm respeedtest"|"dasterm network"|"dasterm storage"|"dasterm services"|"dasterm security"|"dasterm doctor"|"dasterm update"|"dasterm version"|"dasterm about"|"dasterm brain-ai"|"dasterm clear-brain-ai"|"dasterm ai-provider"|"dasterm ai-test")
      return 0
      ;;
    "/help"|"/status"|"/lite"|"/full"|"/speedtest"|"/respeedtest"|"/network"|"/storage"|"/services"|"/security"|"/doctor"|"/update"|"/version"|"/about"|"/brain-ai"|"/clear-brain-ai"|"/ai-provider"|"/ai-test")
      return 0
      ;;
    "speedtest")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

dasterm_ai_command_run() {
  local cmd="$1"
  case "$cmd" in
    "/help") dasterm help ;;
    "/status") dasterm status ;;
    "/lite") dasterm lite ;;
    "/full") dasterm full ;;
    "/speedtest") dasterm speedtest ;;
    "/respeedtest") dasterm respeedtest ;;
    "/network") dasterm network ;;
    "/storage") dasterm storage ;;
    "/services") dasterm services ;;
    "/security") dasterm security ;;
    "/doctor") dasterm doctor ;;
    "/update") dasterm update ;;
    "/version") dasterm version ;;
    "/about") dasterm about ;;
    "/brain-ai") dasterm brain-ai ;;
    "/clear-brain-ai") dasterm clear-brain-ai ;;
    "/ai-provider") dasterm ai-provider ;;
    "/ai-test") dasterm ai-test ;;
    "speedtest") dasterm respeedtest ;;
    *) $cmd ;;
  esac
}

dasterm_ai_memory_add() {
  local input="$1"
  local output="$2"
  local file count
  dasterm_ai_memory_init
  file="$(dasterm_ai_memory_file)"
  jq --arg input "$input" --arg output "$output" '.items += [{input:$input,output:$output}]' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  count="$(jq -r '.items | length' "$file" 2>/dev/null || echo 0)"
  if [ "$count" -gt 5 ]; then
    dasterm_ai_memory_summarize
  fi
}

dasterm_ai_memory_summarize() {
  local file data prompt summary old
  file="$(dasterm_ai_memory_file)"
  data="$(jq -r '(.summary // "") + "\n" + ((.items // []) | map("Input: " + .input + "\nOutput: " + .output) | join("\n\n"))' "$file" 2>/dev/null)"
  prompt="$(dasterm_ai_summary_prompt "$data")"
  summary="$(dasterm_ai_call "$prompt" "Kamu adalah peringkas memori Dasterm AI. Balas hanya ringkasan singkat." || true)"
  [ -n "$summary" ] || summary="$(echo "$data" | tail -c 1200)"
  old="$(jq -r '.date // empty' "$file")"
  jq -n --arg date "$old" --arg summary "$summary" '{date:$date,summary:$summary,items:[]}' > "$file"
  chmod 600 "$file"
}

dasterm_ai_ask() {
  local input="$*"
  if [ -z "${input// }" ]; then
    dasterm_warn "$(dasterm_t ai_empty)"
    return 1
  fi
  if ! dasterm_has curl || ! dasterm_has jq; then
    dasterm_error "AI needs curl and jq."
    return 1
  fi
  local memory systemprompt answer json hasil cmd
  memory="$(dasterm_ai_memory_context)"
  systemprompt="$(dasterm_ai_system_prompt "$memory")"
  dasterm_title "$(dasterm_t ai_title)"
  answer="$(dasterm_ai_call "$input" "$systemprompt" || true)"
  if [ -z "$answer" ]; then
    dasterm_error "All AI providers failed."
    return 1
  fi
  json="$(dasterm_ai_extract_json "$answer" || true)"
  if [ -z "$json" ]; then
    json="$(jq -n --arg hasil "$answer" '{hasil:$hasil}')"
  fi
  hasil="$(echo "$json" | jq -r '.hasil // empty' 2>/dev/null)"
  cmd="$(echo "$json" | jq -r '.cmd // empty' 2>/dev/null)"
  [ -n "$hasil" ] || hasil="$answer"
  echo "$hasil"
  dasterm_ai_memory_add "$input" "$hasil"
  if declare -F dasterm_telemetry_send >/dev/null 2>&1; then
    dasterm_telemetry_send ai
  fi
  if [ -n "$cmd" ]; then
    echo
    if ! dasterm_ai_command_safe "$cmd"; then
      dasterm_warn "AI suggested a command, but Dasterm blocked it because it is not in the safe whitelist."
      dasterm_kv "Blocked CMD" "$cmd"
      return 0
    fi
    dasterm_info "$(dasterm_t ai_cmd_suggest):"
    echo "$cmd"
    echo
    if dasterm_confirm "$(dasterm_t ai_run_cmd)"; then
      dasterm_ai_command_run "$cmd"
    else
      dasterm_warn "$(dasterm_t ai_cancel)"
    fi
  fi
}

dasterm_ai_test() {
  local memory systemprompt p out
  memory="$(dasterm_ai_memory_context)"
  systemprompt="$(dasterm_ai_system_prompt "$memory")"
  dasterm_title "AI Provider Test"
  for p in chocomilk prexzy_copilot prexzy_zai; do
    out="$(dasterm_ai_provider_call "$p" "Balas JSON {\"hasil\":\"ok\"}" "$systemprompt" || true)"
    if [ -n "$out" ]; then
      dasterm_success "$p OK"
    else
      dasterm_error "$p FAILED"
    fi
  done
}