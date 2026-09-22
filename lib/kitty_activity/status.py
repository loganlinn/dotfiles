"""Read native window state and the same aggregate used by the tab bar."""
import json
import sys
from pathlib import Path
from kittens.tui.handler import result_handler
from kitty.rc.base import MatchError

def _location():
    pass


sys.path.insert(0, str(Path(_location.__code__.co_filename).resolve().parents[2] / 'config/kitty'))
try:
    from kitty_activity_state import collect_tab, collect_window
finally:
    sys.path.pop(0)


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    match, origin = args[1:3]
    target = boss.window_id_map.get(target_window_id)
    origin_window = boss.window_id_map.get(int(origin)) if origin.isdecimal() else None
    windows = list(boss.match_windows(match, origin_window)) if match else ([target] if target else [])
    if match and not windows:
        raise MatchError(match)
    rows = []
    for w in sorted(windows, key=lambda w: w.id):
        rollup = collect_tab(w.tabref())
        rows.append({**collect_window(w), 'tab_state': rollup['state'], 'tab_activity': rollup})
    return json.dumps(rows, indent=2)
