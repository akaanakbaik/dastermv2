dasterm_services_systemd_unit() {
  local unit="$1"
  if dasterm_has systemctl; then
    systemctl is-active "$unit" 2>/dev/null || echo "not detected"
  else
    echo "systemctl unavailable"
  fi
}

dasterm_services_process_count() {
  local name="$1"
  pgrep -f "$name" 2>/dev/null | wc -l | awk '{print $1}'
}

dasterm_services_port_list() {
  if dasterm_has ss; then
    ss -tulpen 2>/dev/null | awk 'NR>1 {
      split($5,a,":");
      p=a[length(a)];
      if(p~/^[0-9]+$/) {
        proc=$0;
        gsub(/^.*users:\(\("/,"",proc);
        gsub(/".*$/,"",proc);
        if(proc==$0) proc="unknown";
        print p"/"proc;
      }
    }' | sort -n | uniq | head -30 | tr '\n' ' '
  else
    echo "N/A"
  fi
}

dasterm_services_docker_summary() {
  if ! dasterm_has docker; then
    echo "not installed"
    return
  fi
  if ! docker info >/dev/null 2>&1; then
    echo "installed but not reachable"
    return
  fi
  local running total images
  running="$(docker ps -q 2>/dev/null | wc -l | awk '{print $1}')"
  total="$(docker ps -aq 2>/dev/null | wc -l | awk '{print $1}')"
  images="$(docker images -q 2>/dev/null | sort -u | wc -l | awk '{print $1}')"
  echo "${running} running / ${total} total | ${images} images"
}

dasterm_services_pm2_summary() {
  if ! dasterm_has pm2; then
    echo "not installed"
    return
  fi
  local total online
  total="$(pm2 jlist 2>/dev/null | jq 'length' 2>/dev/null || echo 0)"
  online="$(pm2 jlist 2>/dev/null | jq '[.[] | select(.pm2_env.status=="online")] | length' 2>/dev/null || echo 0)"
  echo "${online} online / ${total} total"
}

dasterm_services_cloudflared_summary() {
  if dasterm_has cloudflared; then
    local p
    p="$(dasterm_services_process_count cloudflared)"
    if [ "$p" -gt 0 ]; then
      echo "running (${p} process)"
    else
      echo "installed, not running"
    fi
  else
    echo "not installed"
  fi
}

dasterm_services_nginx_summary() {
  if dasterm_has nginx; then
    dasterm_services_systemd_unit nginx
  else
    echo "not installed"
  fi
}

dasterm_services_apache_summary() {
  if dasterm_has apache2; then
    dasterm_services_systemd_unit apache2
  elif dasterm_has httpd; then
    dasterm_services_systemd_unit httpd
  else
    echo "not installed"
  fi
}

dasterm_services_database_summary() {
  local out=""
  if dasterm_has psql || [ "$(dasterm_services_process_count postgres)" -gt 0 ]; then
    local s
    s="$(dasterm_services_systemd_unit postgresql)"
    out="${out}PostgreSQL: ${s}; "
  fi
  if dasterm_has mysql || dasterm_has mariadb; then
    local s
    s="$(dasterm_services_systemd_unit mysql)"
    [ "$s" = "not detected" ] && s="$(dasterm_services_systemd_unit mariadb)"
    out="${out}MySQL/MariaDB: ${s}; "
  fi
  if dasterm_has redis-server || dasterm_has redis-cli; then
    local s
    s="$(dasterm_services_systemd_unit redis-server)"
    [ "$s" = "not detected" ] && s="$(dasterm_services_systemd_unit redis)"
    out="${out}Redis: ${s}; "
  fi
  [ -n "$out" ] && echo "$out" || echo "none detected"
}

dasterm_services_failed_units() {
  if dasterm_has systemctl; then
    local failed
    failed="$(systemctl --failed --no-legend 2>/dev/null | awk '{print $1"("$2")"}' | paste -sd ", " -)"
    [ -n "$failed" ] && echo "$failed" || echo "none"
  else
    echo "N/A"
  fi
}

dasterm_services_show() {
  dasterm_title "$(dasterm_t services)"
  dasterm_kv "Docker" "$(dasterm_services_docker_summary)"
  dasterm_kv "PM2" "$(dasterm_services_pm2_summary)"
  dasterm_kv "Nginx" "$(dasterm_services_nginx_summary)"
  dasterm_kv "Apache" "$(dasterm_services_apache_summary)"
  dasterm_kv "Cloudflared" "$(dasterm_services_cloudflared_summary)"
  dasterm_kv "SSH" "$(dasterm_services_systemd_unit ssh)"
  dasterm_kv "Cron" "$(dasterm_services_systemd_unit cron)"
  dasterm_kv "Database" "$(dasterm_services_database_summary)"
  dasterm_kv "Failed Units" "$(dasterm_services_failed_units)"
  echo

  dasterm_title "Open Ports"
  local ports
  ports="$(dasterm_services_port_list)"
  [ -n "$ports" ] && echo "$ports" || echo "No listening ports detected"
  echo

  dasterm_title "Top Service Processes"
  ps -eo pid,comm,%cpu,%mem --sort=-%mem 2>/dev/null | head -12 || true
  dasterm_footer
}