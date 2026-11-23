dasterm_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release 2>/dev/null || true
    echo "${PRETTY_NAME:-${NAME:-Linux}}"
    return
  fi
  if dasterm_has lsb_release; then
    lsb_release -d 2>/dev/null | cut -f2
    return
  fi
  echo "Linux"
}

dasterm_os_id() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release 2>/dev/null || true
    echo "${ID:-linux}"
    return
  fi
  echo "linux"
}

dasterm_os_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release 2>/dev/null || true
    echo "${VERSION_ID:-unknown}"
    return
  fi
  echo "unknown"
}

dasterm_virt() {
  local v
  v="$(systemd-detect-virt 2>/dev/null || true)"
  if [ -n "$v" ] && [ "$v" != "none" ]; then
    echo "$v"
    return
  fi
  if grep -qa docker /proc/1/cgroup 2>/dev/null; then
    echo "docker"
    return
  fi
  if [ -f /.dockerenv ]; then
    echo "docker"
    return
  fi
  if [ -d /proc/vz ] && [ ! -d /proc/bc ]; then
    echo "openvz"
  elif grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
    echo "wsl"
  else
    echo "physical/unknown"
  fi
}

dasterm_boot_time() {
  local boot
  boot="$(uptime -s 2>/dev/null || true)"
  [ -n "$boot" ] || boot="$(who -b 2>/dev/null | awk 'NF>=4 {print $3" "$4}')"
  echo "${boot:-N/A}"
}

dasterm_cpu_model() {
  local model
  model="$(awk -F: '/model name|Hardware|Processor/ {gsub(/^[ \t]+/,"",$2); if(length($2)) {print $2; exit}}' /proc/cpuinfo 2>/dev/null | cut -c1-70)"
  [ -n "$model" ] || model="$(uname -m 2>/dev/null || true)"
  echo "${model:-N/A}"
}

dasterm_cpu_flags() {
  local flags
  flags="$(awk -F: '/flags/{print $2; exit}' /proc/cpuinfo 2>/dev/null | grep -oE 'vmx|svm|aes|avx|avx2|sse4_2' | sort -u | tr '\n' ' ' | dasterm_trim)"
  [ -n "$flags" ] && echo "$flags" || echo "N/A"
}

dasterm_gpu() {
  if dasterm_has lspci; then
    local gpu
    gpu="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | head -1 | cut -d: -f3- | dasterm_trim | cut -c1-70)"
    [ -n "$gpu" ] && echo "$gpu" || echo "N/A"
    return
  fi
  echo "N/A"
}

dasterm_ram_line() {
  local value
  value="$(free -h 2>/dev/null | awk '/Mem:/ {
    used=$3; total=$2;
    printf "%s used of %s", used, total
  }')"
  echo "${value:-N/A}"
}

dasterm_ram_percent() {
  local value
  value="$(free 2>/dev/null | awk '/Mem:/ {if($2 > 0) printf "%.1f", ($3/$2)*100; else print "0.0"}')"
  echo "${value:-0.0}"
}

dasterm_swap_line() {
  local value
  value="$(free -h 2>/dev/null | awk '/Swap:/ {
    if($2=="0B" || $2=="0") print "Disabled";
    else printf "%s used of %s", $3, $2
  }')"
  echo "${value:-N/A}"
}

dasterm_disk_line() {
  local path="${1:-/}"
  local value
  value="$(df -Ph "$path" 2>/dev/null | awk 'NR==2 {printf "%s used of %s (%s)", $3, $2, $5}')"
  echo "${value:-N/A}"
}

dasterm_disk_percent() {
  local path="${1:-/}"
  local value
  value="$(df -P "$path" 2>/dev/null | awk 'NR==2 {gsub("%","",$5); print $5+0}')"
  echo "${value:-0}"
}

dasterm_load_line() {
  awk '{printf "%.2f, %.2f, %.2f", $1, $2, $3}' /proc/loadavg 2>/dev/null || echo "N/A"
}

dasterm_pkg_count() {
  if dasterm_has dpkg-query; then
    dpkg-query -f '${binary:Package}\n' -W 2>/dev/null | wc -l | awk '{print $1}'
    return
  fi
  if dasterm_has rpm; then
    rpm -qa 2>/dev/null | wc -l | awk '{print $1}'
    return
  fi
  if dasterm_has pacman; then
    pacman -Q 2>/dev/null | wc -l | awk '{print $1}'
    return
  fi
  if dasterm_has apk; then
    apk info 2>/dev/null | wc -l | awk '{print $1}'
    return
  fi
  echo "N/A"
}

dasterm_shell_name() {
  basename "${SHELL:-unknown}"
}

dasterm_terminal_name() {
  echo "${TERM_PROGRAM:-${TERM:-unknown}}"
}

dasterm_systemd_available() {
  dasterm_has systemctl && [ -d /run/systemd/system ]
}

dasterm_service_state() {
  local name="$1"
  if dasterm_systemd_available; then
    local s
    s="$(systemctl is-active "$name" 2>/dev/null || true)"
    case "$s" in
      active) echo "active" ;;
      inactive) echo "inactive" ;;
      failed) echo "failed" ;;
      *) echo "not detected" ;;
    esac
    return
  fi
  if dasterm_has rc-service; then
    if rc-service "$name" status >/dev/null 2>&1; then
      echo "running"
    else
      echo "not running/unknown"
    fi
  elif pgrep -x "$name" >/dev/null 2>&1; then
    echo "running"
  else
    echo "not detected"
  fi
}

dasterm_ufw_state() {
  if dasterm_has ufw; then
    ufw status 2>/dev/null | awk -F: '/Status:/ {gsub(/^ /,"",$2); print $2; exit}'
    return
  fi
  echo "not installed"
}

dasterm_failed_units_count() {
  if dasterm_systemd_available; then
    local units
    units="$(systemctl --failed --no-legend --plain 2>/dev/null)" || { echo "N/A"; return; }
    printf '%s\n' "$units" | awk 'NF {n++} END {print n+0}'
  else
    echo "N/A"
  fi
}

dasterm_reboot_required() {
  if [ -f /var/run/reboot-required ]; then
    echo "yes"
  else
    echo "no"
  fi
}
