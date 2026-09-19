"""Pin the tab title to the focused window's current directory name."""

import os

from kittens.tui.handler import result_handler


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss) -> None:
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = window.tabref()
    cwd = window.get_cwd_of_child(oldest=True)
    if tab is not None and cwd:
        tab.set_title(os.path.basename(os.path.normpath(cwd)) or cwd)
