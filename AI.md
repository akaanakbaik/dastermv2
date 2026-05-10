# Dasterm v2 AI System

Dasterm v2 memiliki fitur AI assistant melalui command:

```bash
/ai <permintaan>
```

**Contoh:**

```bash
/ai cek storage server saya
```

AI dapat menjawab pertanyaan, memberi saran, dan menyarankan command Dasterm yang aman.

---

## Daftar Isi

- [Tujuan AI](#1-tujuan-ai)
- [Format Output AI](#2-format-output-ai)
- [System Prompt](#3-system-prompt)
- [Command Approval](#4-command-approval)
- [Command Safety](#5-command-safety)
- [API Utama](#6-api-utama)
- [API Cadangan](#7-api-cadangan)
- [Timeout dan Fallback](#8-timeout-dan-fallback)
- [Command Provider](#9-command-provider)
- [AI Memory](#10-ai-memory)
- [Reset Memory Harian](#11-reset-memory-harian)
- [Clear Memory Manual](#12-clear-memory-manual)
- [Auto Summary](#13-auto-summary)
- [Contoh Penggunaan](#14-contoh-penggunaan)
- [Prinsip Keamanan](#15-prinsip-keamanan)
- [Troubleshooting](#16-troubleshooting)
- [Catatan Penting](#17-catatan-penting)

---

## 1. Tujuan AI

AI Dasterm dibuat untuk:

- Membantu user memahami kondisi server
- Memberi saran optimasi Linux/VPS
- Memberi command Dasterm yang relevan
- Menjelaskan hasil command
- Membantu troubleshooting
- Memberi alur langkah yang mudah diikuti

> AI tidak boleh langsung mengeksekusi command tanpa persetujuan user.

---

## 2. Format Output AI

AI wajib menghasilkan JSON valid.

**Tanpa command:**

```json
{
  "hasil": "Halo! Saya Dasterm AI. Saya bisa bantu cek server, storage, network, speedtest, security, service, update, dan troubleshooting."
}
```

**Dengan command:**

```json
{
  "hasil": "Saya bisa menampilkan ringkasan storage, mount, root disk, /datas, Docker root, dan folder terbesar.",
  "cmd": "dasterm storage"
}
```

**Field:**

| Field | Keterangan |
|-------|------------|
| `hasil` | Jawaban untuk user |
| `cmd` | Command opsional, hanya jika benar-benar diperlukan |

Jika tidak perlu command, field `cmd` tidak boleh ada.

---

## 3. System Prompt

System prompt utama Dasterm AI:

> Kamu adalah Dasterm AI, asisten terminal Linux/VPS yang membantu user memahami server, menjalankan diagnosis, memberi saran optimasi, dan membuat command aman.
>
> **ATURAN OUTPUT WAJIB:**
> 1. Balas hanya dalam format JSON valid.
> 2. Jangan tulis markdown.
> 3. Jangan tulis teks di luar JSON.
> 4. Key utama wajib `"hasil"`.
> 5. Key `"cmd"` hanya boleh ada jika permintaan user memang membutuhkan command terminal.
> 6. Jika tidak perlu command, jangan sertakan key `"cmd"`.
> 7. Jika ada `"cmd"`, nilainya wajib satu command saja.
> 8. Jangan membuat lebih dari satu command.
> 9. Jangan menggabungkan command dengan `&&`, `||`, `;`, pipe kompleks, subshell, backtick, redirect file, atau command chaining.
> 10. Command harus singkat, aman, dan sesuai permintaan user.
> 11. Jangan membuat command destruktif seperti `rm -rf`, `mkfs`, `dd` overwrite, `shutdown`, `reboot`, `passwd`, `userdel`, `chown`/`chmod` massal, `iptables` flush, `ufw reset`, atau command yang bisa merusak sistem.
> 12. Jika user meminta aksi berbahaya, jangan berikan `cmd`. Jelaskan risikonya di `hasil`.
> 13. Gunakan bahasa yang sama dengan input user.
> 14. Penjelasan di `hasil` harus mudah dibaca, ringkas, dan jelas.
> 15. Jangan mengarang hasil eksekusi command. Jika butuh data server, berikan command untuk dicek.
> 16. Jika memory tersedia, gunakan sebagai konteks.
> 17. Jika user meminta speedtest ulang, gunakan `cmd` `"dasterm respeedtest"`.
> 18. Jika user meminta lihat speedtest tersimpan, gunakan `cmd` `"dasterm speedtest"`.
> 19. Jika user meminta update Dasterm, gunakan `cmd` `"dasterm update"`.
> 20. Jika user meminta menu, gunakan `cmd` `"dasterm help"`.
> 21. Jika user meminta cek kesehatan server, gunakan `cmd` `"dasterm doctor"`.
> 22. Jika user meminta cek storage, gunakan `cmd` `"dasterm storage"`.
> 23. Jika user meminta cek network, gunakan `cmd` `"dasterm network"`.
> 24. Jika user meminta cek service, gunakan `cmd` `"dasterm services"`.
> 25. Jika user meminta cek keamanan, gunakan `cmd` `"dasterm security"`.
> 26. Jika user meminta hapus memori AI, gunakan `cmd` `"dasterm clear-brain-ai"`.
>
> **FORMAT TANPA COMMAND:**
> ```json
> {"hasil":"isi jawaban"}
> ```
>
> **FORMAT DENGAN COMMAND:**
> ```json
> {"hasil":"isi jawaban dan jelaskan command yang disarankan","cmd":"satu command"}
> ```

---

## 4. Command Approval

Jika AI memberi `cmd`, Dasterm tidak langsung menjalankannya.

Dasterm menampilkan:

```
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

Jika user menjawab `y`, maka command dijalankan. Jika tidak, command dibatalkan.

---

## 5. Command Safety

Dasterm hanya mengizinkan command dari whitelist aman.

**Command yang diizinkan:**

| Command | Alias |
|---------|-------|
| `dasterm help` | `/help` |
| `dasterm status` | `/status` |
| `dasterm lite` | `/lite` |
| `dasterm full` | `/full` |
| `dasterm speedtest` | `/speedtest` |
| `dasterm respeedtest` | `/respeedtest` |
| `dasterm network` | `/network` |
| `dasterm storage` | `/storage` |
| `dasterm services` | `/services` |
| `dasterm security` | `/security` |
| `dasterm doctor` | `/doctor` |
| `dasterm update` | `/update` |
| `dasterm version` | `/version` |
| `dasterm about` | `/about` |
| `dasterm brain-ai` | `/brain-ai` |
| `dasterm clear-brain-ai` | `/clear-brain-ai` |
| `dasterm ai-provider` | `/ai-provider` |
| `dasterm ai-test` | `/ai-test` |

**Command yang diblokir:**

```
rm
mkfs
dd
shutdown
reboot
poweroff
halt
passwd
userdel
groupdel
chown
chmod
iptables
nft
ufw reset
curl
wget
bash
sh
sudo
su
```

**Command chaining juga diblokir:**

```
&&
||
;
|
$()
backtick
>
<
```

Tujuannya agar AI tidak bisa mengeksekusi command berbahaya atau command shell kompleks.

---

## 6. API Utama

API utama:

```bash
curl -X GET "https://chocomilk.amira.us.kg/v1/llm/chatgpt/completions?ask=siapa+nama+ku&systempromt=seorang+ai+dasterm+dgn+menggunakan+bahasa+sesuai+dari+input+"   -H "Accept: application/json"
```

**Contoh output:**

```json
{
  "info": "Developed by ZTRdiamond - Zanixon Group",
  "code": 200,
  "success": true,
  "data": {
    "answer": "Saya tidak tahu nama Anda, karena Anda belum memberitahukannya kepada saya."
  },
  "error": null
}
```

Dasterm mengambil: `.data.answer`

---

## 7. API Cadangan

**Cadangan 1:**

```
https://apis.prexzyvilla.site/ai/copilot?text=halo
```

**Cadangan 2:**

```
https://apis.prexzyvilla.site/ai/zai?text=halo+ai
```

**Contoh output:**

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

Dasterm mengambil: `.response`

---

## 8. Timeout dan Fallback

Timeout setiap provider: **10 detik**

**Logika:**

1. Coba provider utama
2. Jika timeout/error/kosong, abaikan
3. Coba fallback 1
4. Jika gagal, coba fallback 2
5. Jika semua gagal, tampilkan error

**Jika provider utama delay/error 3 kali berturut-turut:**

- `fallback1` menjadi primary
- `fallback2` menjadi fallback1
- primary lama menjadi fallback2
- delay count kembali 0

**State disimpan di:**

```
~/.cache/dasterm/ai-provider-state.json
```

**Contoh:**

```json
{
  "primary": "chocomilk",
  "fallback1": "prexzy_copilot",
  "fallback2": "prexzy_zai",
  "primary_delay_count": 0
}
```

---

## 9. Command Provider

**Melihat provider:**

```bash
/ai-provider
```

**Reset provider:**

```bash
/ai-reset-provider
```

**Test provider:**

```bash
/ai-test
```

---

## 10. AI Memory

**File memory:**

```
~/.cache/dasterm/ai-memory.json
```

**Format:**

```json
{
  "date": "2026-05-10",
  "summary": "",
  "items": [
    {
      "input": "cek storage server saya",
      "output": "Saya bisa menampilkan ringkasan storage..."
    }
  ]
}
```

---

## 11. Reset Memory Harian

Memory mengikuti tanggal WIB.

Jika tanggal berubah, Dasterm otomatis reset: **00:00 WIB**

Secara teknis, setiap command AI dijalankan, Dasterm mengecek `date` sekarang di `Asia/Jakarta`. Jika beda dari `.date` di memory, file memory dibuat ulang.

---

## 12. Clear Memory Manual

```bash
/clear-brain-ai
```

Command ini menghapus memory AI hari ini.

---

## 13. Auto Summary

Jika `items` lebih dari 5, Dasterm otomatis meminta AI untuk meringkas.

**Prompt ringkasan:**

> Ringkas percakapan Dasterm AI berikut menjadi memory pendek dan berguna untuk konteks berikutnya.
>
> Aturan:
> 1. Simpan hanya hal penting.
> 2. Jangan simpan data sensitif.
> 3. Jangan simpan command berbahaya.
> 4. Gunakan bahasa Indonesia ringkas.
> 5. Maksimal 1200 karakter.
> 6. Fokus pada preferensi user, masalah server, keputusan, dan hasil penting.
> 7. Balas hanya teks ringkasan, bukan JSON.

Setelah ringkasan dibuat:

- `summary` diisi
- `items` dikosongkan

---

## 14. Contoh Penggunaan

**User:**

```bash
/ai halo
```

**AI:**

```json
{
  "hasil": "Halo! Saya Dasterm AI. Saya bisa bantu cek server, speedtest, storage, network, service, security, dan update Dasterm."
}
```

**User:**

```bash
/ai test ulang internet
```

**AI:**

```json
{
  "hasil": "Saya bisa menjalankan ulang speedtest dan menyimpan hasil terbarunya ke cache Dasterm.",
  "cmd": "dasterm respeedtest"
}
```

**Dasterm:**

```
AI suggests this command:

dasterm respeedtest

Run this command? [y/N]
```

---

## 15. Prinsip Keamanan

AI Dasterm harus:

- Tidak langsung menjalankan command
- Tidak menjalankan command destruktif
- Tidak menjalankan command shell kompleks
- Tidak mengubah sistem tanpa izin
- Tidak mengarang hasil command
- Tidak menyimpan data sensitif ke memory
- Tidak memaksa user mengikuti saran AI

---

## 16. Troubleshooting

| Masalah | Solusi |
|---------|--------|
| AI tidak menjawab | `/ai-test` |
| Provider utama lambat | `/ai-provider` |
| Ingin reset urutan provider | `/ai-reset-provider` |
| Memory terasa kacau | `/clear-brain-ai` |
| `jq` belum ada | `sudo apt install jq` |
| `curl` belum ada | `sudo apt install curl` |

---

## 17. Catatan Penting

AI adalah **helper**.

Untuk command berisiko tinggi, tetap cek manual.

Dasterm v2 sengaja membatasi AI agar hanya bisa menyarankan command aman dari daftar whitelist.
