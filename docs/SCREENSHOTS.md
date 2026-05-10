# Dasterm v2 Screenshots and Preview

Dokumen ini berisi contoh tampilan Dasterm v2.

Output asli bisa berbeda tergantung:

```text
Distro
Theme
Mode
Terminal width
Dependency tersedia
Fastfetch/Neofetch tersedia
Speedtest cache tersedia
Service yang berjalan
```

---

## 1. Lite Mode Preview

Command:

```bash
/lite
```

Atau:

```bash
dasterm lite
```

Preview:

```text
╭────────────────────────────╮
│ dasterm v2 by aka          │
╰────────────────────────────╯

╭──────────────────────────────────────────────────────────╮
│ Dasterm Dashboard                                         │
╰──────────────────────────────────────────────────────────╯
User@Host            : root@aka
OS                   : Ubuntu 24.04 LTS
Kernel               : 6.8.0-45-generic
Uptime               : 4 hours, 27 minutes
Health               : 92/100 GOOD
RAM                  : 2.1G used of 8.0G
Disk /               : 5.3G used of 40G (14%)
IP                   : 10.0.0.5
Load                 : 0.12, 0.09, 0.05
Provider             : PT Telkom Indonesia
Region               : Singapore
Ping                 : 12.43 ms
Download             : 938.42 Mbps
Upload               : 812.10 Mbps
Tested At            : 2026-05-10 19:30:00 WIB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tip: ketik /help untuk melihat semua menu Dasterm.
```

---

## 2. Full Mode Preview

Command:

```bash
/full
```

Atau:

```bash
dasterm full
```

Preview:

```text
██████╗  █████╗ ███████╗████████╗███████╗██████╗ ███╗   ███╗
██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
██║  ██║███████║███████╗   ██║   █████╗  ██████╔╝██╔████╔██║
██║  ██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
██████╔╝██║  ██║███████║   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝

╭──────────────────────────────────────────────────────────╮
│ System                                                     │
╰──────────────────────────────────────────────────────────╯
User@Host            : root@aka
OS                   : Ubuntu 24.04 LTS
Kernel               : 6.8.0-45-generic
Architecture         : x86_64
Virtualization       : kvm
Boot Time            : 2026-05-10 10:05
Uptime               : 4 hours, 27 minutes
Load Average         : 0.12, 0.09, 0.05
Health               : 92/100 GOOD
CPU Model            : AMD EPYC Processor
CPU Cores            : 4
CPU Flags            : aes avx avx2 svm
RAM                  : 2.1G used of 8.0G
Swap                 : Disabled
Disk Root            : 5.3G used of 40G (14%)
Disk /datas          : 20G used of 916G (3%)
GPU                  : Red Hat QXL paravirtual GPU
Processes            : 127
Users                : 1

╭──────────────────────────────────────────────────────────╮
│ Network                                                    │
╰──────────────────────────────────────────────────────────╯
Private IP           : 10.0.0.5
Public IP            : 167.71.xxx.xxx
Gateway              : 10.0.0.1
DNS                  : 1.1.1.1 8.8.8.8
Provider             : PT Telkom Indonesia
Region               : Singapore
Ping                 : 12.43 ms
Download             : 938.42 Mbps
Upload               : 812.10 Mbps
Tested At            : 2026-05-10 19:30:00 WIB

╭──────────────────────────────────────────────────────────╮
│ Services                                                   │
╰──────────────────────────────────────────────────────────╯
Docker               : active
Nginx                : active
Apache               : not detected
Cloudflared          : active
SSH                  : active
UFW                  : active

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tip: type /help to view all Dasterm menus.
```

---

## 3. Speedtest Preview

Command:

```bash
/speedtest
```

Preview:

```text
Speedtest
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Provider           : PT Telkom Indonesia
Region             : Singapore
Server             : Example Provider
Source             : ookla-speedtest
Ping               : 12.43 ms
Jitter             : 1.02 ms
Packet Loss        : 0
Download           : 938.42 Mbps | 117.30 MB/s | 0.938 Gbps | 0.117 GB/s
Upload             : 812.10 Mbps | 101.51 MB/s | 0.812 Gbps | 0.102 GB/s
Formula MB/s       : Mbps / 8
Formula Gbps       : Mbps / 1000
Formula GB/s       : Mbps / 8000
Tested At          : 2026-05-10 19:30:00 WIB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tip: ketik /help untuk melihat semua menu Dasterm.
```

---

## 4. Network Preview

Command:

```bash
/network
```

Preview:

```text
Network
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Private IP         : 10.0.0.5
Public IP          : 167.71.xxx.xxx
Interface          : eth0
Gateway            : 10.0.0.1
DNS                : 1.1.1.1 8.8.8.8
Ping 1.1.1.1       : 12.1 ms
Ping 8.8.8.8       : 20.3 ms
Open Ports         : 22/sshd 80/nginx 443/nginx 3000/node
```

