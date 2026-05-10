# Dasterm v2 Usage Guide

Dasterm v2 is an interactive Linux terminal dashboard with Lite/Full mode, cached speedtest, AI assistant, storage analyzer, service monitor, security check, doctor, updater, and optional telemetry.

---

## 1. Install

Recommended:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Direct install:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --install'
```

Dasterm needs sudo because it installs files to:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
```

---

## 2. After Install

Reload your shell:

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

## 3. Main Commands

```bash
/help
```

Show all commands.

```bash
/status
```

Show dashboard using active mode.

```bash
/lite
```

Show Lite dashboard.

```bash
/full
```

Show Full dashboard.

```bash
/config
```

Open interactive config.

```bash
/update
```

Update Dasterm.

```bash
/uninstall
```

Open uninstall flow.

```bash
/version
```

Show version.

```bash
/about
```

Show project info.

---

## 4. Dashboard Modes

Dasterm has two modes:

```text
Lite
Full
```

Lite is fast and compact.

Full is complete and more detailed.

Change mode:

```bash
/config
```

Run Lite manually:

```bash
/lite
```

Run Full manually:

```bash
/full
```

---

## 5. Language

Dasterm supports:

```text
Indonesia
English
```

Change language:

```bash
/config
```

---

## 6. Theme

Themes:

```text
Pastel
Cyber
Ocean
Mono
```

Change theme:

```bash
/config
```

---

## 7. User@Host

You can set custom terminal identity such as:

```text
root@aka
aka@server
admin@vps
student@lab
```

Change it:

```bash
/config
```

If you do not want Dasterm to change prompt:

```text
Change prompt? off
```

---

## 8. Speedtest

Dasterm does not run speedtest every login.

It reads saved speedtest from:

```text
~/.cache/dasterm/speedtest.json
```

View saved result:

```bash
/speedtest
```

Run new test and save:

```bash
/respeedtest
```

Formula:

```text
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

---

## 9. Network

Run:

```bash
/network
```

Shows:

```text
Private IP
Public IP
Interface
Gateway
DNS
Ping 1.1.1.1
Ping 8.8.8.8
Open ports
Speedtest cache
```

---

## 10. Storage

Run:

```bash
/storage
```

Shows:

```text
Root disk
Root filesystem
Root inode usage
/datas disk if available
Docker root
Docker usage
Mount list
Largest directories
Node modules scan
Storage suggestions
```

---

## 11. Services

Run:

```bash
/services
```

Shows:

```text
Docker
PM2
Nginx
Apache
Cloudflared
SSH
Cron
PostgreSQL
MySQL/MariaDB
Redis
Failed systemd units
Open ports
Top service processes
```

---

## 12. Security

Run:

```bash
/security
```

Shows:

```text
Security score
Firewall status
SSH root login
SSH password authentication
SSH public key authentication
Fail2ban status
Sudo users
Failed login count
Recent logins
Suggestions
```

Dasterm does not change security config automatically.

---

## 13. Doctor

Run:

```bash
/doctor
```

Checks:

```text
Binary
Library files
Config
Shell integration
Config permission
Cache directory
Speedtest cache
Dependencies
AI runtime
Network connectivity
OS
Virtualization
Root disk
RAM
Failed units
Reboot required
```

---

## 14. AI Assistant

Ask AI:

```bash
/ai cek storage server saya
```

Or:

```bash
dasterm ai "cek storage server saya"
```

If AI suggests a command, Dasterm asks first:

```text
Run this command? [y/N]
```

Command will not run without approval.

---

## 15. AI Memory

Show memory:

```bash
/brain-ai
```

Clear memory:

```bash
/clear-brain-ai
```

Memory file:

```text
~/.cache/dasterm/ai-memory.json
```

Memory resets daily based on WIB date.

---

## 16. AI Provider

Show providers:

```bash
/ai-provider
```

Reset providers:

```bash
/ai-reset-provider
```

Test providers:

```bash
/ai-test
```

Default order:

```text
chocomilk
prexzy_copilot
prexzy_zai
```

---

## 17. Update

Run:

```bash
/update
```

Dasterm will:

```text
Check current version
Check latest version from GitHub
Show changelog if available
Ask confirmation
Download latest files
Apply update
Keep user config
```

---

## 18. Reconfigure

Use:

```bash
/config
```

Or:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
```

---

## 19. Repair

Use repair if files are missing or broken:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
```

---

## 20. Uninstall

Use:

```bash
/uninstall
```

Or:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'
```

Uninstall removes only Dasterm files and shell integration.

---

## 21. File Locations

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/lib/
~/.config/dasterm/config.env
~/.cache/dasterm/
~/.local/share/dasterm/logs/
```

---

## 22. If Slash Command Fails

Run:

```bash
source ~/.bashrc
```

Or use original command:

```bash
dasterm help
dasterm status
dasterm respeedtest
```

---

## 23. Recommended Daily Usage

Quick dashboard:

```bash
/status
```

Health check:

```bash
/doctor
```

Storage:

```bash
/storage
```

Services:

```bash
/services
```

Network:

```bash
/network
```

Speedtest refresh:

```bash
/respeedtest
```

Ask AI:

```bash
/ai kenapa root disk saya cepat penuh?
```

Update:

```bash
/update
```