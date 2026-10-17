"""Native Kitty actions for Codex/Claude links; see session-links.md."""

import argparse
import importlib
import json
from pathlib import Path

import agent_session

from kittens.tui.handler import result_handler
from kitty.clipboard import set_clipboard_string
from kitty.constants import kitty_exe
from kitty.launch import launch, parse_launch_args
from kitty.utils import which

# Kitty's custom-kitten loader adds this directory to sys.path, but does not
# define __file__. Reload the helper so config edits take effect without restart.
session = importlib.reload(agent_session)


def main(args):
    pass


def windows(boss):
    return [dict(id=w.id, tab_id=w.tab_id, os_window_id=w.os_window_id,
                 title=w.title, cwd=w.cwd_of_child, user_vars=dict(w.user_vars))
            for w in boss.all_windows]


def act(boss, source, agent, sid, action, destination, window_id=None):
    try:
        live = windows(boss)
        matching = [w for w in live if w["user_vars"].get(f"{agent.upper()}_SESSION_ID", "").lower() == sid]
        if action == "focus" or (action == "open" and matching):
            if len(matching) > 1 and window_id is None:
                boss.choose_entry("Choose session window", [
                    (w["id"], f"OS {w['os_window_id']} / tab {w['tab_id']} / window {w['id']}: {w['title']}")
                    for w in matching
                ], lambda chosen: act(boss, source, agent, sid, "focus", destination, chosen)
                    if chosen is not None else None)
                return
            chosen = session.select_window({"windows": matching}, window_id)
            boss.set_active_window(chosen["id"], switch_os_window_if_needed=True)
            return
        if action in ("yank", "paste"):
            uri = session.session_uri(agent, sid)
            if action == "yank":
                set_clipboard_string(uri)
            else:
                source.paste_text(uri)
            return
        data = session.gather(agent, sid, live, window_id=window_id)
        if action == "info":
            boss.display_scrollback(source, json.dumps(data, indent=2, ensure_ascii=True), title="Agent session")
            return
        args = [f"--type={'overlay' if action == 'preview' else destination}",
                f"--source-window=id:{source.id}", f"--title={agent}: {sid[:8]}"]
        if action == "preview":
            if not data["transcript_path"] or not Path(data["transcript_path"]).expanduser().is_file():
                raise ValueError("No local transcript found. Use agent-session --transcript-path to select one.")
            command = session.preview_command(data, kitty_exe())
        else:
            args += [f"--cwd={session.resume_cwd(data)}", f"--next-to=id:{source.id}", "--add-to-session=."]
            command = data["resume_command"]
            executable = which(command[0])
            if not executable:
                raise ValueError(f"Cannot find {command[0]} in Kitty's PATH")
            command[0] = executable
        opts, _ = parse_launch_args(args)
        launch(boss, opts, command, target_tab=source.tabref(), rc_from_window=source)
    except (OSError, ValueError, RuntimeError) as exc:
        boss.show_error("Agent session", str(exc))


def mouse_uri(window, boss):
    """Capture Kitty's actual detected/OSC-8 URL, preserving all other URL handlers."""
    captured = []
    previous = window.open_url_handler

    def capture(boss, window, url, hyperlink_id, cwd):
        if url.lower().startswith(("codex:", "claude:")):
            captured.append(url)
            return True
        return previous(boss, window, url, hyperlink_id, cwd) if previous else False

    window.open_url_handler = capture
    try:
        window.mouse_click_url()
    finally:
        window.open_url_handler = previous
    return captured[0] if captured else None


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    source = boss.window_id_map.get(target_window_id)
    if source is None:
        return
    p = argparse.ArgumentParser()
    selectors = p.add_mutually_exclusive_group(required=True)
    selectors.add_argument("--uri")
    selectors.add_argument("--current", action="store_true")
    selectors.add_argument("--mouse", action="store_true")
    selectors.add_argument("--hints", action="store_true")
    p.add_argument("--action", choices=("open", "focus", "resume", "preview", "info", "yank", "paste"), default="open")
    p.add_argument("--type", choices=("tab", "window", "os-window"), default="tab")
    try:
        opts = p.parse_args(args[1:])
        if opts.hints:
            boss.run_kitten_with_metadata("hints", args=[
                "--customize-processing", str(Path(session.__file__).resolve().with_name("session_hints.py")),
                "--", opts.action, opts.type,
            ], window=source)
            return
        if opts.mouse:
            if source.screen.has_selection():
                return  # Shift-drag still selects text.
            opts.uri = mouse_uri(source, boss)
            if not opts.uri:
                return
        if opts.current:
            identities = [(agent, source.user_vars[f"{agent.upper()}_SESSION_ID"])
                          for agent in ("codex", "claude") if source.user_vars.get(f"{agent.upper()}_SESSION_ID")]
            if len(identities) != 1:
                raise ValueError("Current window must have exactly one Codex or Claude session ID")
            agent, sid = identities[0]
            opts.uri = session.session_uri(agent, sid)
        agent, sid = session.identity(uri=opts.uri)
        act(boss, source, agent, sid, opts.action, opts.type, source.id if opts.current else None)
    except (ValueError, SystemExit) as exc:
        boss.show_error("Agent session", str(exc))
