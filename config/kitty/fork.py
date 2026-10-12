"""Fork an agent conversation or clone a shell into a sibling Kitty window.

Claude and Codex use their native session-fork commands. At a zsh prompt,
clone-in-kitty copies the live environment and preserves the pending input.
Other programs get a sibling shell with their available environment and cwd.
"""

import os
import shlex
import uuid

from kittens.tui.handler import result_handler

_FLAGS_WITH_VALUE = frozenset({"--resume", "-r", "--session-id"})
_FLAGS_STANDALONE = frozenset({"--fork-session", "--continue", "-c"})

# Retain explicit Codex settings, but never replay its prompt, image inputs,
# resume selection, or --worktree when forking in the source working directory.
_CODEX_VALUES = frozenset({
    "-c", "--config", "--enable", "--disable", "--remote", "--remote-auth-token-env",
    "-m", "--model", "--local-provider", "-p", "--profile", "-s", "--sandbox",
    "--add-dir", "-a", "--ask-for-approval",
})
_CODEX_FLAGS = frozenset({
    "--strict-config", "--oss", "--approve-for-me", "--full-auto",
    "--dangerously-bypass-approvals-and-sandbox", "--dangerously-bypass-hook-trust",
    "--search", "--no-alt-screen", "--no-daemon",
})


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss
) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    proc = _find_agent_proc(w)
    if not proc or not proc.get("cmdline"):
        _fork_shell(w, boss, args[1:])
        return

    agent, _ = _agent_command(proc["cmdline"])
    session_var = f"{agent.upper()}_SESSION_ID"
    session_id = w.user_vars.get(session_var)
    if not session_id:
        boss.show_error("fork", f"No {session_var} set on this window")
        return

    new_session_id = None
    if agent == "codex":
        cmd = _codex_fork_command(list(proc["cmdline"]), session_id)
    else:
        new_session_id = str(uuid.uuid4())
        cmd = _strip_session_flags(list(proc["cmdline"]))
        cmd.extend([
            "--resume", session_id,
            "--fork-session",
            "--session-id", new_session_id,
        ])

    cwd = ((w.user_vars.get("CODEX_CWD") if agent == "codex" else None)
           or proc.get("cwd") or w.cwd_of_child or "")

    from kitty.launch import launch

    opts = _launch_options(w, args[1:])
    if new_session_id:
        opts.var.append(f"CLAUDE_SESSION_ID={new_session_id}")
    opts.cwd = cwd
    launch(boss, opts, cmd, target_tab=w.tabref(), rc_from_window=w)


def _launch_options(w, args):
    from kitty.launch import parse_launch_args

    opts, _ = parse_launch_args([
        "--type=window", "--copy-env", "--add-to-session=.", *args,
    ])
    # An explicitly targeted kitten must copy from that window, even if another
    # window happens to be focused when it runs.
    opts.source_window = f"id:{w.id}"
    opts.next_to = opts.next_to or opts.source_window
    return opts


def _zsh_at_primary_prompt(w):
    if not w.at_prompt:
        return False
    if not any(os.path.basename((p.get("cmdline") or [""])[0]).lstrip("-") == "zsh"
               for p in w.child.foreground_processes):
        return False
    # Escape-Q is push-line-or-edit in this dotfiles' zsh keymaps. It stashes
    # input at PS1, but edits the whole construct at PS2, so do not inject there.
    for y in range(w.screen.cursor.y, -1, -1):
        line = w.screen.line(y).as_ansi()
        if "\x1b]133;A;k=s" in line or "\x1b]133;C" in line:
            return False
        if "\x1b]133;A" in line:
            return True
    return False


def _fork_shell(w, boss, args):
    if _zsh_at_primary_prompt(w):
        # Bracketed paste keeps quoted launch arguments intact. Zsh restores
        # the stashed command after clone-in-kitty returns to the prompt.
        cmd = shlex.join(["clone-in-kitty", "--type=window", "--add-to-session=.", *args])
        w.write_to_child("\x1bQ")
        w.paste_text(cmd)
        w.write_to_child("\r")
        return

    from kitty.launch import launch

    opts = _launch_options(w, args)
    opts.cwd = opts.cwd or "current"
    # Some macOS processes expose no readable environment. Kitty retains the
    # original launch environment on Child, so use it when that query is empty.
    env = w.child.foreground_environ or w.child.environ
    launch(boss, opts, [], target_tab=w.tabref(), rc_from_window=w, base_env=env)


def _find_agent_proc(w):
    """Resolve the actual foreground CLI before selecting a session user var."""
    for proc in w.child.foreground_processes:
        if _agent_command(proc.get("cmdline"))[0]:
            return proc
    # Fallback: check window's direct child
    child = w.child
    if child.pid is not None:
        cmdline = child.cmdline_of_pid(child.pid)
        if _agent_command(cmdline)[0]:
            return {"cmdline": cmdline, "cwd": child.current_cwd}
    return None


def _agent_command(cmdline):
    if not cmdline:
        return None, 0
    name = os.path.basename(cmdline[0])
    if name in ("claude", "codex"):
        return name, 1
    if name in ("node", "bun") and len(cmdline) > 1:
        script = cmdline[1]
        if os.path.basename(script) == "codex.js":
            return "codex", 2
        if os.path.basename(script) == "claude.js" or ("/claude-code/" in script and script.endswith("/cli.js")):
            return "claude", 2
    return None, 0


def _codex_fork_command(cmdline: list[str], session_id: str) -> list[str]:
    _, prefix = _agent_command(cmdline)
    result = cmdline[:prefix] + ["fork", session_id]
    args = iter(cmdline[prefix:])
    for arg in args:
        if arg == "--":
            break
        if arg in _CODEX_VALUES:
            value = next(args, None)
            if value is not None:
                result.extend((arg, value))
        elif arg in _CODEX_FLAGS:
            result.append(arg)
        elif arg.startswith("--") and arg.partition("=")[0] in _CODEX_VALUES:
            result.append(arg)
        elif any(arg.startswith(flag) and len(arg) > 2 for flag in ("-c", "-m", "-p", "-s", "-a")):
            result.append(arg)
        elif arg in ("-C", "--cd", "-i", "--image"):
            next(args, None)
    return result


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
