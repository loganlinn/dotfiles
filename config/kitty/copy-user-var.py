"""Kitten: select a user_var from any window and copy its value to clipboard."""

from typing import List

from kittens.tui.handler import result_handler


def main(args: List[str]) -> str:
    pass


@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss) -> None:
    entries: dict[str, str] = {}
    for window in boss.all_windows:
        entries.update(window.user_vars)

    if not entries:
        return

    def on_chosen(val) -> None:
        if val is None:
            return
        from kitty.clipboard import set_clipboard_string
        set_clipboard_string(val)

    sorted_entries = sorted(entries.items())
    width = max(len(k) for k, _ in sorted_entries)

    boss.choose_entry(
        "Copy user var to clipboard",
        ((v, f"{k:<{width}}  =  {v}") for k, v in sorted_entries),
        on_chosen,
    )
