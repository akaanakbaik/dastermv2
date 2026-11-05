# Compatibility and verification

Dasterm 2.0.2 targets Linux with Bash. Detection follows available capabilities,
not distro versions, CPU architectures, hypervisor vendors, or fixed disk names.
Universal support for every OS/version cannot be guaranteed. Native Windows,
macOS, BSD, and systems without Bash are outside the system installer's scope.
WSL should use its Linux environment.

## Runtime behavior

- Run a checkout directly with `bash bin/dasterm help`, install system-wide with
  `sudo bash install.sh`, or install without root using
  `bash scripts/install-local.sh --user`.
- User installs live in `~/.local/bin` and `~/.local/share/dasterm`. Reload the
  shell after installation. Repeating installation replaces the integration block.
  `dasterm uninstall` removes the user installation and its shell integration.
- The executable discovers libraries relative to its location, resolves symlinks,
  and supports paths with spaces. `DASTERM_PREFIX` can override the library root.
  Existing layouts under `/usr/local` continue to work. XDG config, cache, and
  data environment variables are honored by the runtime.
- Slash commands use Bash/Zsh functions because Bash rejects `/name` aliases.
- Storage enumerates mounted filesystems using POSIX `df`, including arbitrary
  mount names and more than two filesystems. It does not require `/datas` or
  `findmnt`. Bind mounts and container file mounts can share a physical disk;
  an unmounted disk is not reported as usable storage. No partitions or data move.
- A systemctl executable alone does not establish that systemd is running.
  OpenRC service status and process checks provide alternatives. Unavailable
  failed-unit metrics say `N/A`.
- Missing CPU, RAM, or disk measurements produce fallback values. Disk and RAM
  percentages use zero for calculation when unavailable; these are not evidence
  of an empty disk or unused RAM. ARM CPU descriptions have a fallback.
- External operations use `timeout` or `gtimeout`. Without either, bounded
  operations are skipped rather than started without a time limit. Most dashboard
  features work without jq; speedtests require jq and explain when it is missing.
- AI uses curl's own deadlines and therefore does not require GNU timeout.
  It requires curl/jq and HTTPS. See [AI contract](AI.md) and [terminal UI](UI-UX.md).
- Package installation supports apt, dnf, yum, pacman, zypper, and apk. Arch uses
  `pacman -S`, avoiding a database-only refresh and partial upgrade. Package
  repository availability and EOL operating systems remain operator concerns.

## Automated verification

```bash
make test                      # Bash syntax, ShellCheck, offline Python regressions
cd worker && npm test          # Node 24+, real in-memory SQLite schema
```

Docker smoke tests run in disposable containers, with the checkout mounted read-only:

```bash
docker run --rm -v "$PWD:/src:ro" ubuntu:24.04 bash /src/tests/container-smoke.sh
```

The compatibility workflow repeats this on Ubuntu 22.04/24.04, Debian 12,
Rocky Linux 9, and Alpine 3.22 (installing Bash first on Alpine). Each container
runs 11 commands twice, then install, reconfigure, repair, reinstall, and uninstall.
Connectivity and speedtest providers are intentionally blocked in these smoke tests.
They verify degraded/offline behavior and local installation, not package mirrors.

Python regressions cover command ordering, unknown commands, config dialogues,
manual startup, valid/invalid watch intervals, one/two/multiple mount layouts,
mount names with spaces, missing measurements, systemd/OpenRC states, arbitrary
virtualization results, XDG paths, symlinks, rootless installation/uninstallation,
config escaping, speed units, quoted provider names, speedtest server arguments,
failed-cache preservation, missing timeout, update download/apply failures and
syntax validation, and telemetry opt-in/opt-out.

Worker tests use the repository's actual SQL schema via Node SQLite, exercising
event storage, stats, every documented badge, validation, methods, missing routes,
machine rate limiting, and expired rate-limit buckets.

The AI/UI tests use real curl against a locally trusted HTTPS server and run
PTY sessions for key navigation. CI installs curl, jq, and openssl for these
tests. They never call the public AI provider. See [test results](TEST-RESULTS.md).

## Limits of the evidence

The container tests share the host kernel and x86_64 architecture. They do not
prove boot behavior on KVM, Xen, VMware, OpenVZ, LXC, bare metal, ARM, or every
distro release. Virtualization names and alternate service-manager states are
tested with fixtures. Real multi-disk partitioning, RAID/LVM/encrypted volumes,
live throughput, provider network policy, running systemd/OpenRC daemons, and
Cloudflare D1 deployment require separate integration environments. SQLite tests
exercise queries locally, not Cloudflare's infrastructure. No production server,
disk configuration, or live telemetry deployment is modified by this test suite.
