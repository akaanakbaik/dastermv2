# Dasterm Roadmap

Roadmap ini berisi arah pengembangan Dasterm setelah v2.0.0.

Dasterm v2 fokus pada:

```text
Interactive terminal dashboard
Lite/Full mode
Bilingual UI
Cached speedtest
AI assistant
Storage analyzer
Service monitor
Security check
Doctor
Self-update
Optional telemetry foundation
```

---

## v2.0.0

Status:

```text
Planned initial v2 release
```

Fokus:

```text
Rewrite architecture
Command-based Dasterm binary
Clean shell integration
Lite/Full dashboard
Interactive installer
Speedtest cache
AI assistant
AI memory
AI fallback provider
Storage analyzer
Services monitor
Security check
Doctor
Self-update
README rewrite
Docs
GitHub Actions
Optional Worker telemetry backend
```

---

## v2.0.1

Fokus bug fix kecil.

Target:

```text
ShellCheck cleanup
Fix distro-specific dependency names
Improve installer fallback
Improve /doctor detection
Improve terminal width handling
Fix minor i18n text
Fix speedtest edge cases
```

Prioritas:

```text
Stabilitas
Kompatibilitas
Tidak menambah fitur besar
```

---

## v2.1.0

Fokus telemetry badge live.

Target:

```text
Cloudflare Worker finalization
D1 migration polish
Live README badge
Install counter
Run counter
Top OS #1
Top OS #2
Top virtualization
Top language
Top mode
Public stats endpoint
Better rate limit
Better privacy text
```

Badge yang direncanakan:

```text
Total Installs
Total Runs
Top OS #1
Top OS #2
Top Virtualization
Top Language
Top Mode
Latest Version
```

Catatan:

```text
Telemetry tetap off by default.
User harus opt-in.
```

---

## v2.2.0

Fokus plugin dan customization.

Target:

```text
Plugin system
Custom modules
Custom dashboard sections
Custom logo file
Custom welcome message
Custom command registry
Better theme engine
More language support
Better Termux compatibility
Fish shell support
```

Kemungkinan folder:

```text
~/.config/dasterm/plugins/
~/.config/dasterm/logo.txt
~/.config/dasterm/modules.env
```

---

## v2.3.0

Fokus report/export.

Target:

```text
Export dashboard to JSON
Export dashboard to TXT
Export doctor report
Export security report
Export storage report
Optional upload report
Shareable server summary
```

Command ide:

```bash
dasterm export json
dasterm export text
dasterm doctor --json
dasterm storage --json
dasterm security --json
```

---

## v2.4.0

Fokus AI lebih cerdas tapi tetap aman.

Target:

```text
AI command registry lebih rapi
AI local explanation for Dasterm command
AI can explain stored speedtest
AI can explain doctor output
AI can explain storage issue
AI memory encryption option
AI provider health score
AI provider latency tracking
```

Command ide:

```bash
/ai explain doctor
/ai explain speedtest
/ai why root disk high
/ai-provider stats
```

---

## v2.5.0

Fokus server assistant ringan.

Target:

```text
Guided setup recommendations
Docker move advisor
Pterodactyl storage advisor
Cloudflared tunnel detector
PM2 app advisor
Nginx config detector
SSL certificate expiry check
Domain DNS helper
```

Command ide:

```bash
/advisor
/ssl
/domains
/tunnels
```

---

## v3.0.0

Fokus major version.

Kemungkinan arah:

```text
Modular TUI
Interactive keyboard navigation
Plugin marketplace sederhana
Remote dashboard optional
Better report generator
Optional web dashboard
Optional local API server
```

Catatan:

```text
v3 tidak boleh mengorbankan prinsip ringan dan aman.
```

---

## Prinsip Roadmap

Setiap fitur baru harus menjawab:

```text
Apakah fitur ini berguna untuk VPS/Linux?
Apakah fitur ini aman?
Apakah fitur ini memperlambat login?
Apakah fitur ini mudah dimatikan?
Apakah fitur ini mudah dihapus?
Apakah fitur ini bisa dijelaskan ke pemula?
```

Jika tidak, fitur sebaiknya tidak masuk core.

---

## Prioritas Tertinggi

Prioritas utama setelah v2.0.0:

```text
1. Stabilitas install/update/uninstall
2. ShellCheck cleanup
3. Kompatibilitas distro
4. Speedtest reliability
5. AI command safety
6. Documentation clarity
7. Live telemetry backend
```

---

## Fitur yang Tidak Diprioritaskan

Untuk menjaga Dasterm tetap ringan:

```text
Monitoring real-time berat
Agent daemon background
Auto-fix security tanpa izin
Auto-install banyak package besar
Web dashboard wajib
Telemetry wajib
AI bebas eksekusi command
```

---

## Kesimpulan

Dasterm akan berkembang sebagai:

```text
Mini control panel VPS di terminal
Ringan
Interaktif
Aman
Mudah dipahami
Bisa dikembangkan
```