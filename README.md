# Dasterm v2

> Interactive Linux terminal dashboard with cached speedtest, AI assistant, smart command menu, bilingual interface, system health, storage insight, security checks, self-update, GitHub-powered telemetry badges, and VPS-friendly diagnostics.

<p align="center">
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/install.json" />
  </a>
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/run.json" />
  </a>
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/ai.json" />
  </a>
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/top-os-1.json" />
  </a>
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/top-os-2.json" />
  </a>
  <a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
    <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/machines.json" />
  </a>
</p>

---

## What is Dasterm?

Dasterm is a modern terminal dashboard for Linux servers and VPS environments.

It gives you a clean terminal overview when you log in and provides useful commands such as:

```text
/help
/status
/lite
/full
/speedtest
/respeedtest
/network
/storage
/services
/security
/doctor
/ai
/update
/uninstall
```

Dasterm v2 is designed for:

```text
VPS owners
Linux learners
Developers
Server admins
Pterodactyl users
Docker users
Cloudflare Tunnel users
People who want a useful and beautiful terminal dashboard
```

---

## Highlights

```text
Lite and Full dashboard modes
Indonesian and English interface
Interactive installer
Clean install, update, repair, reconfigure, and uninstall flow
Cached speedtest result
Accurate Mbps, MB/s, Gbps, and GB/s conversion
Provider, region, server, ping, jitter, and packet loss when available
AI assistant with structured metadata output
AI command approval before execution
AI memory reset daily by WIB date
AI provider fallback and auto-rotation
Storage analyzer for / and /datas
Docker, PM2, Nginx, Apache, Cloudflared, SSH, database, and port monitor
Security checker for firewall, SSH, fail2ban, failed login signal
Doctor command for dependency and install health
Optional anonymous telemetry foundation for future README badges
Self-update with /update
Safe shell integration
```

---

## Installation

Recommended install command:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Dasterm installs files to:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
```

Because of that, install needs `sudo` or root access.

---

## Direct Installer Actions

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

## Installer Menu

If you run the installer without arguments:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

You will see:

```text
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
```

---

## Interactive Setup

During setup, Dasterm asks:

```text
Choose language / Pilih bahasa
1) Indonesia
2) English

Choose dashboard mode
1) Lite - fast, compact, small logo
2) Full - complete, best logo, detailed data

Custom User@Host
User@Host [root@ubuntu]:

Choose color theme
1) Pastel
2) Cyber
3) Ocean
4) Mono

Show dashboard on every login? [Y/n]
Change terminal prompt to custom User@Host? [Y/n]
Enable slash commands like /help, /ai, /update? [Y/n]
Run initial speedtest and save result? [Y/n]
Allow anonymous statistics for README badges? [y/N]
```

All preferences are saved to:

```text
~/.config/dasterm/config.env
```

---

## After Install

Reload your shell:

```bash
source ~/.bashrc
```

Or open a new terminal.

Test Dasterm:

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

## Dashboard Modes

Dasterm v2 has only two dashboard modes:

```text
Lite
Full
```

### Lite Mode

Lite mode is fast and compact.

It shows:

```text
User@Host
OS
Kernel
Uptime
Health score
RAM usage
Root disk usage
Private IP
Load average
Saved speedtest summary
Small Dasterm logo
```

Run:

```bash
/lite
```

Or:

```bash
dasterm lite
```

### Full Mode

Full mode is more detailed.

It shows:

```text
Native distro logo through Fastfetch or Neofetch when available
Full system information
CPU model, cores, and flags
RAM and swap
Root disk and /datas disk if detected
GPU
Process count
Logged-in users
Private IP
Public IP cache
Gateway
DNS
Saved speedtest
Docker
Nginx
Apache
Cloudflared
SSH
UFW
```

Run:

```bash
/full
```

Or:

```bash
dasterm full
```

---

## Speedtest System

Dasterm does not run speedtest every time you log in.

During installation, you can choose to run the first speedtest. The result is saved to:

```text
~/.cache/dasterm/speedtest.json
```

The dashboard reads from that saved result.

View saved speedtest result:

```bash
/speedtest
```

Run a new speedtest and save the result:

```bash
/respeedtest
```

Speed conversion:

```text
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

Example:

```text
Download : 938.42 Mbps | 117.30 MB/s | 0.938 Gbps | 0.117 GB/s
Upload   : 812.10 Mbps | 101.51 MB/s | 0.812 Gbps | 0.102 GB/s
```

---

## Command Menu

Show all commands:

```bash
/help
```

Available commands:

