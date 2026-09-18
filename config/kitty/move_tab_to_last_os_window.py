"""Move the active tab to the last focused OS window (like nth_os_window -1)."""

from typing import TYPE_CHECKING, Any

from kittens.tui.handler import result_handler

if TYPE_CHECKING:
    from kitty.boss import Boss


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: Any, target_window_id: int, boss: "Boss") -> None:
    from kitty.fast_data_types import os_window_focus_counters

    w = boss.window_id_map.get(target_window_id)
    tab = (w.tabref() if w is not None else None) or boss.active_tab
    if tab is None:
        return
    fc_map = os_window_focus_counters()
    candidates = [
        (counter, os_window_id)
        for os_window_id, counter in fc_map.items()
        if os_window_id != tab.os_window_id and os_window_id in boss.os_window_map
    ]
    if not candidates:
        boss.show_error("Cannot move tab", "There is no other OS window to move the tab to")
        return
    _, target_os_window_id = max(candidates)
    boss._move_tab_to(tab=tab, target_os_window_id=target_os_window_id)
