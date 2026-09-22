# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Manage owned agent hooks; dispatch lifecycle JSON without emitting agent output."""

from __future__ import annotations

import argparse
import copy
import json
import hashlib
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import textwrap

AGENTS = ("claude", "codex", "pi")
EVENTS = {
    "claude": ("SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
               "PostToolUse", "PostToolUseFailure", "Notification", "Elicitation",
               "ElicitationResult", "Stop", "StopFailure", "SessionEnd"),
    "codex": ("SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
              "PostToolUse", "Stop", "Interrupt", "SessionEnd"),
}
PI_MARKER = "// Managed by kitty-activity hooks; v1\n"


def command(agent):
    return f"kitty-activity hooks run {agent} >/dev/null 2>&1 || true"


def desired(agent):
    return {event: {"hooks": [{"type": "command", "command": command(agent), "timeout": 3}]}
            for event in EVENTS[agent]}


def no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def parse_config(raw):
    data = json.loads(raw, object_pairs_hook=no_duplicates) if raw is not None else {}
    if not isinstance(data, dict) or not isinstance(data.get("hooks", {}), dict):
        raise ValueError("expected an object with a hooks object")
    for event, groups in data.get("hooks", {}).items():
        if not isinstance(groups, list):
            raise ValueError(f"hooks.{event} must be an array")
        for group in groups:
            if not isinstance(group, dict) or not isinstance(group.get("hooks"), list):
                raise ValueError(f"hooks.{event} must contain matcher groups with hooks arrays")
            if any(not isinstance(hook, dict) for hook in group["hooks"]):
                raise ValueError(f"hooks.{event} contains a non-object handler")
    return data


def transform(data, agent, install):
    """Retain unrelated handlers, group fields, event order, and top-level settings."""
    result = copy.deepcopy(data)
    hooks = result.setdefault("hooks", {})
    wanted = desired(agent) if install else {}
    changes = []
    for event in list(dict.fromkeys([*hooks, *wanted])):
        groups = hooks.get(event, [])
        owned = [(i, h) for i, group in enumerate(groups) for h in group["hooks"]
                 if h.get("command") == command(agent)]
        # Keep a correct existing group in place: native Codex trust keys use indices.
        if (event in wanted and len(owned) == 1
                and groups[owned[0][0]] == wanted[event]):
            continue
        if not owned and event not in wanted:
            continue
        kept = []
        for group in groups:
            remaining = [h for h in group["hooks"] if h.get("command") != command(agent)]
            if remaining or remaining == group["hooks"]:
                kept.append({**group, "hooks": remaining})
        if event in wanted:
            kept.append(wanted[event])
        if kept:
            hooks[event] = kept
        else:
            hooks.pop(event, None)
        changes.append(f"{event}: {'install/update' if event in wanted else 'remove'} managed handler")
    if not hooks and "hooks" not in data:
        result.pop("hooks")
    return result, changes


def config_path(agent, override):
    defaults = {
        "claude": ("CLAUDE_CONFIG_DIR", "~/.claude", "settings.json"),
        "codex": ("CODEX_HOME", "~/.codex", "hooks.json"),
        "pi": ("PI_CODING_AGENT_DIR", "~/.pi/agent", "extensions/kitty-activity.ts"),
    }
    env, fallback, suffix = defaults[agent]
    return Path(override or os.environ.get(env) or fallback).expanduser().absolute() / suffix


def plan(agent, path, install):
    # Update the target of config symlinks, keeping the symlinks themselves intact.
    path = path.resolve()
    raw = path.read_bytes() if path.exists() else None
    if agent == "pi":
        if raw is not None and not raw.startswith(PI_MARKER.encode()):
            raise ValueError(f"{path}: refusing to change an unowned extension")
        new = Path(__file__).with_name("pi.ts").read_bytes() if install else None
        changes = [] if raw == new else ["install/update managed extension" if install else "remove managed extension"]
    else:
        data = parse_config(raw)
        updated, changes = transform(data, agent, install)
        new = (json.dumps(updated, indent=2, ensure_ascii=False) + "\n").encode() if changes else raw
    return path, raw, new, changes


