"""Maintain tab-bar bookmark flags."""

from kittens.tui.handler import result_handler


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss) -> None:
    action = args[1] if len(args) > 1 else "toggle"
    if action not in {"toggle", "flag", "clear", "backward", "forward"}:
        boss.show_error("tab_flags", f"Unknown action: {action}")
        return

    from kitty.tab_bar import load_custom_draw_tab_module

    update = load_custom_draw_tab_module().get("update_tab_flags")
    if not callable(update):
        boss.show_error("tab_flags", "Custom tab_bar.py does not expose update_tab_flags")
        return
    update(boss, action)
