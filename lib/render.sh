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
  printf "%${width}s" "" | tr " " "$char"
}

dasterm_section() {
  dasterm_theme_load
  local title="$1"
  printf "\n%b%s%b\n" "$D_C2" "╭$(dasterm_box_line "─" 58)╮" "$D_NC"
  printf "%b│%b %b%-56s%b %b│%b\n" "$D_C2" "$D_NC" "$D_BOLD$D_C1" "$title" "$D_NC" "$D_C2" "$D_NC"
  printf "%b%s%b\n" "$D_C2" "╰$(dasterm_box_line "─" 58)╯" "$D_NC"
}

dasterm_row() {
  dasterm_theme_load
  local key="$1"
  local value="$2"
  printf "%b%-20s%b : %s\n" "$D_C1" "$key" "$D_NC" "$value"
}

dasterm_health_score() {
  local score=100
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
  clear 2>/dev/null || true
  dasterm_logo_lite
  dasterm_section "$(dasterm_t dashboard_title)"
  dasterm_row "User@Host" "${DASTERM_USERHOST:-$(whoami)@$(hostname)}"
  dasterm_row "OS" "$(dasterm_os)"
  dasterm_row "Kernel" "$(uname -r 2>/dev/null || echo N/A)"
  dasterm_row "Uptime" "$(uptime -p 2>/dev/null | sed 's/^up //' || echo N/A)"
  dasterm_row "Health" "$(dasterm_health_score)"
  dasterm_row "RAM" "$(dasterm_ram_line)"
  dasterm_row "Disk /" "$(dasterm_disk_line /)"
  dasterm_row "IP" "$(dasterm_private_ip)"
  dasterm_row "Load" "$(dasterm_load_line)"
  dasterm_render_speed_summary
  dasterm_footer
}

dasterm_render_full() {
  clear 2>/dev/null || true
  dasterm_logo_full
  dasterm_section "$(dasterm_t system)"
  dasterm_row "User@Host" "${DASTERM_USERHOST:-$(whoami)@$(hostname)}"
  dasterm_row "OS" "$(dasterm_os)"
  dasterm_row "Kernel" "$(uname -r 2>/dev/null || echo N/A)"
  dasterm_row "Architecture" "$(uname -m 2>/dev/null || echo N/A)"
  dasterm_row "Virtualization" "$(dasterm_virt)"
  dasterm_row "Boot Time" "$(dasterm_boot_time)"
  dasterm_row "Uptime" "$(uptime -p 2>/dev/null | sed 's/^up //' || echo N/A)"
  dasterm_row "Load Average" "$(dasterm_load_line)"
  dasterm_row "Health" "$(dasterm_health_score)"
  dasterm_row "CPU Model" "$(dasterm_cpu_model)"
  dasterm_row "CPU Cores" "$(nproc 2>/dev/null || echo N/A)"
  dasterm_row "CPU Flags" "$(dasterm_cpu_flags)"
  dasterm_row "RAM" "$(dasterm_ram_line)"
  dasterm_row "Swap" "$(dasterm_swap_line)"
  dasterm_row "Disk Root" "$(dasterm_disk_line /)"
  [ -d /datas ] && dasterm_row "Disk /datas" "$(dasterm_disk_line /datas)"
  dasterm_row "GPU" "$(dasterm_gpu)"
  dasterm_row "Processes" "$(ps -e --no-headers 2>/dev/null | wc -l | awk '{print $1}' || echo N/A)"
  dasterm_row "Users" "$(who 2>/dev/null | wc -l | awk '{print $1}' || echo N/A)"
  dasterm_section "$(dasterm_t network)"
  dasterm_row "Private IP" "$(dasterm_private_ip)"
  dasterm_row "Public IP" "$(dasterm_public_ip_cached)"
  dasterm_row "Gateway" "$(dasterm_gateway)"
  dasterm_row "DNS" "$(dasterm_dns)"
  dasterm_render_speed_summary
  dasterm_section "$(dasterm_t services)"
  dasterm_row "Docker" "$(dasterm_service_state docker)"
  dasterm_row "Nginx" "$(dasterm_service_state nginx)"
  dasterm_row "Apache" "$(dasterm_service_state apache2)"
  dasterm_row "Cloudflared" "$(dasterm_service_state cloudflared)"
  dasterm_row "SSH" "$(dasterm_service_state ssh)"
  dasterm_row "UFW" "$(dasterm_ufw_state)"
  dasterm_footer
}

dasterm_render_dashboard() {
  dasterm_load_config
  dasterm_theme_load
  local mode="${1:-${DASTERM_MODE:-lite}}"
  case "$mode" in
    full) dasterm_render_full ;;
    *) dasterm_render_lite ;;
  esac
}