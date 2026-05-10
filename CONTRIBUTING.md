# Contributing to Dasterm v2

Terima kasih sudah ingin berkontribusi ke Dasterm v2.

Dasterm adalah interactive terminal dashboard untuk Linux/VPS dengan fitur dashboard, speedtest cache, AI assistant, storage analyzer, service monitor, security check, updater, dan telemetry opsional.

---

## 1. Prinsip Project

Kontribusi harus mengikuti prinsip utama Dasterm:

```text
Ringan saat login
Aman untuk server
Mudah dipahami pemula
Berguna untuk developer
Interaktif
Mudah uninstall
Tidak merusak shell user
Tidak menyimpan data sensitif
```

---

## 2. Struktur Project

```text
dastermv2/
├── install.sh
├── VERSION
├── CHANGELOG.md
├── LICENSE
├── README.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
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
│   ├── WORKER.md
│   ├── DEVELOPMENT.md
│   └── FAQ.md
├── worker/
│   ├── package.json
│   ├── wrangler.toml
│   ├── schema.sql
│   └── src/
│       └── index.js
└── .github/
    └── workflows/
        └── test.yml
```

---

## 3. Cara Mulai

Fork repo:

```text
https://github.com/akaanakbaik/dastermv2
```

Clone:

```bash
git clone https://github.com/YOUR_USERNAME/dastermv2.git
cd dastermv2
```

Buat branch:

```bash
git checkout -b feature/nama-fitur
```

---

## 4. Cek Syntax

Sebelum commit, jalankan:

```bash
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
```

Jika punya ShellCheck:

```bash
shellcheck -x install.sh bin/dasterm lib/*.sh
```

---

## 5. Test Manual

Install lokal:

```bash
sudo bash install.sh
```

Test command:

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

Test speedtest:

```bash
dasterm respeedtest
dasterm speedtest
```

Test AI:

```bash
dasterm ai-test
dasterm ai "halo"
dasterm ai "cek storage"
```

Test update:

```bash
dasterm update
```

---

## 6. Aturan Bash

Gunakan shebang:

```bash
#!/usr/bin/env bash
```

Untuk file executable utama:

```bash
set -euo pipefail
IFS=$' \t\n'
```

Untuk file library di `lib/`, hindari `set -euo pipefail` agar tidak merusak caller.

Semua function harus memakai prefix:

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

## 7. Aturan Output

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

Jangan membuat style output yang terlalu berbeda di setiap module.

---

## 8. Bahasa

Dasterm mendukung:

```text
Indonesia
English
```

Jika menambah teks yang tampil ke user, tambahkan key di:

```text
lib/i18n.sh
```

Contoh:

```bash
id:new_key) echo "Teks Indonesia" ;;
en:new_key) echo "English text" ;;
```

Gunakan:

```bash
dasterm_t new_key
```

---

## 9. Mode Dashboard

Dasterm v2 hanya punya dua mode:

```text
lite
full
```

Jangan menambah mode baru kecuali benar-benar penting.

Jika butuh detail tambahan, buat command/module baru seperti:

```text
/storage
/network
/services
/security
/doctor
```

---

## 10. Aturan AI

Fitur AI harus aman.

AI tidak boleh:

```text
Menjalankan command tanpa approval
Menyarankan command destruktif
Menyimpan data sensitif
Mengirim command chaining
Mengeksekusi curl/wget/bash/sh/sudo/su dari output AI
```

Semua command dari AI harus melewati:

```bash
dasterm_ai_command_safe
```

Dan harus meminta konfirmasi user.

---

## 11. Aturan Speedtest

Speedtest tidak boleh berjalan otomatis setiap login.

Speedtest hanya boleh berjalan jika:

```text
User memilih saat install
User menjalankan /respeedtest
AI menyarankan dan user menyetujui
```

Dashboard hanya membaca cache:

```text
~/.cache/dasterm/speedtest.json
```

---

## 12. Aturan Telemetry

Telemetry harus:

```text
Off by default
Opt-in
Transparan
Minimal
Anonymous
Mudah dimatikan
Tidak membuat command gagal jika endpoint mati
```

Telemetry tidak boleh mengirim:

```text
Username
Hostname
IP sebagai stored data
Process list
Command history
AI prompt
AI output
Token
Password
SSH key
File path personal
```

---

## 13. Aturan Security

Command `/security` hanya membaca dan memberi saran.

Jangan membuat Dasterm otomatis mengubah:

```text
sshd_config
firewall
password auth
root login
fail2ban
iptables
nftables
```

Kecuali di masa depan ada fitur khusus yang meminta konfirmasi eksplisit dan jelas.

---

## 14. Commit Message

Gunakan format sederhana:

```text
feat: add new feature
fix: repair bug
docs: update documentation
refactor: improve structure
security: harden ai command validation
ci: update github action
chore: cleanup
```

Contoh:

```text
feat: add speedtest cache
fix: prevent ai command chaining
docs: update usage guide
```

---

## 15. Pull Request

Sebelum membuat PR:

```text
Pastikan bash -n aman
Pastikan shellcheck aman atau warning dijelaskan
Pastikan docs diupdate jika fitur berubah
Pastikan README diupdate jika fitur besar berubah
Pastikan CHANGELOG diupdate
```

PR sebaiknya menjelaskan:

```text
Apa yang diubah
Kenapa diubah
Cara test
Risiko
Screenshot/output jika perlu
```

---

## 16. Issue

Saat membuat issue, sertakan:

```text
Versi Dasterm
OS
Shell
Command yang dijalankan
Output error
Langkah reproduksi
```

Jangan sertakan:

```text
Password
Token
Private key
Cookie
IP jika tidak perlu
Data pribadi
```

---

## 17. Development Roadmap

Prioritas kontribusi yang bagus:

```text
Bug fix
ShellCheck cleanup
Better distro support
Better terminal width handling
Better docs
Worker telemetry backend improvement
Safer AI command registry
More accurate service detection
Better speedtest provider support
```

---

## 18. Kesimpulan

Kontribusi terbaik untuk Dasterm adalah kontribusi yang membuatnya:

```text
Lebih aman
Lebih ringan
Lebih jelas
Lebih mudah dipakai
Lebih mudah dihapus
Lebih berguna untuk VPS
```

Terima kasih sudah membantu Dasterm berkembang.