dasterm_logo_lite() {
  dasterm_theme_load
  printf "%b\n" "${D_C2}╭────────────────────────────╮${D_NC}"
  printf "%b\n" "${D_C2}│${D_NC} ${D_BOLD}${D_C1}dasterm v2${D_NC} ${D_C3}by aka${D_NC}        ${D_C2}│${D_NC}"
  printf "%b\n" "${D_C2}╰────────────────────────────╯${D_NC}"
}

dasterm_logo_full() {
  if dasterm_has fastfetch; then
    fastfetch --logo-type auto --structure Title:OS:Kernel:Uptime:Shell:Terminal:CPU:Memory:Disk 2>/dev/null && return 0
  fi
  if dasterm_has neofetch; then
    neofetch --ascii --disable packages resolution de wm theme icons terminal shell 2>/dev/null && return 0
  fi
  dasterm_theme_load
  printf "%b\n" "${D_C2}██████╗  █████╗ ███████╗████████╗███████╗██████╗ ███╗   ███╗${D_NC}"
  printf "%b\n" "${D_C2}██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║${D_NC}"
  printf "%b\n" "${D_C2}██║  ██║███████║███████╗   ██║   █████╗  ██████╔╝██╔████╔██║${D_NC}"
  printf "%b\n" "${D_C2}██║  ██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║${D_NC}"
  printf "%b\n" "${D_C2}██████╔╝██║  ██║███████║   ██║   ███████╗██║  ██║██║ ╚═╝ ██║${D_NC}"
  printf "%b\n" "${D_C2}╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝${D_NC}"
}

dasterm_box_line() {
  local char="$1"
  local width="${2:-58}"
  local i
  local out=""
  for ((i=0; i<width; i++)); do
    out="${out}${char}"
  done
  echo "$out"
}

dasterm_section() {
  dasterm_theme_load
  local title="$1"
  printf "\n%b%s%b\n" "$D_C2" "╭$(dasterm_box_line "─" 58)╮" "$D_NC"
  printf "%b│%b %b%-56s%b %b│%b\n" "$D_C2" "$D_NC" "$D_BOLD$D_C1" "$title" "$D_NC" "$D_C2" "$D_NC"
  printf "%b%s%b\n" "$D_C2" "╰$(dasterm_box_line "─" 58)╯" "$D_NC"
}

dasterm_row() {
  dasterm_kv "$@"
}

dasterm_health_score() {
  local diskp ramp load1 cores
  diskp="$(df -P / 2>/dev/null | awk 'NR==2{gsub("%","",$5);print $5+0}' || echo 0)"
  ramp="$(free 2>/dev/null | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}' || echo 0)"
  load1="$(awk '{print $1}' /proc/loadavg 2>/dev/null || echo 0)"
  cores="$(nproc 2>/dev/null || echo 1)"
  awk -v d="$diskp" -v r="$ramp" -v l="$load1" -v c="$cores" 'BEGIN{
    s=100;
    if(d>=95)s-=35; else if(d>=85)s-=20; else if(d>=75)s-=10;
    if(r>=95)s-=30; else if(r>=85)s-=18; else if(r>=75)s-=8;
    if(c<1)c=1;
    if(l>=c*2)s-=25; else if(l>=c)s-=12;
    if(s<0)s=0;
    if(s>=85) st="GOOD"; else if(s>=65) st="WARN"; else st="BAD";
    printf "%d/100 %s", s, st;
  }'
}

dasterm_render_speed_summary() {
  local file="$DASTERM_CACHE_DIR/speedtest.json"
  [ -f "$file" ] || {
    dasterm_row "$(dasterm_t speedtest)" "$(dasterm_t speed_saved_empty)"
    return
  }
  local down up ping tested provider region
  down="$(jq -r '.download.mbps // empty' "$file" 2>/dev/null)"
  up="$(jq -r '.upload.mbps // empty' "$file" 2>/dev/null)"
  ping="$(jq -r '.ping.ms // empty' "$file" 2>/dev/null)"
  tested="$(jq -r '.tested_at // empty' "$file" 2>/dev/null)"
  provider="$(jq -r '.provider // empty' "$file" 2>/dev/null)"
  region="$(jq -r '.region // empty' "$file" 2>/dev/null)"
  [ -n "$provider" ] && dasterm_row "Provider" "$provider"
  [ -n "$region" ] && dasterm_row "Region" "$region"
  [ -n "$ping" ] && dasterm_row "Ping" "${ping} ms"
  [ -n "$down" ] && dasterm_row "Download" "${down} Mbps"
  [ -n "$up" ] && dasterm_row "Upload" "${up} Mbps"
  [ -n "$tested" ] && dasterm_row "Tested At" "$tested"
}

