# Dasterm v2 Development Guide

Dokumen ini menjelaskan struktur project, cara testing, standar kode, dan rencana pengembangan Dasterm v2.

---

## 1. Struktur Project

```text
dastermv2/
├── install.sh
├── VERSION
├── CHANGELOG.md
├── LICENSE
├── README.md
├── bin/
│   └── dasterm
├── lib/
│   ├── core.sh
│   ├── i18n.sh
│   ├── render.sh
│   ├── system.sh
│   ├── network.sh
│   ├── speedtest.sh
│   ├── storage.sh
│   ├── services.sh
│   ├── security.sh
│   ├── doctor.sh
│   ├── ai.sh
│   ├── update.sh
│   └── telemetry.sh
├── docs/
│   ├── USAGE.md
│   ├── COMMANDS.md
│   ├── INSTALLER.md
│   ├── SPEEDTEST.md
│   ├── AI.md
│   ├── SECURITY.md
│   ├── TELEMETRY.md
│   └── DEVELOPMENT.md
└── .github/
    └── workflows/
        └── test.yml
```

---

## 2. Filosofi Arsitektur

Dasterm v2 tidak lagi menaruh dashboard panjang di `.bashrc`.

Arsitektur baru:

```text
.bashrc/.zshrc hanya shell integration kecil
/usr/local/bin/dasterm sebagai entrypoint
/usr/local/share/dasterm/lib sebagai library
~/.config/dasterm sebagai config
~/.cache/dasterm sebagai cache
~/.local/share/dasterm/logs sebagai log
```

Tujuan:

```text
Lebih rapi
Lebih mudah update
Lebih mudah uninstall
Lebih mudah debug
Lebih aman
Lebih modular
```

---

## 3. Entry Point

File utama:

```text
bin/dasterm
```

Saat install, file ini dipasang ke:

```text
/usr/local/bin/dasterm
```

Semua command lewat file ini:

```bash
dasterm help
dasterm status
dasterm ai "halo"
dasterm respeedtest
```

---

## 4. Library

Library ada di:

```text
lib/
```

Saat install, library dipasang ke:

```text
/usr/local/share/dasterm/lib/
```

Fungsi setiap file:

```text
core.sh       fungsi umum, warna, config, cache, helper
i18n.sh       bahasa Indonesia/English
render.sh     render dashboard lite/full
system.sh     info OS, CPU, RAM, disk, service state
network.sh    IP, DNS, gateway, ping, open ports
speedtest.sh  speedtest run/show/cache/conversion
storage.sh    disk analyzer, /datas, docker root, largest dirs
services.sh   docker, pm2, nginx, apache, cloudflared, ports
security.sh   firewall, ssh config, fail2ban, login signal
doctor.sh     health check instalasi Dasterm
ai.sh         AI provider, metadata parser, memory, approval
update.sh     self-update logic
telemetry.sh  optional anonymous stats foundation
```

---

## 5. Config

Config user:

```text
~/.config/dasterm/config.env
```

Contoh:

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

## 6. Cache

Cache user:

```text
~/.cache/dasterm/
```

Isi:

```text
speedtest.json
ai-memory.json
ai-provider-state.json
public-ip.cache
```

Cache boleh dihapus.

Dasterm akan membuat ulang jika dibutuhkan.

---

## 7. Logs

Log user:

```text
~/.local/share/dasterm/logs/
```

Log utama:

```text
dasterm.log
```

Log tidak boleh menyimpan secret.

---

## 8. Coding Style

Gunakan Bash:

```bash
#!/usr/bin/env bash
```

Mode aman untuk file utama:

```bash
set -euo pipefail
IFS=$' \t\n'
```

Untuk library, jangan selalu pakai `set -e` karena bisa memengaruhi caller.

Gunakan function prefix:

```text
dasterm_
```

Contoh:

```bash
dasterm_storage_show() {
  :
}
```

---

## 9. Nama Function

Format:

```text
dasterm_<module>_<action>
```

Contoh:

```bash
dasterm_ai_ask
dasterm_ai_provider_show
dasterm_speedtest_run
dasterm_speedtest_show
dasterm_storage_largest_dirs
dasterm_security_suggestions
```

Untuk helper umum:

```bash
dasterm_has
dasterm_now
dasterm_date
dasterm_kv
dasterm_title
```

---

## 10. Output Style

Gunakan helper dari `core.sh`:

```bash
dasterm_title "Title"
dasterm_kv "Key" "Value"
dasterm_success "Done"
dasterm_warn "Warning"
dasterm_error "Error"
dasterm_info "Info"
dasterm_footer
```

Jangan membuat format berbeda-beda di setiap module.

---

## 11. Bahasa

Teks yang sering muncul harus masuk ke:

```text
lib/i18n.sh
```

Gunakan:

```bash
dasterm_t key
```

Contoh:

```bash
dasterm_title "$(dasterm_t network)"
```

Jika menambah teks baru yang muncul ke user, usahakan tambahkan versi:

```text
id
en
```

---

## 12. Dashboard Mode

Dasterm hanya punya dua mode:

```text
lite
full
```

Jangan menambah mode baru tanpa alasan kuat.

Jika butuh tampilan detail, gunakan command terpisah:

```bash
/storage
/network
/services
/security
/doctor
```

