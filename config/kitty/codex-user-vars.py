# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Publish root Codex session metadata to its originating Kitty window."""

import json
import os
import re
import subprocess
import sys

FIELDS = {
    "CODEX_MODEL": "model",
    "CODEX_CWD": "cwd",
    "CODEX_PERMISSION_MODE": "permission_mode",
    "CODEX_TRANSCRIPT_PATH": "transcript_path",
}


def command(payload, env):
    endpoint = env.get("KITTY_LISTEN_ON")
    window = env.get("KITTY_WINDOW_ID", "")
    if not endpoint or not window.isdecimal() or int(window) < 1:
        return None
    if not isinstance(payload, dict) or payload.get("agent_id"):
        return None
    session = payload.get("session_id")
    if not isinstance(session, str) or not re.fullmatch(r"[A-Za-z0-9_-]+", session):
        return None

    event = payload.get("hook_event_name")
    match = f"id:{window}"
    current = f"var:CODEX_SESSION_ID=^{session}$"
    if event == "SessionEnd":
        # A delayed exit from an older session must not erase a newer one.
        match += f" and {current}"
        values = ["CODEX_SESSION_ID", *FIELDS, f"CODEX_PREV_SESSION_ID={session}"]
    elif event in ("SessionStart", "UserPromptSubmit"):
        if event == "UserPromptSubmit":
            match += f" and (not var:CODEX_SESSION_ID or {current})"
        values = [f"CODEX_SESSION_ID={session}"]
        for name, field in FIELDS.items():
            value = payload.get(field)
            values.append(f"{name}={value}" if isinstance(value, str) and value else name)
    else:
        return None
    return ["kitten", "@", "--to", endpoint, "set-user-vars", "--match", match, *values]


def main():
    # Hooks also run in the app and headless sessions, where there is no Kitty.
    if not os.environ.get("KITTY_LISTEN_ON") or not os.environ.get("KITTY_WINDOW_ID"):
        return
    try:
        args = command(json.load(sys.stdin), os.environ)
        if args:
            subprocess.run(args, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=2, check=False)
    except (OSError, ValueError, subprocess.TimeoutExpired):
        pass  # Terminal integration must not interrupt Codex or add model context.


if __name__ == "__main__":
    main()
