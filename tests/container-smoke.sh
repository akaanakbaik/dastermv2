#!/usr/bin/env bash
# Run only inside a disposable Linux container, with the checkout at /src.
set -euo pipefail
cd /src
export HOME=/tmp/dasterm-smoke
mkdir -p "$HOME" /tmp/dasterm-mocks
for name in curl ping fastfetch neofetch; do
  printf '#!/bin/sh\nexit 1\n' > "/tmp/dasterm-mocks/$name"
  chmod +x "/tmp/dasterm-mocks/$name"
done
export PATH="/tmp/dasterm-mocks:$PATH"
for pass in 1 2; do
  for cmd in version help about lite full network services security speedtest doctor storage; do
    bash bin/dasterm "$cmd" >/tmp/dasterm-output 2>/tmp/dasterm-errors
    if [ -s /tmp/dasterm-errors ]; then cat /tmp/dasterm-errors; exit 1; fi
    test -s /tmp/dasterm-output
    echo "PASS $pass $cmd"
  done
done
export USER=root
unset SUDO_USER
for action in install reconfigure repair install; do
  bash install.sh "--$action" --auto >/tmp/dasterm-install-output 2>&1 || {
    cat /tmp/dasterm-install-output; exit 1;
  }
  /usr/local/bin/dasterm version
  bash -c 'eval "$(/usr/local/bin/dasterm shell-init bash)"; /version'
  test "$(grep -c '^### DASTERM_V2_BEGIN ###$' /root/.bashrc)" = 1
  echo "PASS lifecycle $action"
done
printf 'y\n' | bash install.sh --uninstall >/tmp/dasterm-uninstall-output 2>&1
test ! -e /usr/local/bin/dasterm
test ! -L /usr/local/bin/dashterm
test ! -d /usr/local/share/dasterm
if grep -q '^### DASTERM_V2_BEGIN ###$' /root/.bashrc; then exit 1; fi
echo 'PASS lifecycle uninstall'
