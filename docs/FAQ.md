# Dasterm v2 FAQ

Pertanyaan yang sering muncul tentang Dasterm v2.

---

## 1. Apa itu Dasterm?

Dasterm adalah interactive terminal dashboard untuk Linux/VPS.

Dasterm menampilkan informasi server saat login dan menyediakan command seperti:

```text
/help
/status
/lite
/full
/speedtest
/respeedtest
/network
/storage
/services
/security
/doctor
/ai
/update
```

---

## 2. Dasterm cocok untuk siapa?

Dasterm cocok untuk:

```text
Pengguna VPS
Developer
Pelajar Linux
Admin server ringan
Pengguna Docker
Pengguna PM2
Pengguna Cloudflare Tunnel
Pengguna Pterodactyl
Orang yang ingin dashboard terminal rapi
```

---

## 3. Apakah Dasterm berat?

Tidak terlalu.

Dasterm v2 dibuat agar dashboard login tetap ringan.

Speedtest tidak dijalankan setiap login.

Public IP dicache.

Command berat seperti scan folder besar hanya berjalan jika user memanggil command khusus seperti:

```bash
/storage
```

---

## 4. Apa bedanya Lite dan Full?

Lite:

```text
Ringan
Cepat
Logo kecil
Info penting saja
Cocok untuk VPS kecil
```

Full:

```text
Lebih lengkap
Logo besar via fastfetch/neofetch jika ada
Info system, network, service lebih banyak
Cocok untuk server utama
```

---

## 5. Kenapa hanya ada 2 mode?

Agar Dasterm tetap mudah dipahami.

Mode:

```text
lite
full
```

Untuk detail tambahan, gunakan command:

```text
/storage
/network
/services
/security
/doctor
```

---

## 6. Apakah Dasterm menjalankan speedtest setiap login?

Tidak.

Dasterm hanya membaca hasil speedtest tersimpan dari:

```text
~/.cache/dasterm/speedtest.json
```

Untuk test ulang:

```bash
/respeedtest
```

Untuk melihat hasil tersimpan:

```bash
/speedtest
```

---

## 7. Kenapa speedtest saya belum ada?

Karena kamu mungkin memilih tidak menjalankan speedtest saat install.

Jalankan:

```bash
/respeedtest
```

---

## 8. Kenapa provider/region speedtest tidak muncul?

Karena provider speedtest mungkin tidak memberikan data itu.

Dasterm otomatis menyembunyikan field kosong agar output tetap rapi.

---

## 9. Apakah Dasterm butuh root?

Install butuh root/sudo karena memasang file ke:

```text
/usr/local/bin
/usr/local/share/dasterm
```

Namun command sehari-hari bisa dijalankan sebagai user biasa.

---

## 10. Di mana config Dasterm?

Config:

```text
~/.config/dasterm/config.env
```

---

## 11. Di mana cache Dasterm?

Cache:

```text
~/.cache/dasterm/
```

Isi umum:

```text
speedtest.json
ai-memory.json
ai-provider-state.json
public-ip.cache
```

---

## 12. Di mana log Dasterm?

Log:

```text
~/.local/share/dasterm/logs/
```

---

## 13. Apakah Dasterm mengubah `.bashrc`?

Ya, tapi hanya menambahkan block kecil:

```bash
### DASTERM_V2_BEGIN ###
...
### DASTERM_V2_END ###
```

Logic utama tidak ditaruh panjang di `.bashrc`.

---

## 14. Bagaimana cara mematikan dashboard saat login?

Jalankan:

```bash
/config
```

Ubah:

```text
Show dashboard every login?
```

Menjadi:

```text
manual
```

Atau edit config:

```env
DASTERM_SHOW="manual"
```

---

## 15. Bagaimana jika `/help` tidak jalan?

Jalankan:

```bash
source ~/.bashrc
```

Atau buka terminal baru.

Jika masih tidak jalan:

```bash
dasterm config
```

Aktifkan slash alias.

---

## 16. Apakah slash command benar-benar command Linux?

Slash command seperti:

```bash
/help
```

Adalah alias shell untuk:

```bash
dasterm help
```

Jika alias tidak aktif, gunakan command asli:

```bash
dasterm help
```

---

## 17. Apakah AI langsung menjalankan command?

Tidak.

