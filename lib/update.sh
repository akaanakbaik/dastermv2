dasterm_update_raw_base() {
  echo "https://raw.githubusercontent.com/${DASTERM_REPO_OWNER:-akaanakbaik}/${DASTERM_REPO_NAME:-dastermv2}/${DASTERM_REPO_BRANCH:-main}"
}

dasterm_update_latest_version() {
  local base latest
  base="$(dasterm_update_raw_base)"
  latest="$(dasterm_timeout 8 curl -fsSL "${base}/VERSION" 2>/dev/null || true)"
  [ -n "$latest" ] || latest="$(dasterm_timeout 8 curl -fsSL "${base}/bin/dasterm" 2>/dev/null | grep -m1 'DASTERM_VERSION_FALLBACK=' | cut -d'"' -f2 || true)"
  [[ "$latest" =~ ^[0-9]+[.][0-9]+[.][0-9]+([-+][A-Za-z0-9._-]+)?$ ]] || return 1
  echo "$latest"
}

dasterm_update_download() {
  local tmp="$1"
  local base
  base="$(dasterm_update_raw_base)"
  mkdir -p "$tmp/bin" "$tmp/lib"
  curl --connect-timeout 5 --max-time 30 -fsSL "${base}/bin/dasterm" -o "$tmp/bin/dasterm" || return 1
  bash -n "$tmp/bin/dasterm" || return 1
  local f
  for f in core.sh i18n.sh ui.sh render.sh system.sh network.sh speedtest.sh ai.sh update.sh storage.sh security.sh services.sh doctor.sh telemetry.sh; do
    curl --connect-timeout 5 --max-time 30 -fsSL "${base}/lib/${f}" -o "$tmp/lib/${f}" || return 1
    bash -n "$tmp/lib/${f}" || return 1
  done
}

dasterm_update_apply() {
  local tmp="$1"
  if [ "$(id -u)" -ne 0 ] && { [ ! -w "$DASTERM_BINARY" ] || [ ! -w "$DASTERM_LIB" ]; }; then
    if dasterm_has sudo; then
      sudo cp -f "$tmp/lib/"*.sh "$DASTERM_LIB/" || return 1
      sudo chmod 644 "$DASTERM_LIB/"*.sh || return 1
      sudo install -m 755 "$tmp/bin/dasterm" "$DASTERM_BINARY" || return 1
    else
      dasterm_error "Update needs root permission or sudo."
      return 1
    fi
  else
    cp -f "$tmp/lib/"*.sh "$DASTERM_LIB/" || return 1
    chmod 644 "$DASTERM_LIB/"*.sh || return 1
    install -m 755 "$tmp/bin/dasterm" "$DASTERM_BINARY" || return 1
  fi
}

dasterm_update_changelog() {
  local base
  base="$(dasterm_update_raw_base)"
  dasterm_timeout 8 curl -fsSL "${base}/CHANGELOG.md" 2>/dev/null | sed -n '1,80p' || true
}

dasterm_update_run() {
  local current latest tmp changelog
  current="${DASTERM_VERSION:-2.0.2}"
  if ! latest="$(dasterm_update_latest_version)"; then
    dasterm_error "Cannot determine latest version: network unavailable or invalid VERSION."
    return 1
  fi
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

  if [ "$(id -u)" -ne 0 ] && { [ ! -w "$DASTERM_BINARY" ] || [ ! -w "$DASTERM_LIB" ]; } && dasterm_has sudo; then
    dasterm_info "Update membutuhkan hak akses administrator. Silakan masukkan password:"
    sudo -v || return 1
  fi

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/dasterm-update.XXXXXX")" || return 1
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
