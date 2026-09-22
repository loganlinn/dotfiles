"""Paste/yank local Git context or open its repository/PR, without a UI.

    kitten git_context.py paste|yank branch|cdup|toplevel|pr-number|pr-url
    kitten git_context.py open pr|repo

Git and gh run asynchronously; only completion callbacks touch Kitty's UI.
"""

import json
import os
import tempfile
from contextlib import ExitStack

from kittens.tui.handler import result_handler
from kitty.clipboard import set_clipboard_string
from kitty.utils import which
from kitty.window import CwdRequest


COMMANDS = {
    "branch": ("git", "symbolic-ref", "--quiet", "--short", "HEAD"),
    "cdup": ("git", "rev-parse", "--show-cdup"),
    "pr-number": ("gh", "pr", "view", "--json", "number"),
    "pr-url": ("gh", "pr", "view", "--json", "url"),
    "toplevel": ("git", "rev-parse", "--show-toplevel"),
}


def main(args: list[str]) -> None:
    pass


def notify_error(boss, message: str) -> None:
    manager = boss.notification_manager
    notification = manager.create_notification_cmd()
    notification.title = "Git shortcut"
    notification.body = message
    manager.notify_with_command(notification, 0)


def output_value(field: str, output: bytes) -> str:
    value = output.decode("utf-8").removesuffix("\n")
    if field in ("pr-number", "pr-url"):
        data = json.loads(value)
        key = "number" if field == "pr-number" else "url"
        value = data.get(key) if isinstance(data, dict) else None
        if key == "number":
            if type(value) is not int or value <= 0:
                raise ValueError("GitHub CLI returned an invalid PR number")
            return str(value)
        if not isinstance(value, str) or not value:
            raise ValueError("GitHub CLI returned an invalid PR URL")
    if field == "cdup" and not value:
        return "./"
    if not value:
        raise ValueError(f"No {field} found")
    return value


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss) -> None:
    argv = args[1:]
    if len(argv) != 2:
        notify_error(boss, "Expected paste/yank <field> or open pr/repo")
        return
    action, field = argv
    if action == "open" and field == "pr":
        command = ["gh", "pr", "view", "--web"]
    elif action == "open" and field == "repo":
        command = ["gh", "browse"]
    elif action in ("paste", "yank") and field in COMMANDS:
        command = list(COMMANDS[field])
    else:
        notify_error(boss, f"Unknown Git shortcut: {action} {field}")
        return

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    if window.child_is_remote:
        notify_error(boss, "Git shortcuts support local repositories only")
        return
    cwd = CwdRequest(window).cwd_of_child
    if not cwd:
        notify_error(boss, "Cannot determine this window's current directory")
        return
    executable = which(command[0])
    if executable is None:
        notify_error(boss, f"Cannot find {command[0]} in Kitty's executable search path")
        return
    command[0] = executable

    # Files avoid pipe-buffer deadlocks while Kitty's event loop keeps running.
    files = ExitStack()
    launch_fds = []
    try:
        stdout = files.enter_context(tempfile.TemporaryFile())
        stderr = files.enter_context(tempfile.TemporaryFile())
        for stream in (stdout, stderr):
            launch_fds.append(os.dup(stream.fileno()))
    except OSError as err:
        for fd in launch_fds:
            os.close(fd)
        files.close()
        notify_error(boss, str(err))
        return

    def on_death(exit_status, err) -> None:
        # Kitty closes supplied descriptors on launch failure. Duplicates keep
        # our file objects valid; on success we own and close the duplicates.
        if err is None:
            for fd in launch_fds:
                os.close(fd)
        with files:
            try:
                if err is not None:
                    raise RuntimeError(f"Could not run {action} {field}: {err}")
                exit_code = os.waitstatus_to_exitcode(exit_status)
                if exit_code != 0:
                    stderr.seek(0)
                    detail = stderr.read().decode("utf-8", "replace").strip()
                    if not detail and field == "branch":
                        detail = "No branch name found (HEAD may be detached)"
                    raise RuntimeError(detail or f"Command exited with status {exit_code}")
                if action == "open":
                    return
                stdout.seek(0)
                value = output_value(field, stdout.read())
                if action == "yank":
                    set_clipboard_string(value)
                elif target := boss.window_id_map.get(target_window_id):
                    target.paste_text(value)
            except (OSError, ValueError, RuntimeError) as error:
                notify_error(boss, str(error))

    try:
        boss.run_background_process(
            command,
            cwd=cwd,
            env={"GH_PROMPT_DISABLED": "1", "GIT_TERMINAL_PROMPT": "0"},
            stdout=launch_fds[0],
            stderr=launch_fds[1],
            notify_on_death=on_death,
        )
    except Exception as err:
        for fd in launch_fds:
            os.close(fd)
        files.close()
        notify_error(boss, f"Could not start Git shortcut: {err}")
