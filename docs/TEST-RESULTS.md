# Verification snapshot — 2026-11-05

Version: 2.0.1. These are local execution results, not a claim that remote CI or
every VPS platform has passed.

| Check | Result |
| --- | --- |
| `make test` (Bash syntax, full ShellCheck, Python behavior tests) | PASS; 21 Python tests |
| `cd worker && npm test` (Node 24, actual SQLite schema) | PASS; 3 tests |
| Ubuntu 22.04 container | PASS; two command passes and install lifecycle |
| Ubuntu 24.04 container | PASS; two command passes and install lifecycle |
| Debian 12 slim container | PASS; two command passes and install lifecycle |
| Rocky Linux 9 container | PASS; two command passes and install lifecycle |
| Alpine 3.22 container, Bash added, BusyBox userland retained | PASS; two command passes and install lifecycle |
| Ubuntu 24.04 with jq, ShellCheck, Python, make, and Zsh installed | PASS; `make test`, rootless install, Zsh slash command and prompt |
| Release archive build and required test/config files | PASS |
| `git diff --check` | PASS |

Each minimal container runs `version`, `help`, `about`, `lite`, `full`, `network`,
`services`, `security`, `speedtest`, `doctor`, and `storage` twice. Lifecycle order:
install → reconfigure → repair → reinstall → uninstall. Every installed state also
executes `/version` through shell initialization. Tests assert one integration
block after repeated installation and removal of both executable names afterward.

Behavior tests additionally reverse command order, exercise config/manual mode,
watch refresh, user installs, alternate mount layouts, paths containing spaces,
safe prompt/config text, unavailable dependencies, service managers, virtualization
names, update and speedtest success/failure, and telemetry opt-in/opt-out.

The smoke tests deliberately block public network probes and speedtest providers.
Successful speedtest providers and custom server flags use executable fixtures;
they do not measure live network throughput. Mount counts and service-manager
states use fixtures; no disks are repartitioned. Worker database tests use local
SQLite, not a deployed Cloudflare D1 instance. See [compatibility limits](COMPATIBILITY.md).
