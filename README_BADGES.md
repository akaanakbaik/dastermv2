# Dasterm README Badges

Dokumen ini berisi daftar badge yang bisa dipakai di README Dasterm.

---

## 1. Badge Static Saat Awal

Badge static bisa langsung dipakai tanpa backend.

```md
<p align="center">
  <img src="https://img.shields.io/badge/Dasterm-v2.0.0-7c3aed?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Linux-supported-22c55e?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-0ea5e9?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-ID%20%7C%20EN-f97316?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-eab308?style=for-the-badge" />
</p>
```

---

## 2. Badge Placeholder Usage

Sebelum Worker telemetry aktif, pakai placeholder:

```md
<p align="center">
  <img src="https://img.shields.io/badge/Total%20Installs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Total%20Runs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%231-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%232-coming%20soon-111827?style=flat-square" />
</p>
```

---

## 3. Badge Live dari Worker

Jika Worker sudah deploy:

```text
https://dasterm-api.example.com
```

Gunakan:

```md
<p align="center">
  <img src="https://dasterm-api.example.com/badge/installs" />
  <img src="https://dasterm-api.example.com/badge/runs" />
  <img src="https://dasterm-api.example.com/badge/top-os-1" />
  <img src="https://dasterm-api.example.com/badge/top-os-2" />
  <img src="https://dasterm-api.example.com/badge/top-virt" />
  <img src="https://dasterm-api.example.com/badge/top-lang" />
  <img src="https://dasterm-api.example.com/badge/top-mode" />
</p>
```

---

## 4. Markdown Link Badge

Agar badge bisa diklik menuju stats:

```md
[![Total Installs](https://dasterm-api.example.com/badge/installs)](https://dasterm-api.example.com/stats)
[![Total Runs](https://dasterm-api.example.com/badge/runs)](https://dasterm-api.example.com/stats)
[![Top OS #1](https://dasterm-api.example.com/badge/top-os-1)](https://dasterm-api.example.com/stats)
[![Top OS #2](https://dasterm-api.example.com/badge/top-os-2)](https://dasterm-api.example.com/stats)
[![Top Virt](https://dasterm-api.example.com/badge/top-virt)](https://dasterm-api.example.com/stats)
[![Top Lang](https://dasterm-api.example.com/badge/top-lang)](https://dasterm-api.example.com/stats)
[![Top Mode](https://dasterm-api.example.com/badge/top-mode)](https://dasterm-api.example.com/stats)
```

---

## 5. GitHub Action Badge

Jika workflow bernama `Test`:

```md
![Test](https://github.com/akaanakbaik/dastermv2/actions/workflows/test.yml/badge.svg)
```

Dengan link:

```md
[![Test](https://github.com/akaanakbaik/dastermv2/actions/workflows/test.yml/badge.svg)](https://github.com/akaanakbaik/dastermv2/actions/workflows/test.yml)
```

---

## 6. Release Badge

Latest release:

```md
![GitHub Release](https://img.shields.io/github/v/release/akaanakbaik/dastermv2?style=flat-square)
```

Repo size:

```md
![Repo Size](https://img.shields.io/github/repo-size/akaanakbaik/dastermv2?style=flat-square)
```

Last commit:

```md
![Last Commit](https://img.shields.io/github/last-commit/akaanakbaik/dastermv2?style=flat-square)
```

Issues:

```md
![Issues](https://img.shields.io/github/issues/akaanakbaik/dastermv2?style=flat-square)
```

Stars:

```md
![Stars](https://img.shields.io/github/stars/akaanakbaik/dastermv2?style=flat-square)
```

Forks:

```md
![Forks](https://img.shields.io/github/forks/akaanakbaik/dastermv2?style=flat-square)
```

License:

```md
![License](https://img.shields.io/github/license/akaanakbaik/dastermv2?style=flat-square)
```

---

## 7. Recommended Full Badge Block

Gunakan ini di README setelah Worker belum aktif:

```md
<p align="center">
  <img src="https://img.shields.io/badge/Dasterm-v2.0.0-7c3aed?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Linux-supported-22c55e?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-0ea5e9?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-ID%20%7C%20EN-f97316?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-eab308?style=for-the-badge" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Total%20Installs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Total%20Runs-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%231-coming%20soon-111827?style=flat-square" />
  <img src="https://img.shields.io/badge/Top%20OS%20%232-coming%20soon-111827?style=flat-square" />
</p>

<p align="center">
  <a href="https://github.com/akaanakbaik/dastermv2/actions/workflows/test.yml">
    <img src="https://github.com/akaanakbaik/dastermv2/actions/workflows/test.yml/badge.svg" />
  </a>
  <img src="https://img.shields.io/github/v/release/akaanakbaik/dastermv2?style=flat-square" />
  <img src="https://img.shields.io/github/last-commit/akaanakbaik/dastermv2?style=flat-square" />
  <img src="https://img.shields.io/github/repo-size/akaanakbaik/dastermv2?style=flat-square" />
  <img src="https://img.shields.io/github/issues/akaanakbaik/dastermv2?style=flat-square" />
  <img src="https://img.shields.io/github/stars/akaanakbaik/dastermv2?style=flat-square" />
</p>
```

---

## 8. Recommended Live Badge Block

Gunakan ini setelah Worker aktif:

```md
<p align="center">
  <img src="https://img.shields.io/badge/Dasterm-v2.0.0-7c3aed?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Linux-supported-22c55e?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-0ea5e9?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-ID%20%7C%20EN-f97316?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-eab308?style=for-the-badge" />
</p>

<p align="center">
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/installs" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/runs" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/top-os-1" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/top-os-2" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/top-virt" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/top-lang" />
  </a>
  <a href="https://dasterm-api.example.com/stats">
    <img src="https://dasterm-api.example.com/badge/top-mode" />
  </a>
</p>
```

---

## 9. Warna Badge

Rekomendasi warna:

```text
Purple  : 7c3aed
Green   : 22c55e
Blue    : 0ea5e9
Orange  : f97316
Yellow  : eab308
Pink    : ec4899
Dark    : 111827
```

---

## 10. Kesimpulan

Badge README Dasterm sebaiknya menampilkan:

```text
Versi
Linux support
Shell support
Language support
License
CI status
Install count
Run count
Top OS
Top virtualization
Top language
```

Untuk awal, pakai badge placeholder.

Setelah Worker siap, ganti ke badge live.