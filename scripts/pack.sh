#!/usr/bin/env bash
set -euo pipefail
IFS=$' \t\n'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')"
VERSION="${VERSION:-2.0.0}"
DIST_DIR="$ROOT_DIR/dist"
PKG_NAME="dasterm-v${VERSION}"
PKG_DIR="$DIST_DIR/$PKG_NAME"

rm -rf "$DIST_DIR"
mkdir -p "$PKG_DIR"

copy_path() {
  local path="$1"
  if [ -e "$ROOT_DIR/$path" ]; then
    mkdir -p "$PKG_DIR/$(dirname "$path")"
    cp -R "$ROOT_DIR/$path" "$PKG_DIR/$path"
  fi
}

copy_path install.sh
copy_path VERSION
copy_path CHANGELOG.md
copy_path LICENSE
copy_path README.md
copy_path CONTRIBUTING.md
copy_path CODE_OF_CONDUCT.md
copy_path SECURITY.md
copy_path README_BADGES.md
copy_path Makefile
copy_path bin
copy_path lib
copy_path docs
copy_path scripts
copy_path worker
copy_path .github
copy_path .editorconfig
copy_path .gitignore

find "$PKG_DIR" -type f -name "*.sh" -exec chmod +x {} \;
chmod +x "$PKG_DIR/bin/dasterm" 2>/dev/null || true
chmod +x "$PKG_DIR/install.sh" 2>/dev/null || true

cd "$DIST_DIR"
tar -czf "${PKG_NAME}.tar.gz" "$PKG_NAME"

echo "$DIST_DIR/${PKG_NAME}.tar.gz"