# Terminal interface — v2.0.2

```text
D A S T E R M
────────────────────────────────────────
Server overview and tools, in one menu.

  1  Quick overview
  2  Detailed overview
  3  Network
  4  Storage
  5  Services
  6  Security
  7  Doctor
  8  AI · AskGPT5
  9  Dasterm Configuration
  0  Exit

Choose a number (0 to exit) >
```

Run `dasterm menu` or `/menu`. Choose a tool by number, then press Enter to
return. AI returns through `/exit`. `0`, `q`, or EOF leaves the menu. Invalid
choices show a clear hint and keep the menu available; failures in one tool do
not close the whole menu. Ordinary `dasterm` still prints the dashboard.

The dashboard now puts health, uptime, CPU/load, RAM and disk usage bars, network,
and saved speed results in compact sections. Full mode adds mounted filesystems,
platform details, service summaries, and security signals. No screen is cleared
by ordinary status output. Set `DASTERM_LOGO=on` for the optional large logo and
existing Fastfetch/Neofetch support.

Separators follow the terminal width, clamped to 24–100 columns. Labels stack
above values below 60 columns. The terminal wraps UTF-8 content naturally;
byte-oriented wrapping is only used for ASCII text. `NO_COLOR=1`, redirected
output, and `TERM=dumb` suppress color. `DASTERM_ASCII=1` switches separators and
progress bars to ASCII. Themes remain pastel, cyber, ocean, and mono.

`dasterm watch lite 3` refreshes every three seconds. In a Bash 4+ terminal,
`q` quits immediately, `m` toggles lite/full, and Enter refreshes. Ctrl+C remains
available. With nonterminal input or older Bash, watch uses timed refresh with
Ctrl+C. Input settings are restored after single-key reads.

Configuration shows current values, accepts either option numbers or canonical
values, retries invalid input, and supports `/cancel`. A review precedes the final
save confirmation. EOF before confirmation does not save edits. Settings are
prepared in a private staging file and atomically replace the previous config
only after every setting has been written successfully.

English and Indonesian navigation, help, AI messages, and validation text follow
the configured language. Commands and configuration values remain stable for
scripts. See [AI usage](AI.md) and [compatibility](COMPATIBILITY.md).
