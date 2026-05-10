# Dasterm v2 Release Guide

Dokumen ini menjelaskan cara membuat release Dasterm.

---

## 1. Tujuan Release Guide

Release guide membantu menjaga rilis tetap:

```text
Rapi
Aman
Terdokumentasi
Mudah rollback
Mudah diuji
```

---

## 2. Sebelum Release

Pastikan file berikut sudah benar:

```text
VERSION
CHANGELOG.md
README.md
install.sh
bin/dasterm
lib/*.sh
docs/*.md
.github/workflows/test.yml
```

---

## 3. Update VERSION

File:

```text
VERSION
```

Contoh:

```text
2.0.0
```

Untuk patch:

```text
2.0.1
```

Untuk minor:

```text
2.1.0
```

Untuk major:

```text
3.0.0
```

---

## 4. Update Version di Script

Cek version di:

```text
install.sh
bin/dasterm
README.md
CHANGELOG.md
```

Cari:

```bash
grep -R "2.0.0" .
```

Update sesuai versi baru.

---

## 5. Update CHANGELOG

File:

```text
CHANGELOG.md
```

Tambahkan section baru paling atas:

```md
## v2.0.1

### Fixed

- Fix ...
- Improve ...

### Changed

- Update ...
```

Untuk release besar:

```md
## v2.1.0

### Added

- Add ...

### Fixed

- Fix ...

### Security

- Harden ...
```

---

## 6. Jalankan Syntax Check

```bash
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
```

Jika ada error, fix sebelum commit.

---

## 7. Jalankan ShellCheck

```bash
shellcheck -x install.sh bin/dasterm lib/*.sh
```

Jika ShellCheck belum ada:

```bash
sudo apt install shellcheck
```

Atau pakai GitHub Actions.

---

## 8. Test Install Lokal

Di VPS/test machine:

```bash
sudo bash install.sh
```

Pilih:

```text
1) Install / Update
```

Test:

```bash
dasterm version
dasterm help
dasterm lite
dasterm full
dasterm doctor
```

---

## 9. Test Reconfigure

```bash
sudo bash install.sh
```

Pilih:

```text
2) Reconfigure
```

Ubah:

```text
Language
Mode
Theme
Slash alias
Prompt
```

Lalu:

```bash
source ~/.bashrc
/help
/status
```

---

## 10. Test Speedtest

```bash
dasterm respeedtest
dasterm speedtest
```

Pastikan output punya:

```text
Download Mbps
Download MB/s
Download Gbps
Download GB/s
Upload jika tersedia
Tested At
```

---

## 11. Test AI

```bash
dasterm ai-test
dasterm ai "halo"
dasterm ai "cek storage server saya"
```

Pastikan:

```text
AI menjawab
Jika ada cmd, Dasterm meminta approval
Command berbahaya diblokir
Memory tersimpan
```

Cek:

```bash
dasterm brain-ai
```

---

## 12. Test Storage

```bash
dasterm storage
```

Pastikan tidak crash walaupun:

```text
/datas tidak ada
Docker tidak ada
Permission du terbatas
node_modules tidak ada
```

---

## 13. Test Services

```bash
dasterm services
```

Pastikan tidak crash walaupun:

```text
Docker tidak ada
PM2 tidak ada
Nginx tidak ada
systemctl tidak tersedia
```

---

## 14. Test Security

```bash
dasterm security
```

Pastikan tidak crash walaupun:

```text
ufw tidak ada
fail2ban tidak ada
journalctl terbatas
sshd_config tidak bisa dibaca
```

---

## 15. Test Doctor

```bash
dasterm doctor
```

Pastikan menampilkan:

```text
Doctor Score
Files
Dependencies
Connectivity
System Signals
```

---

## 16. Test Update

Sebelum release, `/update` mungkin membaca branch `main`.

Test:

```bash
dasterm update
```

Pastikan:

```text
Current version muncul
Latest version muncul
Changelog muncul jika ada
Konfirmasi muncul
Config tidak hilang
```

---

## 17. Test Uninstall

```bash
sudo bash install.sh
```

Pilih:

```text
3) Uninstall
```

Cek file:

```bash
ls -la /usr/local/bin/dasterm
ls -la /usr/local/share/dasterm
ls -la ~/.config/dasterm
ls -la ~/.cache/dasterm
grep -n "DASTERM_V2" ~/.bashrc ~/.zshrc 2>/dev/null
```

File Dasterm harus hilang.

---

## 18. GitHub Actions

Pastikan workflow hijau:

```text
Bash Syntax
ShellCheck
```

File:

```text
.github/workflows/test.yml
```

Jika gagal, fix sebelum tag.

---

## 19. Commit

Contoh:

```bash
git add .
git commit -m "release: v2.0.0"
git push origin main
```

---

## 20. Tag Release

```bash
git tag v2.0.0
git push origin v2.0.0
```

---

## 21. GitHub Release Notes

Buat release di GitHub:

```text
https://github.com/akaanakbaik/dastermv2/releases
```

Title:

```text
Dasterm v2.0.0
```

Body:

```md
## Dasterm v2.0.0

Initial v2 release.

### Highlights

- Interactive installer
- Lite and Full dashboard
- Indonesian and English UI
- Cached speedtest
- AI assistant
- Storage analyzer
- Services monitor
- Security check
- Doctor
- Self-update
- Optional telemetry Worker backend

### Install

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```
```

---

## 22. Post Release Test

Setelah push ke GitHub, test one-liner dari raw:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Pastikan file bisa didownload.

---

## 23. Rollback

Jika release bermasalah:

```text
Fix di main secepatnya
Release patch version
Update changelog
Beri catatan di GitHub release
```

Jika perlu hapus tag lokal:

```bash
git tag -d v2.0.0
```

Hapus tag remote:

```bash
git push origin :refs/tags/v2.0.0
```

Gunakan hati-hati.

---

## 24. Versioning

Gunakan semantic versioning sederhana:

```text
MAJOR.MINOR.PATCH
```

Contoh:

```text
2.0.0
2.0.1
2.1.0
3.0.0
```

Kapan patch:

```text
Bug fix
Compatibility fix
Small docs fix
```

Kapan minor:

```text
Fitur baru
Telemetry backend
Plugin
Command baru
```

Kapan major:

```text
Perubahan besar arsitektur
Breaking change
Format config berubah
```

---

## 25. Checklist Release

```text
[ ] VERSION updated
[ ] CHANGELOG.md updated
[ ] README.md updated
[ ] Docs updated
[ ] bash -n passed
[ ] shellcheck passed or warnings reviewed
[ ] install tested
[ ] reconfigure tested
[ ] speedtest tested
[ ] ai tested
[ ] storage tested
[ ] services tested
[ ] security tested
[ ] doctor tested
[ ] update tested
[ ] uninstall tested
[ ] GitHub Actions passed
[ ] commit pushed
[ ] tag created
[ ] GitHub release created
[ ] raw install tested
```

---

## 26. Kesimpulan

Release Dasterm harus mengutamakan:

```text
Stabilitas
Keamanan
Kemudahan install
Kemudahan uninstall
Dokumentasi jelas
Tidak merusak shell user
```