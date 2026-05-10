# Dasterm v2 Commands

Dokumen ini berisi daftar command lengkap Dasterm v2.

Dasterm mendukung dua bentuk command:

```bash
dasterm <command>
```

Dan slash alias:

```bash
/<command>
```

Contoh:

```bash
dasterm help
```

Sama dengan:

```bash
/help
```

Slash alias aktif jika saat install/config kamu memilih:

```text
Enable slash commands like /help, /ai, /update? yes
```

---

## 1. Command Ringkas

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

---

## 2. Help

Slash:

```bash
/help
```

Command asli:

```bash
dasterm help
```

Fungsi:

```text
Menampilkan semua command Dasterm.
Menampilkan deskripsi singkat setiap command.
Berguna setelah install untuk melihat menu.
```

---

## 3. Status Dashboard

Slash:

```bash
/status
```

Command asli:

```bash
dasterm status
```

Fungsi:

```text
Menampilkan dashboard sesuai mode aktif di config.
Jika mode aktif lite, tampil lite.
Jika mode aktif full, tampil full.
```

Config mode ada di:

```text
~/.config/dasterm/config.env
```

Field:

```env
DASTERM_MODE="lite"
```

Atau:

```env
DASTERM_MODE="full"
```

---

## 4. Lite Dashboard

Slash:

```bash
/lite
```

Command asli:

```bash
dasterm lite
```

Fungsi:

```text
Menampilkan dashboard ringan.
Lebih cepat.
Lebih cocok untuk VPS kecil.
Logo kecil.
Data ringkas.
```

Lite mode menampilkan:

```text
User@Host
OS
Kernel
Uptime
Health score
RAM
Disk /
IP
Load
Speedtest summary
```

---

## 5. Full Dashboard

Slash:

```bash
/full
```

Command asli:

```bash
dasterm full
```

Fungsi:

```text
Menampilkan dashboard lengkap.
Logo terbaik dari fastfetch/neofetch jika tersedia.
Data sistem detail.
Network detail.
Service detail.
Security/service signal dasar.
```

Full mode cocok untuk:

```text
Server utama
VPS development
VPS Docker
VPS Pterodactyl
Server dengan /datas
Server yang perlu monitoring manual
```

---

## 6. Speedtest Cache

Slash:

```bash
/speedtest
```

Command asli:

```bash
dasterm speedtest
```

Fungsi:

```text
Menampilkan hasil speedtest tersimpan.
Tidak melakukan speedtest ulang.
Cepat.
Tidak membebani bandwidth.
```

File cache:

```text
~/.cache/dasterm/speedtest.json
```

Jika belum ada cache:

```text
Belum ada hasil speedtest tersimpan. Jalankan /respeedtest.
```

---

## 7. Respeedtest

Slash:

```bash
/respeedtest
```

Command asli:

```bash
dasterm respeedtest
```

Fungsi:

```text
Menjalankan speedtest baru.
Menghitung Mbps, MB/s, Gbps, GB/s.
Menyimpan hasil baru.
Menampilkan hasil terbaru.
```

Provider yang dicoba:

```text
Ookla speedtest CLI
speedtest-cli
curl fallback Cloudflare
```

Rumus:

```text
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

---

## 8. Network

Slash:

```bash
/network
```

Command asli:

```bash
dasterm network
```

Fungsi:

```text
Menampilkan detail jaringan.
```

Isi:

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

Public IP dicache selama sekitar 1 jam agar tidak request terus-menerus.

---

## 9. Storage

Slash:

```bash
/storage
```

Command asli:

```bash
dasterm storage
```

Fungsi:

```text
Menampilkan detail penyimpanan server.
```

Isi:

```text
Root disk
Root filesystem
Root inode usage
/datas disk jika tersedia
/datas filesystem
/datas inode usage
Docker root
Docker usage
Mount list
Largest directories /
Largest directories /datas
Node modules scan
Storage suggestions
```

Fitur ini cocok jika server punya storage tambahan:

```text
/datas
```

---

## 10. Services

Slash:

```bash
/services
```

Command asli:

```bash
dasterm services
```

Fungsi:

```text
Menampilkan status service penting.
```

Isi:

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

## 11. Security

Slash:

```bash
/security
```

Command asli:

```bash
dasterm security
```

Fungsi:

```text
Menampilkan sinyal keamanan server.
```

Isi:

```text
Security score
Firewall status
SSH root login
SSH password authentication
SSH pubkey authentication
Fail2ban
Sudo users
Failed login 24h
Recent logins
Suggestions
```

Dasterm hanya membaca dan memberi saran.

Dasterm tidak otomatis mengubah konfigurasi security.

---

## 12. Doctor

Slash:

```bash
/doctor
```

Command asli:

```bash
dasterm doctor
```

Fungsi:

```text
Mengecek kesehatan instalasi Dasterm.
```

Dicek:

```text
Binary
Library
Config
Shell integration
Config permission
Cache directory
Speedtest cache
Dependencies
Speedtest provider
AI runtime
Network
OS
Virtualization
Root disk
RAM
Failed units
Reboot required
```

Gunakan ini jika:

```text
Dasterm tidak muncul
Slash command tidak aktif
Speedtest gagal
AI error
Config rusak
Update gagal
```

---

## 13. AI

Slash:

```bash
/ai cek storage server saya
```

Command asli:

```bash
dasterm ai "cek storage server saya"
```

Fungsi:

```text
Bertanya ke AI Dasterm.
AI menjawab dengan hasil.
Jika perlu command, AI memberi satu command.
Dasterm meminta approval sebelum command dijalankan.
```

Contoh approval:

```text
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