dasterm_render_lite() {
  dasterm_render_side_by_side "lite"
}

dasterm_render_full() {
  dasterm_render_side_by_side "full"
}

dasterm_render_side_by_side() {
  local mode="$1" path
  if [ "${DASTERM_LOGO:-off}" = on ]; then
    if [ "$mode" = full ]; then dasterm_logo_full; else dasterm_logo_lite; fi
  fi
  dasterm_ui_banner "D A S T E R M" "${DASTERM_VERSION:-2.0.2} · $mode · $(dasterm_os)"
  dasterm_kv "User@Host" "${DASTERM_USERHOST:-$(whoami)@$(hostname)}"
  dasterm_kv "Health" "$(dasterm_health_score)"
  dasterm_kv "Uptime" "$(uptime -p 2>/dev/null | sed 's/^up //' || echo N/A)"
  printf '\n'
  dasterm_title "$(dasterm_t system)"
  dasterm_kv "CPU" "$(dasterm_cpu_model)"
  dasterm_kv "Load" "$(dasterm_load_line)"
  dasterm_kv "RAM" "$(dasterm_ram_line)"
  dasterm_kv "RAM usage" "$(dasterm_bar "$(dasterm_ram_percent)" 12)"
  dasterm_kv "Disk /" "$(dasterm_disk_line /)"
  dasterm_kv "Disk usage" "$(dasterm_bar "$(dasterm_disk_percent /)" 12)"
  if [ "$mode" = full ]; then
    dasterm_kv "Kernel" "$(uname -r 2>/dev/null || echo N/A)"
    dasterm_kv "Architecture" "$(uname -m 2>/dev/null || echo N/A)"
    dasterm_kv "Virtualization" "$(dasterm_virt)"
    dasterm_kv "CPU Cores" "$(nproc 2>/dev/null || echo N/A)"
    dasterm_kv "CPU Flags" "$(dasterm_cpu_flags)"
    dasterm_kv "Boot Time" "$(dasterm_boot_time)"
    dasterm_kv "Swap" "$(dasterm_swap_line)"
    dasterm_kv "GPU" "$(dasterm_gpu)"
    dasterm_kv "Processes" "$(ps -e 2>/dev/null | awk 'NR>1 {n++} END {print n+0}')"
    dasterm_kv "Users" "$(who 2>/dev/null | wc -l | awk '{print $1}')"
    dasterm_kv "Packages" "$(dasterm_pkg_count)"
    while IFS= read -r path; do
      [ "$path" = / ] && continue
      dasterm_kv "Disk $path" "$(dasterm_disk_line "$path")"
    done < <(dasterm_storage_paths)
  fi
  printf '\n'
  dasterm_title "$(dasterm_t network)"
  dasterm_kv "Private IP" "$(dasterm_private_ip)"
  if [ "$mode" = full ]; then
    dasterm_kv "Public IP" "$(dasterm_public_ip_cached)"
    dasterm_kv "Interface" "$(dasterm_iface)"
    dasterm_kv "Gateway" "$(dasterm_gateway)"
    dasterm_kv "DNS" "$(dasterm_dns)"
    dasterm_kv "Open Ports" "$(dasterm_open_ports)"
  fi
  dasterm_render_speed_summary || true
  if [ "$mode" = full ]; then
    printf '\n'
    dasterm_title "$(dasterm_t services)"
    dasterm_kv "Docker" "$(dasterm_services_docker_summary)"
    dasterm_kv "PM2" "$(dasterm_services_pm2_summary)"
    dasterm_kv "Nginx" "$(dasterm_services_nginx_summary)"
    dasterm_kv "Apache" "$(dasterm_services_apache_summary)"
    dasterm_kv "Cloudflared" "$(dasterm_services_cloudflared_summary)"
    dasterm_kv "SSH" "$(dasterm_service_state ssh)"
    dasterm_kv "Cron" "$(dasterm_service_state cron)"
    dasterm_kv "Database" "$(dasterm_services_database_summary)"
    dasterm_kv "Failed Units" "$(dasterm_failed_units_count)"
    printf '\n'
    dasterm_title "$(dasterm_t security)"
    dasterm_kv "Firewall" "$(dasterm_security_firewall)"
    dasterm_kv "SSH root login" "$(dasterm_security_ssh_value PermitRootLogin)"
    dasterm_kv "Reboot required" "$(dasterm_reboot_required)"
  fi
  printf '\n'
  dasterm_footer
}

dasterm_render_dashboard() {
  dasterm_load_config
  dasterm_theme_load
  local mode="${1:-${DASTERM_MODE:-lite}}"
  dasterm_render_side_by_side "$mode"
}
