dasterm_doctor_check() {
  local name="$1"
  local status="$2"
  local detail="$3"
  if [ "$status" = "ok" ]; then
    printf "%b✓%b %-22s %s\n" "$D_OK" "$D_NC" "$name" "$detail"
  elif [ "$status" = "warn" ]; then
    printf "%b⚠%b %-22s %s\n" "$D_WARN" "$D_NC" "$name" "$detail"
  else
    printf "%b✗%b %-22s %s\n" "$D_ERR" "$D_NC" "$name" "$detail"
  fi
}

dasterm_doctor_dep() {
  local dep="$1"
  if dasterm_has "$dep"; then
    dasterm_doctor_check "$dep" ok "$(command -v "$dep")"
  else
    dasterm_doctor_check "$dep" warn "missing"
  fi
}

dasterm_doctor_file() {
  local name="$1"
  local path="$2"
  if [ -e "$path" ]; then
    dasterm_doctor_check "$name" ok "$path"
  else
    dasterm_doctor_check "$name" error "missing: $path"
  fi
}

dasterm_doctor_shell_block() {
  local found=0
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && grep -q "DASTERM_V2_BEGIN" "$rc" 2>/dev/null; then
      found=1
    fi
  done
  if [ "$found" -eq 1 ]; then
    dasterm_doctor_check "Shell Integration" ok "installed"
  else
    dasterm_doctor_check "Shell Integration" warn "not found in bashrc/zshrc"
  fi
}

dasterm_doctor_config() {
  if [ -f "$DASTERM_CONFIG" ]; then
    local perm
    perm="$(stat -c "%a" "$DASTERM_CONFIG" 2>/dev/null || echo unknown)"
    if [ "$perm" = "600" ]; then
      dasterm_doctor_check "Config Permission" ok "$perm"
    else
      dasterm_doctor_check "Config Permission" warn "$perm, recommended 600"
    fi
  else
    dasterm_doctor_check "Config" error "missing"
  fi
}

dasterm_doctor_cache() {
  [ -d "$DASTERM_CACHE_DIR" ] && dasterm_doctor_check "Cache Directory" ok "$DASTERM_CACHE_DIR" || dasterm_doctor_check "Cache Directory" warn "missing"
  [ -f "$DASTERM_CACHE_DIR/speedtest.json" ] && dasterm_doctor_check "Speedtest Cache" ok "available" || dasterm_doctor_check "Speedtest Cache" warn "not created yet"
}

dasterm_doctor_network() {
  if timeout 4 bash -c 'exec 3<>/dev/tcp/1.1.1.1/53' >/dev/null 2>&1; then
    dasterm_doctor_check "Network" ok "internet reachable"
  elif timeout 4 ping -c1 -W2 1.1.1.1 >/dev/null 2>&1; then
    dasterm_doctor_check "Network" ok "ping reachable"
  else
    dasterm_doctor_check "Network" warn "offline or blocked"
  fi
}

dasterm_doctor_speed_provider() {
  if dasterm_has speedtest; then
    dasterm_doctor_check "Speedtest Provider" ok "ookla speedtest"
  elif dasterm_has speedtest-cli; then
    dasterm_doctor_check "Speedtest Provider" ok "speedtest-cli"
  elif dasterm_has curl; then
    dasterm_doctor_check "Speedtest Provider" warn "curl fallback only"
  else
    dasterm_doctor_check "Speedtest Provider" error "no provider"
  fi
}

dasterm_doctor_ai_provider() {
  if dasterm_has curl && dasterm_has jq; then
    dasterm_doctor_check "AI Runtime" ok "curl + jq available"
  elif dasterm_has curl; then
    dasterm_doctor_check "AI Runtime" warn "curl available, jq missing"
  else
    dasterm_doctor_check "AI Runtime" error "curl missing"
  fi
}

dasterm_doctor_permissions() {
  if [ -w "$DASTERM_CONFIG_DIR" ] && [ -w "$DASTERM_CACHE_DIR" ]; then
    dasterm_doctor_check "User Permission" ok "config/cache writable"
  else
    dasterm_doctor_check "User Permission" warn "config/cache may not be writable"
  fi
}

dasterm_doctor_summary_score() {
  local score=100
  [ -x /usr/local/bin/dasterm ] || score=$((score-25))
  [ -f "$DASTERM_CONFIG" ] || score=$((score-20))
  dasterm_has curl || score=$((score-15))
  dasterm_has jq || score=$((score-10))
  [ -f "$DASTERM_CACHE_DIR/speedtest.json" ] || score=$((score-5))
  [ "$score" -lt 0 ] && score=0
  if [ "$score" -ge 85 ]; then
    echo "$score/100 GOOD"
  elif [ "$score" -ge 65 ]; then
    echo "$score/100 WARN"
  else
    echo "$score/100 BAD"
  fi
}

dasterm_doctor_show() {
  dasterm_theme_load
  dasterm_title "$(dasterm_t doctor_title)"
  dasterm_kv "Doctor Score" "$(dasterm_doctor_summary_score)"
  dasterm_kv "Dasterm Version" "${DASTERM_VERSION:-2.0.0}"
  dasterm_kv "Language" "${DASTERM_LANG:-id}"
  dasterm_kv "Mode" "${DASTERM_MODE:-lite}"
  dasterm_kv "Theme" "${DASTERM_THEME:-pastel}"
  echo
  dasterm_title "Files"
  dasterm_doctor_file "Binary" "/usr/local/bin/dasterm"
  dasterm_doctor_file "Library" "/usr/local/share/dasterm/lib/core.sh"
  dasterm_doctor_file "Config" "$DASTERM_CONFIG"
  dasterm_doctor_shell_block
  dasterm_doctor_config
  dasterm_doctor_cache
  dasterm_doctor_permissions
  echo
  dasterm_title "Dependencies"
  for dep in bash curl jq awk sed grep sort head tail df free ps ip ss ping timeout; do
    dasterm_doctor_dep "$dep"
  done
  dasterm_doctor_speed_provider
  dasterm_doctor_ai_provider
  echo
  dasterm_title "Connectivity"
  dasterm_doctor_network
  echo
  dasterm_title "System Signals"
  dasterm_doctor_check "OS" ok "$(dasterm_os)"
  dasterm_doctor_check "Virtualization" ok "$(dasterm_virt)"
  dasterm_doctor_check "Root Disk" ok "$(dasterm_disk_line /)"
  dasterm_doctor_check "RAM" ok "$(dasterm_ram_line)"
  dasterm_doctor_check "Failed Units" warn "$(dasterm_failed_units_count)"
  dasterm_doctor_check "Reboot Required" ok "$(dasterm_reboot_required)"
  dasterm_footer
}