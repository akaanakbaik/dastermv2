"""Offline regressions: no root, writes outside a temporary home, or real speedtests."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Runtime(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="dasterm test ")
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.env = dict(os.environ, HOME=str(self.home), NO_COLOR="1", TERM="dumb")
        for name in ("XDG_CONFIG_HOME", "XDG_CACHE_HOME", "XDG_DATA_HOME", "DASTERM_PREFIX"):
            self.env.pop(name, None)

    def shell(self, script, ok=True, input=None):
        result = subprocess.run(["bash", "-uo", "pipefail", "-c", script],
                                cwd=ROOT, env=self.env, input=input, capture_output=True, text=True, timeout=20)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def lib(self, script):
        return self.shell('. lib/core.sh; . lib/system.sh; . lib/storage.sh; '
                          '. lib/services.sh; . lib/i18n.sh; . lib/speedtest.sh; '
                          '. lib/update.sh; ' + script)

    def test_readonly_commands_repeated_in_different_orders(self):
        commands = ["version", "help", "about", "lite", "full", "services", "security", "speedtest"]
        # External network is intentionally unavailable in this smoke test.
        mock = self.home / "mock"
        mock.mkdir()
        for name in ("curl", "ping", "fastfetch", "neofetch"):
            file = mock / name
            file.write_text("#!/bin/sh\nexit 1\n")
            file.chmod(0o755)
        self.env["PATH"] = str(mock) + os.pathsep + self.env["PATH"]
        for command in commands + list(reversed(commands)):
            with self.subTest(command=command):
                output = self.shell(f'bash bin/dasterm {command}')
                self.assertTrue(output.stdout.strip())
                self.assertNotIn("command not found", output.stderr)
                self.assertNotIn("unbound variable", output.stderr)
                self.assertNotIn("\x1b[", output.stdout)

    def test_disk_layouts_and_mount_names(self):
        for mounts in ("/", "/\n/data", "/\n/srv\n/mnt/data disk\n/custom"):
            rows = ["Filesystem 1024-blocks Used Available Capacity Mounted on"]
            for i, mount in enumerate(mounts.splitlines()):
                rows.append(f"/dev/device{i} 1000 200 800 20% {mount}")
            rows += ["tmpfs 1000 0 1000 0% /run", rows[-1]]
            fixture = self.home / "df"
            fixture.write_text("\n".join(rows) + "\n")
            self.env["DF_FIXTURE"] = str(fixture)
            result = self.lib('df() { cat "$DF_FIXTURE"; }; dasterm_storage_paths')
            self.assertEqual(result.stdout.strip(), mounts)

    def test_absent_metrics_never_emit_empty_numbers(self):
        result = self.lib('free() { return 127; }; df() { return 1; }; '
                          'dasterm_ram_line; dasterm_ram_percent; dasterm_swap_line; '
                          'dasterm_disk_line /missing; dasterm_disk_percent /missing')
        self.assertEqual(result.stdout.splitlines(), ["N/A", "0.0", "N/A", "N/A", "0"])

    def test_openrc_and_process_fallback(self):
        result = self.lib('dasterm_systemd_available() { return 1; }; '
                          'rc-service() { [ "$1" = nginx ]; }; '
                          'dasterm_service_state nginx; dasterm_service_state absent; '
                          'dasterm_failed_units_count')
        self.assertEqual(result.stdout.splitlines(), ["running", "not running/unknown", "N/A"])

    def test_inactive_systemd_single_status(self):
        result = self.lib('dasterm_systemd_available() { return 0; }; '
                          'systemctl() { echo inactive; return 3; }; '
                          'dasterm_services_systemd_unit nginx')
        self.assertEqual(result.stdout.strip(), "inactive")

    def test_virtualization_is_not_limited_to_known_providers(self):
        for kind in ("kvm", "lxc", "openvz", "xen", "vmware", "qemu", "wsl", "new-hypervisor"):
            result = self.lib(f'systemd-detect-virt() {{ echo {kind}; }}; dasterm_virt')
            self.assertEqual(result.stdout.strip(), kind)

    def test_config_special_characters_roundtrip(self):
        value = 'user@host "quote" $HOME $(touch INJECTED) `id` \\ | &\nline'
        self.env["TEST_VALUE"] = value
        result = self.lib('dasterm_save_config_value DASTERM_USERHOST "$TEST_VALUE"; '
                          'dasterm_save_config_value DASTERM_USERHOST "$TEST_VALUE"; '
                          '. "$DASTERM_CONFIG"; printf "%s" "$DASTERM_USERHOST"')
        self.assertEqual(result.stdout, value)
        config = self.home / ".config/dasterm/config.env"
        self.assertEqual(config.stat().st_mode & 0o777, 0o600)
        self.assertEqual(config.read_text().count("DASTERM_USERHOST="), 1)
        self.assertFalse((ROOT / "INJECTED").exists())

    def test_speed_json_quotes_units_and_cache_failure(self):
        result = self.lib('dasterm_speed_calc_json 8000000 16000000 12 1 unknown '
                          '\'ISP "quoted"\' region server source')
        data = json.loads(result.stdout)
        self.assertEqual(data["provider"], 'ISP "quoted"')
        self.assertEqual(data["download"]["MBps"], "1.00")
        self.assertEqual(data["upload"]["mbps"], "16.00")
        self.assertEqual(self.lib('dasterm_speed_unit_to_bps 1 Gbit/s').stdout, "1000000000")

    def test_speed_failure_and_all_arguments_propagate(self):
        mock = self.home / "mock"
        mock.mkdir()
        file = mock / "speedtest-cli"
        file.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$HOME/args"\n'
                        'echo \'{"download":8000000,"upload":1000000,"ping":10}\'\n')
        file.chmod(0o755)
        self.env["PATH"] = str(mock) + os.pathsep + self.env["PATH"]
        self.shell('bash bin/dasterm respeedtest python --server 123 --quiet')
        self.assertEqual((self.home / "args").read_text().splitlines(), ["--json", "--server", "123"])
        cache = self.home / ".cache/dasterm/speedtest.json"
        saved = cache.read_text()
        file.write_text('#!/bin/sh\necho "{}"\n')
        result = self.shell('bash bin/dasterm respeedtest python --server 123 --quiet', ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(cache.read_text(), saved)

    def test_timeout_missing_does_not_run_unbounded_command(self):
        result = self.lib('dasterm_has() { return 1; }; '
                          'dasterm_timeout 1 touch "$HOME/unbounded"; '
                          'code=$?; [ "$code" = 127 ] && [ ! -e "$HOME/unbounded" ]')
        self.assertEqual(result.returncode, 0)

    def test_invalid_watch_and_unknown_command(self):
        for args in ("watch lite 0", "watch full -1", "watch full nope", "watch invalid 1", "unknown"):
            self.assertNotEqual(self.shell(f'bash bin/dasterm {args}', ok=False).returncode, 0)

    def test_custom_prefix_xdg_and_symlink(self):
        prefix = self.home / "custom prefix"
        (prefix / "bin").mkdir(parents=True)
        shutil.copytree(ROOT / "lib", prefix / "share/dasterm/lib")
        shutil.copy(ROOT / "bin/dasterm", prefix / "bin/dasterm")
        (prefix / "bin/dasterm").chmod(0o755)
        (prefix / "bin/dashterm").symlink_to("dasterm")
        self.env["CUSTOM_PREFIX"] = str(prefix)
        self.env["XDG_CONFIG_HOME"] = str(self.home / "settings")
        self.shell('bash "$CUSTOM_PREFIX/bin/dashterm" version')
        self.assertTrue((self.home / "settings/dasterm/config.env").is_file())
        self.shell('bash "$CUSTOM_PREFIX/bin/dasterm" shell-init bash > "$HOME/init"; bash -n "$HOME/init"')
        self.assertIn(str(prefix), (self.home / "init").read_text().replace("\\", ""))
        self.shell('shopt -s expand_aliases; '
                   'eval "$(bash "$CUSTOM_PREFIX/bin/dasterm" shell-init bash)"; eval /version')

    def test_update_stops_at_first_failed_required_download(self):
        self.lib('curl() { return 22; }; '
                 'if dasterm_update_download "$HOME/update"; then exit 1; fi')
        self.lib('curl() { return 22; }; dasterm_timeout() { shift; "$@"; }; '
                 'if dasterm_update_latest_version; then exit 1; fi')

    def test_update_download_apply_and_syntax_validation(self):
        self.env["SOURCE_TREE"] = str(ROOT)
        self.lib('curl() { local url="" dest=""; while [ "$#" -gt 0 ]; do '
                 'case "$1" in https:*) url="$1" ;; -o) shift; dest="$1" ;; esac; shift; done; '
                 'cp "$SOURCE_TREE/${url#*/main/}" "$dest"; }; '
                 'dasterm_update_download "$HOME/update" || exit 1; '
                 'DASTERM_BINARY="$HOME/prefix/bin/dasterm"; DASTERM_LIB="$HOME/prefix/share/dasterm/lib"; '
                 'mkdir -p "$(dirname "$DASTERM_BINARY")" "$DASTERM_LIB"; '
                 'touch "$DASTERM_BINARY"; dasterm_update_apply "$HOME/update" || exit 1; '
                 'bash "$DASTERM_BINARY" version')
        installed = self.home / "prefix/share/dasterm/lib"
        self.assertEqual(len(list(installed.glob('*.sh'))), len(list((ROOT / 'lib').glob('*.sh'))))
        self.lib('curl() { while [ "$1" != -o ]; do shift; done; shift; '
                 'printf "if broken" > "$1"; }; '
                 'if dasterm_update_download "$HOME/broken"; then exit 1; fi')

    def test_config_dialog_and_auto_manual(self):
        self.shell('bash bin/dasterm config', input='2\n2\n4\ncustom@host\nmanual\noff\noff\noff\n')
        config = (self.home / '.config/dasterm/config.env').read_text()
        self.assertIn('DASTERM_MODE=full', config)
        self.assertIn('DASTERM_LANG=en', config)
        self.assertEqual(self.shell('bash bin/dasterm auto').stdout, '')
        self.assertTrue(self.shell('bash bin/dasterm status').stdout.strip())

    def test_telemetry_off_and_on_payload(self):
        self.lib('. lib/telemetry.sh; '
                 'dasterm_timeout() { shift; "$@"; }; '
                 'curl() { cat > "$HOME/payload"; }; '
                 'DASTERM_TELEMETRY_ENDPOINT=https://test.invalid; '
                 'DASTERM_TELEMETRY=off; dasterm_telemetry_send run; '
                 '[ ! -e "$HOME/payload" ] || exit 1; '
                 'DASTERM_TELEMETRY=on; dasterm_telemetry_send doctor')
        data = json.loads((self.home / 'payload').read_text())
        self.assertEqual(data['event'], 'doctor')
        self.assertRegex(data['machine_hash'], r'^[0-9a-f]{64}$')

    def test_watch_valid_interval_refreshes(self):
        result = self.shell('timeout 1 bash bin/dasterm watch lite 0.1', ok=False)
        self.assertEqual(result.returncode, 124)
        self.assertIn('Refreshing every 0.1s', result.stdout)

    def test_installer_help_without_privileges(self):
        self.shell('bash install.sh --help')

    def test_user_install_repeat_and_uninstall_preserves_shell_content(self):
        (self.home / '.bashrc').write_text('# keep my settings\n')
        for _ in range(2):
            self.shell('bash scripts/install-local.sh --user')
            self.shell('bash "$HOME/.local/bin/dasterm" help')
        self.assertEqual((self.home / '.bashrc').read_text().count('### DASTERM_V2_BEGIN ###'), 1)
        self.shell('bash "$HOME/.local/bin/dasterm" uninstall', input='y\n')
        self.assertFalse((self.home / '.local/bin/dasterm').exists())
        self.assertFalse((self.home / '.local/bin/dashterm').is_symlink())
        self.assertEqual((self.home / '.bashrc').read_text().strip(), '# keep my settings')

    def test_shell_init_custom_prompt_is_literal(self):
        self.env['TEST_VALUE'] = "$(touch $HOME/INJECTED) `touch $HOME/INJECTED` 'quote'@host"
        self.lib('dasterm_save_config_value DASTERM_USERHOST "$TEST_VALUE"')
        result = self.shell('eval "$(bash bin/dasterm shell-init bash)"; printf "%s" "${PS1@P}"')
        self.assertFalse((self.home / 'INJECTED').exists())
        self.assertIn('$(touch', result.stdout)

    @unittest.skipUnless(shutil.which('zsh'), 'zsh is tested in the full-dependency CI job')
    def test_zsh_slash_command_and_literal_prompt(self):
        self.shell('bash scripts/install-local.sh --user')
        self.env['TEST_VALUE'] = "$(touch $HOME/INJECTED) `touch $HOME/INJECTED` '@host"
        self.lib('dasterm_save_config_value DASTERM_USERHOST "$TEST_VALUE"')
        output = self.shell('zsh -c \'eval "$(bash "$HOME/.local/bin/dasterm" shell-init zsh)"; '
                            '/version; print -P "$PS1"\'')
        self.assertFalse((self.home / 'INJECTED').exists())
        self.assertIn('$(touch', output.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
