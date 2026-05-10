# Dasterm v2 Installer

Dasterm v2 memakai satu installer interaktif untuk:

```text
Install
Update
Reconfigure
Uninstall
Repair
Exit
```

Installer utama:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

---

## 1. Tujuan Installer

Installer dibuat agar user tidak perlu mengingat banyak command.

Satu command bisa dipakai untuk:

```text
Install pertama kali
Update file
Ubah config
Repair jika file rusak
Uninstall bersih
```

---

## 2. Menu Utama

Saat installer dijalankan:

```text
╔══════════════════════════════════════════════════════════════╗
║                         DASTERM V2                          ║
║            Interactive Linux Terminal Dashboard              ║
╚══════════════════════════════════════════════════════════════╝

Choose language / Pilih bahasa
1) Indonesia
2) English

Choose action
1) Install / Update
2) Reconfigure
3) Uninstall
4) Repair
5) Exit
```

---

## 3. Install / Update

Pilih:

```text
1) Install / Update
```

Installer akan:

```text
Mendeteksi target user
Membaca OS dan package manager
Meminta pilihan bahasa
Meminta pilihan mode
Meminta User@Host
Meminta theme
Meminta pengaturan dashboard login
Meminta pengaturan prompt
Meminta pengaturan slash alias
Meminta pilihan speedtest awal
Meminta pilihan telemetry anonim
Install dependency dasar
Download file Dasterm dari GitHub
Install binary ke /usr/local/bin/dasterm
Install library ke /usr/local/share/dasterm/lib
Simpan config ke ~/.config/dasterm/config.env
Inject shell integration ke .bashrc dan .zshrc
Menjalankan speedtest awal jika dipilih
```

---

## 4. Reconfigure

Pilih:

```text
2) Reconfigure
```

Fungsi:

```text
Mengubah config tanpa menghapus file Dasterm.
```

Yang bisa diubah:

```text
Language
Mode
Theme
User@Host
Dashboard login behavior
Prompt custom
Slash alias
Telemetry
Initial speedtest option
```

Reconfigure menyimpan ulang:

```text
~/.config/dasterm/config.env
```

---

## 5. Uninstall

Pilih:

```text
3) Uninstall
```

Installer akan meminta konfirmasi:

```text
This will remove Dasterm files and shell integration.
Continue uninstall? [y/N]
```

Jika user setuju, Dasterm menghapus:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm
~/.config/dasterm
~/.cache/dasterm
Dasterm shell block dari ~/.bashrc
Dasterm shell block dari ~/.zshrc
```

Uninstall tidak menghapus file lain di luar daftar tersebut.

---

## 6. Repair

Pilih:

```text
4) Repair
```

Repair dipakai jika:

```text
Binary hilang
Library hilang
Update gagal
Shell integration rusak
Config masih ada tapi Dasterm error
```

Repair akan:

```text
Install dependency dasar
Download ulang file dari GitHub
Replace binary
Replace library
Inject ulang shell integration
```

Repair tidak menghapus config user.

---

## 7. Exit

Pilih:

```text
5) Exit
```

Installer langsung keluar tanpa mengubah sistem.

---

## 8. File yang Diinstall

Binary:

```text
/usr/local/bin/dasterm
```

Library:

```text
/usr/local/share/dasterm/lib/
```

Config user:

```text
~/.config/dasterm/config.env
```

Cache:

```text
~/.cache/dasterm/
```

Log:

```text
~/.local/share/dasterm/logs/
```

Shell integration:

```text
~/.bashrc
~/.zshrc
```

---

## 9. Shell Integration

Installer menambahkan block kecil:

```bash
### DASTERM_V2_BEGIN ###
if [ -x /usr/local/bin/dasterm ]; then
  eval "$(/usr/local/bin/dasterm shell-init 2>/dev/null)"
  if [ -z "${DASTERM_SESSION_DONE:-}" ] && [ -t 1 ]; then
    export DASTERM_SESSION_DONE=1
    /usr/local/bin/dasterm auto 2>/dev/null || true
  fi
