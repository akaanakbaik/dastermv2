dasterm_speedtest_file() {
  echo "$DASTERM_CACHE_DIR/speedtest.json"
}

dasterm_speed_unit_to_bps() {
  local value="$1"
  local unit="$2"
  awk -v v="$value" -v u="$unit" 'BEGIN{
    unit=tolower(u);
    gsub(/\/sec/,"/s",unit);
    if(unit=="bit/s" || unit=="bps") m=1;
    else if(unit=="kbit/s" || unit=="kbps") m=1000;
    else if(unit=="mbit/s" || unit=="mbps") m=1000000;
    else if(unit=="gbit/s" || unit=="gbps") m=1000000000;
    else if(unit=="tbit/s" || unit=="tbps") m=1000000000000;
    else if(unit=="kbyte/s" || unit=="kb/s") m=8000;
    else if(unit=="mbyte/s" || unit=="mb/s") m=8000000;
    else if(unit=="gbyte/s" || unit=="gb/s") m=8000000000;
    else m=1000000;
    printf "%.0f", v*m;
  }'
}

dasterm_speed_calc_json() {
  local down_bps="$1"
  local up_bps="$2"
  local ping="$3"
  local jitter="$4"
  local loss="$5"
  local provider="$6"
  local region="$7"
  local server="$8"
  local source="$9"
  awk -v d="$down_bps" -v u="$up_bps" -v p="$ping" -v j="$jitter" -v l="$loss" -v provider="$provider" -v region="$region" -v server="$server" -v source="$source" -v tested="$(dasterm_now)" 'BEGIN{
    d_mbps=d/1000000;
    u_mbps=u/1000000;
    d_MBps=d_mbps/8;
    u_MBps=u_mbps/8;
    d_gbps=d_mbps/1000;
    u_gbps=u_mbps/1000;
    d_GBps=d_MBps/1000;
    u_GBps=u_MBps/1000;
    printf "{";
    printf "\"tested_at\":\"%s\",", tested;
    printf "\"source\":\"%s\",", source;
    printf "\"provider\":\"%s\",", provider;
    printf "\"region\":\"%s\",", region;
    printf "\"server\":\"%s\",", server;
    printf "\"ping\":{\"ms\":\"%.2f\",\"jitter_ms\":\"%.2f\",\"packet_loss\":\"%s\"},", p+0, j+0, l;
    printf "\"download\":{\"bps\":\"%.0f\",\"mbps\":\"%.2f\",\"MBps\":\"%.2f\",\"gbps\":\"%.3f\",\"GBps\":\"%.3f\"},", d, d_mbps, d_MBps, d_gbps, d_GBps;
    printf "\"upload\":{\"bps\":\"%.0f\",\"mbps\":\"%.2f\",\"MBps\":\"%.2f\",\"gbps\":\"%.3f\",\"GBps\":\"%.3f\"},", u, u_mbps, u_MBps, u_gbps, u_GBps;
    printf "\"formula\":{\"MBps\":\"Mbps / 8\",\"Gbps\":\"Mbps / 1000\",\"GBps\":\"Mbps / 8000\"}";
    printf "}\n";
  }'
}

dasterm_speedtest_ookla() {
  local raw down up ping jitter loss provider region server
  raw="$(timeout 180 speedtest --accept-license --accept-gdpr --format=json 2>/dev/null || true)"
  [ -n "$raw" ] || return 1
  echo "$raw" | jq -e . >/dev/null 2>&1 || return 1
  down="$(echo "$raw" | jq -r '.download.bandwidth // 0' | awk '{printf "%.0f", $1*8}')"
  up="$(echo "$raw" | jq -r '.upload.bandwidth // 0' | awk '{printf "%.0f", $1*8}')"
  ping="$(echo "$raw" | jq -r '.ping.latency // 0')"
  jitter="$(echo "$raw" | jq -r '.ping.jitter // 0')"
  loss="$(echo "$raw" | jq -r '.packetLoss // 0')"
  provider="$(echo "$raw" | jq -r '.isp // empty')"
  region="$(echo "$raw" | jq -r '.server.location // empty')"
  server="$(echo "$raw" | jq -r '.server.name // empty')"
  [ "$down" != "0" ] || return 1
  dasterm_speed_calc_json "$down" "$up" "$ping" "$jitter" "$loss" "$provider" "$region" "$server" "ookla-speedtest"
}

