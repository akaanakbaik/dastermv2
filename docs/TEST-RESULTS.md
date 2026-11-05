# Verification snapshots — 2026-11-05

## v2.0.2 — AI and terminal UX

| Check | Result |
| --- | --- |
| `make test`: Bash syntax, full ShellCheck, behavior regressions | PASS; 40 Python tests, no skips in the full environment |
| Worker `npm test`, actual SQLite schema | PASS; 3 tests |
| Ubuntu 22.04/24.04, Debian 12, Rocky Linux 9, Alpine 3.22 | PASS; repeated commands, offline AI/menu, install/reconfigure/repair/reinstall/uninstall |
| Real Prexzy endpoint | PASS; `hii`, CLI question, and Unicode/special-character question returned answers |
| Local HTTPS through real curl | PASS; encoding, schema, HTTP/TLS errors, response limits, SIGINT cleanup, chat context/retry |
| Terminal PTY | PASS; menu/chat exit, watch mode toggle/quit, restored echo/canonical input |
| Configuration | PASS; invalid-choice retry, cancellation/EOF, confirmation, staging-failure preservation |
| Layout | PASS; 24/40/80/160 columns, invalid widths, Unicode integrity, redirected output |

The verified provider response reported `qwen3.5-397b-a17b`; AskGPT5 is the
service name, not an assertion that the model is GPT-5. Live availability can
change. CI uses a local HTTPS fixture and does not consume the public AI API.

Previous portability fixtures and worker tests remain part of the suite. Real
disk partitioning/hypervisor boots and all unsupported OS platforms remain outside
this evidence. See [AI](AI.md), [UI/UX](UI-UX.md), and [compatibility](COMPATIBILITY.md).

## v2.0.1 — portability baseline

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
