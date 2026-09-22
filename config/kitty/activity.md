# Kitty tab activity

The tab bar combines native activity from every window in each tab, including hidden windows.
Directory labels, pinned titles, bookmarks, and tab backgrounds retain their existing behavior.

After the steady tab index, indicators appear in this order:

| Signal | Display | Meaning |
| --- | --- | --- |
| Bell | Configured `bell_on_tab` | A window requests attention. Focus acknowledges the bell. |
| Error | `` | Native progress reports an error. |
| Paused | `` | Progress is paused, or an agent needs input. Focus does not resolve the request. |
| Determinate work | `50%` | Average percentage across determinate working windows only. |
| Indeterminate work | `` | Work has no percentage. This glyph does not animate. |
| Unread output | Configured `tab_activity_symbol` | A window produced output since its last focus. Output alone does not imply work. |

A count follows each symbol when multiple windows share that state.
For example, `2 50%×2 3` means two paused windows, two determinate windows averaging 50%, and three indeterminate windows.
Waiting and working indicators can appear together.

Attention indices use dark red `#700018` on selected purple, and bright red on dark backgrounds.
Bookmark index attention retains its existing dark background.
Running shell commands and active progress use steady bright indices. Idle indices remain dim.
Narrow tabs preserve the index first, then truncate indicators and labels to the available width.