dasterm_speedtest_cli_json_cmd() {
  local cmd="$1"
  local raw down up ping provider region server
  raw="$(timeout 180 "$cmd" --json 2>/dev/null || true)"
  [ -n "$raw" ] || return 1
  echo "$raw" | jq -e . >/dev/null 2>&1 || return 1
  down="$(echo "$raw" | jq -r '.download // 0')"
  up="$(echo "$raw" | jq -r '.upload // 0')"
  ping="$(echo "$raw" | jq -r '.ping // 0')"
  provider="$(echo "$raw" | jq -r '.client.isp // empty')"
  region="$(echo "$raw" | jq -r '.server.country // .server.name // empty')"
  server="$(echo "$raw" | jq -r '.server.sponsor // empty')"
  [ "$down" != "0" ] || return 1
  dasterm_speed_calc_json "$down" "$up" "$ping" "0" "unknown" "$provider" "$region" "$server" "${cmd}-json"
}

dasterm_speedtest_text_cmd() {
  local cmd="$1"
  local raw down_value down_unit up_value up_unit down up ping provider region server hosted_line
  raw="$(timeout 180 "$cmd" 2>/dev/null || true)"
  [ -n "$raw" ] || return 1

  down_value="$(printf "%s\n" "$raw" | awk -F: '/Download:/ {gsub(/^[ \t]+/,"",$2); split($2,a," "); print a[1]; exit}')"
  down_unit="$(printf "%s\n" "$raw" | awk -F: '/Download:/ {gsub(/^[ \t]+/,"",$2); split($2,a," "); print a[2]; exit}')"
  up_value="$(printf "%s\n" "$raw" | awk -F: '/Upload:/ {gsub(/^[ \t]+/,"",$2); split($2,a," "); print a[1]; exit}')"
  up_unit="$(printf "%s\n" "$raw" | awk -F: '/Upload:/ {gsub(/^[ \t]+/,"",$2); split($2,a," "); print a[2]; exit}')"

  [ -n "$down_value" ] || return 1
  [ -n "$up_value" ] || up_value="0"
  [ -n "$down_unit" ] || down_unit="Mbit/s"
  [ -n "$up_unit" ] || up_unit="Mbit/s"

  down="$(dasterm_speed_unit_to_bps "$down_value" "$down_unit")"
  up="$(dasterm_speed_unit_to_bps "$up_value" "$up_unit")"

  provider="$(printf "%s\n" "$raw" | awk '/^Testing from / {sub(/^Testing from /,""); sub(/ \(.*/,""); print; exit}')"
  hosted_line="$(printf "%s\n" "$raw" | awk '/^Hosted by / {print; exit}')"
  server="$(printf "%s\n" "$hosted_line" | awk '{sub(/^Hosted by /,""); sub(/ \(.*/,""); print}')"
  region="$(printf "%s\n" "$hosted_line" | sed -n 's/.*(\(.*\)) \[.*/\1/p')"
  ping="$(printf "%s\n" "$hosted_line" | awk -F']:' '{print $2}' | awk '{print $1}')"

  [ -n "$provider" ] || provider=""
  [ -n "$server" ] || server=""
  [ -n "$region" ] || region=""
  [ -n "$ping" ] || ping="0"

  [ "$down" != "0" ] || return 1
  dasterm_speed_calc_json "$down" "$up" "$ping" "0" "unknown" "$provider" "$region" "$server" "${cmd}-text"
}

dasterm_speedtest_curl_fallback() {
  local url bytes start end elapsed bps
  url="https://speed.cloudflare.com/__down?bytes=25000000"
  start="$(date +%s%N)"
  bytes="$(timeout 60 curl -Lfs "$url" -o /dev/null -w '%{size_download}' 2>/dev/null || echo 0)"
  end="$(date +%s%N)"
  elapsed="$(awk -v s="$start" -v e="$end" 'BEGIN{printf "%.6f", (e-s)/1000000000}')"
  bps="$(awk -v b="$bytes" -v t="$elapsed" 'BEGIN{if(t>0) printf "%.0f", (b*8)/t; else print 0}')"
  [ "$bps" != "0" ] || return 1
  dasterm_speed_calc_json "$bps" "0" "$(dasterm_ping_ms 1.1.1.1)" "0" "unknown" "" "Cloudflare fallback" "Cloudflare" "curl-fallback"
}