---

## 13. Speedtest Development

File:

```text
lib/speedtest.sh
```

Provider order:

```text
speedtest
speedtest-cli
curl fallback
```

Hasil wajib disimpan sebagai JSON:

```text
~/.cache/dasterm/speedtest.json
```

Field minimal:

```json
{
  "tested_at": "2026-05-10 19:30:00 WIB",
  "source": "ookla-speedtest",
  "provider": "",
  "region": "",
  "server": "",
  "ping": {
    "ms": "0",
    "jitter_ms": "0",
    "packet_loss": "unknown"
  },
  "download": {
    "bps": "0",
    "mbps": "0",
    "MBps": "0",
    "gbps": "0",
    "GBps": "0"
  },
  "upload": {
    "bps": "0",
    "mbps": "0",
    "MBps": "0",
    "gbps": "0",
    "GBps": "0"
  }
}
```

---

## 14. AI Development

File:

```text
lib/ai.sh
```

AI wajib:

```text
Menggunakan system prompt ketat
Menerima output JSON metadata
Mengambil hasil
Mengambil cmd jika ada
Memvalidasi cmd
Meminta persetujuan
Menjalankan command hanya jika user setuju
Menyimpan memory input/output
Reset memory harian WIB
Auto summary jika item > 5
Fallback provider jika primary gagal
Rotasi provider jika primary delay 3 kali
```

Command AI wajib melewati:

```bash
dasterm_ai_command_safe
```

Jangan menjalankan command AI secara langsung tanpa validasi.

---

## 15. Update Development

File:

```text
lib/update.sh
```

Update harus:

```text
Cek VERSION
Tampilkan current/latest
Tampilkan changelog jika ada
Minta konfirmasi
Download file ke tmp
Apply ke /usr/local/bin dan /usr/local/share/dasterm/lib
Menjaga config user
Hapus tmp
```

Jangan menghapus:

```text
~/.config/dasterm
~/.cache/dasterm
~/.local/share/dasterm
```

---

## 16. Telemetry Development

File:

```text
lib/telemetry.sh
```

Telemetry harus:

```text
Off by default
Opt-in
Tidak mengirim data sensitif
Menggunakan anonymous hash
Bisa dimatikan kapan pun
Tidak menyebabkan command gagal jika endpoint mati
Timeout pendek
```

Event yang aman:

```text
install
run
update
```

Jangan kirim:

```text
Command user
Prompt AI
Output AI
Hostname
Username
Process list
IP sebagai stored data
File path personal
```

---

## 17. Testing Manual

Syntax check:

```bash
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
```

ShellCheck:

```bash
shellcheck -x install.sh bin/dasterm lib/*.sh
```

Install test:

```bash
sudo bash install.sh
```

Command test:

```bash
dasterm version
dasterm help
dasterm lite
dasterm full
dasterm doctor
dasterm network
dasterm storage
dasterm services
dasterm security
```

Speedtest test:

```bash
dasterm respeedtest
dasterm speedtest
```

AI test:

```bash
dasterm ai-test
dasterm ai "halo"
dasterm ai "cek storage"
```

Update test:

```bash
dasterm update
```

---

## 18. GitHub Actions

Workflow:

```text
.github/workflows/test.yml
```

Checks:

```text
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
shellcheck -x install.sh bin/dasterm lib/*.sh
minimal bootstrap test
dasterm version
dasterm help
dasterm doctor
```

---

## 19. Release Flow

Untuk release baru:

```text
Update VERSION
Update CHANGELOG.md
Update README.md jika fitur berubah
Run bash -n
Run shellcheck
Commit
Push
Pastikan GitHub Actions hijau
Tag release
```

Contoh:

```bash
git tag v2.0.0
git push origin v2.0.0
```

---

## 20. Commit Message

Format sederhana:

```text
feat: add storage analyzer
fix: repair ai provider fallback
docs: update usage guide
refactor: split render module
security: restrict ai command whitelist
ci: add shellcheck workflow
```

---

## 21. Branch Strategy

Rekomendasi:

```text
main      stable
dev       development
feature/* fitur baru
fix/*     perbaikan
docs/*    dokumentasi
```

Untuk project kecil, boleh langsung main, tapi pastikan GitHub Actions aman.

---

## 22. Roadmap v2.1

Ide untuk v2.1:

```text
Live telemetry backend
Cloudflare Worker badge API
D1 database
More dashboard themes
Better terminal width handling
Better fastfetch config
More service detectors
Safer AI command registry
Local command explanation
Export report to text/json
```

---

## 23. Roadmap v2.2

Ide untuk v2.2:

```text
Plugin system
Custom modules
Custom dashboard layout
Remote stats page
Install script checksum
Signature verification
Better distro-specific install
Termux support
Fish shell support
```

---

## 24. Design Rule

Jangan membuat Dasterm terlalu berat.

Prioritas:

```text
Cepat saat login
Data valid
Fallback aman
Interaksi jelas
Tidak merusak shell user
Tidak menjalankan command berbahaya
Mudah uninstall
```

---

## 25. Kesimpulan

Dasterm v2 harus terasa seperti:

```text
Mini control panel VPS di terminal
Tetap ringan
Tetap aman
Tetap interaktif
Mudah dipahami pemula
Berguna untuk developer
```