---

## 14. AI Brain

Slash:

```bash
/brain-ai
```

Command asli:

```bash
dasterm brain-ai
```

Fungsi:

```text
Menampilkan memori AI hari ini.
```

Memory file:

```text
~/.cache/dasterm/ai-memory.json
```

---

## 15. Clear AI Brain

Slash:

```bash
/clear-brain-ai
```

Command asli:

```bash
dasterm clear-brain-ai
```

Fungsi:

```text
Menghapus memori AI hari ini.
```

Gunakan jika:

```text
AI salah konteks
Memory terasa kacau
Ingin mulai percakapan baru
Ada data yang tidak ingin tersimpan
```

---

## 16. AI Provider

Slash:

```bash
/ai-provider
```

Command asli:

```bash
dasterm ai-provider
```

Fungsi:

```text
Melihat urutan provider AI aktif.
Melihat primary, fallback1, fallback2.
Melihat primary delay count.
```

---

## 17. Reset AI Provider

Slash:

```bash
/ai-reset-provider
```

Command asli:

```bash
dasterm ai-reset-provider
```

Fungsi:

```text
Mengembalikan urutan provider AI ke default.
```

Default:

```text
primary   : chocomilk
fallback1 : prexzy_copilot
fallback2 : prexzy_zai
```

---

## 18. AI Test

Slash:

```bash
/ai-test
```

Command asli:

```bash
dasterm ai-test
```

Fungsi:

```text
Mengetes semua provider AI.
```

Provider:

```text
chocomilk
prexzy_copilot
prexzy_zai
```

---

## 19. Config

Slash:

```bash
/config
```

Command asli:

```bash
dasterm config
```

Fungsi:

```text
Membuka konfigurasi interaktif.
```

Bisa mengubah:

```text
Language
Mode
Theme
User@Host
Show dashboard
Prompt custom
Slash aliases
Telemetry
```

---

## 20. Update

Slash:

```bash
/update
```

Command asli:

```bash
dasterm update
```

Fungsi:

```text
Mengecek versi terbaru dari GitHub.
Membandingkan dengan versi lokal.
Menampilkan changelog jika ada.
Meminta konfirmasi.
Download file baru.
Apply update.
Menjaga config tetap aman.
```

---

## 21. Uninstall

Slash:

```bash
/uninstall
```

Command asli:

```bash
dasterm uninstall
```

Fungsi:

```text
Membuka installer utama untuk uninstall bersih.
```

Uninstall menghapus:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm
~/.config/dasterm
~/.cache/dasterm
Shell integration di .bashrc/.zshrc
```

---

## 22. Version

Slash:

```bash
/version
```

Command asli:

```bash
dasterm version
```

Fungsi:

```text
Menampilkan versi Dasterm.
```

---

## 23. About

Slash:

```bash
/about
```

Command asli:

```bash
dasterm about
```

Fungsi:

```text
Menampilkan informasi project, author, repo, dan versi.
```

---

## 24. Jika Slash Command Tidak Jalan

Jalankan:

```bash
source ~/.bashrc
```

Atau buka terminal baru.

Jika masih tidak jalan:

```bash
dasterm config
```

Pastikan slash alias aktif:

```text
Enable slash aliases? on
```

---

## 25. Jika Command Dasterm Tidak Ditemukan

Cek binary:

```bash
ls -la /usr/local/bin/dasterm
```

Jika tidak ada, install ulang:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
1) Install / Update
```

Atau:

```text
4) Repair
```

---

## 26. Rekomendasi Penggunaan Harian

Saat login:

```bash
/status
```

Cek server cepat:

```bash
/doctor
```

Cek storage:

```bash
/storage
```

Cek service:

```bash
/services
```

Cek network:

```bash
/network
```

Test ulang speed:

```bash
/respeedtest
```

Tanya AI:

```bash
/ai kenapa storage root saya cepat penuh?
```

Update Dasterm:

```bash
/update
```