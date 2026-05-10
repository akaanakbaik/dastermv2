# Dasterm v2 Telemetry

Dasterm v2 memiliki rancangan telemetry opsional untuk mendukung badge profesional di README seperti:

- Total Installs
- Total Runs
- Top OS #1
- Top OS #2
- Top Virtualization
- Top Language

Telemetry ini bersifat **opsional** dan default-nya **mati**.

```bash
DASTERM_TELEMETRY="off"
```

---

## Daftar Isi

- [Status Default](#1-status-default)
- [Tujuan Telemetry](#2-tujuan-telemetry)
- [Data yang Boleh Dikumpulkan](#3-data-yang-boleh-dikumpulkan)
- [Data yang Tidak Boleh Dikumpulkan](#4-data-yang-tidak-boleh-dikumpulkan)
- [Anonymous Machine Hash](#5-anonymous-machine-hash)
- [File Konfigurasi](#6-file-konfigurasi)
- [Mengaktifkan Telemetry](#7-mengaktifkan-telemetry)
- [Mematikan Telemetry](#8-mematikan-telemetry)
- [Backend yang Disarankan](#9-backend-yang-disarankan)
- [Endpoint yang Disarankan](#10-endpoint-yang-disarankan)
- [Event Type](#11-event-type)
- [Struktur Database D1](#12-struktur-database-d1)
- [Hitungan Badge](#13-hitungan-badge)
- [Badge SVG](#14-badge-svg)
- [README Badge](#15-readme-badge)
- [Rate Limit](#16-rate-limit)
- [Privacy Text untuk README](#17-privacy-text-untuk-readme)
- [Rekomendasi Implementasi](#18-rekomendasi-implementasi)
- [Kesimpulan](#19-kesimpulan)

---

## 1. Status Default

Secara default:

```
Telemetry OFF
```

Dasterm tidak mengirim statistik penggunaan kecuali user mengaktifkannya saat instalasi atau config.

Saat install, user akan ditanya:

```
Allow anonymous statistics for README badges? [y/N]
```

Default: **No**

---

## 2. Tujuan Telemetry

Tujuan telemetry:

- Menampilkan jumlah penggunaan sepanjang masa
- Menampilkan jumlah install
- Menampilkan distro Linux paling banyak dipakai
- Menampilkan virtualization paling banyak dipakai
- Menampilkan mode dashboard paling populer
- Menampilkan bahasa paling populer
- Membantu pengembangan Dasterm

> Telemetry bukan untuk melacak user secara personal.

---

## 3. Data yang Boleh Dikumpulkan

Jika telemetry aktif, payload yang dikirim:

```json
{
  "event": "install",
  "version": "2.0.0",
  "distro": "ubuntu",
  "distro_version": "24.04",
  "arch": "x86_64",
  "virt": "kvm",
  "lang": "id",
  "mode": "lite",
  "machine_hash": "anonymous_sha256_hash",
  "date": "2026-05-10"
}
```

**Field:**

| Field | Keterangan |
|-------|------------|
| `event` | Tipe event |
| `version` | Dasterm version |
| `distro` | Linux distro |
| `distro_version` | Linux distro version |
| `arch` | CPU architecture |
| `virt` | Virtualization type |
| `lang` | Language |
| `mode` | Dashboard mode |
| `machine_hash` | Anonymous machine hash |
| `date` | Tanggal |

---

## 4. Data yang Tidak Boleh Dikumpulkan

Dasterm tidak boleh sengaja mengumpulkan:

- Username
- Hostname
- Public IP sebagai data tersimpan
- Private IP
- Path personal
- Isi file
- Command history
- Process list
- SSH key
- Token
- Password
- Environment secret
- Email
- Nama asli user
- Lokasi detail
- Daftar folder
- Daftar service lengkap

---

## 5. Anonymous Machine Hash

Untuk mencegah statistik install terlalu mudah dobel, Dasterm bisa membuat hash anonim dari:

```
/etc/machine-id
```

Tetapi yang dikirim bukan machine-id mentah.

**Yang dikirim:**

```
sha256("dasterm-v2-anonymous" + machine-id)
```

**Contoh hasil:**

```
a9f4c3...anonymous hash
```

Hash ini digunakan untuk menghitung unique install secara lebih rapi.

---

## 6. File Konfigurasi

Config telemetry ada di:

```
~/.config/dasterm/config.env
```

**Contoh:**

```bash
DASTERM_TELEMETRY="off"
DASTERM_TELEMETRY_ENDPOINT=""
```

**Jika ingin mengaktifkan manual:**

```bash
DASTERM_TELEMETRY="on"
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

---

## 7. Mengaktifkan Telemetry

**Cara paling mudah:**

```bash
/config
```

Lalu set:

```
Anonymous telemetry? on
```

**Atau edit manual:**

```bash
nano ~/.config/dasterm/config.env
```

Ubah:

```bash
DASTERM_TELEMETRY="on"
```

Tambahkan endpoint:

```bash
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

---

## 8. Mematikan Telemetry

**Via config:**

```bash
/config
```

Set:

```
Anonymous telemetry? off
```

**Atau edit manual:**

```bash
nano ~/.config/dasterm/config.env
```

Ubah:

```bash
DASTERM_TELEMETRY="off"
```

---

## 9. Backend yang Disarankan

| Backend | Keterangan |
|---------|------------|
| **Cloudflare Worker + D1** | Rekomendasi terbaik |
| Cloudflare Worker + KV | Alternatif |
| Vercel Serverless + Upstash Redis | Alternatif |
| Node.js API + SQLite | Alternatif |
| Node.js API + PostgreSQL | Alternatif |

**Rekomendasi terbaik: Cloudflare Worker + D1**

Karena:

- Gratis/hemat
- Cepat
- Cocok untuk badge SVG
- Tidak butuh VPS
- Mudah rate limit
- Mudah deploy

---

## 10. Endpoint yang Disarankan

```
POST /api/usage
GET  /badge/installs
GET  /badge/runs
GET  /badge/top-os-1
GET  /badge/top-os-2
GET  /badge/top-virt
GET  /badge/top-lang
GET  /stats
```

---

## 11. Event Type

Event yang disarankan:

- `install`
- `run`
- `update`
- `respeedtest`
- `ai`
- `doctor`

Namun untuk privacy dan efisiensi, badge awal cukup:

- `install`
- `run`
- `update`

---

## 12. Struktur Database D1

**Contoh tabel:**

```sql
CREATE TABLE usage_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event TEXT NOT NULL,
  version TEXT,
  distro TEXT,
  distro_version TEXT,
  arch TEXT,
  virt TEXT,
  lang TEXT,
  mode TEXT,
  machine_hash TEXT,
  date TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_usage_event ON usage_events(event);
CREATE INDEX idx_usage_distro ON usage_events(distro);
CREATE INDEX idx_usage_machine ON usage_events(machine_hash);
CREATE INDEX idx_usage_date ON usage_events(date);
```

---

## 13. Hitungan Badge

**Total installs:**

```sql
SELECT COUNT(DISTINCT machine_hash) AS total
FROM usage_events
WHERE event = 'install';
```

**Total runs:**

```sql
SELECT COUNT(*) AS total
FROM usage_events
WHERE event = 'run';
```

**Top OS #1:**

```sql
SELECT distro, COUNT(*) AS total
FROM usage_events
GROUP BY distro
ORDER BY total DESC
LIMIT 1;
```

**Top OS #2:**

```sql
SELECT distro, COUNT(*) AS total
FROM usage_events
GROUP BY distro
ORDER BY total DESC
LIMIT 1 OFFSET 1;
```

**Top virtualization:**

```sql
SELECT virt, COUNT(*) AS total
FROM usage_events
GROUP BY virt
ORDER BY total DESC
LIMIT 1;
```

**Top language:**

```sql
SELECT lang, COUNT(*) AS total
FROM usage_events
GROUP BY lang
ORDER BY total DESC
LIMIT 1;
```

---

## 14. Badge SVG

Badge endpoint harus mengembalikan SVG.

**Contoh URL:**

```
https://your-worker.example.com/badge/installs
```

**Contoh output visual:**

```
Total Installs | 1,204
```

**Header:**

```
Content-Type: image/svg+xml
Cache-Control: public, max-age=300
```

---

## 15. README Badge

Setelah backend siap, README bisa memakai:

```markdown
![Total Installs](https://your-worker.example.com/badge/installs)
![Total Runs](https://your-worker.example.com/badge/runs)
![Top OS #1](https://your-worker.example.com/badge/top-os-1)
![Top OS #2](https://your-worker.example.com/badge/top-os-2)
![Top Virt](https://your-worker.example.com/badge/top-virt)
![Top Lang](https://your-worker.example.com/badge/top-lang)
```

---

## 16. Rate Limit

Agar tidak mudah dimanipulasi:

- Batasi event per `machine_hash` per hari
- Batasi request per IP di Worker
- Validasi event type
- Validasi versi Dasterm
- Abaikan payload terlalu besar
- Abaikan field aneh
- Gunakan cache untuk badge

**Contoh rule:**

| Event | Maksimal per machine_hash/hari |
|-------|-------------------------------|
| `install` | 3 |
| `run` | 30 |
| `update` | 10 |

---

## 17. Privacy Text untuk README

Tambahkan bagian ini di README:

```markdown
## Anonymous Usage Statistics

Dasterm can optionally send anonymous usage statistics to power public README badges.

Telemetry is **disabled by default**.

**Collected:**
- Event type
- Dasterm version
- Linux distro
- CPU architecture
- Virtualization type
- Language
- Dashboard mode
- Anonymous machine hash

**Not collected:**
- Username
- Hostname
- Files
- Commands
- Process list
- IP address as stored data
- Shell history
- Private keys

**Disable anytime:**

```bash
/config
```
```

---

## 18. Rekomendasi Implementasi

Untuk v2.0.0, telemetry foundation sudah cukup.

Untuk v2.1.0, tambahkan backend resmi:

- Cloudflare Worker
- D1 database
- SVG badge generator
- Public `/stats` endpoint
- Rate limit
- README badge live

> Jangan aktifkan telemetry otomatis tanpa persetujuan user.

---

## 19. Kesimpulan

Telemetry Dasterm harus:

- **Optional**
- **Transparent**
- **Minimal**
- **Anonymous**
- **Easy to disable**
- **Useful for public project stats**

Dengan desain ini, Dasterm terlihat profesional tanpa mengorbankan privacy user.
