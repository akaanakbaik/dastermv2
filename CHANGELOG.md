# Changelog

## v2.0.0

Dasterm v2 is a full rewrite focused on interactive setup, better dashboard logic, cached network speed, AI assistant, bilingual UI, clean commands, safer shell integration, and VPS-ready diagnostics.

### Added

- New repository target: `akaanakbaik/dastermv2`
- New command-based architecture using `/usr/local/bin/dasterm`
- Clean shell integration with small `.bashrc` and `.zshrc` block
- Interactive installer with one menu for install, update, reconfigure, repair, uninstall, and exit
- Language selection: Indonesian and English
- Dashboard mode selection: Lite and Full
- Theme selection: Pastel, Cyber, Ocean, and Mono
- Optional custom `User@Host`
- Optional prompt customization
- Optional slash command aliases
- Optional initial speedtest during installation
- Optional anonymous telemetry foundation for future README badges
- Lite dashboard with compact logo and fast system summary
- Full dashboard with Fastfetch or Neofetch logo fallback
- System health score
- RAM, swap, disk, uptime, CPU, GPU, virtualization, users, and process info
- Cached public IP lookup
- Network view with private IP, public IP, interface, gateway, DNS, ping, ports, and speed cache
- Speedtest cache saved to `~/.cache/dasterm/speedtest.json`
- `/respeedtest` command to run speedtest again and save the result
- `/speedtest` command to view saved speedtest without retesting
- Accurate speed conversion:
  - Mbps
  - MB/s
  - Gbps
  - GB/s
- Speedtest provider, region, server, ping, jitter, packet loss, and tested time when available
- Storage analyzer with root disk, `/datas`, mount list, Docker root, Docker usage, largest folders, and node_modules scan
- Service monitor for Docker, PM2, Nginx, Apache, Cloudflared, SSH, Cron, database services, failed units, and open ports
- Security checker with firewall, SSH root login, password authentication, pubkey authentication, fail2ban, sudo users, failed login count, and recent logins
- Doctor command for installation health, dependencies, permissions, cache, connectivity, and system signals
- AI assistant command: `/ai <request>`
- AI structured metadata parsing with `hasil` and optional `cmd`
- AI command approval before execution
- Safe command whitelist for AI command execution
- AI memory stored daily
- AI memory auto-reset based on WIB date
- `/clear-brain-ai` command
- `/brain-ai` command
- AI memory summarization after more than five items
- AI provider fallback:
  - chocomilk
  - prexzy copilot
  - prexzy zai
- AI provider auto-rotation after three primary delays
- `/ai-provider`
- `/ai-reset-provider`
- `/ai-test`
- `/update` command with version check and changelog display
- README rewritten for v2
- GitHub Actions test workflow
- MIT License

### Changed

- Old long `.bashrc` dashboard block replaced with lightweight shell integration
- Dashboard logic moved into library files
- Config moved to `~/.config/dasterm/config.env`
- Cache moved to `~/.cache/dasterm`
- Logs moved to `~/.local/share/dasterm/logs`
- Default display is more responsive and cleaner
- Install and uninstall now use one interactive installer

### Security

- Config uses `chmod 600`
- AI command execution requires confirmation
- AI commands are restricted to safe known Dasterm commands
- Telemetry is disabled by default
- Anonymous telemetry design avoids username, hostname, process list, files, command history, and private data

### Notes

- Live README usage badges need a future backend such as Cloudflare Worker plus D1 or KV
- Fastfetch, Neofetch, Ookla Speedtest, speedtest-cli, Docker, PM2, UFW, and Fail2ban are optional