```text
/help              Show command menu
/status            Show active dashboard mode
/lite              Show lite dashboard
/full              Show full dashboard
/speedtest         Show saved speedtest result
/respeedtest       Run speedtest again and save result
/network           Show network, DNS, gateway, IP, ports, and speed cache
/storage           Show disk, /datas, mounts, Docker root, largest folders
/services          Show Docker, PM2, Nginx, Apache, Cloudflared, SSH, ports
/security          Check firewall, SSH root login, password auth, fail2ban
/doctor            Check Dasterm installation, dependencies, cache, config
/ai <request>      Ask Dasterm AI
/brain-ai          Show today's AI memory
/clear-brain-ai    Clear today's AI memory
/ai-provider       Show AI provider order
/ai-reset-provider Reset AI provider order
/ai-test           Test all AI providers
/config            Open interactive config
/update            Update Dasterm
/uninstall         Open clean uninstall flow
/version           Show Dasterm version
/about             Show project info
```

Slash commands are shell aliases. The original command also works:

```bash
dasterm help
dasterm respeedtest
dasterm ai "cek storage server saya"
```

---

## AI Assistant

Ask AI:

```bash
/ai cek storage server saya
```

AI internally returns structured metadata:

```json
{
  "hasil": "Saya bisa menampilkan ringkasan storage, mount, root disk, /datas, Docker root, dan folder terbesar.",
  "cmd": "dasterm storage"
}
```

If AI suggests a command, Dasterm asks for approval first:

```text
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

The command will not run unless you approve it.

---

## AI Memory

AI memory is saved daily in:

```text
~/.cache/dasterm/ai-memory.json
```

Rules:

```text
Memory resets every day based on WIB date
/clear-brain-ai clears memory manually
If memory items exceed 5, Dasterm asks AI to summarize them
The summary becomes the next memory context
```

---

## AI Provider Fallback

Default provider order:

```text
1. chocomilk
2. prexzy copilot
3. prexzy zai
```

If the main provider is slow or fails for more than 10 seconds, Dasterm ignores it and uses fallback.

If the main provider delays 3 times, Dasterm rotates provider order automatically.

---

## Storage Analyzer

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
/datas filesystem
/datas inode usage
Docker root directory
Docker disk usage
Important mounts
Largest folders in /
Largest folders in /datas
Nearby node_modules
Suggestions for moving heavy data
```

---

## Services Monitor

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
Listening ports
Top service processes
```

---

## Security Check

Run:

```bash
/security
```

Shows:

```text
Security score
Firewall status
SSH root login setting
SSH password authentication setting
SSH public key setting
Fail2ban status
Sudo/wheel users
Failed login count in the last 24 hours
Recent logins
Suggestions
```

Dasterm only reads and suggests. It does not change SSH or firewall settings automatically.

---

## Doctor

Run:

```bash
/doctor
```

Checks:

```text
Dasterm binary
Library files
Config file
Shell integration
Config permissions
Cache directory
Speedtest cache
Dependencies
AI runtime
Internet connectivity
OS
Virtualization
Root disk
RAM
Failed units
Reboot requirement
```

---

## Update

Run:

```bash
/update
```

Dasterm checks the latest version from this repository, shows current and latest version, displays changelog if available, asks for confirmation, downloads files, applies update, and keeps your config.

---

## Reconfigure

Use:

```bash
/config
```

Or direct installer:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
```

---

## Uninstall

Use:

```bash
/uninstall
```

Or direct installer:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'
```

Uninstall removes:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
~/.config/dasterm
~/.cache/dasterm
Dasterm shell block from ~/.bashrc and ~/.zshrc
```

---

## Files

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/lib/
~/.config/dasterm/config.env
~/.cache/dasterm/
~/.local/share/dasterm/logs/
```

---

## Optional Anonymous Statistics

Anonymous statistics are disabled by default.

If enabled, they can power public badges such as:

```text
Total Installs
Total Runs
Top OS #1
Top OS #2
Top Virtualization
Top Language
Top Mode
```

Collected when enabled:

```text
Event type
Dasterm version
Linux distro
Linux distro version
CPU architecture
Virtualization type
Language
Dashboard mode
Anonymous machine hash
Date
```

Not intentionally collected:

```text
Username
Hostname
Personal files
Commands
Process list
IP address as stored data
Shell history
Private keys
Tokens
Passwords
```

---

## Supported Systems

Dasterm targets:

```text
Ubuntu
Debian
Linux Mint
Fedora
CentOS
RHEL
Rocky Linux
AlmaLinux
Arch Linux
Manjaro
EndeavourOS
openSUSE
Alpine Linux
WSL
Docker
LXC
KVM
QEMU
VMware
```

---

## Requirements

Core:

```text
bash
curl
jq
awk
sed
grep
coreutils
procps
iproute2
util-linux
```

Optional but recommended:

```text
fastfetch
neofetch
speedtest
speedtest-cli
pciutils
bc
docker
pm2
ufw
fail2ban
```

---

## Author

aka

Email: [akaanakbaik17@proton.me](mailto:akaanakbaik17@proton.me)

GitHub: [github.com/akaanakbaik](https://github.com/akaanakbaik)

---

## Project

Repository: [github.com/akaanakbaik/dastermv2](https://github.com/akaanakbaik/dastermv2)

---

## License

MIT License.

Made with love by aka.