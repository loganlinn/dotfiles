"""Fork the current Claude conversation into a new kitty window.

Reads CLAUDE_SESSION_ID from user vars, extends the foreground cmdline
with --resume SESSION_ID --fork-session, and launches a new window.
"""

import os

from kittens.tui.handler import result_handler

_FLAGS_WITH_VALUE = frozenset({"--resume", "-r", "--session-id"})
_FLAGS_STANDALONE = frozenset({"--fork-session", "--continue", "-c"})


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss
) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    session_id = w.user_vars.get("CLAUDE_SESSION_ID")
    if not session_id:
        boss.show_error("claude-fork", "No CLAUDE_SESSION_ID set on this window")
        return

    proc = _find_claude_proc(w)
    if not proc or not proc.get("cmdline"):
        boss.show_error("claude-fork", "Could not find claude process in foreground group")
        return

    cmd = _strip_session_flags(list(proc["cmdline"]))
    cmd.extend(["--resume", session_id, "--fork-session"])

    cwd = proc.get("cwd") or w.cwd_of_child or ""

    from kitty.launch import launch, parse_launch_args

    opts, _ = parse_launch_args(args[1:] or ["--type=window", "--copy-env"])
    opts.cwd = cwd
    launch(boss, opts, cmd, target_tab=w.tabref(), rc_from_window=w)


def _find_claude_proc(w):
    """Search foreground process group for the claude process."""
    for proc in w.child.foreground_processes:
        if _is_claude_cmd(proc.get("cmdline")):
            return proc
    # Fallback: check window's direct child
    child = w.child
    if child.pid is not None:
        cmdline = child.cmdline_of_pid(child.pid)
        if _is_claude_cmd(cmdline):
            return {"cmdline": cmdline, "cwd": child.current_cwd}
    return None


def _is_claude_cmd(cmdline) -> bool:
    if not cmdline:
        return False
    return os.path.basename(cmdline[0]) == "claude"


def _strip_session_flags(cmdline: list[str]) -> list[str]:
    result = []
    skip_next = False
    for i, arg in enumerate(cmdline):
        if skip_next:
            skip_next = False
            continue
        if arg in _FLAGS_STANDALONE:
            continue
        if arg in _FLAGS_WITH_VALUE:
            if i + 1 < len(cmdline) and not cmdline[i + 1].startswith("-"):
                skip_next = True
            continue
        if any(arg.startswith(f + "=") for f in _FLAGS_WITH_VALUE):
            continue
        result.append(arg)
    return result
