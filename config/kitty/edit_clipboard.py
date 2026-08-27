"""Edit the system clipboard contents in $EDITOR inside an overlay window.

Reads the clipboard in-process (no clipboard_control permission prompt),
writes it to a 0600 temp file, opens the configured editor on it in an
overlay, and when the editor exits 0 writes the file contents back to the
clipboard. A nonzero exit (e.g. :cq in vim) leaves the clipboard untouched.
The temp file is removed on every path.

Editor resolution uses kitty's get_editor(): VISUAL/EDITOR from the shell
env (via `env read_from_shell`), shlex-split so multi-word values like
"nvim -f" or "code --wait" work. Forking GUI editors must include their
wait flag in EDITOR/VISUAL themselves.

An empty clipboard opens an empty buffer (compose mode); saving writes the
new text to the clipboard.

Use via:
    map kitty_mod+y>c kitten edit_clipboard.py
"""

import contextlib
import os
import tempfile

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

    from kitty.clipboard import get_clipboard_string, set_clipboard_string
    from kitty.launch import launch, parse_launch_args
    from kitty.utils import get_editor, which

    try:
        original = get_clipboard_string()
    except Exception as e:
        boss.show_error("edit-clipboard", f"Could not read clipboard: {e}")
        return

    # mkstemp guarantees 0600; clipboard may hold secrets.
    fd, path = tempfile.mkstemp(prefix="kitty-clipboard-edit-", suffix=".txt")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", errors="replace") as f:
            f.write(original)
    except Exception as e:
        with contextlib.suppress(OSError):
            os.unlink(path)
        boss.show_error("edit-clipboard", f"Could not write temp file: {e}")
        return

    def cleanup() -> None:
        with contextlib.suppress(OSError):
            os.unlink(path)

    cmd = get_editor(path_to_edit=path)
    exe = cmd[0]
    if not os.path.isabs(exe) and not which(exe):
        cleanup()
        boss.show_error("edit-clipboard", f"Editor not found: {exe}")
        return

    def on_editor_death(wait_status: int, err: Exception | None) -> None:
        try:
            if err is not None or os.waitstatus_to_exitcode(wait_status) != 0:
                return  # editor aborted: leave clipboard untouched
            with open(path, encoding="utf-8", errors="replace") as f:
                edited = f.read()
            # Editors like vim append a final newline on save; drop it iff
            # the original had none, so round-tripping is lossless.
            if not original.endswith("\n") and edited.endswith("\n"):
                edited = edited[:-1]
            set_clipboard_string(edited)
        except Exception as e:
            boss.show_error("edit-clipboard", f"Could not update clipboard: {e}")
        finally:
            cleanup()

    opts, _ = parse_launch_args([
        "--type=overlay",
        "--title=edit clipboard",
        f"--next-to=id:{w.id}",
        f"--source-window=id:{w.id}",
    ])
    try:
        ew = launch(boss, opts, cmd, target_tab=w.tabref())
        pid = ew.child.pid if ew is not None else None
        if not pid:
            raise RuntimeError("editor window failed to start")
        boss.monitor_pid(pid, on_editor_death)
    except Exception as e:
        cleanup()
        boss.show_error("edit-clipboard", f"Could not launch editor: {e}")
