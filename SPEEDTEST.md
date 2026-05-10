# Dasterm v2 Speedtest System

Dasterm v2 memiliki sistem speedtest cache.

**Tujuannya:**

- Speedtest hanya dijalankan saat user meminta
- Hasil disimpan
- Dashboard login membaca hasil tersimpan
- Login terminal tetap cepat
- Server tidak terus-menerus melakukan speedtest

---

## Daftar Isi

- [File Cache](#1-file-cache)
- [Menjalankan Speedtest Pertama](#2-menjalankan-speedtest-pertama)
- [Melihat Hasil Tersimpan](#3-melihat-hasil-tersimpan)
- [Test Ulang Speed](#4-test-ulang-speed)
- [Provider Speedtest](#5-provider-speedtest)
- [Ookla Speedtest CLI](#6-ookla-speedtest-cli)
- [speedtest-cli](#7-speedtest-cli)
- [Curl Fallback](#8-curl-fallback)
- [Format JSON Cache](#9-format-json-cache)
- [Konversi Matematika](#10-konversi-matematika)
- [Mbps vs MB/s](#11-mbps-vs-mbs)
- [Gbps vs GB/s](#12-gbps-vs-gbs)
- [Kenapa Tidak Test Setiap Login?](#13-kenapa-tidak-test-setiap-login)
- [Kapan Perlu /respeedtest?](#14-kapan-perlu-respeedtest)
- [Hasil Tidak Lengkap](#15-hasil-tidak-lengkap)
- [Install Speedtest Provider](#16-install-speedtest-provider)
- [Troubleshooting](#17-troubleshooting)
- [Saran Tampilan Dashboard](#18-saran-tampilan-dashboard)
- [Kesimpulan](#19-kesimpulan)

---

## 1. File Cache

Hasil speedtest disimpan di:

```
~/.cache/dasterm/speedtest.json
```

Dashboard Lite dan Full membaca file ini.

Jika file belum ada, dashboard menampilkan pesan:

```
No saved speedtest result. Run /respeedtest.
```

Atau dalam bahasa Indonesia:

```
Belum ada hasil speedtest tersimpan. Jalankan /respeedtest.
```

---

## 2. Menjalankan Speedtest Pertama

Saat instalasi, Dasterm bertanya:

```
Run initial speedtest and save result? [Y/n]
```

Jika user memilih **yes**, Dasterm menjalankan speedtest dan menyimpan hasilnya.

Jika user memilih **no**, speedtest tidak dijalankan.

---

## 3. Melihat Hasil Tersimpan

```bash
/speedtest
```

Atau:

```bash
dasterm speedtest
```

Command ini tidak melakukan test ulang. Command ini hanya membaca:

```
~/.cache/dasterm/speedtest.json
```

---

## 4. Test Ulang Speed

```bash
/respeedtest
```

Atau:

```bash
dasterm respeedtest
```

Command ini akan:

1. Menjalankan speedtest baru
2. Menghitung Mbps, MB/s, Gbps, GB/s
3. Menyimpan hasil ke `speedtest.json`
4. Menampilkan hasil terbaru

---

## 5. Provider Speedtest

Dasterm mencoba provider berurutan:

1. **Ookla speedtest CLI**
2. **speedtest-cli**
3. **curl fallback** ke Cloudflare download test

---

## 6. Ookla Speedtest CLI

Jika tersedia, Dasterm memakai:

```bash
speedtest --accept-license --accept-gdpr --format=json
```

**Data yang bisa didapat:**

- ISP/provider
- Server name
- Server location/region
- Ping
- Jitter
- Packet loss
- Download bandwidth
- Upload bandwidth

Ookla biasanya memberi hasil paling lengkap.

---

## 7. speedtest-cli

Jika Ookla tidak ada, Dasterm mencoba:

```bash
speedtest-cli --json
```

**Data yang bisa didapat:**

- Provider/ISP
- Server sponsor
- Server country
- Ping
- Download
- Upload

Tidak semua field tersedia.

---

## 8. Curl Fallback

Jika speedtest CLI tidak tersedia, Dasterm mencoba fallback:

```
https://speed.cloudflare.com/__down?bytes=25000000
```

Fallback ini hanya menghitung download. Upload akan menjadi `0` atau tidak lengkap.

Fallback tetap berguna untuk estimasi koneksi dasar.

---

## 9. Format JSON Cache

**Contoh:**

```json
{
  "tested_at": "2026-05-10 19:30:00 WIB",
  "source": "ookla-speedtest",
  "provider": "PT Telkom Indonesia",
  "region": "Singapore",
  "server": "Example Provider",
  "ping": {
    "ms": "12.43",
    "jitter_ms": "1.02",
    "packet_loss": "0"
  },
  "download": {
    "bps": "938420000",
    "mbps": "938.42",
    "MBps": "117.30",
    "gbps": "0.938",
    "GBps": "0.117"
  },
  "upload": {
    "bps": "812100000",
    "mbps": "812.10",
    "MBps": "101.51",
    "gbps": "0.812",
    "GBps": "0.102"
  },
  "formula": {
    "MBps": "Mbps / 8",
    "Gbps": "Mbps / 1000",
    "GBps": "Mbps / 8000"
  }
}
```

---

## 10. Konversi Matematika

Dasterm memakai konversi decimal networking standar:

- 1 Mbps = 1 megabit per second
- 1 byte = 8 bit
- 1 MB/s = 8 Mbps
- 1 Gbps = 1000 Mbps
- 1 GB/s = 8000 Mbps

**Rumus:**

```
MB/s = Mbps / 8
Gbps = Mbps / 1000
GB/s = Mbps / 8000
```

**Contoh download:**

```
938.42 Mbps
```

Maka:

```
MB/s = 938.42 / 8
MB/s = 117.3025
MB/s = 117.30 MB/s

Gbps = 938.42 / 1000
Gbps = 0.93842
Gbps = 0.938 Gbps

GB/s = 938.42 / 8000
GB/s = 0.1173025
GB/s = 0.117 GB/s
```

---

## 11. Mbps vs MB/s

**Perbedaan penting:**

| Unit | Keterangan |
|------|------------|
| Mbps | Megabit per second |
| MB/s | Megabyte per second |

ISP biasanya menampilkan Mbps. Download file biasanya terasa seperti MB/s.

**Contoh:**

| Mbps | MB/s |
|------|------|
| 100 Mbps | ~12.5 MB/s |
| 1 Gbps | ~125 MB/s |
| 10 Gbps | ~1,250 MB/s atau 1.25 GB/s |

---

## 12. Gbps vs GB/s

| Unit | Keterangan |
|------|------------|
| Gbps | Gigabit per second |
| GB/s | Gigabyte per second |

Karena 1 byte = 8 bit:

```
1 Gbps = 0.125 GB/s
```

**Contoh:**

| Gbps | GB/s |
|------|------|
| 2 Gbps | 0.25 GB/s |
| 5 Gbps | 0.625 GB/s |
| 10 Gbps | 1.25 GB/s |

---

## 13. Kenapa Tidak Test Setiap Login?

Speedtest setiap login tidak disarankan karena:

- Membuang bandwidth
- Membuat login terminal lambat
- Bisa membebani server kecil
- Bisa terkena limit provider speedtest
- Tidak perlu jika hanya ingin melihat hasil terakhir

Karena itu Dasterm memakai cache.

---

## 14. Kapan Perlu /respeedtest?

Jalankan `/respeedtest` jika:

- Baru beli VPS
- Pindah region
- Ganti provider
- Jaringan terasa lambat
- Ingin membandingkan performa
- Setelah restart network
- Setelah pindah node/server

---

## 15. Hasil Tidak Lengkap

Jika provider/region/server tidak muncul, kemungkinan:

- Provider speedtest tidak memberikan field itu
- Fallback curl sedang digunakan
- `jq` gagal membaca output
- Tool speedtest berbeda format
- Server memblokir sebagian request

Dasterm akan menyembunyikan field kosong agar dashboard tetap rapi.

---

## 16. Install Speedtest Provider

### Debian/Ubuntu

```bash
sudo apt update
sudo apt install speedtest-cli jq curl
```

Untuk Ookla resmi, install sesuai dokumentasi Ookla Speedtest CLI.

### Alpine

```bash
sudo apk add speedtest-cli jq curl
```

### Arch

```bash
sudo pacman -S speedtest-cli jq curl
```

### Fedora

```bash
sudo dnf install speedtest-cli jq curl
```

---

## 17. Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `/speedtest` kosong | `/respeedtest` |
| `/respeedtest` gagal | `dasterm doctor` |
| Hasil fallback hanya download | Normal — curl fallback tidak mengukur upload |
| Ping N/A | ICMP ping mungkin diblokir provider/server |
| Speed sangat rendah | Coba ulang beberapa kali, coba beda jam, cek load server, cek limit VPS, cek provider sedang gangguan |

**Cek apakah ada:**

- `curl`
- `jq`
- `speedtest`
- `speedtest-cli`
- Internet connection

---

## 18. Saran Tampilan Dashboard

**Di Lite mode**, cukup tampilkan ringkas:

```
Download : 938.42 Mbps
Upload   : 812.10 Mbps
Ping     : 12.43 ms
```

**Di Full mode**, tampilkan lengkap:

```
Provider
Region
Server
Source
Ping
Jitter
Packet Loss
Download Mbps | MB/s | Gbps | GB/s
Upload Mbps | MB/s | Gbps | GB/s
Tested At
```

---

## 19. Kesimpulan

Sistem speedtest Dasterm v2 dibuat untuk:

- **Cepat**
- **Akurat**
- **Tidak membebani login**
- **Mudah diulang**
- **Mudah dibaca**
- **Bisa dipakai untuk dokumentasi performa VPS**

**Gunakan:**

```bash
/respeedtest
```

Untuk update hasil.

**Gunakan:**

```bash
/speedtest
```

Untuk melihat hasil tersimpan.
