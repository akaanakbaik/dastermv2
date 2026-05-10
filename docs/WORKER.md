# Dasterm Telemetry Worker

Dokumen ini menjelaskan cara memakai backend telemetry opsional untuk badge README Dasterm v2.

Backend ini memakai:

```text
Cloudflare Worker
Cloudflare D1
SVG badge endpoint
Anonymous usage stats
Rate limit ringan
```

Telemetry ini opsional dan default-nya mati di Dasterm.

---

## 1. Tujuan Worker

Worker dipakai untuk membuat badge seperti:

```text
Total Installs
Total Runs
Top OS #1
Top OS #2
Top Virtualization
Top Language
Top Mode
```

Contoh badge:

```md
![Total Installs](https://your-worker.example.com/badge/installs)
![Total Runs](https://your-worker.example.com/badge/runs)
![Top OS #1](https://your-worker.example.com/badge/top-os-1)
![Top OS #2](https://your-worker.example.com/badge/top-os-2)
![Top Virt](https://your-worker.example.com/badge/top-virt)
![Top Lang](https://your-worker.example.com/badge/top-lang)
![Top Mode](https://your-worker.example.com/badge/top-mode)
```

---

## 2. Struktur Worker

```text
worker/
├── package.json
├── wrangler.toml
├── schema.sql
├── .gitignore
└── src/
    └── index.js
```

---

## 3. Install Wrangler

Masuk ke folder worker:

```bash
cd worker
```

Install dependency:

```bash
npm install
```

Login Cloudflare:

```bash
npx wrangler login
```

---

## 4. Buat Database D1

Jalankan:

```bash
npm run db:create
```

Cloudflare akan memberikan output seperti:

```text
database_name = "dasterm_telemetry"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Copy `database_id`, lalu edit:

```text
worker/wrangler.toml
```

Ganti:

```toml
database_id = "replace-with-your-d1-database-id"
```

Menjadi:

```toml
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

---

## 5. Migrasi Database

Jalankan:

```bash
npm run db:migrate
```

Untuk test lokal:

```bash
npm run db:local
```

---

## 6. Jalankan Worker Lokal

```bash
npm run dev
```

Biasanya Worker berjalan di:

```text
http://localhost:8787
```

Cek endpoint:

```bash
curl http://localhost:8787/
```

Output:

```json
{
  "success": true,
  "name": "Dasterm",
  "endpoints": [
    "POST /api/usage",
    "GET /badge/installs",
    "GET /badge/runs",
    "GET /badge/top-os-1",
    "GET /badge/top-os-2",
    "GET /badge/top-virt",
    "GET /badge/top-lang",
    "GET /badge/top-mode",
    "GET /stats"
  ]
}
```

---

## 7. Deploy Worker

```bash
npm run deploy
```

Setelah deploy, Cloudflare memberi URL seperti:

```text
https://dasterm-telemetry.username.workers.dev
```

---

## 8. Endpoint Usage

Endpoint:

```text
POST /api/usage
```

Contoh request:

```bash
curl -X POST "https://dasterm-telemetry.username.workers.dev/api/usage" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "install",
    "version": "2.0.0",
    "distro": "ubuntu",
    "distro_version": "24.04",
    "arch": "x86_64",
    "virt": "kvm",
    "lang": "id",
    "mode": "lite",
    "machine_hash": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    "date": "2026-05-10"
  }'
```

Output sukses:

```json
{
  "success": true
}
```

---

## 9. Event yang Diizinkan

Worker menerima event:

```text
install
run
update
respeedtest
ai
doctor
```

Untuk badge awal, cukup pakai:

```text
install
run
update
```

---

## 10. Badge Endpoint

Total installs:

```text
/badge/installs
```

Total runs:

```text
/badge/runs
```

Top OS #1:

```text
/badge/top-os-1
```

Top OS #2:

```text
/badge/top-os-2
```

Top virtualization:

```text
/badge/top-virt
```

Top language:

```text
/badge/top-lang
```

Top mode:

```text
/badge/top-mode
```

---

## 11. Stats Endpoint

Endpoint:

```text
/stats
```

Contoh:

```bash
curl https://dasterm-telemetry.username.workers.dev/stats
```

Output:

```json
{
  "success": true,
  "project": "Dasterm",
  "installs": 1204,
  "runs": 9320,
  "updates": 88,
  "top": {
    "os1": {
      "name": "ubuntu",
      "total": 700
    },
    "os2": {
      "name": "debian",
      "total": 220
    },
    "virt": {
      "name": "kvm",
      "total": 600
    },
    "lang": {
      "name": "id",
      "total": 900
    },
    "mode": {
      "name": "lite",
      "total": 850
    }
  }
}
```

---

## 12. Hubungkan Dasterm ke Worker

Edit config:

```bash
nano ~/.config/dasterm/config.env
```

Tambahkan:

```env
DASTERM_TELEMETRY="on"
DASTERM_TELEMETRY_ENDPOINT="https://dasterm-telemetry.username.workers.dev/api/usage"
```

