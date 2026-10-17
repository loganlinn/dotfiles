# Agent session links

`agent-session` accepts one of:

```sh
agent-session --uri codex://threads/01a146dc-e00d-76a3-ae6e-65169da8a47a
agent-session --codex-session 01a146dc-e00d-76a3-ae6e-65169da8a47a
agent-session --claude-session 93bef8f8-00b9-4419-a3f6-9be946c745a7
agent-session --uri claude://sessions/93bef8f8-00b9-4419-a3f6-9be946c745a7
```

`claude://threads/UUID` is also accepted. IDs must be complete UUIDs; URL queries,
fragments, and arbitrary executable arguments are not accepted.

The default action prints JSON: matching Kitty window/tab/OS-window IDs, all
user variables on those windows, cwd, transcript path, resume argv, sources,
and any lookup warnings. `found: false` exits with status 1. Discovery queries
the inherited `KITTY_LISTEN_ON` connection (or `--to ENDPOINT`); it does not
search other Kitty instances. `--no-kitty` uses local records only.

Live metadata comes from `CODEX_SESSION_ID` / `CLAUDE_SESSION_ID` and the matching
`*_CWD`, `*_TRANSCRIPT_PATH`, `*_MODEL`, and `*_PERMISSION_MODE` variables when
present. Missing fields come from the newest Codex `state_N.sqlite` index opened
read-only, Codex rollout headers, or Claude project transcripts. `CODEX_HOME`
and `CLAUDE_CONFIG_DIR` are respected. Previous-session variables never count as
live matches. Multiple live clients remain separate entries.

Add action options to any of the commands above:

| Options | Behavior |
| --- | --- |
| `--action info` | Print gathered JSON (default). |
| `--action focus` | Focus an existing session window. |
| `--action open` | Focus an existing window; otherwise resume in a new tab. |
| `--action resume --type tab` | Always launch a new tab that resumes the session. |
| `--action resume --type window` | Always launch a new Kitty pane. |
| `--action resume --type os-window` | Always launch a new OS window. |
| `--action preview` | View transcript messages and tool records in a `less` overlay; `q` closes it. |
| `--action transcript` | Print the same transcript as plain text. |
| `--action uri` | Print the canonical session URI. |
| `--action resume-command` | Print a shell-quoted resume command. |

`--type` also controls the fallback destination for `open`. `--window-id ID`
selects one matching client when the same session appears in several panes.
`--source-window ID` selects where a new pane or overlay opens. The default is
the caller's Kitty window when it belongs to the connected instance, otherwise
Kitty's active window. `--cwd DIR` overrides a missing/moved resume directory.
`--transcript-path FILE` selects a transcript whose metadata matches the ID.

`--app-server` additionally initializes a temporary `codex app-server` over
stdio and calls `thread/read` with `includeTurns: false`. This is opt-in, CLI
only, with a timeout; it does not resume the thread or send a turn. Its returned
metadata appears under `app_server`. Its runtime status describes that server,
not another daemon or desktop client. Default lookup does not start a server.

Normal JSONL transcripts need no dependencies beyond Python, provided by `uv`
for the CLI. Compressed `.jsonl.zst` transcripts additionally require `zstd`.
Transcript text has terminal control characters removed before previewing.

## Kitty bindings

Kitty detects `codex://` and `claude://` as URLs. The normal click/URL-hint path
uses `open-actions.conf`: focus a matching client, or resume in a new tab. A
duplicate live match opens a native window picker. Native focus uses Kitty's
window objects rather than starting a remote-control subprocess.

| Binding | Action |
| --- | --- |
| Click (ungrabbed), or Ctrl+Shift-click | Open normally: focus or resume. |
| Shift-click | Resume in a new tab, even if already open. |
| Alt+Shift-click | Resume in a new pane, even if already open. |
| Ctrl+Alt+Shift-click | Preview transcript in an overlay. |
| `kitty_mod+o`, then `j` | Hint session links and open one. |
| `kitty_mod+o`, then `Shift+j` / `Alt+j` | Hint and resume in a tab / pane. |
| `kitty_mod+o`, then `Ctrl+j` | Hint and preview a transcript. |
| `kitty_mod+p`, then `j` | Hint and paste a session URI into the current terminal. |
| `kitty_mod+y`, then `j` | Hint and copy a session URI to the clipboard. |
| `kitty_mod+p` / `kitty_mod+y`, then `Shift+j` | Paste / copy the current window's session URI. |
| `kitty_mod+u`, then `i` / `p` | Show current session JSON / preview its transcript. |
| `kitty_mod+u`, then `t` / `w` | Resume the current session in a tab / pane. |

`kitty_mod` is Ctrl+Shift. Hints find visible session URIs across soft line wraps.
The existing general URL/hyperlink hints also work. Modified clicks on other
URLs retain their normal handler; Shift-drag keeps text selection. Paste
bindings paste text without sending Enter.

New config files are registered in Home Manager. After installing their
symlinks, Ctrl+Shift+F5 reloads the config. The script is available through the
existing dotfiles `bin` PATH setup.

Implementation references: [Kitty open actions](https://sw.kovidgoyal.net/kitty/open_actions/),
[custom hints](https://sw.kovidgoyal.net/kitty/kittens/hints/), and the local Kitty
source's `Window.open_url_handler`, `Window.mouse_click_url`, `Boss.choose_entry`,
and `kitty.launch` APIs. The app-server request follows the local Codex
`app-server-protocol` definitions for `InitializeParams` and `ThreadReadParams`.
