"""Toggle stack layout with smart window focus.

When not in first window: focus first window + stack layout (zoom in).
When in first window with stack: restore previous layout + focus previous window (zoom out).
"""


def main(args: list[str]) -> str:
    pass


def handle_result(
    args: list[str], answer: str, target_window_id: int, boss
) -> None:
    tab = boss.active_tab
    if tab is None:
        return
    windows = tab.windows.all_windows
    if not windows:
        return

    active = tab.active_window
    first = windows[0]
    current_layout = tab.current_layout.name

    if active is first and current_layout == "stack":
        # Zoom out: restore layout, focus previous window
        tab.last_used_layout()
        tab.nth_window(-1)
    else:
        # Zoom in: focus first window, stack layout
        if active is not first:
            tab.set_active_window(first)
        if current_layout != "stack":
            tab.goto_layout("stack")
