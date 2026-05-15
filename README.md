<div align="center">

# Dasterm v2

### A smart, beautiful, and VPS-friendly Linux terminal dashboard.

Dasterm v2 turns a normal Linux terminal login into a clean interactive dashboard with system insight, cached speedtest, slash commands, AI assistance, storage diagnostics, security checks, service monitoring, self-update, and optional public telemetry badges.

<br />

<a href="https://github.com/akaanakbaik/dastermv2">
  <img src="https://img.shields.io/badge/project-Dasterm%20v2-111827?style=for-the-badge" alt="Project" />
</a>
<a href="https://github.com/akaanakbaik/dastermv2/blob/main/LICENSE">
  <img src="https://img.shields.io/badge/license-MIT-16a34a?style=for-the-badge" alt="License" />
</a>
<a href="https://github.com/akaanakbaik/dastermv2">
  <img src="https://img.shields.io/badge/platform-Linux-2563eb?style=for-the-badge" alt="Platform" />
</a>
<a href="https://github.com/akaanakbaik/dastermv2">
  <img src="https://img.shields.io/badge/shell-Bash-f59e0b?style=for-the-badge" alt="Shell" />
</a>

<br />
<br />

<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/install.json" alt="Total installs" />
</a>
<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/run.json" alt="Total runs" />
</a>
<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/ai.json" alt="AI usage" />
</a>
<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/top-os-1.json" alt="Top OS 1" />
</a>
<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/top-os-2.json" alt="Top OS 2" />
</a>
<a href="https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/generated/summary.json">
  <img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/stats/badges/machines.json" alt="Unique machines" />
</a>

<br />
<br />

