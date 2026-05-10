# Dasterm v2 Install Commands

Dokumen ini berisi command install, update, repair, reconfigure, dan uninstall yang direkomendasikan untuk Dasterm v2.

Dasterm v2 memasang file ke:

```text
/usr/local/bin/dasterm
/usr/local/share/dasterm/
```

Karena itu, install membutuhkan akses `sudo` atau root.

---

## Install Recommended

Gunakan command ini:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Lalu pilih:

```text
1) Install / Update
```

---

## Install Langsung Tanpa Menu

Jika ingin langsung masuk mode install:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --install
```

---

## Reconfigure

Untuk mengatur ulang bahasa, mode, theme, prompt, slash alias, speedtest awal, dan telemetry:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --reconfigure
```

Atau dari command Dasterm:

```bash
/config
```

---

## Repair

Gunakan repair jika:

```text
Binary hilang
Library hilang
Shell integration rusak
Update gagal
Dasterm tidak bisa berjalan normal
```

Command:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
```

---

## Uninstall

Untuk uninstall bersih:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --uninstall
```

Atau:

```bash
/uninstall
```

---

## Manual Download

Jika tidak ingin memakai process substitution:

```bash
curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o install.sh
chmod +x install.sh
sudo ./install.sh
```

Langsung install:

```bash
sudo ./install.sh --install
```

Langsung repair:

```bash
sudo ./install.sh --repair
```

Langsung uninstall:

```bash
sudo ./install.sh --uninstall
```

---

## Setelah Install

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

## Jika Tidak Pakai Sudo

Jika menjalankan tanpa sudo:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Installer akan memberi instruksi untuk menjalankan ulang dengan sudo.

Ini normal karena Dasterm perlu menulis ke `/usr/local/bin` dan `/usr/local/share`.

---

## Kesimpulan

Command paling aman dan direkomendasikan:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh)
```

Untuk direct action:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --install
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --reconfigure
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --uninstall
```