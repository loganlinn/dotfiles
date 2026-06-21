"""Toggle stack layout with smart window focus and theme switch.

When not in first window: focus first window + stack layout (zoom in).
When in first window with stack: restore previous layout + focus previous window (zoom out).

While in stack layout, apply STACK_THEME to the active tab as a visual
cue that other windows are hidden behind this one. On exit, re-apply
current-theme.conf so the tab returns to the active session theme.
"""

import os

from kittens.tui.handler import result_handler

CONFIG_DIRECTORY = os.getenv("KITTY_CONFIG_DIRECTORY") or os.path.expanduser("~/.dotfiles/config/kitty")
STACK_THEME = os.path.join(CONFIG_DIRECTORY, "themes/Catppuccin-Macchiato.conf")
DEFAULT_THEME = os.path.join(CONFIG_DIRECTORY, "current-theme.conf")


def main(args: list[str]) -> str:
    pass


@result_handler(no_ui=True)
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
    match = ("--match-tab", f"id:{tab.id}")

    if active is first and current_layout == "stack":
        # Zoom out: restore layout, focus previous window, restore theme
        tab.last_used_layout()
        tab.nth_window(-1)
        boss.call_remote_control(tab.active_window, ("set-colors", *match, DEFAULT_THEME))
    else:
        # Zoom in: focus first window, stack layout, apply stack theme
        if active is not first:
            tab.set_active_window(first)
        if current_layout != "stack":
            tab.goto_layout("stack")
        boss.call_remote_control(tab.active_window, ("set-colors", *match, STACK_THEME))
