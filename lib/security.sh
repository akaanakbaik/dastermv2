dasterm_security_ssh_value() {
  local key="$1"
  local file="/etc/ssh/sshd_config"
  [ -f "$file" ] || {
    echo "N/A"
    return
  }
  awk -v k="$key" 'tolower($1)==tolower(k) && $0 !~ /^[[:space:]]*#/ {print $2; found=1} END{if(!found)print "default"}' "$file" 2>/dev/null
}

dasterm_security_firewall() {
  if dasterm_has ufw; then
    local s
    s="$(ufw status 2>/dev/null | awk -F: '/Status:/ {gsub(/^ /,"",$2);print $2;exit}')"
    [ -n "$s" ] && echo "ufw $s" && return
  fi
  if dasterm_has firewall-cmd; then
    if firewall-cmd --state >/dev/null 2>&1; then
      echo "firewalld running"
    else
      echo "firewalld not running"
    fi
    return
  fi
  if dasterm_has iptables; then
    local rules
    rules="$(iptables -S 2>/dev/null | wc -l | awk '{print $1}')"
    echo "iptables rules: $rules"
    return
  fi
  echo "not detected"
}

dasterm_security_fail2ban() {
  if dasterm_has fail2ban-client; then
    fail2ban-client status 2>/dev/null | awk -F: '/Jail list/ {gsub(/^[ \t]+/,"",$2); print $2; exit}' || echo "installed"
  else
    echo "not installed"
  fi
}

dasterm_security_sudo_users() {
  if getent group sudo >/dev/null 2>&1; then
    getent group sudo | awk -F: '{print $4}'
    return
  fi
  if getent group wheel >/dev/null 2>&1; then
    getent group wheel | awk -F: '{print $4}'
    return
  fi
  echo "N/A"
}

dasterm_security_last_logins() {
  last -n 5 2>/dev/null | head -5 || echo "N/A"
}

dasterm_security_failed_logins() {
  if dasterm_has journalctl; then
    journalctl -u ssh -u sshd --since "24 hours ago" 2>/dev/null | grep -ciE 'failed password|invalid user|authentication failure' || echo 0
    return
  fi
  if [ -f /var/log/auth.log ]; then
    grep -ciE 'failed password|invalid user|authentication failure' /var/log/auth.log 2>/dev/null || echo 0
    return
  fi
  echo "N/A"
}

dasterm_security_risk_score() {
  local score=100
  local root password firewall failed
  root="$(dasterm_security_ssh_value PermitRootLogin)"
  password="$(dasterm_security_ssh_value PasswordAuthentication)"
  firewall="$(dasterm_security_firewall)"
  failed="$(dasterm_security_failed_logins)"
  case "$root" in yes|without-password|prohibit-password) score=$((score-20)) ;; esac
  case "$password" in yes|default) score=$((score-15)) ;; esac
  echo "$firewall" | grep -qiE 'inactive|not detected|not running' && score=$((score-20))
  if [[ "$failed" =~ ^[0-9]+$ ]] && [ "$failed" -gt 10 ]; then
    score=$((score-15))
  fi
  [ "$score" -lt 0 ] && score=0
  if [ "$score" -ge 85 ]; then
    echo "$score/100 GOOD"
  elif [ "$score" -ge 65 ]; then
    echo "$score/100 WARN"
  else
    echo "$score/100 BAD"
  fi
}

dasterm_security_suggestions() {
  local root password firewall
  root="$(dasterm_security_ssh_value PermitRootLogin)"
  password="$(dasterm_security_ssh_value PasswordAuthentication)"
  firewall="$(dasterm_security_firewall)"
  case "$root" in
    yes|without-password|prohibit-password) dasterm_warn "SSH root login is not fully disabled. Safer setting: PermitRootLogin no." ;;
    *) dasterm_success "SSH root login setting looks acceptable." ;;
  esac
  case "$password" in
    yes|default) dasterm_warn "PasswordAuthentication may be enabled. SSH key login is safer." ;;
    *) dasterm_success "SSH password login setting looks acceptable." ;;
  esac
  echo "$firewall" | grep -qiE 'inactive|not detected|not running' && dasterm_warn "Firewall is not clearly active. Consider enabling UFW or firewalld." || dasterm_success "Firewall signal detected."
  if ! dasterm_has fail2ban-client; then
    dasterm_info "Fail2ban is not installed. It can help reduce brute-force SSH attacks."
  fi
}

dasterm_security_show() {
  dasterm_title "$(dasterm_t security)"
  dasterm_kv "Security Score" "$(dasterm_security_risk_score)"
  dasterm_kv "Firewall" "$(dasterm_security_firewall)"
  dasterm_kv "SSH Root Login" "$(dasterm_security_ssh_value PermitRootLogin)"
  dasterm_kv "SSH Password Auth" "$(dasterm_security_ssh_value PasswordAuthentication)"
  dasterm_kv "SSH Pubkey Auth" "$(dasterm_security_ssh_value PubkeyAuthentication)"
  dasterm_kv "Fail2ban" "$(dasterm_security_fail2ban)"
  dasterm_kv "Sudo Users" "$(dasterm_security_sudo_users)"
  dasterm_kv "Failed Login 24h" "$(dasterm_security_failed_logins)"
  echo
  dasterm_title "Suggestions"
  dasterm_security_suggestions
  echo
  dasterm_title "Recent Logins"
  dasterm_security_last_logins
  dasterm_footer
}