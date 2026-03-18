"""draw kitty tab"""
# pyright: reportMissingImports=false,reportGeneralTypeIssues=false,reportAttributeAccessIssue=false,reportCallIssue=false
# pylint: disable=E0401,C0116,C0103,W0603,R0913

import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title
from kitty.utils import color_as_int

opts = get_options()
REFRESH_TIME = 1

def _draw_mode_indicator(draw_data: DrawData, screen: Screen) -> int:
    boss = get_boss()
    mode = boss.mappings.current_keyboard_mode_name if boss and boss.mappings else ""
    if mode == "":
        label = "NORMAL"
    elif mode == "__sequence__":
        label = "SEQ"
    else:
        label = mode

    is_active = label != "NORMAL"
    fg = as_rgb(int("21222c", 16))
    bg = as_rgb(int("bd93f9", 16)) if is_active else as_rgb(int("6272a4", 16))

    cell = f" {label} "
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.cursor.bold = True
    screen.draw(cell)
    screen.cursor.bold = False
    screen.cursor.fg = 0
    screen.cursor.bg = as_rgb(color_as_int(draw_data.default_bg))
    screen.draw(" ")
    return len(cell) + 1


def _draw_session_indicator(draw_data: DrawData, screen: Screen, tab: TabBarData) -> int:
    session_name = tab.session_name
    if not session_name:
        return 0

    fg = as_rgb(int("f8f8f2", 16))
    bg = as_rgb(int("44475a", 16))

    cell = f" {session_name} "
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.draw(cell)
    screen.cursor.fg = 0
    screen.cursor.bg = as_rgb(color_as_int(draw_data.default_bg))
    screen.draw(" ")
    return len(cell) + 1


def _draw_left_status(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int, is_last: bool,
    extra_data: ExtraData
) -> int:
    if draw_data.leading_spaces:
        screen.draw(' ' * draw_data.leading_spaces)
    draw_title(draw_data, screen, tab, index, max_tab_length)
    trailing_spaces = 0 # min(max_tab_length - 1, draw_data.trailing_spaces)
    max_tab_length -= trailing_spaces
    extra = screen.cursor.x - before - max_tab_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw('\u2026')
    if trailing_spaces:
        screen.draw(' ' * trailing_spaces)
    end = screen.cursor.x
    screen.cursor.bold = screen.cursor.italic = False
    screen.cursor.fg = 0
    if not is_last:
        screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.draw(draw_data.sep)
    screen.cursor.bg = 0
    return end

def _draw_right_status(draw_data: DrawData, screen: Screen, is_last: bool) -> int:
    if not is_last:
        return screen.cursor.x

    DATE_FG = as_rgb(int("ffffff", 16))
    cells = [
        (DATE_FG, as_rgb(color_as_int(draw_data.default_bg)), datetime.datetime.now().strftime("\ue0b3 %a %b %-d %H:%M ")),
    ]

    right_status_length = 0
    for _, _, cell in cells:
        right_status_length += len(cell)

    draw_spaces = screen.columns - screen.cursor.x - right_status_length
    if draw_spaces > 0:
        screen.draw(" " * draw_spaces)

    for fg, bg, cell in cells:
        screen.cursor.fg = fg
        screen.cursor.bg = bg
        screen.draw(cell)
    screen.cursor.fg = 0
    screen.cursor.bg = 0

    screen.cursor.x = max(screen.cursor.x, screen.columns - right_status_length)
    return screen.cursor.x

def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()

timer_id = None

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id
    global right_status_length
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    # Draw static indicators before first tab
    if index == 1:
        before += _draw_mode_indicator(draw_data, screen)
        before += _draw_session_indicator(draw_data, screen, tab)
    # Reset cursor colors to match the tab about to be drawn
    if tab.is_active:
        screen.cursor.bg = as_rgb(color_as_int(draw_data.active_bg))
        screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
    else:
        screen.cursor.bg = as_rgb(color_as_int(draw_data.inactive_bg))
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
    # Set cursor to where `left_status` ends, instead `right_status`,
    # to enable `open new tab` feature
    end = _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    _draw_right_status(
        draw_data,
        screen,
        is_last,
    )
    return end