Atau via:

```bash
/config
```

Set telemetry menjadi:

```text
on
```

Lalu tambahkan endpoint manual ke config.

---

## 13. README Badge Live

Setelah Worker aktif, ganti badge placeholder di README:

```md
![Total Installs](https://dasterm-telemetry.username.workers.dev/badge/installs)
![Total Runs](https://dasterm-telemetry.username.workers.dev/badge/runs)
![Top OS #1](https://dasterm-telemetry.username.workers.dev/badge/top-os-1)
![Top OS #2](https://dasterm-telemetry.username.workers.dev/badge/top-os-2)
![Top Virt](https://dasterm-telemetry.username.workers.dev/badge/top-virt)
![Top Lang](https://dasterm-telemetry.username.workers.dev/badge/top-lang)
![Top Mode](https://dasterm-telemetry.username.workers.dev/badge/top-mode)
```

---

## 14. Rate Limit

Worker memiliki rate limit ringan:

```text
IP based daily bucket
Machine hash daily bucket
```

Default:

```text
install    max 3 per machine_hash per day
run        max 30 per machine_hash per day
other      max 10 per machine_hash per day
IP bucket  max 120 per event per day
```

Tujuannya:

```text
Mengurangi spam
Mengurangi manipulasi badge
Menghindari abuse endpoint
```

---

## 15. Data yang Disimpan

Tabel `usage_events` menyimpan:

```text
event
version
distro
distro_version
arch
virt
lang
mode
machine_hash
date
user_agent_hash
created_at
```

---

## 16. Data yang Tidak Disimpan

Worker tidak menyimpan secara langsung:

```text
IP address mentah
Username
Hostname
Personal files
Commands
AI prompt
AI output
Process list
Private IP
Public key
Private key
Password
Token
Shell history
```

Catatan:

```text
Cloudflare mungkin tetap memproses metadata request untuk operasi jaringan, tetapi Worker tidak menyimpan IP mentah ke database.
```

---

## 17. Query Badge

Total installs:

```sql
SELECT COUNT(DISTINCT machine_hash)
FROM usage_events
WHERE event = 'install';
```

Total runs:

```sql
SELECT COUNT(*)
FROM usage_events
WHERE event = 'run';
```

Top OS:

```sql
SELECT distro AS name, COUNT(*) AS total
FROM usage_events
WHERE distro IS NOT NULL AND distro != ''
GROUP BY distro
ORDER BY total DESC
LIMIT 1;
```

Top OS #2:

```sql
SELECT distro AS name, COUNT(*) AS total
FROM usage_events
WHERE distro IS NOT NULL AND distro != ''
GROUP BY distro
ORDER BY total DESC
LIMIT 1 OFFSET 1;
```

---

## 18. Update Schema

Jika nanti schema berubah, buat file migration baru.

Untuk versi sederhana, bisa update `schema.sql`, lalu jalankan:

```bash
npm run db:migrate
```

Karena query memakai:

```sql
CREATE TABLE IF NOT EXISTS
CREATE INDEX IF NOT EXISTS
```

Aman dijalankan ulang.

---

## 19. Custom Domain

Kamu bisa pasang custom domain di Cloudflare Workers.

Contoh:

```text
https://dasterm-api.kaai.my.id
```

Lalu endpoint:

```text
https://dasterm-api.kaai.my.id/api/usage
https://dasterm-api.kaai.my.id/badge/installs
```

Config Dasterm:

```env
DASTERM_TELEMETRY_ENDPOINT="https://dasterm-api.kaai.my.id/api/usage"
```

README badge:

```md
![Total Installs](https://dasterm-api.kaai.my.id/badge/installs)
```

---

## 20. Troubleshooting

Jika deploy gagal:

```bash
npx wrangler whoami
```

Jika database tidak ditemukan:

```bash
npm run db:create
```

Pastikan `database_id` benar di:

```text
wrangler.toml
```

Jika migration gagal:

```bash
npx wrangler d1 execute dasterm_telemetry --file=./schema.sql
```

Jika badge selalu 0:

```text
Pastikan Dasterm mengirim telemetry
Pastikan endpoint benar
Pastikan DASTERM_TELEMETRY="on"
Pastikan DASTERM_TELEMETRY_ENDPOINT tidak kosong
Cek /stats
```

Jika request kena rate limit:

```text
Tunggu sampai bucket harian reset
Kurangi event run terlalu sering
```

---

## 21. Security Notes

Jangan pakai Worker untuk menyimpan:

```text
Secret
Token
Password
Command history
AI prompt
User personal data
```

Worker ini hanya untuk statistik anonim sederhana.

---

## 22. Kesimpulan

Cloudflare Worker telemetry membuat Dasterm terlihat profesional dengan badge live, tetapi tetap harus:

```text
Optional
Transparent
Minimal
Anonymous
Rate-limited
Easy to disable
```