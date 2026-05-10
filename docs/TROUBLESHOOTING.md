# Dasterm Troubleshooting

Dokumen ini membantu memperbaiki masalah umum di Dasterm v2.

---

## 1. Command `dasterm` Tidak Ditemukan

Cek file binary:

```bash
ls -la /usr/local/bin/dasterm
```

Jika tidak ada, install/repair:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
4) Repair
```

Jika permission salah:

```bash
sudo chmod +x /usr/local/bin/dasterm
```

---

## 2. Slash Command `/help` Tidak Jalan

Slash command adalah alias shell.

Reload shell:

```bash
source ~/.bashrc
```

Atau untuk Zsh:

```bash
source ~/.zshrc
```

Cek alias:

```bash
alias /help
```

Jika tidak ada, jalankan:

```bash
dasterm config
```

Aktifkan:

```text
Enable slash aliases? on
```

---

## 3. Dashboard Tidak Muncul Saat Login

Cek config:

```bash
cat ~/.config/dasterm/config.env
```

Pastikan:

```env
DASTERM_SHOW="always"
```

Jika `manual`, ubah via:

```bash
/config
```

Atau:

```bash
dasterm config
```

Cek shell block:

```bash
grep -n "DASTERM_V2_BEGIN" ~/.bashrc ~/.zshrc 2>/dev/null
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

## 4. Dashboard Muncul Dua Kali

Kemungkinan shell nested atau `.bashrc` dan `.zshrc` sama-sama terpanggil.

Cek block:

```bash
grep -n "DASTERM_V2_BEGIN" ~/.bashrc ~/.zshrc 2>/dev/null
```

Hapus duplikat dengan repair atau uninstall/install ulang.

Dasterm memakai:

```bash
DASTERM_SESSION_DONE
```

Agar tidak tampil berulang dalam satu session.

---

## 5. Tampilan Berantakan

Penyebab umum:

```text
Terminal terlalu sempit
Font tidak mendukung box drawing
NO_COLOR aktif
TERM tidak cocok
```

Coba:

```bash
echo $TERM
tput cols
```

Gunakan mode lite:

```bash
/lite
```

Atau:

```bash
dasterm lite
```

Gunakan theme mono:

```bash
/config
```

Pilih:

```text
Mono
```

---

## 6. Logo Full Tidak Bagus

Full mode memakai:

```text
fastfetch
neofetch
fallback ASCII Dasterm
```

Install neofetch:

```bash
sudo apt update
sudo apt install neofetch
```

Jika tersedia, fastfetch lebih modern:

```bash
sudo apt install fastfetch
```

Pada beberapa distro, nama package fastfetch berbeda.

---

## 7. Speedtest Belum Ada

Jika dashboard menampilkan:

```text
No saved speedtest result. Run /respeedtest.
```

Jalankan:

```bash
/respeedtest
```

Atau:

```bash
dasterm respeedtest
```

---

## 8. `/respeedtest` Gagal

Cek dependency:

```bash
dasterm doctor
```

Cek internet:

```bash
ping -c 1 1.1.1.1
```

Install dependency dasar:

```bash
sudo apt update
sudo apt install curl jq speedtest-cli
```

Jika speedtest-cli tidak tersedia, Dasterm masih mencoba curl fallback.

---

## 9. Speedtest Hanya Ada Download

Itu bisa terjadi jika Dasterm memakai curl fallback.

Curl fallback hanya mengukur download dari Cloudflare.

Untuk hasil lengkap, install speedtest provider:

```bash
sudo apt install speedtest-cli
```

Atau gunakan Ookla Speedtest CLI resmi.

---

## 10. Provider/Region Speedtest Kosong

Tidak semua provider speedtest memberikan data:

```text
provider
region
server
packet loss
jitter
```

Jika field kosong, Dasterm menyembunyikannya agar output rapi.

---

## 11. Public IP Lambat atau N/A

Public IP memakai request internet dan dicache.

Jika N/A:

```text
Internet tidak tersedia
api.ipify.org tidak bisa diakses
curl belum terinstall
Firewall memblokir request
```

Cek:

```bash
curl -fsSL https://api.ipify.org
```

---

## 12. `/storage` Lama

`/storage` melakukan scan folder besar memakai `du`.

Pada server besar, bisa butuh beberapa detik.

Dasterm memberi timeout, tetapi beberapa filesystem tetap lambat.

Jika sangat lambat, jalankan manual:

```bash
du -xhd 1 / 2>/dev/null | sort -hr | head
```

---

## 13. Docker Info Error

Jika output Docker:

```text
installed but not reachable
```

Kemungkinan:

```text
Docker daemon mati
User belum masuk group docker
Butuh sudo
Socket permission terbatas
```

Cek:

```bash
systemctl status docker
```

Atau:

```bash
docker info
```

---

## 14. PM2 Tidak Terdeteksi

Pastikan PM2 ada di PATH shell kamu:

```bash
which pm2
pm2 jlist
```

Jika PM2 diinstall via user tertentu, root mungkin tidak melihat PM2 user tersebut.

---

## 15. `/security` Permission Denied

Beberapa file seperti SSH config atau log auth mungkin butuh root.

Coba:

```bash
sudo dasterm security
```

Namun hati-hati jika prompt dan HOME berubah saat memakai sudo.

---

## 16. Failed Login 24h N/A

Penyebab:

```text
journalctl tidak tersedia
Log auth tidak tersedia
Permission terbatas
Distro memakai path log berbeda
```

Dasterm akan menampilkan N/A jika tidak bisa membaca.

---

## 17. `/doctor` Menampilkan Dependency Missing

Install dependency sesuai distro.

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install curl jq coreutils util-linux procps iproute2 gawk sed grep pciutils bc
```

Alpine:

```bash
sudo apk add curl jq coreutils util-linux procps iproute2 gawk sed grep pciutils bc
```

Arch:

```bash
sudo pacman -S curl jq coreutils util-linux procps-ng iproute2 gawk sed grep pciutils bc
```

Fedora:

```bash
sudo dnf install curl jq coreutils util-linux procps-ng iproute gawk sed grep pciutils bc
```

---

## 18. AI Tidak Menjawab

Cek:

```bash
/ai-test
```

Atau:

```bash
dasterm ai-test
```

Pastikan:

```text
curl tersedia
jq tersedia
internet tersedia
provider tidak down
```

Cek provider:

```bash
/ai-provider
```

Reset provider:

```bash
/ai-reset-provider
```

---

## 19. AI Menghasilkan JSON Rusak

Dasterm mencoba mengambil JSON dari output AI.

Jika tetap rusak, output dianggap sebagai teks biasa.

Command tidak akan dijalankan jika field `cmd` tidak valid.

---

## 20. AI Command Diblokir

Jika muncul:

```text
AI suggested a command, but Dasterm blocked it...
```

Artinya command tidak masuk whitelist aman.

Ini normal untuk keamanan.

Gunakan command Dasterm manual jika yakin:

```bash
dasterm help
```

---

## 21. AI Memory Salah Konteks

Hapus memory:

```bash
/clear-brain-ai
```

Lihat memory:

```bash
/brain-ai
```

Memory reset otomatis setiap tanggal berganti berdasarkan WIB.

---

## 22. `/update` Gagal

Cek internet:

```bash
curl -I https://raw.githubusercontent.com
```

Cek repo config:

```bash
grep DASTERM_REPO ~/.config/dasterm/config.env
```

Repair manual:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
4) Repair
```

---

## 23. GitHub Actions Gagal di ShellCheck

ShellCheck sering memberi warning style.

Cek lokal:

```bash
shellcheck -x install.sh bin/dasterm lib/*.sh
```

Jika warning benar, perbaiki.

Jika false positive, tambahkan alasan di PR.

---

## 24. Worker Badge Selalu 0

Cek config Dasterm:

```bash
grep TELEMETRY ~/.config/dasterm/config.env
```

Harus ada:

```env
DASTERM_TELEMETRY="on"
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

Cek worker:

```bash
curl https://your-worker.example.com/stats
```

Cek kirim manual:

```bash
curl -X POST "https://your-worker.example.com/api/usage" \
  -H "Content-Type: application/json" \
  -d '{"event":"install","version":"2.0.0","distro":"ubuntu","distro_version":"24.04","arch":"x86_64","virt":"kvm","lang":"id","mode":"lite","machine_hash":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","date":"2026-05-10"}'
```

---

## 25. Worker Rate Limited

Jika response:

```text
rate limited
```

Tunggu sampai bucket harian reset.

Limit default:

```text
install max 3 per machine per day
run max 30 per machine per day
other max 10 per machine per day
IP max 120 per event per day
```

---

## 26. Uninstall Tidak Bersih

Jalankan installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Pilih:

```text
3) Uninstall
```

Cek sisa file:

```bash
ls -la /usr/local/bin/dasterm
ls -la /usr/local/share/dasterm
ls -la ~/.config/dasterm
ls -la ~/.cache/dasterm
grep -n "DASTERM_V2" ~/.bashrc ~/.zshrc 2>/dev/null
```

Hapus manual jika perlu.

---

## 27. Masih Error?

Jalankan:

```bash
dasterm doctor
```

Lalu buat issue:

```text
https://github.com/akaanakbaik/dastermv2/issues
```

Sertakan:

```text
Output /doctor
OS
Shell
Command yang error
Langkah reproduksi
```

Jangan kirim token, password, private key, atau data sensitif.