---

## 5. Storage Preview

Command:

```bash
/storage
```

Preview:

```text
Storage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Root Disk          : 5.3G used of 40G (14%) on /dev/vda1
Root FS            : ext4
Root Inodes        : 120K used of 2.5M (5%)
Data Disk          : 20G used of 916G (3%) on /dev/vdb1
Data FS            : ext4
Data Inodes        : 40K used of 58M (1%)
Docker Root        : /var/lib/docker
Docker Usage       : Images: 4.2GB | Reclaimable: 1.2GB

Mounts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/                /dev/vda1            ext4          40G     5.3G      34G    14%
/datas           /dev/vdb1            ext4         916G      20G     896G     3%

Suggestions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ Docker still uses /var/lib/docker. If /datas is your large disk, consider moving Docker data to /datas/docker.
```

---

## 6. Services Preview

Command:

```bash
/services
```

Preview:

```text
Services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Docker             : 5 running / 8 total | 12 images
PM2                : 3 online / 3 total
Nginx              : active
Apache             : not installed
Cloudflared        : running (2 process)
SSH                : active
Cron               : active
Database           : PostgreSQL: active; Redis: active;
Failed Units       : none

Open Ports
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
22/sshd 80/nginx 443/nginx 3000/node 5432/postgres
```

---

## 7. Security Preview

Command:

```bash
/security
```

Preview:

```text
Security
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Security Score     : 85/100 GOOD
Firewall           : ufw active
SSH Root Login     : no
SSH Password Auth  : no
SSH Pubkey Auth    : yes
Fail2ban           : sshd
Sudo Users         : aka
Failed Login 24h   : 2

Suggestions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ SSH root login setting looks acceptable.
✓ SSH password login setting looks acceptable.
✓ Firewall signal detected.
```

---

## 8. Doctor Preview

Command:

```bash
/doctor
```

Preview:

```text
Dasterm Doctor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Doctor Score       : 95/100 GOOD
Dasterm Version    : 2.0.0
Language           : id
Mode               : lite
Theme              : pastel

Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Binary               /usr/local/bin/dasterm
✓ Library              /usr/local/share/dasterm/lib/core.sh
✓ Config               /home/aka/.config/dasterm/config.env
✓ Shell Integration    installed
✓ Config Permission    600
✓ Cache Directory      /home/aka/.cache/dasterm
✓ Speedtest Cache      available
```

---

## 9. AI Preview

Command:

```bash
/ai cek storage server saya
```

Preview:

```text
Dasterm AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Saya bisa menampilkan ringkasan storage, mount, root disk, /datas, Docker root, dan folder terbesar.

ℹ AI menyarankan command:
dasterm storage

Run this command? [y/N]:
```

Jika user memilih `y`, Dasterm menjalankan:

```bash
dasterm storage
```

---

## 10. Config Preview

Command:

```bash
/config
```

Preview:

```text
Dasterm Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1) Indonesia
2) English
Language [id]:

1) Lite
2) Full
Mode [lite]:

1) Pastel
2) Cyber
3) Ocean
4) Mono
Theme [pastel]:

User@Host [root@aka]:
Show dashboard every login? [always] always/manual:
Change prompt? [on] on/off:
Enable slash aliases? [on] on/off:
Anonymous telemetry? [off] on/off:
```

---

## 11. Installer Preview

Command:

```bash
bash -c 'f=/tmp/dasterm-install.sh; curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh -o "$f" && sudo bash "$f"'
```

Preview:

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

## 12. Badge Preview

Current placeholder badges:

```text
Dasterm v2.0.0
Linux supported
Shell Bash | Zsh
Language ID | EN
License MIT
Total Installs coming soon
Total Runs coming soon
Top OS #1 coming soon
Top OS #2 coming soon
```

Future live badge example:

```text
installs 1,204
runs 9,320
top os #1 ubuntu 700
top os #2 debian 220
top virt kvm 600
top lang id 900
```

---

## 13. Adding Real Screenshots

Recommended screenshot files:

```text
assets/screenshots/lite.png
assets/screenshots/full.png
assets/screenshots/speedtest.png
assets/screenshots/ai.png
assets/screenshots/installer.png
```

Recommended terminal size:

```text
100 columns x 32 rows
```

Recommended themes:

```text
Pastel for main README
Mono for compatibility docs
Cyber for preview/social post
```

---

## 14. README Screenshot Section

After adding images, README can include:

```md
## Preview

### Lite Mode

![Dasterm Lite](assets/screenshots/lite.png)

### Full Mode

![Dasterm Full](assets/screenshots/full.png)

### AI Assistant

![Dasterm AI](assets/screenshots/ai.png)
```

---

## 15. Kesimpulan

Dasterm v2 should look:

```text
Clean
Readable
Fast
Useful
Server-friendly
Beginner-friendly
Professional
```