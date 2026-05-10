dasterm_storage_mount_line() {
  local path="$1"
  if df -h "$path" >/dev/null 2>&1; then
    df -h "$path" | awk 'NR==2 {printf "%s used of %s (%s) on %s", $3, $2, $5, $1}'
  else
    echo "not found"
  fi
}

dasterm_storage_fs_type() {
  local path="$1"
  df -T "$path" 2>/dev/null | awk 'NR==2 {print $2}' || echo "N/A"
}

dasterm_storage_inode_line() {
  local path="$1"
  df -ih "$path" 2>/dev/null | awk 'NR==2 {printf "%s used of %s (%s)", $3, $2, $5}' || echo "N/A"
}

dasterm_storage_mounts() {
  findmnt -rno TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,USE% 2>/dev/null | awk '
  $1 ~ /^\/($|home|root|var|datas|mnt|opt)/ {
    printf "%-16s %-20s %-8s %8s %8s %8s %6s\n", $1, $2, $3, $4, $5, $6, $7
  }' | head -20
}

dasterm_storage_largest_dirs() {
  local base="${1:-/}"
  local max_depth="${2:-1}"
  if [ ! -d "$base" ]; then
    echo "not found"
    return
  fi
  if [ "$base" = "/" ]; then
    timeout 12 du -xhd "$max_depth" "$base" 2>/dev/null | sort -hr | head -10 || echo "permission denied or timeout"
  else
    timeout 12 du -hd "$max_depth" "$base" 2>/dev/null | sort -hr | head -10 || echo "permission denied or timeout"
  fi
}

dasterm_storage_docker_root() {
  if dasterm_has docker; then
    docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo "N/A"
  else
    echo "not installed"
  fi
}

dasterm_storage_docker_size() {
  if dasterm_has docker; then
    docker system df 2>/dev/null | awk 'NR==2 {print "Images: "$4" | Reclaimable: "$5" "$6} NR==3 {print "Containers: "$4" | Reclaimable: "$5" "$6}' | paste -sd " | " -
  else
    echo "not installed"
  fi
}

dasterm_storage_node_modules_scan() {
  local base="${1:-$HOME}"
  timeout 10 find "$base" -maxdepth 4 -type d -name node_modules 2>/dev/null | head -10 | while read -r d; do
    du -sh "$d" 2>/dev/null
  done | sort -hr | head -10
}

dasterm_storage_suggestions() {
  local rootp datas docker_root
  rootp="$(dasterm_disk_percent /)"
  datas="no"
  [ -d /datas ] && datas="yes"
  docker_root="$(dasterm_storage_docker_root)"
  if [ "$rootp" -ge 85 ]; then
    dasterm_warn "Root disk usage is high. Move heavy data, logs, Docker, or project files to a larger disk."
  fi
  if [ "$datas" = "yes" ]; then
    if [ "$docker_root" = "/var/lib/docker" ]; then
      dasterm_info "Docker still uses /var/lib/docker. If /datas is your large disk, consider moving Docker data to /datas/docker."
    fi
    if [ -d /var/lib/pterodactyl ]; then
      dasterm_info "Pterodactyl data detected. Check whether volumes should be moved or symlinked to /datas."
    fi
  fi
  if [ "$rootp" -lt 85 ] && [ "$datas" = "no" ]; then
    dasterm_info "Storage looks normal. No /datas directory detected."
  fi
}

dasterm_storage_show() {
  dasterm_title "$(dasterm_t storage)"
  dasterm_kv "Root Disk" "$(dasterm_storage_mount_line /)"
  dasterm_kv "Root FS" "$(dasterm_storage_fs_type /)"
  dasterm_kv "Root Inodes" "$(dasterm_storage_inode_line /)"
  if [ -d /datas ]; then
    dasterm_kv "Data Disk" "$(dasterm_storage_mount_line /datas)"
    dasterm_kv "Data FS" "$(dasterm_storage_fs_type /datas)"
    dasterm_kv "Data Inodes" "$(dasterm_storage_inode_line /datas)"
  fi
  dasterm_kv "Docker Root" "$(dasterm_storage_docker_root)"
  dasterm_kv "Docker Usage" "$(dasterm_storage_docker_size)"
  echo
  dasterm_title "Mounts"
  dasterm_storage_mounts || true
  echo
  dasterm_title "Largest Directories /"
  dasterm_storage_largest_dirs / 1 || true
  if [ -d /datas ]; then
    echo
    dasterm_title "Largest Directories /datas"
    dasterm_storage_largest_dirs /datas 1 || true
  fi
  echo
  dasterm_title "Node Modules Scan"
  local nm
  nm="$(dasterm_storage_node_modules_scan "$HOME")"
  [ -n "$nm" ] && echo "$nm" || echo "No node_modules found near $HOME"
  echo
  dasterm_title "Suggestions"
  dasterm_storage_suggestions
  dasterm_footer
}