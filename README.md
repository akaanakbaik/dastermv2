# Dasterm v2

> Interactive Linux terminal dashboard with cached speedtest, AI assistant, smart command menu, bilingual interface, system health, storage insight, security checks, and full VPS-friendly diagnostics.

<p align="center">
  <img src="https://img.shields.io/badge/Dasterm-v2.0.0-7c3aed?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Linux-supported-22c55e?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-0ea5e9?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-ID%20%7C%20EN-f97316?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-eab308?style=for-the-badge" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Total%20Installs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Total%20Runs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%231-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%232-coming%20soon-111827?style=flat-square" />
</p>

---

## What is Dasterm?

Dasterm is a modern terminal dashboard for Linux servers and VPS environments.

It gives you a clean terminal overview every time you log in, while also providing useful commands such as `/help`, `/storage`, `/network`, `/respeedtest`, `/doctor`, `/security`, `/services`, `/update`, and `/ai`.

Dasterm v2 is designed for:

- VPS owners
- Linux learners
- Developers
- Server admins
- Pterodactyl users
- Docker users
- Cloudflare Tunnel users
- Anyone who wants a beautiful and useful terminal dashboard

---

## Highlights

- Lite and Full dashboard modes
- Indonesian and English interface
- Cached speedtest result
- Accurate Mbps, MB/s, Gbps, and GB/s conversion
- Provider, region, server, ping, jitter, and packet loss info when available
- `/respeedtest` to retest internet speed and save new result
- `/speedtest` to view saved result without testing again
- AI assistant with metadata output parsing
- Command suggestion approval before execution
- AI provider fallback and auto-rotation
- Daily AI memory with auto-summary
- `/clear-brain-ai` to reset AI memory
- `/update` for self-update
- `/doctor` for installation and dependency checks
- `/storage` for root disk, `/datas`, Docker root, mounts, largest folders
- `/services` for Docker, PM2, Nginx, Apache, Cloudflared, SSH, databases, ports
- `/security` for firewall, SSH config, fail2ban, login signals
- Slash command aliases like `/help`
- Clean install, reconfigure, repair, and uninstall from one installer
- Safe shell injection
- Config stored in `~/.config/dasterm/config.env`
- Cache stored in `~/.cache/dasterm`
- Logs stored in `~/.local/share/dasterm/logs`

---

## Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
The installer gives you one interactive entry point:
Plain text
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
Interactive Setup
During setup, Dasterm asks:
Plain text
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
Dashboard Modes
Lite Mode
Lite mode is fast, clean, and compact.
It shows:
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
Full Mode
Full mode is detailed and more visual.
It shows:
Native distro logo through Fastfetch or Neofetch when available
Full system information
CPU model, cores, flags
RAM and swap
Root disk and /datas disk if detected
GPU
process count
logged-in users
private IP
public IP cache
gateway
DNS
saved speedtest
Docker, Nginx, Apache, Cloudflared, SSH, UFW status
Speedtest System
Dasterm does not run speedtest every time you log in.
During installation, you can choose to run the first speedtest. The result is saved to:
Plain text
~/.cache/dasterm/speedtest.json
The dashboard reads from that saved result.
To run a new speedtest:
Bash
/respeedtest
To view saved speedtest result:
Bash
/speedtest
Speedtest output includes:
Plain text
Provider
Region
Server
Source
Ping
Jitter
Packet Loss
Download Mbps
Download MB/s
Download Gbps
Download GB/s
Upload Mbps
Upload MB/s
Upload Gbps
Upload GB/s
Tested At
Conversion formula:
Plain text
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
Example:
Plain text
Download : 938.42 Mbps | 117.30 MB/s | 0.938 Gbps | 0.117 GB/s
Upload   : 812.10 Mbps | 101.51 MB/s | 0.812 Gbps | 0.101 GB/s
If provider or region is not available, Dasterm hides that field.
Command Menu
After installation, you can type:
Bash
/help
Available commands:
Plain text
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
The slash commands are aliases. The real command is also available:
Bash
dasterm help
dasterm respeedtest
dasterm ai "cek storage server saya"
AI Assistant
Dasterm includes an AI assistant:
Bash
/ai cek storage server saya
The AI must return structured metadata internally:
JSON
{
  "hasil": "Saya bisa menampilkan ringkasan storage, mount, root disk, /datas, dan folder terbesar.",
  "cmd": "dasterm storage"
}
If the AI suggests a command, Dasterm asks for approval first:
Plain text
AI suggests this command:

dasterm storage

Run this command? [y/N]
The command will not run unless you approve it.
AI Memory
AI memory is saved daily in:
Plain text
~/.cache/dasterm/ai-memory.json
Rules:
Memory resets every day at 00:00 WIB
/clear-brain-ai clears memory manually
If memory items exceed 5, Dasterm asks AI to summarize them
The summary becomes the next memory context
AI Provider Fallback
Default provider order:
Plain text
1. chocomilk
2. prexzy copilot
3. prexzy zai
If the main provider is slow or fails for more than 10 seconds, Dasterm ignores it and uses fallback.
If the main provider delays 3 times, Dasterm rotates provider order automatically:
Plain text
fallback1 becomes primary
fallback2 becomes fallback1
old primary becomes fallback2
Storage Analyzer
Bash
/storage
Shows:
Root disk
Root filesystem
Root inode usage
/datas disk if available
Docker root directory
Docker disk usage
Important mounts
Largest folders in /
Largest folders in /datas
Nearby node_modules
Suggestions for moving heavy data
This is especially useful for VPS setups with extra storage mounted at /datas.
Services Monitor
Bash
/services
Shows:
Docker status
Docker containers/images summary
PM2 apps
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
Security Check
Bash
/security
Shows:
Security score
Firewall status
SSH root login setting
SSH password authentication setting
SSH public key setting
Fail2ban status
sudo/wheel users
failed login count in the last 24 hours
recent logins
suggestions
Doctor
Bash
/doctor
Checks:
Dasterm binary
library files
config file
shell integration
config permissions
cache directory
speedtest cache
dependencies
AI runtime
internet connectivity
OS
virtualization
root disk
RAM
failed units
reboot requirement
Update
Bash
/update
Dasterm checks the latest version from this repository, shows current and latest version, displays changelog if available, asks for confirmation, downloads files, applies update, and keeps your config.
Reconfigure or Uninstall
Run the installer again:
Bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
Choose:
Plain text
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
Files
Plain text
/usr/local/bin/dasterm
/usr/local/share/dasterm/lib/
~/.config/dasterm/config.env
~/.cache/dasterm/
~/.local/share/dasterm/logs/
Optional Anonymous Statistics
Anonymous statistics are disabled by default.
If enabled, they can be used later for professional README badges such as:
Plain text
Total Installs
Total Runs
Top OS #1
Top OS #2
Top Virtualization
Top Language
Collected when enabled:
Plain text
event type
Dasterm version
Linux distro
Linux distro version
CPU architecture
virtualization type
language
dashboard mode
anonymous machine hash
date
Not intentionally collected:
Plain text
username
hostname
personal files
commands
process list
IP address as stored data
shell history
private keys
To make live badges work, you can later add a small backend such as:
Plain text
Cloudflare Worker + D1/KV
Recommended endpoints:
Plain text
POST /api/usage
GET /badge/installs
GET /badge/runs
GET /badge/top-os-1
GET /badge/top-os-2
GET /badge/top-virt
GET /stats
After the backend is ready, set:
Bash
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
Recommended GitHub Actions
After all files are uploaded, you should add a GitHub Action to test Bash syntax and ShellCheck.
Recommended workflow:
Plain text
.github/workflows/test.yml
Suggested checks:
Plain text
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
shellcheck install.sh bin/dasterm lib/*.sh
ShellCheck can warn about style and safety issues before releases.
Supported Systems
Dasterm targets:
Plain text
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
Requirements
Core:
Plain text
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
Optional but recommended:
Plain text
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
Dasterm has fallbacks when optional tools are missing.
Author
aka
Email: akaanakbaik17@proton.me
GitHub: github.com/akaanakbaik⁠�
Project
Repository: github.com/akaanakbaik/dastermv2⁠�
License
MIT License.
Made with love by aka.