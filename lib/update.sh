dasterm_update_raw_base() {
  echo "https://raw.githubusercontent.com/${DASTERM_REPO_OWNER:-akaanakbaik}/${DASTERM_REPO_NAME:-dastermv2}/${DASTERM_REPO_BRANCH:-main}"
}

dasterm_update_latest_version() {
  local base latest
  base="$(dasterm_update_raw_base)"
  latest="$(timeout 8 curl -fsSL "${base}/VERSION" 2>/dev/null || true)"
  [ -n "$latest" ] || latest="$(timeout 8 curl -fsSL "${base}/bin/dasterm" 2>/dev/null | grep -m1 'DASTERM_VERSION_FALLBACK=' | cut -d'"' -f2 || true)"
  [ -n "$latest" ] && echo "$latest" || echo "${DASTERM_VERSION:-2.0.0}"
}

dasterm_update_download() {
  local tmp="$1"
  local base
  base="$(dasterm_update_raw_base)"
  mkdir -p "$tmp/bin" "$tmp/lib"
  curl -fsSL "${base}/bin/dasterm" -o "$tmp/bin/dasterm"
  for f in core.sh i18n.sh render.sh system.sh network.sh speedtest.sh ai.sh update.sh storage.sh security.sh services.sh doctor.sh telemetry.sh; do
    curl -fsSL "${base}/lib/${f}" -o "$tmp/lib/${f}"
  done
  curl -fsSL "${base}/install.sh" -o "$tmp/install.sh" 2>/dev/null || true
  curl -fsSL "${base}/VERSION" -o "$tmp/VERSION" 2>/dev/null || true
}

dasterm_update_apply() {
  local tmp="$1"
  if [ "$(id -u)" -ne 0 ]; then
    if dasterm_has sudo; then
      sudo install -m 755 "$tmp/bin/dasterm" /usr/local/bin/dasterm
      sudo mkdir -p /usr/local/share/dasterm/lib
      sudo cp -f "$tmp/lib/"*.sh /usr/local/share/dasterm/lib/
      sudo chmod 644 /usr/local/share/dasterm/lib/*.sh
    else
      dasterm_error "Update needs root permission or sudo."
      return 1
    fi
  else
    install -m 755 "$tmp/bin/dasterm" /usr/local/bin/dasterm
    mkdir -p /usr/local/share/dasterm/lib
    cp -f "$tmp/lib/"*.sh /usr/local/share/dasterm/lib/
    chmod 644 /usr/local/share/dasterm/lib/*.sh
  fi
}

dasterm_update_changelog() {
  local base
  base="$(dasterm_update_raw_base)"
  timeout 8 curl -fsSL "${base}/CHANGELOG.md" 2>/dev/null | sed -n '1,80p' || true
}

dasterm_update_run() {
  local current latest tmp changelog
  current="${DASTERM_VERSION:-2.0.0}"
  latest="$(dasterm_update_latest_version)"
  dasterm_title "$(dasterm_t update_title)"
  dasterm_kv "$(dasterm_t update_current)" "$current"
  dasterm_kv "$(dasterm_t update_latest)" "$latest"
  echo
  changelog="$(dasterm_update_changelog)"
  if [ -n "$changelog" ]; then
    dasterm_title "Changelog"
    echo "$changelog"
    echo
  fi
  if [ "$current" = "$latest" ]; then
    dasterm_success "Dasterm is already up to date."
    return 0
  fi
  if ! dasterm_confirm "$(dasterm_t update_confirm)"; then
    return 0
  fi
  tmp="${TMPDIR:-/tmp}/dasterm-update-$$"
  rm -rf "$tmp"
  mkdir -p "$tmp"
  if dasterm_spinner_run "Downloading update" dasterm_update_download "$tmp"; then
    :
  else
    rm -rf "$tmp"
    dasterm_error "Failed to download update."
    return 1
  fi
  if dasterm_spinner_run "Applying update" dasterm_update_apply "$tmp"; then
    :
  else
    rm -rf "$tmp"
    dasterm_error "Failed to apply update."
    return 1
  fi
  rm -rf "$tmp"
  dasterm_save_config_value "DASTERM_VERSION" "$latest"
  if declare -F dasterm_telemetry_send >/dev/null 2>&1; then
    dasterm_telemetry_send update
  fi
  dasterm_success "$(dasterm_t update_done)"
  dasterm_info "Run: source ~/.bashrc"
}