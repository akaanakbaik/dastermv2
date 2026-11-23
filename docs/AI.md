# Dasterm AI — v2.0.2

AI uses the supplied Prexzy AskGPT5 endpoint directly. The Linux client needs
`curl` and `jq`; no Node.js, Python, API key, or AI SDK is required at runtime.

```bash
dasterm ai "Bagaimana mengecek kapasitas disk Linux?"
dasterm ai chat
printf '%s' 'Jelaskan perbedaan RAM dan swap' | dasterm ai --stdin
dasterm ai --help
```

After shell initialization, `/ai` supports the same arguments. `dasterm ai`
starts chat when attached to a terminal, or reads a question from piped input.
Use `dasterm ai -- "chat"` to ask a literal question matching a command name.

## Chat controls

| Input | Behavior |
| --- | --- |
| A question | Send it with the preceding successful exchange, when it fits |
| `/clear` | Forget local context and the pending failed request |
| `/retry` | Retry the exact failed request, only when requested |
| `/help` | Show controls |
| `/exit`, `/quit`, `/back` | Return to the menu or shell |
| `//text` | Send a message beginning with `/text` |
| EOF / Ctrl+D | Leave chat cleanly |

Only the immediately preceding successful exchange is retained in process
memory. If adding that exchange exceeds 4000 bytes, the next question is sent
without earlier context and the UI explains why. A failed request never advances
the successful conversation context. There is no automatic retry or fallback to
another provider.

## Request and response

```bash
curl --get 'https://prexzyapis.com/ai/askgpt5' \
  --data-urlencode 'prompt=hii'
```

The verified response uses this shape (other provider fields are ignored):

```json
{
  "status": true,
  "statusCode": 200,
  "response": "Hii, User! How can I help you today?",
  "model": "qwen3.5-397b-a17b"
}
```

AskGPT5 is the service's name. The UI displays the returned model rather than
claiming that every request uses GPT-5. The provider can change its backend.
`DASTERM_AI_ENDPOINT` can override the HTTPS URL for a compatible service or
tests; the default is the URL above.

Prompts must be nonblank and at most 4000 bytes after UTF-8 encoding. curl URL
encoding preserves `&`, `+`, `%`, quotes, line breaks, and Unicode. Requests use
an 8-second connect deadline and a 45-second total deadline. Responses are capped
at 1 MiB and must contain exactly one successful JSON object with a nonempty
string `response`. HTTPS certificate verification remains enabled.

HTTP errors, rate limits, TLS/DNS failures, timeouts, invalid JSON, and oversized
responses fail direct questions with a nonzero exit status. The chat remains available for another
question or an explicit retry. Redirected one-shot output contains only answer
text; status messages and errors go to stderr. Chat and terminal output add a
model label and readable sections. Terminal control characters from the provider
are removed; AI text is never evaluated as a shell command.

## Data handling

Dasterm sends the question and, in chat mode, the preceding exchange to Prexzy
through HTTPS query parameters. It does not automatically collect or attach
system metrics, IPs, files, process lists, or shell history. You can paste the
information you want to discuss. No chat history or provider `state` token is
saved by Dasterm; private temporary response files are removed after success or
failure. The provider and its infrastructure may retain requests under their own
policies. Closing the local chat does not delete a provider's records.

Old `brain-ai`, `clear-brain-ai`, provider ordering/reset, and `ai-test` commands
are not part of this implementation. Use `/clear` inside chat and the automated
tests described below. Preexisting cache files from older releases are not read
or transmitted, and this release does not remove your old files automatically.

## Verification

`make test` exercises real curl against a locally trusted HTTPS fixture. It
covers request encoding, schema/HTTP errors, TLS rejection, timeouts, response
limits, terminal controls, context/retry/clear behavior, and dependency failures.
PTY tests press keys in real terminal sessions for menu, chat, and watch mode,
and check that input echo/canonical mode are restored on exit. Public Prexzy
availability is checked separately; CI does not consume the public AI API.
