# Dasterm v2 Architecture

Dokumen ini menjelaskan arsitektur Dasterm v2.

---

## 1. Gambaran Umum

Dasterm v2 memakai arsitektur modular.

Tujuan:

```text
Tidak menaruh logic panjang di .bashrc
Mudah update
Mudah uninstall
Mudah test
Mudah tambah fitur
Lebih aman
```

---

## 2. Komponen Utama

```text
install.sh
bin/dasterm
lib/*.sh
docs/*.md
worker/
.github/workflows/test.yml
```

---

## 3. Installer

File:

```text
install.sh
```

Tugas:

```text
Menampilkan wizard interaktif
Memilih bahasa
Memilih mode
Memilih theme
Mengatur User@Host
Mengatur prompt
Mengatur slash alias
Mengatur speedtest awal
Mengatur telemetry
Install dependency
Download source dari GitHub
Install binary
Install library
Write config
Inject shell integration
Run initial speedtest jika dipilih
Uninstall
Repair
```

Installer memakai:

```text
/tmp/dasterm-install.lock
```

Untuk mencegah dua installer berjalan bersamaan.

---

## 4. Binary Entry Point

File repo:

```text
bin/dasterm
```

Lokasi setelah install:

```text
/usr/local/bin/dasterm
```

Tugas:

```text
Load config
Load library
Dispatch command
Generate shell init
Render dashboard
Run modules
```

Contoh dispatch:

```text
dasterm help
dasterm status
dasterm speedtest
dasterm respeedtest
dasterm ai
dasterm update
```

---

## 5. Library Directory

Repo:

```text
lib/
```

Install:

```text
/usr/local/share/dasterm/lib/
```

Library dipisahkan berdasarkan domain.

```text
core.sh       helper dasar
i18n.sh       bahasa
render.sh     dashboard rendering
system.sh     system info
network.sh    network info
speedtest.sh  speedtest cache
storage.sh    storage analyzer
services.sh   service monitor
security.sh   security checker
doctor.sh     health checker
ai.sh         AI assistant
update.sh     self update
telemetry.sh  optional telemetry
```

---

## 6. Shell Integration

Dasterm menambahkan block kecil ke:

```text
~/.bashrc
~/.zshrc
```

Block:

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

Fungsi:

```text
Load slash aliases
Apply custom prompt jika aktif
Show dashboard jika aktif
```

---

## 7. Config Layer

Config:

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

Config diload oleh:

```text
bin/dasterm
core.sh
```

---

## 8. Cache Layer

Cache:

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

Cache bisa dihapus dan dibuat ulang.

---

## 9. Data Layer

Data/log:

```text
~/.local/share/dasterm/logs/
```

File log:

```text
dasterm.log
```

Log hanya untuk operasi dasar.

Jangan menyimpan secret.

---

## 10. Dashboard Flow

Saat terminal dibuka:

```text
.bashrc/.zshrc
  -> dasterm shell-init
      -> print alias/prompt commands
  -> dasterm auto
      -> load config
      -> if DASTERM_SHOW=manual exit
      -> render dashboard by mode
```

Mode:

```text
lite
full
```

---

## 11. Command Flow

Contoh:

```bash
dasterm storage
```

Flow:

```text
bin/dasterm
  -> dasterm_dispatch
  -> dasterm_load_all
  -> source lib files
  -> dasterm_storage_show
  -> render output
```

---

## 12. Speedtest Flow

Command:

```bash
dasterm respeedtest
```

Flow:

```text
dasterm_speedtest_run
  -> try Ookla speedtest
  -> fallback speedtest-cli
  -> fallback curl Cloudflare
  -> calculate Mbps, MB/s, Gbps, GB/s
  -> save speedtest.json
  -> show result
```

Dashboard:

```text
dasterm_render_speed_summary
  -> read speedtest.json
  -> show saved result
```

Dashboard tidak menjalankan test ulang.

---

## 13. AI Flow

Command:

```bash
dasterm ai "cek storage"
```

Flow:

```text
dasterm_ai_ask
  -> load memory
  -> build system prompt
  -> call primary provider
  -> fallback if timeout/error
  -> parse JSON
  -> print hasil
  -> save memory input/output
  -> if cmd exists:
      -> validate whitelist
      -> ask approval
      -> run command if yes
```

---

## 14. AI Provider Flow

Provider state:

```text
~/.cache/dasterm/ai-provider-state.json
```

Default:

```json
{
  "primary": "chocomilk",
  "fallback1": "prexzy_copilot",
  "fallback2": "prexzy_zai",
  "primary_delay_count": 0
}
```

Timeout:

```text
10 seconds
```

Jika primary gagal 3 kali:

```text
fallback1 -> primary
fallback2 -> fallback1
old primary -> fallback2
```

---

## 15. AI Memory Flow

Memory:

```text
~/.cache/dasterm/ai-memory.json
```

Format:

```json
{
  "date": "2026-05-10",
  "summary": "",
  "items": []
}
```

Saat command AI:

```text
Cek tanggal WIB
Jika tanggal berbeda, reset memory
Tambahkan input/output
Jika items > 5, summarize via AI
Simpan summary
Kosongkan items
```

---

## 16. Update Flow

Command:

```bash
dasterm update
```

Flow:

```text
Get current version
Get latest VERSION from GitHub
Show changelog
Ask confirmation
Download files to tmp
Apply binary/library
Keep config/cache
Update config version
```

---

## 17. Telemetry Flow

Telemetry default off.

Jika aktif:

```text
dasterm_telemetry_send event
  -> check DASTERM_TELEMETRY=on
  -> check endpoint
  -> build anonymous payload
  -> POST with timeout
  -> ignore error
```

Telemetry tidak boleh membuat command gagal.

---

## 18. Worker Architecture

Folder:

```text
worker/
```

Komponen:

```text
Cloudflare Worker
D1 database
SVG badge generator
Rate limit table
Usage events table
```

Endpoint:

```text
POST /api/usage
GET /badge/installs
GET /badge/runs
GET /badge/top-os-1
GET /badge/top-os-2
GET /badge/top-virt
GET /badge/top-lang
GET /badge/top-mode
GET /stats
```

---

## 19. Error Handling

Dasterm memakai prinsip:

```text
Fallback jika tool tidak ada
Tampilkan N/A jika data tidak tersedia
Jangan crash dashboard hanya karena satu command gagal
Command berat diberi timeout
AI fallback jika provider gagal
Telemetry error diabaikan
```

---

## 20. Security Boundaries

Batas aman:

```text
AI command whitelist
AI command approval
Telemetry opt-in
Config permission 600
Uninstall scope jelas
Shell integration kecil
No speedtest every login
No auto-fix security
```

---

## 21. Design Tradeoff

Dasterm sengaja memilih:

```text
Bash untuk kompatibilitas
JSON cache untuk kesederhanaan
Cloudflare Worker opsional untuk badge
No daemon background
No real-time heavy monitor
No auto destructive action
```

---

## 22. Kesimpulan

Arsitektur Dasterm v2 dibuat agar:

```text
Mudah dipasang
Mudah dipakai
Mudah diupdate
Mudah dihapus
Aman untuk VPS
Tetap ringan
Bisa dikembangkan
```