def apply(path, old, new):
    current = path.read_bytes() if path.exists() else None
    if current != old:
        raise ValueError(f"{path} changed after preview; retry")
    if old == new:
        return
    if new is None:
        path.unlink()
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600
    fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(new)
            stream.flush()
            os.fsync(stream.fileno())
            os.fchmod(stream.fileno(), mode)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def event_state(agent, payload):
    # Subagent lifecycle must never replace the foreground parent's state.
    if not isinstance(payload, dict) or payload.get("agent_id"):
        return None
    event = payload.get("hook_event_name")
    if event not in EVENTS[agent]:
        return None
    if event == "SessionStart":
        return "idle"
    if event == "SessionEnd":
        return "clear"
    if event in ("Stop", "StopFailure", "Interrupt"):
        return {"Stop": "completed", "StopFailure": "failed", "Interrupt": "cancelled"}[event]
    if event in ("PermissionRequest", "Elicitation"):
        return "attention"
    if event == "Notification":
        return "attention" if payload.get("notification_type") in ("idle_prompt", "permission_prompt", "elicitation_dialog") else None
    if event == "PreToolUse":
        name = str(payload.get("tool_name", "")).rsplit(".", 1)[-1]
        return "attention" if name in ("AskUserQuestion", "ExitPlanMode", "request_user_input") else "working"
    return "working"


def run_hook(agent):
    target = os.environ.get("KITTY_LISTEN_ON")
    window = os.environ.get("KITTY_WINDOW_ID", "")
    # Hooks are headless: require both identifiers, never use a focused fallback.
    if not target or not window.isdecimal() or int(window) <= 0:
        return
    try:
        payload = json.load(sys.stdin)
        state = event_state(agent, payload)
        if state:
            # Forward identity and event metadata, never prompts, tool inputs,
            # transcripts, or tool output to the terminal process.
            keys = ("hook_event_name", "session_id", "thread_id", "prompt_id", "turn_id",
                    "tool_use_id", "tool_call_id", "call_id", "request_id", "elicitation_id",
                    "tool_name", "mcp_server_name", "notification_type", "is_interrupt")
            data = {key: payload[key] for key in keys if key in payload}
            # PermissionRequest omits tool_use_id in Claude and Codex. Correlate
            # with the same tool input without forwarding that input to Kitty.
            if payload.get("tool_name") and "tool_input" in payload:
                fingerprint = json.dumps([payload["tool_name"], payload["tool_input"]],
                                         sort_keys=True, separators=(",", ":"))
                data["tool_fingerprint"] = hashlib.sha256(fingerprint.encode()).hexdigest()
            emit(agent, data, target, window)

    except (OSError, ValueError, subprocess.TimeoutExpired):
        pass  # A status integration must not block the agent or produce hook output.


def emit(agent, data, target, window):
    if not target or not window.isdecimal() or int(window) <= 0:
        return
    bridge = str(Path(__file__).with_name("bridge.py").resolve())
    subprocess.run(["kitten", "@", "kitten", "--to", target, bridge,
                    "event", f"id:{window}", window, agent, json.dumps(data)],
                   stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                   stderr=subprocess.DEVNULL, timeout=1.5, check=False)


def print_status(plans, color="auto"):
    """Show installation state without exposing unrelated configuration values."""
    colored = color == "always" or (
        color == "auto" and sys.stdout.isatty()
        and os.environ.get("TERM") != "dumb" and not os.environ.get("NO_COLOR")
    )

    def style(text, code):
        return f"\033[{code}m{text}\033[0m" if colored else text

    rows = []
    for agent, (path, old, _new, changes) in plans:
        if not changes:
            state = "installed"
        else:
            owned = old is not None if agent == "pi" else any(
                handler.get("command") == command(agent)
                for groups in parse_config(old).get("hooks", {}).values()
                for group in groups for handler in group["hooks"]
            )
            state = "needs update" if owned else "not installed"
        try:
            location = "~/" + str(path.relative_to(Path.home()))
        except ValueError:
            location = str(path)
        rows.append((agent, state, location))

    headers = ("AGENT", "STATUS", "CONFIGURATION")
    widths = [max(len(headers[i]), *(len(row[i]) for row in rows)) for i in range(2)]
    path_width = max(20, shutil.get_terminal_size((100, 24)).columns - sum(widths) - 4)
    widths.append(min(path_width, max(len(headers[2]), *(len(row[2]) for row in rows))))
    print("  ".join(style(value.ljust(width), "1;36") for value, width in zip(headers, widths)).rstrip())
    print(style("  ".join("─" * width for width in widths), "2"))
    for agent, state, location in rows:
        lines = textwrap.wrap(location, width=widths[2], break_on_hyphens=False) or [""]
        status_color = "32" if state == "installed" else "33"
        print(f"{agent:<{widths[0]}}  {style(state.ljust(widths[1]), status_color)}  {lines[0]}")
        for line in lines[1:]:
            print(" " * (widths[0] + widths[1] + 4) + line)
    if any(agent == "codex" for agent, _ in plans):
        print("\n" + style("Codex trust: check /hooks (not inspected here).", "2"))


