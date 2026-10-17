"""Hint session URIs in visible text, including across terminal soft wraps."""

from pathlib import Path
import runpy

LINK = runpy.run_path(str(Path(__file__).resolve().with_name("agent_session.py")))["LINK"]


def mark(text, args, Mark, extra_cli_args, *unused):
    offsets = [i for i, char in enumerate(text) if char not in "\r\0"]
    plain = "".join(text[i] for i in offsets)
    for index, match in enumerate(LINK.finditer(plain)):
        start, end = match.span()
        yield Mark(index, offsets[start], offsets[end - 1] + 1, match.group(), {})


def handle_result(args, data, target_window_id, boss, extra_cli_args, *unused):
    source = boss.window_id_map.get(target_window_id)
    if source is None:
        return
    action = extra_cli_args[0] if extra_cli_args else "open"
    destination = extra_cli_args[1] if len(extra_cli_args) > 1 else "tab"
    for uri in filter(None, data["match"]):
        boss.run_kitten_with_metadata("session_links.py", args=[
            "--uri", uri, "--action", action, "--type", destination,
        ], window=source)