fi
### DASTERM_V2_END ###
```

Tujuan:

```text
Load slash alias
Load prompt custom jika aktif
Menampilkan dashboard saat login jika aktif
Tidak menaruh script panjang di .bashrc
Lebih mudah dihapus
Lebih aman
```

---

## 10. Config File

Config disimpan di:

```text
~/.config/dasterm/config.env
```

Contoh:

```env
DASTERM_VERSION="2.0.0"
DASTERM_LANG="id"
DASTERM_MODE="lite"
DASTERM_THEME="pastel"
DASTERM_USERHOST="root@aka"
DASTERM_SHOW="always"
DASTERM_PROMPT="on"
DASTERM_SLASH="on"
DASTERM_TELEMETRY="off"
DASTERM_REPO_OWNER="akaanakbaik"
DASTERM_REPO_NAME="dastermv2"
DASTERM_REPO_BRANCH="main"
```

Permission:

```text
600
```

Artinya hanya user pemilik yang bisa membaca dan menulis.

---

## 11. Bahasa Installer

Installer mendukung:

```text
Indonesia
English
```

Bahasa yang dipilih akan disimpan sebagai:

```env
DASTERM_LANG="id"
```

Atau:

```env
DASTERM_LANG="en"
```

---

## 12. Mode Installer

Mode dashboard:

```text
Lite
Full
```

Lite:

```text
Cepat
Ringkas
Logo kecil
Cocok VPS kecil
```

Full:

```text
Lengkap
Logo besar
Fastfetch/Neofetch jika ada
Cocok VPS utama
```

---

## 13. Theme Installer

Theme:

```text
Pastel
Cyber
Ocean
Mono
```

Theme hanya memengaruhi warna tampilan.

Tidak memengaruhi logic atau data.

---

## 14. Prompt Custom

Jika aktif:

```env
DASTERM_PROMPT="on"
```

Dasterm akan mengatur prompt terminal:

```text
user@host:/path$
```

Berdasarkan:

```env
DASTERM_USERHOST="root@aka"
```

Jika tidak ingin Dasterm mengubah prompt:

```env
DASTERM_PROMPT="off"
```

Atau melalui:

```bash
/config
```

---

## 15. Slash Alias

Jika aktif:

```env
DASTERM_SLASH="on"
```

Dasterm akan membuat alias:

```bash
alias /help='dasterm help'
alias /status='dasterm status'
alias /respeedtest='dasterm respeedtest'
alias /ai='dasterm ai'
alias /update='dasterm update'
```

Jika tidak aktif:

```env
DASTERM_SLASH="off"
```

Gunakan command asli:

```bash
dasterm help
dasterm status
dasterm ai "halo"
```

---

## 16. Speedtest Awal

Installer bertanya:

```text
Run initial speedtest and save result? [Y/n]
```

Jika yes:

```text
Dasterm menjalankan speedtest sekali.
Hasil disimpan ke ~/.cache/dasterm/speedtest.json.
Dashboard login membaca hasil itu.
```

Jika no:

```text
Speedtest tidak dijalankan.
Dashboard menampilkan info bahwa cache belum ada.
```

Kapan pun bisa jalankan:

```bash
/respeedtest
```

---

## 17. Telemetry

Installer bertanya:

```text
Allow anonymous statistics for README badges? [y/N]
```

Default:

```text
No
```

Jika yes:

```env
DASTERM_TELEMETRY="on"
```

Namun telemetry tetap membutuhkan endpoint:

```env
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

Jika endpoint kosong, tidak ada data yang dikirim.

---

## 18. Dependency

Installer mencoba install dependency dasar sesuai package manager.

Package manager yang didukung:

```text
apt-get
dnf
yum
pacman
zypper
apk
```

Dependency dasar:

```text
curl
ca-certificates
jq
coreutils
util-linux
procps
iproute2
gawk
sed
grep
pciutils
lsb-release
bc
```

Jika offline, installer akan melewati dependency install.

---

## 19. Permission Root

Karena file dipasang ke:

```text
/usr/local/bin
/usr/local/share
```

Install membutuhkan root/sudo.

Jika installer dijalankan tanpa root tapi `sudo` tersedia, installer mencoba memakai sudo.

Jika sudo tidak ada, installer meminta user menjalankan sebagai root.

---

## 20. Lock Installer

Installer memakai lock file:

```text
/tmp/dasterm-install.lock
```

Tujuan:

```text
Mencegah dua proses installer berjalan bersamaan.
Mencegah file tertimpa secara bersamaan.
Mencegah race condition.
```

---

## 21. Temporary Directory

Installer memakai:

```text
/tmp/dasterm-install-<pid>
```

Setelah selesai, folder sementara dihapus otomatis.

---

## 22. Cara Install Manual

Jika tidak mau pakai one-liner, bisa:

```bash
curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

---

## 23. Cara Repair Manual

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
4) Repair
```

---

## 24. Cara Uninstall Manual

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
3) Uninstall
```

---

## 25. Setelah Install

Jalankan:

```bash
source ~/.bashrc
```

Atau buka terminal baru.

Test:

```bash
dasterm version
dasterm help
dasterm doctor
```

Jika slash alias aktif:

```bash
/help
/doctor
/status
```

---

## 26. Troubleshooting Installer

Jika curl gagal:

```bash
sudo apt install curl ca-certificates
```

Jika jq tidak ada:

```bash
sudo apt install jq
```

Jika slash command tidak aktif:

```bash
source ~/.bashrc
```

Jika command `dasterm` tidak ditemukan:

```bash
ls -la /usr/local/bin/dasterm
```

Jika tidak ada, repair:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
4) Repair
```

---

## 27. Kesimpulan

Installer Dasterm v2 dibuat agar:

```text
Satu jalur
Interaktif
Aman
Mudah uninstall
Mudah repair
Mudah update
Tidak mengotori .bashrc dengan script panjang
Config user tetap rapi
```