def main(argv=None):
    parser = argparse.ArgumentParser(prog="kitty-activity hooks", description=__doc__,
        epilog="Requires uv and kitten on PATH. See ~/.dotfiles/config/kitty/activity.md. "
               "Codex: restart, then review and trust new hooks with /hooks. Pi: /reload.")
    commands = parser.add_subparsers(dest="action", required=True)
    for action in ("install", "uninstall", "status"):
        sub = commands.add_parser(action, help={"install": "add or repair managed hooks",
            "uninstall": "remove only managed hooks", "status": "inspect configured hooks (not runtime trust)"}[action])
        if action == "status":
            sub.add_argument("agent", choices=(*AGENTS, "all"), nargs="?", default="all")
            sub.add_argument("--color", choices=("auto", "always", "never"), default="auto",
                             help="terminal colors (auto respects NO_COLOR and TERM=dumb)")
        else:
            sub.add_argument("agent", choices=(*AGENTS, "all"))
        sub.add_argument("--config-dir", help="agent config directory (requires one agent)")
        if action != "status":
            sub.add_argument("--dry-run", "--preview", action="store_true", help="show changes without writing files")
    run = commands.add_parser("run", help="internal: read an agent hook event from stdin")
    run.add_argument("agent", choices=tuple(EVENTS))
    sender = commands.add_parser("emit", help="internal: send a pi lifecycle event")
    sender.add_argument("agent", choices=("pi",))
    sender.add_argument("payload")
    sender.add_argument("--to", required=True)
    sender.add_argument("--window-id", required=True)
    args = parser.parse_args(argv)
    if args.action == "emit":
        try:
            emit(args.agent, json.loads(args.payload), args.to, args.window_id)
        except (OSError, ValueError, subprocess.TimeoutExpired):
            pass
        return 0
    if args.action == "run":
        run_hook(args.agent)
        return 0
    if args.config_dir and args.agent == "all":
        parser.error("--config-dir requires one agent")
    agents = AGENTS if args.agent == "all" else (args.agent,)
    plans = []
    try:
        # Parse every selected config before making any changes.
        for agent in agents:
            path = config_path(agent, args.config_dir)
            item = plan(agent, path, args.action != "uninstall")
            plans.append((agent, item))
        if args.action == "status":
            print_status(plans, args.color)
            return 0
        for agent, (path, old, new, changes) in plans:
            preview = getattr(args, "dry_run", False)
            print(f"{agent}: {'preview' if preview else args.action} {path}")
            for change in changes:
                print(f"  {change}")
            if not changes:
                print("  no changes")
            elif args.action == "install":
                if agent == "pi":
                    print("  source: lib/kitty_activity/pi.ts")
                else:
                    print(f"  command: {command(agent)} (timeout: 3s)")
            if not preview:
                apply(path, old, new)
        if "codex" in agents and args.action != "uninstall":
            print("Codex: config presence does not establish trust. Restart and use /hooks to review new/changed hooks.")
        if args.action == "install":
            print("After installation: restart Claude/Codex; run /reload in pi. Hooks require kitty-activity, uv, and kitten on PATH.")
        return 0
    except (OSError, ValueError) as error:
        print(f"kitty-activity: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
