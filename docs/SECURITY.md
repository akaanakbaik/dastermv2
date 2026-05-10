# Dasterm v2 Security

Dokumen ini menjelaskan desain keamanan Dasterm v2.

Dasterm adalah dashboard dan assistant terminal. Karena berjalan di server Linux, keamanan harus menjadi prioritas.

---

## 1. Prinsip Keamanan

Dasterm v2 mengikuti prinsip:

```text
Tidak mengubah sistem tanpa izin
Tidak menjalankan command AI tanpa approval
Tidak menjalankan command berbahaya dari AI
Tidak menyimpan data sensitif
Telemetry mati secara default
Shell integration kecil dan mudah dihapus
Config permission 600
Uninstall bersih
```

---

## 2. Shell Integration Aman

Dasterm tidak menaruh seluruh logic di `.bashrc`.

Installer hanya menambahkan block kecil:

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

Keuntungan:

```text
Mudah dihapus
Tidak membuat .bashrc terlalu panjang
Logic utama ada di /usr/local/bin/dasterm
Library ada di /usr/local/share/dasterm/lib
```

---

## 3. Config Permission

Config disimpan di:

```text
~/.config/dasterm/config.env
```

Permission:

```text
600
```

Artinya:

```text
Owner bisa read/write
Group tidak bisa read
Other tidak bisa read
```

Tujuannya agar config lebih aman.

---

## 4. Cache Permission

Cache disimpan di:

```text
~/.cache/dasterm/
```

Isi cache:

```text
speedtest.json
ai-memory.json
ai-provider-state.json
public-ip.cache
```

Cache tidak dimaksudkan untuk menyimpan secret.

---

## 5. AI Command Approval

AI tidak bisa langsung menjalankan command.

Flow:

```text
User menjalankan /ai
AI memberi hasil
Jika ada cmd, Dasterm menampilkan command
Dasterm meminta approval
User memilih yes/no
Command hanya jalan jika user memilih yes
```

Contoh:

```text
AI suggests this command:

dasterm storage

Run this command? [y/N]
```

Default:

```text
No
```

Jika user hanya tekan Enter, command batal.

---

## 6. AI Output Metadata

AI diminta membalas JSON:

```json
{
  "hasil": "Penjelasan untuk user.",
  "cmd": "dasterm storage"
}
```

Atau tanpa command:

```json
{
  "hasil": "Penjelasan untuk user."
}
```

Dasterm mengambil:

```text
hasil
cmd
```

Jika JSON rusak, Dasterm mencoba extract JSON.

Jika tetap gagal, output AI dianggap sebagai hasil biasa tanpa command.

---

## 7. AI Command Whitelist

Dasterm hanya mengizinkan command aman tertentu.

Allowed:

```text
dasterm help
dasterm status
dasterm lite
dasterm full
dasterm speedtest
dasterm respeedtest
dasterm network
dasterm storage
dasterm services
dasterm security
dasterm doctor
dasterm update
dasterm version
dasterm about
dasterm brain-ai
dasterm clear-brain-ai
dasterm ai-provider
dasterm ai-test
```

