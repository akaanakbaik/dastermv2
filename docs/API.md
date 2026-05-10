# Dasterm v2 API Notes

Dokumen ini menjelaskan endpoint eksternal yang dipakai Dasterm v2.

Dasterm v2 bisa memakai beberapa API untuk:

```text
AI assistant
AI fallback
Telemetry opsional
Public IP cache
Speedtest fallback
Update dari GitHub raw
```

---

## 1. AI Main Provider

Provider utama default:

```text
chocomilk
```

Endpoint:

```text
https://chocomilk.amira.us.kg/v1/llm/chatgpt/completions
```

Contoh:

```bash
curl -X GET "https://chocomilk.amira.us.kg/v1/llm/chatgpt/completions?ask=halo&systempromt=seorang+ai+dasterm" \
  -H "Accept: application/json"
```

Contoh response:

```json
{
  "info": "Developed by ZTRdiamond - Zanixon Group",
  "code": 200,
  "success": true,
  "data": {
    "answer": "Halo! Ada yang bisa saya bantu?"
  },
  "error": null
}
```

Dasterm mengambil:

```text
.data.answer
```

---

## 2. AI Fallback Provider 1

Provider:

```text
prexzy_copilot
```

Endpoint:

```text
https://apis.prexzyvilla.site/ai/copilot
```

Contoh:

```bash
curl -X GET "https://apis.prexzyvilla.site/ai/copilot?text=halo" \
  -H "Accept: application/json"
```

Contoh response:

```json
{
  "status": true,
  "statusCode": 200,
  "creator": "prexzy",
  "model": "Copilot",
  "text": "halo",
  "response": "Halo! Ada yang bisa saya bantu?",
  "timestamp": "2026-05-10T12:37:58.039Z"
}
```

Dasterm mengambil:

```text
.response
```

---

## 3. AI Fallback Provider 2

Provider:

```text
prexzy_zai
```

Endpoint:

```text
https://apis.prexzyvilla.site/ai/zai
```

Contoh:

```bash
curl -X GET "https://apis.prexzyvilla.site/ai/zai?text=halo+ai" \
  -H "Accept: application/json"
```

Contoh response:

```json
{
  "status": true,
  "statusCode": 200,
  "creator": "prexzy",
  "model": "Z.ai GLM-5",
  "text": "halo ai",
  "response": "Halo! Apa kabar? Ada yang bisa saya bantu hari ini?",
  "timestamp": "2026-05-10T12:37:58.039Z"
}
```

Dasterm mengambil:

```text
.response
```

---

## 4. AI Timeout

Setiap provider diberi timeout:

```text
10 seconds
```

Jika provider utama timeout/error:

```text
Output provider utama diabaikan
Dasterm lanjut ke fallback 1
Jika fallback 1 gagal, lanjut fallback 2
```

Jika provider utama gagal 3 kali:

```text
fallback1 menjadi primary
fallback2 menjadi fallback1
primary lama menjadi fallback2
```

State disimpan di:

```text
~/.cache/dasterm/ai-provider-state.json
```

---

## 5. AI Metadata Contract

Dasterm meminta AI mengembalikan JSON:

```json
{
  "hasil": "Jawaban untuk user.",
  "cmd": "dasterm storage"
}
```

Jika tidak perlu command:

```json
{
  "hasil": "Jawaban untuk user."
}
```

Aturan:

```text
hasil wajib ada
cmd optional
cmd hanya boleh satu command
cmd tidak boleh command chaining
cmd harus melewati whitelist
cmd harus disetujui user sebelum dijalankan
```

---

## 6. Public IP API

Dasterm memakai:

```text
https://api.ipify.org
```

Contoh:

```bash
curl -fsSL https://api.ipify.org
```

Hasil disimpan cache di:

```text
~/.cache/dasterm/public-ip.cache
```

TTL cache:

```text
3600 seconds
```

Public IP hanya untuk tampilan dashboard/network.

---

## 7. Speedtest Provider

Dasterm mencoba provider berikut:

```text
1. Ookla Speedtest CLI
2. speedtest-cli
3. curl fallback Cloudflare
```

---

## 8. Ookla Speedtest CLI

Command:

```bash
speedtest --accept-license --accept-gdpr --format=json
```

Data yang dipakai:

```text
download.bandwidth
upload.bandwidth
ping.latency
ping.jitter
packetLoss
isp
server.location
server.name
```

Catatan:

```text
Ookla bandwidth biasanya byte per second.
Dasterm mengubah ke bit per second dengan * 8.
```

---

## 9. speedtest-cli

Command:

```bash
speedtest-cli --json
```

Data yang dipakai:

```text
download
upload
ping
client.isp
server.country
server.sponsor
```

---

## 10. Curl Speedtest Fallback

Endpoint:

```text
https://speed.cloudflare.com/__down?bytes=25000000
```

Command internal:

```bash
curl -Lfs "https://speed.cloudflare.com/__down?bytes=25000000" -o /dev/null -w '%{size_download}'
```

Dasterm menghitung waktu mulai dan selesai, lalu menghitung:

```text
bps = downloaded_bytes * 8 / elapsed_seconds
```

Fallback ini hanya mengukur download.

---

## 11. Update API

Dasterm update mengambil file dari GitHub raw:

```text
https://raw.githubusercontent.com/akaanakbaik/dastermv2/main
```

File yang dibaca:

```text
VERSION
CHANGELOG.md
bin/dasterm
lib/*.sh
```

Command:

```bash
/update
```

Flow:

```text
Ambil VERSION
Bandingkan dengan versi lokal
Ambil CHANGELOG.md jika ada
Minta konfirmasi
Download file baru
Apply ke /usr/local/bin dan /usr/local/share/dasterm/lib
```

---

## 12. Telemetry API

Telemetry optional memakai endpoint:

```env
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

Request:

```http
POST /api/usage
Content-Type: application/json
```

Payload:

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

---

## 13. Telemetry Badge API

Jika memakai Worker opsional, endpoint badge:

```text
GET /badge/installs
GET /badge/runs
GET /badge/top-os-1
GET /badge/top-os-2
GET /badge/top-virt
GET /badge/top-lang
GET /badge/top-mode
```

Response:

```http
Content-Type: image/svg+xml
Cache-Control: public, max-age=300
```

---

## 14. Stats API

Endpoint:

```text
GET /stats
```

Contoh response:

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

## 15. API Failure Rule

Dasterm harus tetap berjalan walaupun API gagal.

Aturan:

```text
AI API gagal -> coba fallback
All AI gagal -> tampilkan error, jangan crash
Public IP API gagal -> tampilkan N/A
Speedtest API gagal -> coba fallback
Telemetry API gagal -> abaikan
GitHub update gagal -> tampilkan error, jangan merusak install
```

---

## 16. Privacy Rule

API tidak boleh digunakan untuk mengirim:

```text
Password
Token
SSH key
Command history
Process list
Personal file content
Private environment variables
AI output ke telemetry
AI prompt ke telemetry
```

---

## 17. Kesimpulan

Dasterm memakai API hanya untuk fitur yang membutuhkan network:

```text
AI
Update
Public IP
Speedtest fallback
Telemetry optional
```

Semua API harus punya fallback atau error handling agar Dasterm tetap stabil.