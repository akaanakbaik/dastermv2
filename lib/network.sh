dasterm_private_ip() {
  local ip
  ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  if [ -n "$ip" ]; then
    echo "$ip"
    return
  fi
  ip="$(ip route get 1.1.1.1 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++)if($i=="src"){print $(i+1);exit}}')"
  [ -n "$ip" ] && echo "$ip" || echo "N/A"
}

dasterm_public_ip_cached() {
  local file="$DASTERM_CACHE_DIR/public-ip.cache"
  dasterm_mkdirs
  if dasterm_cache_valid "$file" 3600; then
    cat "$file"
    return
  fi
  local ip
  ip="$(dasterm_public_ip)"
  [ -n "$ip" ] || ip="N/A"
  echo "$ip" > "$file"
  echo "$ip"
}

dasterm_gateway() {
  ip route 2>/dev/null | awk '/default/ {print $3; exit}' || echo "N/A"
}

dasterm_iface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++)if($i=="dev"){print $(i+1);exit}}' || echo "N/A"
}

dasterm_dns() {
  local dns
  dns="$(awk '/^nameserver/{printf "%s ", $2}' /etc/resolv.conf 2>/dev/null | dasterm_trim)"
  [ -n "$dns" ] && echo "$dns" || echo "N/A"
}

dasterm_ping_ms() {
  local host="${1:-1.1.1.1}"
  ping -c 1 -W 2 "$host" 2>/dev/null | awk -F'time=' '/time=/{split($2,a," "); print a[1]; exit}' || echo "N/A"
}

dasterm_open_ports() {
  if dasterm_has ss; then
    ss -tuln 2>/dev/null | awk 'NR>1 {split($5,a,":"); p=a[length(a)]; if(p~/^[0-9]+$/) print p}' | sort -n | uniq | tr '\n' ' ' | dasterm_trim
    return
  fi
  echo "N/A"
}

dasterm_network_show() {
  dasterm_title "$(dasterm_t network)"
  dasterm_kv "Private IP" "$(dasterm_private_ip)"
  dasterm_kv "Public IP" "$(dasterm_public_ip_cached)"
  dasterm_kv "Interface" "$(dasterm_iface)"
  dasterm_kv "Gateway" "$(dasterm_gateway)"
  dasterm_kv "DNS" "$(dasterm_dns)"
  dasterm_kv "Ping 1.1.1.1" "$(dasterm_ping_ms 1.1.1.1) ms"
  dasterm_kv "Ping 8.8.8.8" "$(dasterm_ping_ms 8.8.8.8) ms"
  dasterm_kv "Open Ports" "$(dasterm_open_ports)"
  echo
  dasterm_speedtest_show
}