Slash allowed:

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
/update
/version
/about
/brain-ai
/clear-brain-ai
/ai-provider
/ai-test
```

---

## 8. AI Command Blocklist

Dasterm memblokir command berisiko:

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

Dasterm juga memblokir command chaining:

```text
&&
||
;
|
$()
backtick
>
<
```

Tujuannya agar AI tidak bisa membuat command kompleks atau menyisipkan command lain.

---

## 9. AI Memory Safety

AI memory disimpan di:

```text
~/.cache/dasterm/ai-memory.json
```

Memory berisi:

```text
Ringkasan input user
Ringkasan output AI
Summary harian
Tanggal WIB
```

Memory tidak dimaksudkan untuk menyimpan:

```text
Password
Token
SSH key
Private key
Cookie
Email sensitif
File rahasia
Data login
```

Jika user ingin menghapus:

```bash
/clear-brain-ai
```

---

## 10. Reset Memory Harian

Memory reset otomatis berdasarkan tanggal WIB.

Jika tanggal berubah, Dasterm membuat memory baru.

Tujuan:

```text
Memory tidak membesar terus
Konteks tetap segar
Data lama tidak tersimpan terlalu lama
```

---

## 11. Telemetry Default Off

Telemetry default:

```env
DASTERM_TELEMETRY="off"
```

Saat install, default jawaban telemetry adalah no.

Telemetry hanya aktif jika user mengizinkan.

---

## 12. Data Telemetry yang Boleh

Jika aktif, telemetry hanya boleh mengirim:

```text
event type
Dasterm version
Linux distro
Linux distro version
CPU architecture
Virtualization type
Language
Dashboard mode
Anonymous machine hash
Date
```

---

## 13. Data Telemetry yang Tidak Boleh

Dasterm tidak boleh sengaja mengirim:

```text
Username
Hostname
Public IP sebagai data tersimpan
Private IP
Command history
Process list
Personal files
SSH key
Token
Password
Email
Environment secrets
```

---

## 14. Anonymous Machine Hash

Jika telemetry aktif, Dasterm membuat hash anonim.

Source:

```text
/etc/machine-id
```

Yang dikirim:

```text
sha256("dasterm-v2-anonymous" + machine-id)
```

Machine-id mentah tidak dikirim.

---

## 15. Speedtest Safety

Speedtest tidak dijalankan setiap login.

Alasan:

```text
Menghemat bandwidth
Menghindari login lambat
Menghindari server kecil terbebani
Menghindari request berulang ke provider speedtest
```

Speedtest hanya berjalan jika:

```text
User memilih saat install
User menjalankan /respeedtest
AI menyarankan dan user menyetujui command respeedtest
```

---

## 16. Update Safety

Command:

```bash
/update
```

Akan:

```text
Cek versi terbaru
Tampilkan versi saat ini dan versi terbaru
Tampilkan changelog jika ada
Minta konfirmasi
Download file
Replace binary/library
Menjaga config user
```

Update tidak menghapus config.

---

## 17. Uninstall Safety

Uninstall hanya menghapus file Dasterm:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm
~/.config/dasterm
~/.cache/dasterm
Shell block Dasterm di .bashrc/.zshrc
```

Uninstall tidak menghapus project, service, Docker, storage, atau file user lain.

---

## 18. Security Command

Command:

```bash
/security
```

Hanya membaca status.

Dasterm tidak otomatis:

```text
Mengubah sshd_config
Mengaktifkan firewall
Menonaktifkan root login
Mengubah password auth
Install fail2ban
Restart SSH
```

Dasterm hanya memberi warning dan saran.

---

## 19. Doctor Command

Command:

```bash
/doctor
```

Mengecek:

```text
File Dasterm
Permission config
Dependency
Network
AI runtime
Speedtest cache
Shell integration
System signal
```

Doctor tidak mengubah sistem.

---

## 20. Risiko yang Perlu Diketahui

Dasterm tetap berjalan di shell user.

Hal yang harus diingat:

```text
Jangan menaruh token di config.env
Jangan menanyakan secret ke AI
Jangan menyetujui command yang tidak dipahami
Selalu baca command sebelum mengetik y
Jangan menjalankan Dasterm dari source yang tidak dipercaya
```

---

## 21. Best Practice

Rekomendasi:

```text
Install dari repo resmi
Aktifkan telemetry hanya jika percaya endpoint
Gunakan /doctor setelah update
Gunakan /security untuk audit ringan
Gunakan /clear-brain-ai jika pernah mengetik data sensitif
Cek isi ~/.config/dasterm/config.env secara berkala
Cek shell block di ~/.bashrc jika ada masalah
```

---

## 22. Report Security Issue

Jika menemukan bug keamanan, buat issue di repo:

```text
https://github.com/akaanakbaik/dastermv2/issues
```

Jelaskan:

```text
Versi Dasterm
OS
Command yang dijalankan
Output error
Potensi dampak
Langkah reproduksi
```

Jangan menaruh token, password, private key, atau data sensitif di issue publik.

---

## 23. Kesimpulan

Dasterm v2 dibuat agar AI dan dashboard tetap aman:

```text
AI dibatasi
Command butuh approval
Telemetry optional
Config private
Shell integration ringan
Uninstall bersih
```