dasterm_speedtest_run() {
  local quiet="${1:-}"
  local file json
  file="$(dasterm_speedtest_file)"
  dasterm_mkdirs
  [ "$quiet" = "--quiet" ] || dasterm_info "$(dasterm_t speed_running)"

  json=""

  if dasterm_has speedtest && dasterm_has jq; then
    json="$(dasterm_speedtest_ookla || true)"
  fi

  if [ -z "$json" ] && dasterm_has speedtest-cli && dasterm_has jq; then
    json="$(dasterm_speedtest_cli_json_cmd speedtest-cli || true)"
  fi

  if [ -z "$json" ] && dasterm_has speedtest && dasterm_has jq; then
    json="$(dasterm_speedtest_cli_json_cmd speedtest || true)"
  fi

  if [ -z "$json" ] && dasterm_has speedtest; then
    json="$(dasterm_speedtest_text_cmd speedtest || true)"
  fi

  if [ -z "$json" ] && dasterm_has speedtest-cli; then
    json="$(dasterm_speedtest_text_cmd speedtest-cli || true)"
  fi

  if [ -z "$json" ] && dasterm_has curl; then
    json="$(dasterm_speedtest_curl_fallback || true)"
  fi

  if [ -z "$json" ]; then
    dasterm_error "Speedtest failed. Install speedtest, speedtest-cli, jq, or curl."
    return 1
  fi

  printf "%s\n" "$json" | jq . > "$file" 2>/dev/null || printf "%s\n" "$json" > "$file"
  chmod 600 "$file"

  if [ "$quiet" != "--quiet" ]; then
    dasterm_success "$(dasterm_t speed_saved)"
    dasterm_speedtest_show
  fi
}

dasterm_speedtest_show() {
  local file
  file="$(dasterm_speedtest_file)"

  if [ ! -f "$file" ]; then
    dasterm_warn "$(dasterm_t speed_saved_empty)"
    return 0
  fi

  local provider region server source tested ping jitter loss d1 d2 d3 d4 u1 u2 u3 u4 formula1 formula2 formula3
  provider="$(jq -r '.provider // empty' "$file" 2>/dev/null)"
  region="$(jq -r '.region // empty' "$file" 2>/dev/null)"
  server="$(jq -r '.server // empty' "$file" 2>/dev/null)"
  source="$(jq -r '.source // empty' "$file" 2>/dev/null)"
  tested="$(jq -r '.tested_at // empty' "$file" 2>/dev/null)"
  ping="$(jq -r '.ping.ms // empty' "$file" 2>/dev/null)"
  jitter="$(jq -r '.ping.jitter_ms // empty' "$file" 2>/dev/null)"
  loss="$(jq -r '.ping.packet_loss // empty' "$file" 2>/dev/null)"
  d1="$(jq -r '.download.mbps // empty' "$file" 2>/dev/null)"
  d2="$(jq -r '.download.MBps // empty' "$file" 2>/dev/null)"
  d3="$(jq -r '.download.gbps // empty' "$file" 2>/dev/null)"
  d4="$(jq -r '.download.GBps // empty' "$file" 2>/dev/null)"
  u1="$(jq -r '.upload.mbps // empty' "$file" 2>/dev/null)"
  u2="$(jq -r '.upload.MBps // empty' "$file" 2>/dev/null)"
  u3="$(jq -r '.upload.gbps // empty' "$file" 2>/dev/null)"
  u4="$(jq -r '.upload.GBps // empty' "$file" 2>/dev/null)"
  formula1="$(jq -r '.formula.MBps // "Mbps / 8"' "$file" 2>/dev/null)"
  formula2="$(jq -r '.formula.Gbps // "Mbps / 1000"' "$file" 2>/dev/null)"
  formula3="$(jq -r '.formula.GBps // "Mbps / 8000"' "$file" 2>/dev/null)"

  dasterm_title "$(dasterm_t speedtest)"
  [ -n "$provider" ] && dasterm_kv "Provider" "$provider"
  [ -n "$region" ] && dasterm_kv "Region" "$region"
  [ -n "$server" ] && dasterm_kv "Server" "$server"
  [ -n "$source" ] && dasterm_kv "Source" "$source"
  [ -n "$ping" ] && dasterm_kv "Ping" "${ping} ms"
  [ -n "$jitter" ] && dasterm_kv "Jitter" "${jitter} ms"
  [ -n "$loss" ] && dasterm_kv "Packet Loss" "$loss"
  dasterm_kv "Download" "${d1} Mbps | ${d2} MB/s | ${d3} Gbps | ${d4} GB/s"
  dasterm_kv "Upload" "${u1} Mbps | ${u2} MB/s | ${u3} Gbps | ${u4} GB/s"
  dasterm_kv "Formula MB/s" "$formula1"
  dasterm_kv "Formula Gbps" "$formula2"
  dasterm_kv "Formula GB/s" "$formula3"
  [ -n "$tested" ] && dasterm_kv "Tested At" "$tested"
  dasterm_footer
}