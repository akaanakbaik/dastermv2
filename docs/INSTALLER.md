# Dasterm v2 Installer

Dasterm v2 uses one interactive installer for:

```text
Install / Update
Reconfigure
Uninstall
Repair
Exit
```

Recommended command:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Dasterm installs files to:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
```

Because of that, install requires `sudo` or root access.

---

## 1. Main Menu

Run:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Menu:

```text
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
```

---

## 2. Direct Actions

Install directly:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --install'
```

Reconfigure directly:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
```

Repair directly:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
```

Uninstall directly:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'
```

---

## 3. Install / Update

Choose:

```text
1) Install / Update
```

The installer will:

```text
Detect target user
Detect OS and package manager
Ask language
Ask dashboard mode
Ask User@Host
Ask theme
Ask dashboard login behavior
Ask prompt behavior
Ask slash alias behavior
Ask initial speedtest option
Ask anonymous telemetry option
Install basic dependencies
Download Dasterm files from GitHub
Install binary to /usr/local/bin/dasterm
Install libraries to /usr/local/share/dasterm/lib
Save config to ~/.config/dasterm/config.env
Inject shell integration to .bashrc and .zshrc
Run initial speedtest if selected
```

---

## 4. Reconfigure

Choose:

```text
2) Reconfigure
```

Or run:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
```

Reconfigure changes user preferences without removing Dasterm files.

You can change:

```text
Language
Mode
Theme
User@Host
Dashboard login behavior
Prompt custom behavior
Slash alias behavior
Telemetry setting
Initial speedtest option
```

Config is saved to:

```text
~/.config/dasterm/config.env
```

---

## 5. Uninstall

Choose:

```text
3) Uninstall
```

Or run:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'
```

The installer asks:

```text
This will remove Dasterm files and shell integration.
Continue uninstall? [y/N]
```

If approved, uninstall removes:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
~/.config/dasterm
~/.cache/dasterm
Dasterm shell block from ~/.bashrc
Dasterm shell block from ~/.zshrc
```

Uninstall does not remove unrelated user files, Docker files, projects, VPS data, or services.

---

## 6. Repair

Choose:

```text
4) Repair
```

Or run:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
```

Repair is useful when:

```text
Binary is missing
Library files are missing
Shell integration is broken
Update failed
Dasterm command does not work normally
```

Repair will:

```text
Install basic dependencies
Download files again
Replace binary
Replace libraries
Refresh shell integration
Keep user config
```

---

## 7. Exit

Choose:

```text
5) Exit
```

The installer exits without changes.

---

## 8. Installed Files

Binary:

```text
/usr/local/bin/dasterm
```

Libraries:

```text
/usr/local/share/dasterm/lib/
```

User config:

```text
~/.config/dasterm/config.env
```

Cache:

```text
~/.cache/dasterm/
```

Logs:

```text
~/.local/share/dasterm/logs/
```

Shell integration:

```text
~/.bashrc
~/.zshrc
```

---

## 9. Shell Integration

The installer adds a small block:

```bash
### DASTERM_V2_BEGIN ###
if [ -x /usr/local/bin/dasterm ]; then
  eval "$(/usr/local/bin/dasterm shell-init 2>/dev/null)"
  if [ -z "${DASTERM_SESSION_DONE:-}" ] && [ -t 1 ]; then
    export DASTERM_SESSION_DONE=1
    /usr/local/bin/dasterm auto 2>/dev/null || true
  fi
fi
### DASTERM_V2_END ###
```

Purpose:

```text
Load slash aliases
Apply custom prompt if enabled
Show dashboard at login if enabled
Keep .bashrc/.zshrc clean
Make uninstall easy
```

---

## 10. Config File

Config:

```text
~/.config/dasterm/config.env
```

Example:

```env
DASTERM_VERSION="2.0.0"
DASTERM_LANG="id"
DASTERM_MODE="lite"
DASTERM_THEME="pastel"
DASTERM_USERHOST="root@aka"
DASTERM_SHOW="always"
DASTERM_PROMPT="on"
DASTERM_SLASH="on"
DASTERM_TELEMETRY="off"
DASTERM_REPO_OWNER="akaanakbaik"
DASTERM_REPO_NAME="dastermv2"
DASTERM_REPO_BRANCH="main"
```

Permission:

```text
600
```

---

## 11. If You Run Without Sudo

If you run:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

The installer will show:

```text
Root access is required for this action.
Run:
  bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

This is normal.

---

## 12. Manual Download

If your shell does not support process substitution:

```bash
curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

Direct actions:

```bash
sudo ./install.sh --install
sudo ./install.sh --reconfigure
sudo ./install.sh --repair
sudo ./install.sh --uninstall
```

---

## 13. After Install

Run:

```bash
source ~/.bashrc
```

Or open a new terminal.

Test:

```bash
dasterm version
dasterm help
dasterm doctor
```

If slash aliases are enabled:

```bash
/help
/status
/doctor
```

---

## 14. Troubleshooting Installer

If `curl` is missing:

```bash
sudo apt install curl ca-certificates
```

If `jq` is missing:

```bash
sudo apt install jq
```

If slash commands are not active:

```bash
source ~/.bashrc
```

If `dasterm` is not found:

```bash
ls -la /usr/local/bin/dasterm
```

Repair:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
```

---

## 15. Summary

The recommended command is:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Direct commands:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --install'
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'
```