"""AI transport is tested through real curl and a trusted local HTTPS fixture.

No public API requests are made by this suite. PTY tests exercise real keystrokes.
"""
import http.server
import json
import os
from pathlib import Path
import pty
import select
import shlex
import signal
import shutil
import ssl
import subprocess
import tempfile
import termios
import threading
import time
import unittest
import urllib.parse

ROOT = Path(__file__).resolve().parents[1]
VALID = {'status': True, 'statusCode': 200, 'response': 'Jawaban aman ✓',
         'model': 'reported-model', 'state': 'PRIVATE_PROVIDER_STATE'}


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.server.prompts.append(urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)['prompt'][0])
        code, body = self.server.responses.pop(0) if self.server.responses else (200, VALID)
        body = body.encode() if isinstance(body, str) else json.dumps(body).encode()
        delay = self.server.delay
        self.server.started.set()
        if delay:
            time.sleep(delay)
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass  # curl correctly closes early on an oversized response.

    def log_message(self, *args):
        pass


@unittest.skipUnless(shutil.which('openssl') and shutil.which('curl') and shutil.which('jq'),
                     'AI transport tests require openssl, curl, and jq')
class AIUI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tls = tempfile.TemporaryDirectory(prefix='dasterm-tls-')
        cls.cert = Path(cls.tls.name) / 'cert.pem'
        key = Path(cls.tls.name) / 'key.pem'
        subprocess.run(['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes',
                        '-keyout', str(key), '-out', str(cls.cert), '-days', '1',
                        '-subj', '/CN=localhost', '-addext', 'subjectAltName=IP:127.0.0.1'],
                       check=True, capture_output=True)
        cls.server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cls.cert, key)
        cls.server.socket = context.wrap_socket(cls.server.socket, server_side=True)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()
        cls.tls.cleanup()

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='dasterm-ui-')
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.env = dict(os.environ, HOME=str(self.home), NO_COLOR='1', TERM='xterm',
                        TMPDIR=str(self.home), CURL_CA_BUNDLE=str(self.cert),
                        NO_PROXY='127.0.0.1', no_proxy='127.0.0.1',
                        DASTERM_AI_ENDPOINT=f'https://127.0.0.1:{self.server.server_port}/ai')
        for key in ('XDG_CONFIG_HOME', 'XDG_CACHE_HOME', 'XDG_DATA_HOME', 'DASTERM_PREFIX'):
            self.env.pop(key, None)
        self.server.prompts = []
        self.server.responses = []
        self.server.delay = 0
        self.server.started = threading.Event()
        # Real curl is used for the local TLS fixture. Other public probes are
        # blocked so menu/watch tests never depend on the public network.
        transport = self.home / 'transport'
        transport.mkdir()
        curl = transport / 'curl'
        curl.write_text('#!/bin/sh\nfor arg do\ncase "$arg" in\n'
                        'https://127.0.0.1:*) exec ' + shlex.quote(shutil.which('curl')) +
                        ' "$@" ;;\nesac\ndone\nexit 7\n')
        curl.chmod(0o755)
        self.env['PATH'] = str(transport) + os.pathsep + self.env['PATH']
        self.cli('version')
        self.config = self.home / '.config/dasterm/config.env'
        with self.config.open('a') as f:
            f.write('DASTERM_LANG=en\n')

    def cli(self, *args, input=None, ok=True):
        result = subprocess.run(['bash', str(ROOT / 'bin/dasterm'), *args], env=self.env,
                                input=input, text=True, capture_output=True, timeout=12)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_https_unicode_encoding_and_no_state_leak(self):
        prompt = 'uji & + ? # % "quote"\n日本語 👋 $(touch unsafe)'
        result = self.cli('ai', '--', prompt)
        self.assertEqual(self.server.prompts, [prompt])
        self.assertEqual(result.stdout, VALID['response'] + '\n')
        self.assertNotIn('PRIVATE_PROVIDER_STATE', result.stdout + result.stderr)
        self.assertEqual(list(self.home.glob('dasterm-ai.*')), [])
        self.assertFalse((self.home / '.cache/dasterm/ai-memory.json').exists())

    def test_stdin_and_prompt_validation_without_requests(self):
        self.cli('ai', '--stdin', input='question from stdin')
        self.assertEqual(self.server.prompts, ['question from stdin'])
        for prompt in ('', '  \t', 'a' * 4001, '界' * 1334):
            result = self.cli('ai', '--', prompt, ok=False)
            self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.server.prompts), 1)
        self.assertNotEqual(self.cli('ai', '--stdin', input='a' * 10000, ok=False).returncode, 0)

    def test_http_errors_do_not_retry_or_show_raw_body(self):
        for code in (400, 401, 403, 404, 414, 429, 500, 503):
            with self.subTest(code=code):
                self.server.responses = [(code, 'PRIVATE_RAW_ERROR_BODY')]
                before = len(self.server.prompts)
                result = self.cli('ai', 'test', ok=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(str(code), result.stderr)
                self.assertNotIn('PRIVATE_RAW_ERROR_BODY', result.stdout + result.stderr)
                self.assertEqual(len(self.server.prompts), before + 1)
                self.assertEqual(list(self.home.glob('dasterm-ai.*')), [])

    def test_invalid_json_and_schema_rejected(self):
        invalid = ['<html>proxy error</html>', '{broken', [], {}, '{}\n' + json.dumps(VALID),
                   {**VALID, 'status': False}, {**VALID, 'statusCode': 500},
                   {**VALID, 'statusCode': '200'}, {**VALID, 'response': None},
                   {**VALID, 'statusCode': False},
                   {**VALID, 'response': {}}, {**VALID, 'response': '   '},
                   {**VALID, 'response': '\x1b\x07'}]
        for body in invalid:
            with self.subTest(body=body):
                self.server.responses = [(200, body)]
                result = self.cli('ai', 'test', ok=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('Invalid AI response', result.stderr)

    def test_terminal_control_sequences_are_not_executed(self):
        self.server.responses = [(200, {**VALID, 'response': 'safe\x1b[2J\x07\rtext\u009b31m',
                                        'model': 'model\x1b]52;clipboard'})]
        result = self.cli('ai', 'test')
        self.assertNotIn('\x1b', result.stdout)
        self.assertNotIn('\x07', result.stdout)
        self.assertNotIn('\r', result.stdout)
        self.assertNotIn('\u009b', result.stdout)

    def test_tls_verification_is_required(self):
        self.env.pop('CURL_CA_BUNDLE')
        result = self.cli('ai', 'test', ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('certificate', result.stderr)
        self.assertEqual(self.server.prompts, [])

    def test_interrupted_request_cleans_private_temporary_response(self):
        self.server.delay = 2
        proc = subprocess.Popen(['bash', str(ROOT / 'bin/dasterm'), 'ai', 'cancel test'],
                                env=self.env, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, start_new_session=True)
        try:
            self.assertTrue(self.server.started.wait(timeout=5))
            os.killpg(proc.pid, signal.SIGINT)
            proc.communicate(timeout=5)
            self.assertNotEqual(proc.returncode, 0)
            deadline = time.monotonic() + 2
            while list(self.home.glob('dasterm-ai.*')) and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertEqual(list(self.home.glob('dasterm-ai.*')), [])
        finally:
            if proc.poll() is None:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.communicate()

    def test_timeout_and_missing_dependencies_are_actionable(self):
        mock = self.home / 'mock'
        mock.mkdir()
        curl = mock / 'curl'
        curl.touch()
        curl.chmod(0o755)
        self.env['PATH'] = str(mock) + os.pathsep + self.env['PATH']
        for code, message in ((6, 'DNS'), (7, 'connection'), (28, 'timeout'),
                              (60, 'certificate'), (63, '1 MiB')):
            curl.write_text(f'#!/bin/sh\nexit {code}\n')
            result = self.cli('ai', 'test', ok=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(message, result.stderr)
            self.assertEqual(list(self.home.glob('dasterm-ai.*')), [])
        self.env['SOURCE_TREE'] = str(ROOT)
        result = subprocess.run(['bash', '-c',
            '. "$SOURCE_TREE/lib/core.sh"; . "$SOURCE_TREE/lib/i18n.sh"; '
            '. "$SOURCE_TREE/lib/ai.sh"; dasterm_has() { [ "$1" != jq ]; }; '
            'DASTERM_LANG=en; dasterm_ai_request test'],
            env=self.env, text=True, capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('requires curl and jq', result.stderr)
        self.assertEqual(self.server.prompts, [])

    def test_chat_context_clear_retry_help_and_eof(self):
        self.server.responses = [(429, {}), (200, VALID)]
        result = self.cli('ai', 'chat', input='first\n/retry\nsecond\n/clear\nthird\n/help\n/exit\n')
        self.assertEqual(self.server.prompts[:2], ['first', 'first'])
        self.assertIn('Previous user:\nfirst', self.server.prompts[2])
        self.assertIn('second', self.server.prompts[2])
        self.assertEqual(self.server.prompts[3], 'third')
        self.assertIn('reported-model', result.stdout)
        self.assertNotIn('PRIVATE_PROVIDER_STATE', result.stdout + result.stderr)
        self.cli('ai', 'chat', input='/retry\n/unknown\n\n')
        self.assertEqual(len(self.server.prompts), 4)

    def test_oversize_response_is_rejected(self):
        self.server.responses = [(200, {**VALID, 'response': 'x' * 1048577})]
        result = self.cli('ai', 'test', ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('1 MiB', result.stderr)
        self.assertEqual(list(self.home.glob('dasterm-ai.*')), [])

    def test_long_chat_context_is_omitted_without_truncating_unicode(self):
        self.server.responses = [(200, {**VALID, 'response': '界' * 1500})]
        result = self.cli('ai', 'chat', input='first\nsecond\n/exit\n')
        self.assertEqual(self.server.prompts, ['first', 'second'])
        self.assertIn('without it', result.stdout)

    def test_retry_preserves_previous_turn_without_recursive_history(self):
        self.server.responses = [(200, VALID), (503, {}), (200, VALID), (200, VALID)]
        self.cli('ai', 'chat', input='first\nsecond\n/retry\nthird\n/exit\n')
        self.assertEqual(self.server.prompts[1], self.server.prompts[2])
        self.assertIn('Previous user:\nsecond', self.server.prompts[3])
        self.assertNotIn('Previous user:\nfirst', self.server.prompts[3])

    def test_config_batch_failure_preserves_original(self):
        before = self.config.read_text()
        self.env['SOURCE_TREE'] = str(ROOT)
        result = subprocess.run(['bash', '-c',
            '. "$SOURCE_TREE/lib/core.sh"; '
            'dasterm_save_config_value() { printf "partial" >> "$DASTERM_CONFIG"; return 1; }; '
            'dasterm_save_config_batch DASTERM_MODE full'],
            env=self.env, text=True, capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), before)
        self.assertEqual(list(self.config.parent.glob('config.env.*')), [])

    def test_menu_invalid_input_back_and_eof(self):
        result = self.cli('menu', input='invalid\n1\n\n8\n/exit\n0\n')
        self.assertIn('Invalid choice', result.stdout)
        self.assertIn('Quick overview', result.stdout)
        self.assertIn('Dasterm AI', result.stdout)
        self.assertEqual(self.server.prompts, [])
        self.cli('menu', input='')

    def test_configuration_cancel_eof_validation_and_commit(self):
        before = self.config.read_text()
        self.cli('config', input='/cancel\n')
        self.assertEqual(self.config.read_text(), before)
        result = self.cli('config', input='2\n2\n', ok=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), before)
        result = self.cli('config', input='bad\n2\n2\n4\nuser@host\nmanual\noff\noff\noff\nn\n')
        self.assertIn('Invalid choice', result.stderr)
        self.assertEqual(self.config.read_text(), before)
        self.cli('config', input='en\nfull\nmono\nuser@host\nmanual\noff\noff\noff\ny\n')
        self.assertIn('DASTERM_MODE=full', self.config.read_text())
        self.assertEqual(self.cli('auto').stdout, '')

    def test_widths_invalid_columns_and_unicode_integrity(self):
        for width in ('24', '40', '80', '160', '0008', 'invalid', '-1'):
            with self.subTest(width=width):
                self.env['COLUMNS'] = width
                result = self.cli('lite')
                self.assertNotIn('\x1b', result.stdout)
                self.assertNotIn('integer expression', result.stderr)
        self.env['COLUMNS'] = '24'
        long_text = '日本語👋' * 40
        self.server.responses = [(200, {**VALID, 'response': long_text})]
        result = self.cli('ai', 'chat', input='unicode\n/exit\n')
        self.assertIn(long_text, result.stdout)

    def pty_session(self, args, wait_for, keys):
        master, slave = pty.openpty()
        initial_flags = termios.tcgetattr(slave)[3]
        proc = subprocess.Popen(['bash', str(ROOT / 'bin/dasterm'), *args],
                                stdin=slave, stdout=slave, stderr=slave, env=self.env,
                                start_new_session=True)
        os.close(slave)
        output = b''
        try:
            deadline = time.monotonic() + 10
            while wait_for.encode() not in output and time.monotonic() < deadline:
                if select.select([master], [], [], 0.1)[0]:
                    output += os.read(master, 65536)
            self.assertIn(wait_for.encode(), output)
            os.write(master, keys)
            proc.wait(timeout=10)
            while select.select([master], [], [], 0.1)[0]:
                try:
                    chunk = os.read(master, 65536)
                except OSError:
                    break
                if not chunk:
                    break
                output += chunk
            self.assertEqual(proc.returncode, 0, output.decode(errors='replace'))
            mask = termios.ECHO | termios.ICANON
            self.assertEqual(termios.tcgetattr(master)[3] & mask, initial_flags & mask)
            return output.decode()
        finally:
            if proc.poll() is None:
                proc.kill()
                proc.wait()
            os.close(master)

    def test_real_terminal_watch_quit_without_enter(self):
        output = self.pty_session(['watch', 'lite', '5'], 'q: Exit', b'mq')
        self.assertIn('q: Exit', output)
        self.assertIn('full', output)

    def test_real_terminal_menu_and_ai_exit(self):
        self.pty_session(['menu'], 'Choose a number', b'0\n')
        self.pty_session(['ai'], 'You >', b'/exit\n')
