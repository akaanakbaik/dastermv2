dasterm_telemetry_endpoint() {
  echo "${DASTERM_TELEMETRY_ENDPOINT:-}"
}

dasterm_telemetry_machine_hash() {
  local seed id
  seed="dasterm-v2-anonymous"
  if [ -f /etc/machine-id ]; then
    id="$(cat /etc/machine-id 2>/dev/null)"
  else
    id="$(hostname 2>/dev/null || echo unknown)-$(uname -m 2>/dev/null || echo unknown)"
  fi
  printf "%s:%s" "$seed" "$id" | sha256sum 2>/dev/null | awk '{print $1}'
}

dasterm_telemetry_payload() {
  local event="$1"
  jq -n \
    --arg event "$event" \
    --arg version "${DASTERM_VERSION:-2.0.0}" \
    --arg distro "$(dasterm_os_id)" \
    --arg distro_version "$(dasterm_os_version)" \
    --arg arch "$(uname -m 2>/dev/null || echo unknown)" \
    --arg virt "$(dasterm_virt)" \
    --arg lang "${DASTERM_LANG:-id}" \
    --arg mode "${DASTERM_MODE:-lite}" \
    --arg machine "$(dasterm_telemetry_machine_hash)" \
    --arg date "$(dasterm_date)" \
    '{
      event:$event,
      version:$version,
      distro:$distro,
      distro_version:$distro_version,
      arch:$arch,
      virt:$virt,
      lang:$lang,
      mode:$mode,
      machine_hash:$machine,
      date:$date
    }'
}

dasterm_telemetry_send() {
  local event="$1"
  [ "${DASTERM_TELEMETRY:-off}" = "on" ] || return 0
  local endpoint
  endpoint="$(dasterm_telemetry_endpoint)"
  [ -n "$endpoint" ] || return 0
  dasterm_has curl || return 0
  dasterm_has jq || return 0
  dasterm_telemetry_payload "$event" | timeout 5 curl -fsSL -X POST "$endpoint" -H "Content-Type: application/json" --data-binary @- >/dev/null 2>&1 || true
}

dasterm_telemetry_badge_notes() {
  cat <<'EOF'
Telemetry is optional and disabled by default.
Collected when enabled:
- Event type: install, run, update
- Dasterm version
- Linux distro and version
- CPU architecture
- Virtualization type
- Language and dashboard mode
- Anonymous machine hash

Never intentionally collected:
- Username
- Hostname
- Personal files
- Commands
- Process list
- IP address as stored data
- Shell history
EOF
}