Jika AI menyarankan command, Dasterm meminta persetujuan:

```text
Run this command? [y/N]
```

Default adalah no.

---

## 18. Apakah AI bisa menjalankan command berbahaya?

Dasterm membatasi command AI dengan whitelist.

Command seperti ini diblokir:

```text
rm
dd
mkfs
shutdown
reboot
chmod
chown
curl
wget
bash
sudo
su
```

Command chaining juga diblokir:

```text
&&
||
;
|
$()
>
<
```

---

## 19. Apa itu AI memory?

AI memory adalah ringkasan input/output AI hari ini.

File:

```text
~/.cache/dasterm/ai-memory.json
```

Memory reset otomatis berdasarkan tanggal WIB.

Hapus manual:

```bash
/clear-brain-ai
```

---

## 20. Apakah AI memory menyimpan password?

Seharusnya tidak.

Namun jangan pernah mengetik password/token/private key ke AI.

Jika terlanjur, jalankan:

```bash
/clear-brain-ai
```

Dan rotate secret jika perlu.

---

## 21. Apakah telemetry aktif otomatis?

Tidak.

Telemetry default:

```env
DASTERM_TELEMETRY="off"
```

Saat install, default jawabannya no.

---

## 22. Untuk apa telemetry?

Telemetry opsional dipakai untuk badge README seperti:

```text
Total Installs
Total Runs
Top OS
Top Virtualization
Top Language
```

---

## 23. Data apa yang dikirim telemetry?

Jika aktif:

```text
event
version
distro
distro version
architecture
virtualization
language
mode
anonymous machine hash
date
```

Tidak sengaja dikirim:

```text
username
hostname
command history
AI prompt
AI output
files
process list
password
token
SSH key
```

---

## 24. Bagaimana cara update Dasterm?

Jalankan:

```bash
/update
```

Atau:

```bash
dasterm update
```

---

## 25. Bagaimana cara uninstall?

Jalankan:

```bash
/uninstall
```

Atau installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
3) Uninstall
```

---

## 26. Distro apa yang didukung?

Target:

```text
Ubuntu
Debian
Linux Mint
Fedora
CentOS
RHEL
Rocky Linux
AlmaLinux
Arch Linux
Manjaro
EndeavourOS
openSUSE
Alpine
WSL
Docker
LXC
KVM
QEMU
VMware
```

---

## 27. Dependency minimal apa?

Minimal:

```text
bash
curl
jq
awk
sed
grep
coreutils
procps
iproute2
util-linux
```

Opsional:

```text
fastfetch
neofetch
speedtest
speedtest-cli
docker
pm2
ufw
fail2ban
```

---

## 28. Kenapa Full mode tidak menampilkan logo bagus?

Kemungkinan belum ada:

```text
fastfetch
neofetch
```

Install salah satu.

Ubuntu/Debian:

```bash
sudo apt install neofetch
```

Atau fastfetch jika tersedia di repo/package manager kamu.

---

## 29. Kenapa `/storage` lama?

Karena `/storage` melakukan scan folder besar dengan `du`.

Dasterm memberi timeout, tetapi pada server besar tetap bisa terasa beberapa detik.

---

## 30. Kenapa `/security` tidak mengubah setting SSH saya?

Karena Dasterm v2 hanya membaca dan memberi saran.

Dasterm tidak otomatis mengubah konfigurasi keamanan agar tidak merusak akses server.

---

## 31. Kenapa `/update` butuh sudo?

Karena update mengganti file di:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/lib
```

Lokasi itu biasanya butuh root/sudo.

---

## 32. Bagaimana cara repair?

Jalankan:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
4) Repair
```

---

## 33. Apa yang harus dilakukan setelah install?

Jalankan:

```bash
source ~/.bashrc
```

Lalu:

```bash
/help
/doctor
/status
```

---

## 34. Bagaimana kalau ada bug?

Buat issue di:

```text
https://github.com/akaanakbaik/dastermv2/issues
```

Sertakan:

```text
Versi Dasterm
OS
Shell
Command yang dijalankan
Output error
Langkah reproduksi
```

Jangan sertakan secret.

---

## 35. Apakah Dasterm bisa dipakai di Termux?

Target utama Dasterm v2 adalah Linux server/VPS.

Termux belum menjadi target utama, tetapi bisa masuk roadmap v2.2.