# Dasterm v2 API Notes

Dokumen ini menjelaskan endpoint eksternal yang dipakai Dasterm v2.

Dasterm v2 bisa memakai beberapa API untuk:

```text
AI assistant
Telemetry opsional
Public IP cache
Speedtest fallback
Update dari GitHub raw
```

---

## 1. AI: Prexzy AskGPT5

```bash
curl --get 'https://prexzyapis.com/ai/askgpt5' --data-urlencode 'prompt=hii'
```

Dasterm requires a successful JSON object with `status: true`, optional numeric
`statusCode` in the 2xx range, and a nonempty string `response`. The optional
`model` is displayed as reported by the provider; AskGPT5 is a service name,
not a guarantee of GPT-5. On 2026-11-05 the service reported
`qwen3.5-397b-a17b`.

Prompts are capped at 4000 UTF-8 bytes. HTTPS verification remains enabled;
connect/total deadlines are 8/45 seconds and responses are limited to 1 MiB.
No automatic retries or provider fallback are performed. Dasterm does not
persist provider state or chat history. See [AI.md](AI.md) for chat controls,
data handling, error behavior, and tests. This replaces the earlier provider
ordering, daily memory, and fallback contracts.

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
AI API gagal -> tampilkan error; /retry hanya atas permintaan pengguna
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
