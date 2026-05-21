from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    from kitty.fast_data_types import os_window_font_size

    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    current = os_window_font_size(w.os_window_id)
    orig = w.user_vars.get('big_mode_orig')

    if orig:
        # currently in big mode — restore stashed size
        try:
            target = float(orig)
        except ValueError:
            target = current / 2
        boss.change_font_size(False, None, target)
        w.set_user_var('big_mode_orig', None)
    else:
        # entering big mode — stash and double
        w.set_user_var('big_mode_orig', f'{current:.4f}')
        boss.change_font_size(False, None, current * 2)