[Install](#installation) · [Commands](#commands) · [AI Assistant](#ai-assistant) · [Speedtest](#speedtest-system) · [Security](#security-check) · [Telemetry](#optional-anonymous-telemetry)

</div>

---

## Overview

Dasterm v2 is an interactive terminal dashboard for Linux servers, VPS, containers, and daily development environments. It is designed to make server monitoring easier without opening a separate web panel.

When you open a terminal, Dasterm can show a clean dashboard containing system status, speedtest cache, storage usage, running services, network information, security hints, and quick slash commands.

It is especially useful for:

- VPS owners who want a beautiful login dashboard
- Linux learners who want readable server information
- Developers who manage Node.js, Docker, PM2, Nginx, Apache, Cloudflared, or databases
- Pterodactyl users who often debug services, ports, storage, and network issues
- Server admins who want quick diagnostics without remembering many commands

---

## Features

| Area | What Dasterm v2 does |
| --- | --- |
| Dashboard | Lite and Full terminal dashboard modes |
| Language | Indonesian and English interface |
| Installer | Install, update, repair, reconfigure, and uninstall from one installer |
| Speedtest | Cached speedtest with Mbps, MB/s, Gbps, and GB/s conversion |
| AI | AI assistant with safe command approval before execution |
| AI Memory | Daily memory cache based on WIB date with manual reset support |
| Provider Fallback | AI provider fallback, timeout handling, and auto-rotation |
| Storage | Root disk, `/datas`, mounts, Docker root, inode usage, and largest folders |
| Services | Docker, PM2, Nginx, Apache, Cloudflared, SSH, Cron, databases, ports |
| Security | Firewall, SSH, fail2ban, failed login signal, sudo users, login history |
| Doctor | Dependency, config, cache, shell integration, network, and system health check |
| Update | Self-update flow that keeps existing configuration |
| Telemetry | Optional anonymous statistics for public README badges |

---

## Installation

Run this command on your Linux server:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Dasterm installs to:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
```

Root or `sudo` access is required because Dasterm installs a global executable and shared runtime files.

---

## Direct Installer Actions

| Action | Command |
| --- | --- |
| Install or update | `bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --install'` |
| Reconfigure | `bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'` |
| Repair | `bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'` |
| Uninstall | `bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --uninstall'` |

When the installer is started without arguments, it opens an interactive menu:

```text
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
```

---

## Interactive Setup

During setup, Dasterm can ask for:

- Interface language: Indonesian or English
- Dashboard mode: Lite or Full
- Custom `User@Host` display
- Color theme: Pastel, Cyber, Ocean, or Mono
- Dashboard display on every login
- Slash command aliases such as `/help`, `/ai`, and `/update`
- Initial speedtest cache generation
- Optional anonymous statistics for README badges

Configuration is saved in:

```text
~/.config/dasterm/config.env
```

After installation, reload your shell:

```bash
source ~/.bashrc
```

Or open a new terminal session.

Test the installation:

```bash
dasterm version
dasterm help
dasterm doctor
```

---

## Dashboard Modes

### Lite Mode

Lite mode is fast, compact, and ideal for low-resource VPS environments.

It shows:

- User and host display
- OS, kernel, and uptime
- Health score
- RAM and root disk usage
- Private IP
- Load average
- Saved speedtest summary
- Small Dasterm logo

Run:

```bash
/lite
```

Or:

```bash
dasterm lite
```

### Full Mode

Full mode is detailed and suitable for deeper system inspection.

It shows:

- Native distro logo using Fastfetch or Neofetch when available
- Full system information
- CPU model, cores, and flags
- RAM and swap usage
- Root disk and `/datas` disk if detected
- GPU information
- Process count and logged-in users
- Private IP, public IP cache, gateway, and DNS
- Saved speedtest result
- Docker, Nginx, Apache, Cloudflared, SSH, and UFW status

Run:

```bash
/full
```

Or:

```bash
dasterm full
```

---

## Commands

Show all commands:

```bash
/help
```

| Command | Description |
| --- | --- |
| `/help` | Show command menu |
| `/status` | Show active dashboard mode |
| `/lite` | Show Lite dashboard |
| `/full` | Show Full dashboard |
| `/speedtest` | Show saved speedtest result |
| `/respeedtest` | Run speedtest again and save the result |
| `/network` | Show network, DNS, gateway, IP, ports, and speed cache |
| `/storage` | Show disk, `/datas`, mounts, Docker root, and largest folders |
| `/services` | Show Docker, PM2, Nginx, Apache, Cloudflared, SSH, and ports |
| `/security` | Check firewall, SSH, fail2ban, and failed login signals |
| `/doctor` | Check installation, dependencies, cache, config, and system health |
| `/ai <request>` | Ask Dasterm AI |
| `/brain-ai` | Show today's AI memory |
| `/clear-brain-ai` | Clear today's AI memory |
| `/ai-provider` | Show AI provider order |
| `/ai-reset-provider` | Reset AI provider order |
| `/ai-test` | Test all AI providers |
| `/config` | Open interactive configuration |
| `/update` | Update Dasterm |
| `/uninstall` | Open clean uninstall flow |
| `/version` | Show Dasterm version |
| `/about` | Show project info |

Slash commands are shell aliases. The original CLI also works:

```bash
dasterm help
dasterm respeedtest
dasterm ai "cek storage server saya"
```

---

## Speedtest System

Dasterm does not run speedtest every time you log in. That keeps login fast and avoids wasting bandwidth.

During installation, you can run the first speedtest. The result is saved to:

```text
~/.cache/dasterm/speedtest.json
```

Show saved result:

```bash
/speedtest
```

Run a new test and update the cache:

```bash
/respeedtest
```

Conversion used by Dasterm:

```text
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

Example output:

```text
Download : 938.42 Mbps | 117.30 MB/s | 0.938 Gbps | 0.117 GB/s
Upload   : 812.10 Mbps | 101.51 MB/s | 0.812 Gbps | 0.102 GB/s
```

---

## AI Assistant

Ask AI from your terminal:

```bash
/ai cek storage server saya
```

Dasterm expects structured AI output like this:

```json
{
  "hasil": "Saya bisa menampilkan ringkasan storage, mount, root disk, /datas, Docker root, dan folder terbesar.",
  "cmd": "dasterm storage"
}
```

If AI suggests a command, Dasterm asks for confirmation first:

```text
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

The command is not executed unless you approve it.

---

## AI Memory

AI memory is stored daily in:

```text
~/.cache/dasterm/ai-memory.json
```

Behavior:

- Memory resets every day based on WIB date
- `/clear-brain-ai` clears memory manually
- When memory items exceed the configured limit, Dasterm asks AI to summarize them
- The summary becomes the next context memory

---

## AI Provider Fallback

Default provider order:

```text
1. chocomilk
2. prexzy copilot
3. prexzy zai
```

Fallback behavior:

- If the main provider is slow or fails for more than 10 seconds, Dasterm tries the next provider
- If the main provider delays repeatedly, Dasterm can rotate provider order automatically
- `/ai-provider` shows the current order
- `/ai-reset-provider` resets the provider order
- `/ai-test` checks all configured providers

---

## Storage Analyzer

Run:

```bash
/storage
```

It checks:

- Root disk usage
- Root filesystem and inode usage
- `/datas` disk when available
- `/datas` filesystem and inode usage
- Docker root directory
- Docker disk usage
- Important mounts
- Largest folders in `/`
- Largest folders in `/datas`
- Nearby `node_modules`
- Suggestions for moving heavy data

---

## Services Monitor

Run:

```bash
/services
```

It checks:

- Docker
- PM2
- Nginx
- Apache
- Cloudflared
- SSH
- Cron
- PostgreSQL
- MySQL or MariaDB
- Redis
- Failed systemd units
- Listening ports
- Top service processes

---

## Security Check

Run:

```bash
/security
```

It checks:

- Security score
- Firewall status
- SSH root login setting
- SSH password authentication setting
- SSH public key setting
- Fail2ban status
- Sudo or wheel users
- Failed login count in the last 24 hours
- Recent logins
- Recommended hardening suggestions

Dasterm only reads and suggests. It does not automatically change SSH, firewall, or login settings.

---

## Doctor

Run:

```bash
/doctor
```

Doctor checks:

- Dasterm binary
- Library files
- Config file
- Shell integration
- Config permissions
- Cache directory
- Speedtest cache
- Dependencies
- AI runtime
- Internet connectivity
- OS information
- Virtualization
- Root disk
- RAM
- Failed systemd units
- Reboot requirement

---

## Update

Run:

```bash
/update
```

Dasterm checks the latest version from this repository, compares it with your installed version, shows changelog information when available, asks for confirmation, downloads updated files, applies the update, and keeps your existing configuration.

---

## Reconfigure

Use the built-in configuration menu:

```bash
/config
```

Or run the installer directly:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --reconfigure'
```

---

## Uninstall

Use:

```bash
/uninstall
```

Or run:

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

## File Locations

| Path | Purpose |
| --- | --- |
| `/usr/local/bin/dasterm` | Main executable |
| `/usr/local/share/dasterm/` | Shared runtime files |
| `/usr/local/share/dasterm/lib/` | Library scripts |
| `~/.config/dasterm/config.env` | User configuration |
| `~/.cache/dasterm/` | Cache files |
| `~/.cache/dasterm/speedtest.json` | Saved speedtest result |
| `~/.cache/dasterm/ai-memory.json` | Daily AI memory |
| `~/.local/share/dasterm/logs/` | Runtime logs |

---

## Optional Anonymous Telemetry

Anonymous telemetry is disabled by default and only runs when you enable it.

It can power public project badges such as:

- Total installs
- Total runs
- AI usage
- Top OS #1
- Top OS #2
- Top virtualization
- Top language
- Top mode
- Unique machines

When enabled, Dasterm may collect:

- Event type
- Dasterm version
- Linux distro and version
- CPU architecture
- Virtualization type
- Language preference
- Dashboard mode
- Anonymous machine hash
- Date

Dasterm does not intentionally collect:

- Username
- Hostname
- Personal files
- Commands
- Process list
- Stored IP address data
- Shell history
- Private keys
- Tokens
- Passwords

---

## Supported Systems

Dasterm targets common Linux environments, including:

- Ubuntu
- Debian
- Linux Mint
- Fedora
- CentOS
- RHEL
- Rocky Linux
- AlmaLinux
- Arch Linux
- Manjaro
- EndeavourOS
- openSUSE
- Alpine Linux
- WSL
- Docker
- LXC
- KVM
- QEMU
- VMware

---

## Requirements

Core dependencies:

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

## Troubleshooting

Run Doctor first:

```bash
/doctor
```

Common recovery commands:

```bash
/update
/config
```

Repair directly with the installer:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f" --repair'
```

If slash commands are not available, reload your shell:

```bash
source ~/.bashrc
```

Or open a new terminal session.

---

## Project Links

- Repository: [github.com/akaanakbaik/dastermv2](https://github.com/akaanakbaik/dastermv2)
- Author: [aka](https://github.com/akaanakbaik)
- Email: [akaanakbaik17@proton.me](mailto:akaanakbaik17@proton.me)

---

## License

MIT License.

Made with love by aka.
