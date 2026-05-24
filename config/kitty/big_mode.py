from kittens.tui.handler import result_handler

BIG_FONT_MULTIPLIER = 1.67
BIG_PADDING = 25.0
PADDING_EDGES = ('padding-left', 'padding-top', 'padding-right', 'padding-bottom')


def main(args):
    pass


def _set_padding(w, tab, value):
    from kitty.rc.set_spacing import patch_window_edges

    patch_window_edges(w, {edge: value for edge in PADDING_EDGES})
    if tab is not None:
        tab.relayout()


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    from kitty.fast_data_types import os_window_font_size

    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    tab = w.tabref()
    current = os_window_font_size(w.os_window_id)
    orig = w.user_vars.get('big_mode_orig')

    if orig:
        # exit big mode — restore stashed size
        try:
            target = float(orig)
        except ValueError:
            target = current / BIG_FONT_MULTIPLIER
        boss.change_font_size(False, None, target)
        w.set_user_var('big_mode_orig', None)
        if tab is not None and w.user_vars.get('big_mode_stacked') == '1':
            tab.toggle_layout('stack')
            w.set_user_var('big_mode_stacked', None)
        _set_padding(w, tab, None)
    else:
        # enter big mode — stash and scale up
        w.set_user_var('big_mode_orig', f'{current:.4f}')
        boss.change_font_size(False, None, current * BIG_FONT_MULTIPLIER)
        if tab is not None and tab.current_layout.name != 'stack':
            tab.toggle_layout('stack')
            w.set_user_var('big_mode_stacked', '1')
        _set_padding(w, tab, BIG_PADDING)
