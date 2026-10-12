# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Route Codex hooks through session identities announced by its terminal UI.

Loaded both as a Kitty watcher and a Codex hook. The shared Codex daemon's
terminal environment is deliberately ignored: it belongs to another client.
"""

import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time

FIELDS = {
    "CODEX_MODEL": "model",
    "CODEX_CWD": "cwd",
    "CODEX_PERMISSION_MODE": "permission_mode",
    "CODEX_TRANSCRIPT_PATH": "transcript_path",
}
# Use one per-user path, independent of a long-lived daemon's XDG environment.
ROUTES = Path.home() / ".cache/kitty/codex-sessions"
PREFIX_VAR = "CODEX_SESSION_PREFIX"
STATE_ATTR = "_codex_session_route"
HOOK_MARK = "_codex_session_watcher"
CALLBACKS = ("on_close", "on_cmd_startstop", "on_title_change")
UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
# Codex 0.162 truncates the title's session-id item to 29 characters + '...'.
# Accept that explicit UUID prefix or a full UUID, never a project/title guess.
TITLE_ID = re.compile(r"(?<![\w-])([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{5})(?:[0-9a-f]{7}|\.\.\.)(?![\w-])")


def is_codex(window):
    for proc in window.child.foreground_processes:
        argv = proc.get("cmdline") or []
        if argv and (os.path.basename(argv[0]) == "codex" or (
            os.path.basename(argv[0]) in ("node", "bun") and len(argv) > 1
            and os.path.basename(argv[1]) == "codex.js"
        )):
            return True
    return False


def clear_window(window):
    route = getattr(window, STATE_ATTR, None)
    if route is None:
        return
    path, prefix = route
    path.unlink(missing_ok=True)
    delattr(window, STATE_ATTR)
    if window.user_vars.get(PREFIX_VAR) != prefix:
        return
    previous = window.user_vars.get("CODEX_SESSION_ID")
    for name in (PREFIX_VAR, "CODEX_SESSION_ID", *FIELDS):
        window.set_user_var(name, None)
    if previous:
        window.set_user_var("CODEX_PREV_SESSION_ID", previous)


def bind_window(boss, window, prefix):
    old = getattr(window, STATE_ATTR, None)
    if old is not None and old[1] == prefix:
        return
    clear_window(window)
    if not boss.listening_on:
        return
    ROUTES.mkdir(parents=True, exist_ok=True, mode=0o700)
    folder = ROUTES / prefix
    folder.mkdir(parents=True, exist_ok=True, mode=0o700)
    path = folder / f"{os.getpid()}-{window.id}.json"
    route = {"endpoint": boss.listening_on, "window_id": window.id,
             "kitty_pid": os.getpid(), "prefix": prefix}
    # A newly selected session must not retain the previous session's metadata.
    for name in ("CODEX_SESSION_ID", *FIELDS):
        window.set_user_var(name, None)
    window.set_user_var(PREFIX_VAR, prefix)
    with tempfile.NamedTemporaryFile(mode="w", dir=folder, delete=False) as temp:
        json.dump(route, temp)
    os.replace(temp.name, path)
    setattr(window, STATE_ATTR, (path, prefix))


def on_title_change(boss, window, data):
    if not data.get("from_child"):
        return
    title = data.get("title", "")
    match = TITLE_ID.search(title) if is_codex(window) else None
    if match is None:
        clear_window(window)
        return
    bind_window(boss, window, match.group(1))
    # Keep the normal project/activity title, including any manually set title.
    suffix = re.sub(r"^\s*\|\s*", "", title[match.end():])
    visible = re.sub(r"\s+", " ", title[:match.start()] + suffix).strip(" |")
    window.child_title = visible or "Codex"
    window.title_updated()


def on_cmd_startstop(boss, window, data):
    clear_window(window)


def on_close(boss, window, data):
    clear_window(window)


def on_load(boss, data):
    # Reloads need to reach existing windows as well as future ones. Function
    # markers also make a manual `kitten codex-user-vars.py` refresh idempotent.
    for window in boss.window_id_map.values():
        for name in CALLBACKS:
            callbacks = getattr(window.watchers, name)
            callbacks[:] = [f for f in callbacks if not getattr(f, HOOK_MARK, False)]
            callbacks.append(globals()[name])
        # Only reparse a still-raw title; our displayed title omits the ID.
        if TITLE_ID.search(window.child_title):
            on_title_change(boss, window, {"title": window.child_title, "from_child": True})


for _name in CALLBACKS:
    setattr(globals()[_name], HOOK_MARK, True)


def valid_payload(payload):
    return (isinstance(payload, dict) and not payload.get("agent_id")
            and isinstance(payload.get("session_id"), str)
            and re.fullmatch(UUID, payload["session_id"]) is not None
            and payload.get("hook_event_name") in ("SessionStart", "UserPromptSubmit", "SessionEnd"))


def command(payload, route):
    if not valid_payload(payload):
        return None
    session = payload["session_id"]
    window, endpoint = route.get("window_id"), route.get("endpoint")
    if (type(window) is not int or window < 1 or not isinstance(endpoint, str)
            or not endpoint or route.get("prefix") != session[:29]):
        return None
    current = f"var:CODEX_SESSION_ID=^{session}$"
    match = f"id:{window} and var:{PREFIX_VAR}=^{session[:29]}$"
    if payload["hook_event_name"] == "SessionEnd":
        match += f" and {current}"
        values = ["CODEX_SESSION_ID", *FIELDS, f"CODEX_PREV_SESSION_ID={session}"]
    else:
        match += f" and (not var:CODEX_SESSION_ID or {current})"
        values = [f"CODEX_SESSION_ID={session}"]
        for name, field in FIELDS.items():
            value = payload.get(field)
            values.append(f"{name}={value}" if isinstance(value, str) and value else name)
    return ["kitten", "@", "--to", endpoint, "set-user-vars", "--match", match, *values]


def routes_for(payload):
    folder = ROUTES / payload["session_id"][:29]
    for path in folder.glob("*.json"):
        try:
            route = json.loads(path.read_text())
            if not isinstance(route, dict) or type(route.get("kitty_pid")) is not int or route["kitty_pid"] < 1:
                continue
            os.kill(route["kitty_pid"], 0)
            yield route
        except ProcessLookupError:
            path.unlink(missing_ok=True)
        except (OSError, ValueError):
            continue


def main(args=None):
    if args is not None:  # Kitty kitten; handle_result performs the work.
        return
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        return
    if not valid_payload(payload):
        return
    # A CLI launched with an initial prompt can race its first title callback.
    routes = list(routes_for(payload))
    if not routes and payload["hook_event_name"] == "SessionStart":
        for _ in range(4):
            time.sleep(0.1)
            routes = list(routes_for(payload))
            if routes:
                break
    deadline = time.monotonic() + 2
    for route in routes:
        argv = command(payload, route)
        if argv is None:
            continue
        try:
            result = subprocess.run(argv, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                                    stderr=subprocess.PIPE, text=True,
                                    timeout=max(0.05, deadline - time.monotonic()), check=False)
            if result.returncode:
                print(f"kitty user vars: {payload['session_id']} window {route['window_id']}: "
                      f"{result.stderr.strip()[:300]}", file=sys.stderr)
        except (OSError, subprocess.TimeoutExpired) as error:
            print(f"kitty user vars: {error}", file=sys.stderr)
        if time.monotonic() >= deadline:
            break


# Kitty imports the same file as a no-UI kitten when installing into existing
# windows. The standalone uv hook does not have Kitty's Python modules.
try:
    from kittens.tui.handler import result_handler
except ImportError:
    pass
else:
    @result_handler(no_ui=True)
    def handle_result(args, answer, target_window_id, boss):
        on_load(boss, {})

if __name__ == "__main__":
    main()
