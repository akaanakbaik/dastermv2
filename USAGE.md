# Dasterm v2 Usage Guide

Dasterm v2 adalah dashboard terminal Linux interaktif dengan mode Lite/Full, speedtest cache, AI assistant, health check, storage analyzer, service monitor, security check, dan updater.

Dokumen ini menjelaskan cara menggunakan semua command utama Dasterm.

---

## Daftar Isi

- [Menjalankan Dasterm](#1-menjalankan-dasterm)
- [Command Utama](#2-command-utama)
- [Mode Dashboard](#3-mode-dashboard)
- [Bahasa](#4-bahasa)
- [Theme](#5-theme)
- [User@Host Custom](#6-userhost-custom)
- [Speedtest](#7-speedtest)
- [Network](#8-network)
- [Storage](#9-storage)
- [Services](#10-services)
- [Security](#11-security)
- [Doctor](#12-doctor)
- [AI Assistant](#13-ai-assistant)
- [AI Memory](#14-ai-memory)
- [AI Provider](#15-ai-provider)
- [Update](#16-update)
- [Reconfigure](#17-reconfigure)
- [Uninstall](#18-uninstall)
- [File Lokasi](#19-file-lokasi)
- [Troubleshooting Cepat](#20-troubleshooting-cepat)
- [Command Asli Tanpa Slash](#21-command-asli-tanpa-slash)

---

## 1. Menjalankan Dasterm

Setelah install, kamu bisa menjalankan:

```bash
dasterm
```

Atau menggunakan slash command:

```bash
/status
```

Jika slash command belum aktif, jalankan:

```bash
dasterm config
```

Lalu aktifkan opsi:

```
Enable slash aliases? on
```

---

## 2. Command Utama

| Command | Deskripsi |
|---------|-----------|
| `/help` | Menampilkan semua menu dan command Dasterm |
| `/status` | Menampilkan dashboard sesuai mode aktif |
| `/lite` | Menampilkan dashboard Lite |
| `/full` | Menampilkan dashboard Full |
| `/config` | Membuka konfigurasi interaktif |
| `/update` | Mengecek dan mengupdate Dasterm ke versi terbaru |
| `/uninstall` | Membuka flow uninstall bersih |
| `/version` | Menampilkan versi Dasterm |
| `/about` | Menampilkan informasi project |

---

## 3. Mode Dashboard

Dasterm menyediakan dua mode utama: **Lite** dan **Full**.

### Lite Mode

Lite mode dibuat untuk cepat dan ringkas.

**Cocok untuk:**
- VPS kecil
- NAT VPS
- LXC container
- Server dengan RAM kecil
- Terminal mobile
- Login cepat

**Lite mode menampilkan:**
- User@Host
- OS
- Kernel
- Uptime
- Health score
- RAM usage
- Disk root
- Private IP
- Load average
- Speedtest cache summary
- Small Dasterm logo

**Jalankan manual:**

```bash
/lite
```

Atau:

```bash
dasterm lite
```

### Full Mode

Full mode dibuat untuk tampilan lengkap.

**Cocok untuk:**
- VPS utama
- Server development
- Server production ringan
- Server Docker
- Server Pterodactyl
- Server dengan storage tambahan

**Full mode menampilkan:**
- Fastfetch atau Neofetch logo jika tersedia
- User@Host
- OS
- Kernel
- Architecture
- Virtualization
- Boot time
- Uptime
- Load average
- Health score
- CPU model
- CPU cores
- CPU flags
- RAM
- Swap
- Disk root
- Disk `/datas` jika tersedia
- GPU
- Processes
- Logged-in users
- Private IP
- Public IP
- Gateway
- DNS
- Speedtest cache
- Docker
- Nginx
- Apache
- Cloudflared
- SSH
- UFW

**Jalankan manual:**

```bash
/full
```

Atau:

```bash
dasterm full
```

---

## 4. Bahasa

Dasterm mendukung dua bahasa:

- **Indonesia**
- **English**

Bahasa dipilih saat instalasi.

**Untuk mengganti bahasa:**

```bash
/config
```

Pilih:

```
1) Indonesia
2) English
```

Bahasa ini akan digunakan untuk dashboard, menu, dan sebagian besar output Dasterm.

---

## 5. Theme

Dasterm menyediakan beberapa theme:

- **Pastel**
- **Cyber**
- **Ocean**
- **Mono**

**Ganti theme:**

```bash
/config
```

Theme tidak memengaruhi data, hanya tampilan warna.

---

## 6. User@Host Custom

Saat install/config, kamu bisa mengatur tampilan:

```
root@aka
aka@server
admin@vps
student@lab
```

Prompt terminal juga bisa dibuat mengikuti User@Host custom.

**Jika ingin mematikan prompt custom:**

```bash
/config
```

Lalu pilih:

```
Change prompt? off
```

---

## 7. Speedtest

Dasterm tidak menjalankan speedtest setiap kali login agar server tidak berat dan hasil login tetap cepat.

Saat install, kamu bisa memilih menjalankan speedtest pertama. Hasil disimpan di:

```
~/.cache/dasterm/speedtest.json
```

**Melihat hasil tersimpan:**

```bash
/speedtest
```

**Test ulang dan simpan hasil baru:**

```bash
/respeedtest
```

Dasterm menampilkan hasil dalam:

| Unit | Keterangan |
|------|------------|
| Mbps | Megabit per second |
| MB/s | Megabyte per second |
| Gbps | Gigabit per second |
| GB/s | Gigabyte per second |

**Rumus:**

```
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

**Contoh:**

```
Download : 938.42 Mbps | 117.30 MB/s | 0.938 Gbps | 0.117 GB/s
Upload   : 812.10 Mbps | 101.51 MB/s | 0.812 Gbps | 0.101 GB/s
```

Jika provider, region, atau server tersedia dari speedtest provider, Dasterm akan menampilkannya. Jika tidak tersedia, bagian itu disembunyikan.

---

## 8. Network

```bash
/network
```

Menampilkan:

- Private IP
- Public IP
- Interface
- Gateway
- DNS
- Ping 1.1.1.1
- Ping 8.8.8.8
- Open ports
- Speedtest cache

Public IP dicache agar tidak melakukan request internet terus-menerus.

---

## 9. Storage

```bash
/storage
```

Menampilkan:

- Root disk
- Root filesystem
- Root inode usage
- `/datas` disk jika tersedia
- `/datas` filesystem
- `/datas` inode usage
- Docker root
- Docker usage
- Mount list
- Largest directories `/`
- Largest directories `/datas`
- Node modules scan
- Storage suggestions

Fitur ini berguna jika kamu punya disk tambahan seperti `/datas`. Dasterm akan memberi saran jika Docker masih berada di `/var/lib/docker` padahal `/datas` tersedia.

---

## 10. Services

```bash
/services
```

Menampilkan:

- Docker
- PM2
- Nginx
- Apache
- Cloudflared
- SSH
- Cron
- PostgreSQL
- MySQL/MariaDB
- Redis
- Failed systemd units
- Open ports
- Top service processes

Cocok untuk mengecek server web, bot, tunnel, dan service penting.

---

## 11. Security

```bash
/security
```

Menampilkan:

- Security score
- Firewall status
- SSH root login
- SSH password authentication
- SSH public key authentication
- Fail2ban status
- Sudo users
- Failed login count in last 24 hours
- Recent logins
- Suggestions

Dasterm akan memberi **warning** jika:

- Root login SSH masih aktif
- PasswordAuthentication aktif
- Firewall tidak terlihat aktif
- Fail2ban belum terinstall
- Failed login terlalu banyak

> Dasterm hanya memberi saran, tidak mengubah konfigurasi security otomatis.

---

## 12. Doctor

```bash
/doctor
```

Doctor mengecek kesehatan Dasterm.

**Yang dicek:**

- Binary
- Library files
- Config
- Shell integration
- Config permission
- Cache directory
- Speedtest cache
- Dependencies
- Speedtest provider
- AI runtime
- Network connectivity
- OS
- Virtualization
- Root disk
- RAM
- Failed units
- Reboot required

Gunakan command ini jika Dasterm error, tidak muncul saat login, atau ada command yang tidak bekerja.

---

## 13. AI Assistant

```bash
/ai <permintaan>
```

**Contoh:**

```bash
/ai cek storage server saya
```

AI akan memberikan jawaban. Jika AI menyarankan command, Dasterm akan meminta persetujuan dulu.

**Contoh:**

```
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

Command tidak dijalankan sebelum user menyetujui.

---

## 14. AI Memory

**Melihat memori AI:**

```bash
/brain-ai
```

**Menghapus memori AI:**

```bash
/clear-brain-ai
```

**Memori AI:**

- Disimpan per hari
- Reset otomatis berdasarkan tanggal WIB
- Diringkas otomatis jika item lebih dari 5
- Tidak dimaksudkan untuk menyimpan data sensitif

**File memori:**

```
~/.cache/dasterm/ai-memory.json
```

---

## 15. AI Provider

**Melihat provider AI aktif:**

```bash
/ai-provider
```

**Reset provider AI:**

```bash
/ai-reset-provider
```

**Test semua provider AI:**

```bash
/ai-test
```

**Provider default:**

```
1. chocomilk
2. prexzy copilot
3. prexzy zai
```

Jika provider utama timeout/error lebih dari 10 detik, Dasterm memakai fallback. Jika provider utama lambat 3 kali, urutan provider otomatis diputar.

---

## 16. Update

```bash
/update
```

Dasterm akan:

1. Mengecek versi saat ini
2. Mengecek versi terbaru dari GitHub
3. Menampilkan changelog jika tersedia
4. Meminta konfirmasi
5. Download file terbaru
6. Replace binary dan library
7. Menjaga config user tetap aman

> Config tidak dihapus saat update.

---

## 17. Reconfigure

Untuk reconfigure, jalankan installer lagi:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```
2) Reconfigure
```

Atau pakai:

```bash
/config
```

---

## 18. Uninstall

**Cara uninstall:**

```bash
/uninstall
```

Atau jalankan installer lagi:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```
3) Uninstall
```

**Uninstall akan menghapus:**

- `/usr/local/bin/dasterm`
- `/usr/local/share/dasterm`
- `~/.config/dasterm`
- `~/.cache/dasterm`
- Shell integration di `.bashrc` / `.zshrc`

---

## 19. File Lokasi

| Path | Tujuan |
|------|--------|
| `/usr/local/bin/dasterm` | Binary utama |
| `/usr/local/share/dasterm/lib/` | Library files |
| `~/.config/dasterm/config.env` | Konfigurasi |
| `~/.cache/dasterm/` | Cache directory |
| `~/.local/share/dasterm/logs/` | Log files |

---

## 20. Troubleshooting Cepat

| Masalah | Solusi |
|---------|--------|
| `/help` tidak dikenal | `source ~/.bashrc` atau buka terminal baru |
| Slash command masih tidak bisa | `dasterm config` → aktifkan slash alias |
| Dashboard tidak muncul saat login | `dasterm doctor` |
| Speedtest tidak tersedia | `dasterm respeedtest` |
| Error dependency | `sudo apt install curl jq iproute2 procps coreutils util-linux` |
| AI tidak jalan | `dasterm ai-test` |
| Update gagal | Jalankan installer → pilih `4) Repair` |

---

## 21. Command Asli Tanpa Slash

Semua slash command punya bentuk asli.

| Slash Command | Command Asli |
|---------------|--------------|
| `/help` | `dasterm help` |
| `/respeedtest` | `dasterm respeedtest` |
| `/ai cek server` | `dasterm ai "cek server"` |

Jika slash alias bermasalah, gunakan command `dasterm`.
