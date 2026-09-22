"""Targeted no-UI bridge. Never writes to child input."""
import importlib
import json
import sys
from pathlib import Path

from kittens.tui.handler import result_handler
from kitty.rc.base import MatchError

def _location():
    pass


sys.path.insert(0, str(Path(_location.__code__.co_filename).resolve().parents[2] / 'config/kitty'))
try:
    import kitty_activity_state as activity
finally:
    sys.path.pop(0)


def main(args):
    pass


def targets(boss, target_window_id, match, origin):
    target = boss.window_id_map.get(target_window_id)
    origin_window = boss.window_id_map.get(int(origin)) if origin.isdecimal() else None
    windows = list(boss.match_windows(match, origin_window)) if match else ([target] if target else [])
    if match and not windows:
        raise MatchError(match)
    return windows


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    action, match, origin, *payload = args[1:]
    if action == 'reload':
        sys.path.insert(0, str(Path(_location.__code__.co_filename).resolve().parents[2] / 'config/kitty'))
        try:
            importlib.reload(activity)
        finally:
            sys.path.pop(0)
        activity.install(boss)
        return 'Activity watchers and housekeeping reloaded'
    windows = targets(boss, target_window_id, match, origin)
    activity.ensure_timer(boss)
    if action == 'event':
        agent, raw = payload
        data = json.loads(raw)
        for w in windows:
            activity.event(w, agent, data)
    else:
        for w in windows:
            activity.manual(w, action)
