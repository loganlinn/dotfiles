"""Copy the last shell command *and* its output to the clipboard.

Built-in `copy_last_command_output` only grabs the output region (between
OSC 133 OUTPUT_START and the next PROMPT_START). Kitty separately tracks
the cmdline on `window.last_cmd_cmdline` (set in cmd_output_marking via
shell-integration), but never combines the two. This kitten joins them
into a `$ <cmd>\n<output>` block so the clipboard payload is paste-ready
for sharing.

Requires shell-integration. Use via:
    map kitty_mod+y>p kitten copy_cmd_with_output.py
"""

from kittens.tui.handler import result_handler


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss
) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    from kitty.clipboard import set_clipboard_string
    from kitty.window import CommandOutput

    output = w.cmd_output(
        CommandOutput.last_non_empty, as_ansi=False, add_wrap_markers=False
    )
    if not output:
        boss.show_error(
            "copy-cmd-with-output",
            "No command output found (shell-integration required)",
        )
        return

    cmdline = (w.last_cmd_cmdline or "").strip()
    prefix = f"$ {cmdline}\n" if cmdline else ""
    set_clipboard_string(prefix + output.rstrip("\n") + "\n")