Kitty distinguishes bells, unread output, desktop notifications, and OSC 9;4 progress.
A desktop notification does not automatically establish any of the other signals.
See [Kitty notifications](https://sw.kovidgoyal.net/kitty/desktop-notifications/) and
[Kitty configuration](https://sw.kovidgoyal.net/kitty/conf/).

## Manual control and diagnostics

```sh
kitty-activity set working
kitty-activity set attention --match "id:$KITTY_WINDOW_ID"
kitty-activity set idle
kitty-activity clear
kitty-activity status --match all
kitty-activity status --to unix:/tmp/my-kitty --match 'title:project'
```

`working` writes native indeterminate progress. `attention` writes native paused progress.
`idle` clears owned progress and suppresses shell-running fallback.
`clear` removes the manual override and restores adapter or shell state.
Neither command clears progress subsequently emitted by another application.

The CLI retains bare states, `--window-id`, `--match`/`-m`, `--to`, `--password`,
`--password-file`, `--password-env`, and `--use-password`.
Password input passes to Kitty unchanged, including `--password-file -`.
Without `--match`, Kitty uses its native originating-window selection.

All state updates and diagnostics run targeted no-UI kittens through `kitten @ kitten`.
Remote-control password rules must permit the `kitten` command.
The selected Kitty instance must have access to the helper files at the resolved dotfiles path.
The bridge calls native progress and bell handlers. It never sends escape sequences to child input.

Status JSON includes:

- Window, tab, and OS-window IDs.
- Native bell, unread output, and progress state/percentage.
- Effective state and source, plus adapter progress ownership.
- Agent identity, session ID, pending request IDs, last observed hook event, and outcome.
- The same tab counts and average percentage used by the renderer.

`kitty-activity status` reports observed runtime state.
`kitty-activity hooks status` reports installed configuration. Installation does not prove event delivery or Codex hook trust.

## Agent prerequisites

The CLI requires `kitten` on PATH. Hooks also require `kitty-activity` and `uv` with a local Python 3.11 or later.
The hook helper uses the standard library and runs offline.
Headless hooks require both `KITTY_LISTEN_ON` and a positive `KITTY_WINDOW_ID`.
Hooks without these values do nothing. They never target the focused window as a fallback.

```sh
kitty-activity hooks status
kitty-activity hooks status codex --color always
kitty-activity hooks install all --dry-run
kitty-activity hooks install claude
kitty-activity hooks install codex
kitty-activity hooks install pi
kitty-activity hooks uninstall all --preview
kitty-activity hooks uninstall pi
```

Install and uninstall require an explicit agent or `all`.
Repeated installation preserves correct managed handlers and unrelated configuration.
Preview mode does not write files. Status supports `--color auto|always|never` and respects `NO_COLOR`.

For a separate configuration directory:

```sh
kitty-activity hooks install claude --config-dir /tmp/claude-test --preview
```

Defaults honor `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, and `PI_CODING_AGENT_DIR`.
Existing managed Claude/Codex command strings remain unchanged.
Hook forwarding includes identity and lifecycle metadata, without prompts, tool inputs, transcripts, or tool output.

### Codex

Restart Codex after installation. Review and trust managed hooks through `/hooks`.
The adapter recognizes these verified terminal-title forms in identified Codex foreground sessions:

- A leading frame from `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` means work.
- `[ ! ] Action Required` and `[ . ] Action Required` both mean pending input.
- The title remainder learned from a spinner means idle when the spinner disappears.

The current local configuration uses `terminal_title = ["spinner", "project"]`.
Title state takes precedence over ordinary work hooks. Unrecognized titles fall back to hooks.
Hook identity or Kitty's foreground process inventory identifies Codex. A matching title alone cannot identify an agent.
This supports spinner and input transitions when individual hook events are missing.
An observed working-to-idle title transition rings a completion bell. A subsequent Stop hook does not ring again.

The verified parser targets the spinner/project title layout. Customized layouts with a spinner elsewhere use hook fallback.
Disabling animations can remove the work spinner. Keep lifecycle hooks enabled for that configuration.
Desktop notifications remain separate from native progress and bells.

### Claude

Restart Claude after installation.
The bridge leaves `terminalProgressBarEnabled` unchanged. The current configuration disables native terminal progress.
If Claude later emits native progress, that progress takes precedence over the adapter.

Permission, tool-input, and elicitation requests retain available tool/request IDs.
Unrelated tool completion cannot clear a pending request. Matching completion or elicitation results resolve the corresponding request.
Permission requests omit tool IDs. The bridge correlates these requests with a hash of the tool name and input.
Concurrent calls with identical input remain paused until all matching calls complete.
Elicitation without an ID uses the same MCP server name.
A notification without request metadata stays pending until the next user prompt or terminal lifecycle event.

Claude does not expose every UI transition through these hooks.
Resumption becomes visible at the next supported lifecycle event, such as matching tool completion or `UserPromptSubmit`.
See the [Claude hook reference](https://code.claude.com/docs/en/hooks) for event payloads.

### pi

Run `/reload` after installing the extension.
Only TUI sessions publish activity. RPC and headless modes remain quiet.
The extension serializes events and attaches a session ID and sequence number.
Settled turns produce completion bells. Aborted turns clear work without a completion bell. Failed turns show error progress.

Custom dialog owners must publish a stable request ID:

```ts
pi.events.emit("kitty-activity:attention", { id: "confirm-deploy", active: true });
try {
  await showDialog();
} finally {
  pi.events.emit("kitty-activity:attention", { id: "confirm-deploy", active: false });
}
```

Nested dialogs remain paused until all pending IDs resolve.

## Ownership and cleanup

Adapter progress belongs to one window and agent session.
Each owned write records native state, percentage, and update timestamp.
Any later application write revokes ownership, even when it writes the same progress value.
Adapter cleanup cannot erase that application progress.

Session end, shell command completion, foreground agent exit, and window removal clear owned state.
Completion, cancellation, and failure have separate outcomes.
Repeated states do not rewrite progress. Resolved request IDs and retired sessions reject delayed events.
Available turn IDs and pi sequence numbers reject stale events.
Without an event sequence or turn ID, arbitrary reordering across two turns cannot always be distinguished.

The existing one-second housekeeping timer refreshes owned progress every 20 seconds.
Quiet turns therefore survive Kitty's 60-second progress expiry.
Foreground discovery uses Kitty's native process inventory every five seconds, outside drawing.
Drawing performs no subprocess calls, process discovery, or animation scheduling.

## Activation and troubleshooting

Home Manager registers `kitty_activity_state.py`, `tab_activity.py`, and `tab_bar.py`.
Keep their live configuration symlinks pointed at the dotfiles versions.
For an existing Kitty instance, reload the bridge before reloading the configuration:

```sh
kitten @ kitten ~/.dotfiles/lib/kitty_activity/bridge.py reload '' ''
kitten @ load-config
```

The bridge replaces only its own watcher callbacks, initializes existing windows,
removes obsolete `tab_activity` variables, and replaces its housekeeping timer.
It also removes the previous renderer's timer during migration.
Repeated activation does not accumulate owned watchers or timers.

If a signal is missing:

1. Run `kitty-activity status --match all`.
2. Compare `native_progress`, `source`, `agent`, and `last_hook_event` with the expected state.
3. Run `kitty-activity hooks status` to inspect installation separately.
4. For Codex, inspect `/hooks` trust and the configured terminal title.
5. For Claude, wait for the next supported lifecycle event after answering a prompt.
6. For remote instances, supply `--to` and an explicit `--match`.

Existing quiet Claude/pi sessions need a new lifecycle event after initial activation.
Existing Codex sessions can initialize from their current foreground identity and title.
Applications can override adapter progress at any time. Status reports `native-progress` when that happens.

## Validation

```sh
uv run --offline --no-project test/test_kitty_activity_cli.py
node test/kitty_activity_pi.mjs
kitty +runpy 'import runpy; runpy.run_path("test/test_kitty_activity.py", run_name="__main__")'
```

`test/runtime_activity.py SOCKET` runs destructive fixture checks only in a disposable Kitty instance.
It creates fixture tabs and OS windows, exercises native output and adapter events, reloads configuration,
and checks quiet progress after 66 seconds.
Never point that check at your working Kitty instance.
