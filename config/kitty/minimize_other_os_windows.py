"""Minimize other OS windows, switch to the last one, or restore all."""

from kittens.tui.handler import result_handler
from kitty.fast_data_types import (
    WINDOW_MINIMIZED,
    change_os_window_state,
    os_window_focus_counters,
)


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss) -> None:
    mode = args[1]
    ids = tuple(boss.os_window_map)
    if not ids:
        return

    if mode in {"current", "last", "restore"}:
        original = boss.window_id_map.get(target_window_id)
        if original is None or original.os_window_id not in ids:
            return
        keep = original.os_window_id
        if mode == "restore":
            # Restore oldest first to preserve focus history, then refocus the
            # original window. On macOS, focusing also unminimizes a window.
            counters = os_window_focus_counters()
            for os_window_id in sorted(ids, key=lambda wid: counters.get(wid, 0)):
                if os_window_id != keep:
                    boss.focus_os_window(os_window_id, if_needed_only=False)
            boss.focus_os_window(keep, if_needed_only=False)
            return
        if mode == "last":
            # Resolve before switching: focus changes reorder the history.
            counters = os_window_focus_counters()
            candidates = [wid for wid in ids if wid != keep and wid in counters]
            if not candidates:
                return
            keep = max(candidates, key=counters.__getitem__)
            boss.focus_os_window(keep, if_needed_only=False)
    else:
        num = int(mode)
        if num < 1:
            raise ValueError("Expected a positive OS window number")
        # Match nth_os_window's ordering and clamp to the last existing window.
        # combine can retain the original dispatch window while focus changes.
        keep = ids[min(num, len(ids)) - 1]

    for os_window_id in ids:
        if os_window_id != keep:
            change_os_window_state(WINDOW_MINIMIZED, os_window_id)
