# Security Policy

Dokumen ini menjelaskan cara melaporkan masalah keamanan di Dasterm v2.

---

## Supported Versions

Versi yang didukung:

```text
v2.x
```

Versi lama seperti v12 interactive sebelumnya dianggap legacy dan tidak menjadi fokus utama security fix.

---

## Security Scope

Masalah yang termasuk security issue:

```text
AI bisa menjalankan command tanpa approval
AI command whitelist bisa dibypass
Command berbahaya bisa dieksekusi melalui /ai
Telemetry mengirim data sensitif
Installer menghapus file di luar scope Dasterm
Update mengambil file dari sumber tidak sesuai
Config permission terlalu terbuka
Shell integration menjalankan kode tidak aman
Worker telemetry menyimpan IP mentah tanpa kebutuhan
Worker menerima payload berbahaya
```

---

## Not Security Issue

Hal yang biasanya bukan security issue:

```text
Tampilan dashboard rusak
Warna tidak cocok
Output kurang rapi
Distro tertentu belum didukung
Speedtest gagal karena provider
AI provider sedang down
Badge README belum aktif
```

Itu tetap boleh dilaporkan sebagai bug biasa.

---

## Report a Vulnerability

Jika menemukan vulnerability, buat issue dengan judul jelas.

Contoh:

```text
security: AI command whitelist bypass with ...
```

Sertakan:

```text
Versi Dasterm
OS dan distro
Shell
Command yang dijalankan
Output yang muncul
Langkah reproduksi
Dampak
Saran fix jika ada
```

Jangan sertakan:

```text
Token
Password
Private key
Cookie
Data personal
IP server pribadi jika tidak perlu
```

---

## Sensitive Reports

Jika issue terlalu sensitif untuk publik, hubungi maintainer:

```text
akaanakbaik17@proton.me
```

Subject yang disarankan:

```text
Dasterm Security Report
```

---

## Response Expectation

Maintainer akan mencoba:

```text
Membaca laporan
Memastikan dampak
Membuat fix
Menambahkan test jika perlu
Update changelog
Memberi credit jika pelapor setuju
```

---

## AI Command Security

Fitur `/ai` harus mengikuti aturan:

```text
AI output harus diparse sebagai metadata
Command AI harus satu command saja
Command AI harus melewati whitelist
Command AI harus meminta approval
Command AI tidak boleh memakai chaining
Command AI tidak boleh menjalankan shell bebas
```

Command berbahaya harus diblokir:

```text
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

---

## Telemetry Security

Telemetry harus:

```text
Off by default
Opt-in
Tidak mengirim username
Tidak mengirim hostname
Tidak mengirim command history
Tidak mengirim AI prompt/output
Tidak mengirim file list
Tidak mengirim process list
Tidak menyimpan IP mentah di database Worker
```

---

## Installer Security

Installer harus:

```text
Memakai lock file
Tidak menghapus file selain file Dasterm
Tidak menaruh script panjang di .bashrc
Menyimpan config permission 600
Menghapus temporary directory
Meminta konfirmasi uninstall
```

---

## Update Security

Update harus:

```text
Mengambil file dari repo Dasterm yang dikonfigurasi
Menampilkan versi current/latest
Menampilkan changelog jika ada
Meminta konfirmasi
Tidak menghapus config/cache user
```

---

## Best Practice for Users

User disarankan:

```text
Install dari repo resmi
Baca command AI sebelum menyetujui
Jangan aktifkan telemetry jika tidak percaya endpoint
Jangan menaruh secret di config.env
Gunakan /doctor setelah update
Gunakan /security untuk audit ringan
Gunakan /clear-brain-ai jika pernah mengetik data sensitif
```

---

## Disclosure

Jika fix sudah tersedia, vulnerability bisa ditulis di changelog dengan detail secukupnya.

Jangan menulis exploit lengkap yang bisa langsung disalahgunakan jika belum ada mitigasi.