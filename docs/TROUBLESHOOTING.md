# Dasterm Troubleshooting

This document helps you fix common Dasterm v2 issues.

---

## 1. `dasterm` Command Not Found

Check binary:

```bash
ls -la /usr/local/bin/dasterm
```

If missing, repair:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
```

If permission is wrong:

```bash
sudo chmod +x /usr/local/bin/dasterm
```

---

## 2. `/help` Does Not Work

Slash commands are shell aliases.

Reload shell:

```bash
source ~/.bashrc
```

Or for Zsh:

```bash
source ~/.zshrc
```

Check alias:

```bash
alias /help
```

If alias is missing:

```bash
dasterm config
```

Enable slash aliases:

```text
Enable slash aliases? on
```

---

## 3. Dashboard Does Not Show at Login

Check config:

```bash
cat ~/.config/dasterm/config.env
```

Make sure:

```env
DASTERM_SHOW="always"
```

If it is `manual`, change it:

```bash
/config
```

Or:

```bash
dasterm config
```

Check shell block:

```bash
grep -n "DASTERM_V2_BEGIN" ~/.bashrc ~/.zshrc 2>/dev/null
```

If missing, repair:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
```

---

## 4. Dashboard Shows Twice

Possible causes:

```text
Nested shell
Duplicate shell block
Both .bashrc and .zshrc loaded unexpectedly
```

Check:

```bash
grep -n "DASTERM_V2_BEGIN" ~/.bashrc ~/.zshrc 2>/dev/null
```

Repair:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
```

---

## 5. Display Looks Broken

Common causes:

```text
Terminal too narrow
Font does not support box drawing
NO_COLOR is active
TERM value is unusual
```

Check:

```bash
echo "$TERM"
tput cols
```

Use Lite mode:

```bash
/lite
```

Use Mono theme:

```bash
/config
```

---

## 6. Full Mode Logo Is Not Good

Full mode uses:

```text
fastfetch
neofetch
fallback Dasterm ASCII
```

Install Neofetch:

```bash
sudo apt update
sudo apt install neofetch
```

If available, Fastfetch is better:

```bash
sudo apt install fastfetch
```

---

## 7. No Saved Speedtest Result

If dashboard shows:

```text
No saved speedtest result. Run /respeedtest.
```

Run:

```bash
/respeedtest
```

Or:

```bash
dasterm respeedtest
```

---

## 8. `/respeedtest` Fails

Check Dasterm health:

```bash
dasterm doctor
```

Check internet:

```bash
ping -c 1 1.1.1.1
```

Install basic tools:

```bash
sudo apt update
sudo apt install curl jq speedtest-cli
```

---

## 9. Speedtest Only Shows Download

This can happen when Dasterm uses curl fallback.

Curl fallback only measures download.

For complete speedtest, install:

```bash
sudo apt install speedtest-cli
```

Or install official Ookla Speedtest CLI.

---

## 10. Provider or Region Is Empty

Some speedtest providers do not return:

```text
provider
region
server
packet loss
jitter
```

Dasterm hides empty fields to keep output clean.

---

## 11. Public IP Is Slow or N/A

Public IP uses:

```text
https://api.ipify.org
```

Check:

```bash
curl -fsSL https://api.ipify.org
```

If it fails:

```text
Internet may be unavailable
curl may be missing
Firewall may block request
api.ipify.org may be unreachable
```

---

## 12. `/storage` Is Slow

`/storage` scans large directories using `du`.

On large servers, this can take a few seconds.

Manual check:

```bash
du -xhd 1 / 2>/dev/null | sort -hr | head
```

---

## 13. Docker Info Error

If Docker shows:

```text
installed but not reachable
```

Possible causes:

```text
Docker daemon is stopped
User is not in docker group
Docker socket permission is restricted
Need sudo
```

Check:

```bash
systemctl status docker
```

Or:

```bash
docker info
```

---

## 14. PM2 Not Detected

Check:

```bash
which pm2
pm2 jlist
```

If PM2 is installed for another user, current user may not see it.

---

## 15. `/security` Permission Denied

Some logs/config files may need root.

Try:

```bash
sudo dasterm security
```

Be careful because `sudo` may change `$HOME`.

---

## 16. Failed Login 24h Shows N/A

Possible causes:

```text
journalctl unavailable
auth log unavailable
permission restricted
different distro log path
```

Dasterm shows `N/A` when it cannot read the data.

---

## 17. `/doctor` Shows Missing Dependencies

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

## 18. AI Does Not Answer

Run:

```bash
/ai-test
```

Or:

```bash
dasterm ai-test
```

Make sure:

```text
curl is installed
jq is installed
internet is available
AI provider is not down
```

Check provider:

```bash
/ai-provider
```

Reset provider:

```bash
/ai-reset-provider
```

---

## 19. AI Output Is Broken JSON

Dasterm tries to extract JSON from AI output.

If it fails, the output is treated as normal text.

No command runs unless a valid and safe `cmd` is found.

---

## 20. AI Command Is Blocked

If you see:

```text
AI suggested a command, but Dasterm blocked it...
```

It means the command is not in the safe whitelist.

This is normal security behavior.

---

## 21. AI Memory Has Wrong Context

Clear memory:

```bash
/clear-brain-ai
```

Show memory:

```bash
/brain-ai
```

Memory resets automatically when the WIB date changes.

---

## 22. `/update` Fails

Check internet:

```bash
curl -I https://raw.githubusercontent.com
```

Check repo config:

```bash
grep DASTERM_REPO ~/.config/dasterm/config.env
```

Repair:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --repair
```

---

## 23. GitHub Actions Fails

Run locally:

```bash
bash -n install.sh
bash -n bin/dasterm
bash -n lib/*.sh
```

ShellCheck:

```bash
shellcheck -x -s bash --severity=error install.sh bin/dasterm lib/*.sh
```

---

## 24. Worker Badge Always Shows 0

Check config:

```bash
grep TELEMETRY ~/.config/dasterm/config.env
```

Required:

```env
DASTERM_TELEMETRY="on"
DASTERM_TELEMETRY_ENDPOINT="https://your-worker.example.com/api/usage"
```

Check stats:

```bash
curl https://your-worker.example.com/stats
```

---

## 25. Worker Rate Limited

If response says:

```text
rate limited
```

Wait for daily reset.

Default limits:

```text
install max 3 per machine per day
run max 30 per machine per day
other max 10 per machine per day
IP max 120 per event per day
```

---

## 26. Uninstall Is Not Clean

Run:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/akaanakbaik/dastermv2/main/install.sh) --uninstall
```

Check leftovers:

```bash
ls -la /usr/local/bin/dasterm
ls -la /usr/local/share/dasterm
ls -la ~/.config/dasterm
ls -la ~/.cache/dasterm
grep -n "DASTERM_V2" ~/.bashrc ~/.zshrc 2>/dev/null
```

---

## 27. Still Error?

Run:

```bash
dasterm doctor
```

Then create an issue:

```text
https://github.com/akaanakbaik/dastermv2/issues
```

Include:

```text
Output from /doctor
OS
Shell
Command that failed
Steps to reproduce
```

Do not include tokens, passwords, private keys, or sensitive data.