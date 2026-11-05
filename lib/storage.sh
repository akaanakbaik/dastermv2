dasterm_storage_mount_line() {
  local path="$1"
  if df -Ph "$path" >/dev/null 2>&1; then
    df -Ph "$path" | awk 'NR==2 {printf "%s used of %s (%s) on %s", $3, $2, $5, $1}'
  else
    echo "not found"
  fi
}

dasterm_storage_fs_type() {
  local path="$1"
  local value
  value="$(df -PT "$path" 2>/dev/null | awk 'NR==2 {print $2}')"
  echo "${value:-N/A}"
}

dasterm_storage_inode_line() {
  local path="$1"
  local value
  value="$(df -Pih "$path" 2>/dev/null | awk 'NR==2 {printf "%s used of %s (%s)", $3, $2, $5}')"
  echo "${value:-N/A}"
}

dasterm_storage_paths() {
  # Enumerate mounted filesystems, never infer disk count from directory names.
  # POSIX df works with GNU coreutils and BusyBox, without requiring findmnt.
  df -Pk 2>/dev/null | awk 'NR>1 && $1 !~ /^(tmpfs|devtmpfs|udev|shm)$/ {
    path=$6; for(i=7;i<=NF;i++) path=path " " $i;
    if(path ~ /^\// && !seen[path]++) print path;
  }'
}

dasterm_storage_mounts() {
  local path
  while IFS= read -r path; do
    printf '%s : %s\n' "$path" "$(dasterm_storage_mount_line "$path")"
  done < <(dasterm_storage_paths)
}

dasterm_storage_largest_dirs() {
  local base="${1:-/}"
  local max_depth="${2:-1}"
  if [ ! -d "$base" ]; then
    echo "not found"
    return
  fi
  if [ "$base" = "/" ]; then
    dasterm_timeout 12 du -xhd "$max_depth" "$base" 2>/dev/null | sort -hr | head -10 || echo "permission denied or timeout"
  else
    dasterm_timeout 12 du -hd "$max_depth" "$base" 2>/dev/null | sort -hr | head -10 || echo "permission denied or timeout"
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
  dasterm_timeout 10 find "$base" -maxdepth 4 -type d -name node_modules 2>/dev/null | head -10 | while read -r d; do
    du -sh "$d" 2>/dev/null
  done | sort -hr | head -10
}

dasterm_storage_suggestions() {
  local rootp path usage
  rootp="$(dasterm_disk_percent /)"
  if [ "$rootp" -ge 85 ]; then
    dasterm_warn "Root disk usage is high. Move heavy data, logs, Docker, or project files to a larger disk."
  fi
  while IFS= read -r path; do
    [ "$path" = / ] && continue
    usage="$(dasterm_disk_percent "$path")"
    if [ "$usage" -ge 85 ]; then
      dasterm_warn "Filesystem $path is ${usage}% full."
    fi
  done < <(dasterm_storage_paths)
  dasterm_info "Only mounted filesystems are shown; bind mounts can share a disk. No data is moved automatically."
}

dasterm_storage_show() {
  dasterm_title "$(dasterm_t storage)"
  dasterm_kv "Root Disk" "$(dasterm_storage_mount_line /)"
  dasterm_kv "Root FS" "$(dasterm_storage_fs_type /)"
  dasterm_kv "Root Inodes" "$(dasterm_storage_inode_line /)"
  local path
  while IFS= read -r path; do
    [ "$path" = / ] && continue
    dasterm_kv "Disk $path" "$(dasterm_storage_mount_line "$path")"
    dasterm_kv "Inodes $path" "$(dasterm_storage_inode_line "$path")"
  done < <(dasterm_storage_paths)
  dasterm_kv "Docker Root" "$(dasterm_storage_docker_root)"
  dasterm_kv "Docker Usage" "$(dasterm_storage_docker_size)"
  echo
  dasterm_title "Mounts"
  dasterm_storage_mounts || true
  echo
  dasterm_title "Largest Directories /"
  dasterm_storage_largest_dirs / 1 || true
  while IFS= read -r path; do
    [ "$path" = / ] && continue
    [ -d "$path" ] || continue
    echo
    dasterm_title "Largest Directories $path"
    dasterm_storage_largest_dirs "$path" 1 || true
  done < <(dasterm_storage_paths)
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
