"""draw kitty tab — powerline style"""
# pyright: reportMissingImports=false,reportGeneralTypeIssues=false,reportAttributeAccessIssue=false,reportCallIssue=false
# pylint: disable=E0401,C0116,C0103,W0603,R0913

import datetime
import os

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

opts = get_options()
REFRESH_TIME = 1

# Dracula palette
BG      = int("282a36", 16)
FG      = int("f8f8f2", 16)
CURRENT = int("44475a", 16)
COMMENT = int("6272a4", 16)
PURPLE  = int("bd93f9", 16)
DARK    = int("21222c", 16)

PL = "\ue0b0"
PL_THIN = "\ue0b1"


def _pl(screen, prev_bg, next_bg):
    screen.cursor.fg = as_rgb(prev_bg)
    screen.cursor.bg = as_rgb(next_bg)
    screen.draw(PL)


def _draw_mode_indicator(draw_data: DrawData, screen: Screen, next_bg: int) -> int:
    boss = get_boss()
    mode = boss.mappings.current_keyboard_mode_name if boss and boss.mappings else ""
    if mode == "":
        label = "NORMAL"
    elif mode == "__sequence__":
        label = "SEQ"
    else:
        label = mode

    is_active = label != "NORMAL"
    mode_bg = PURPLE if is_active else COMMENT

    cell = f" {label} "
    screen.cursor.fg = as_rgb(DARK)
    screen.cursor.bg = as_rgb(mode_bg)
    screen.cursor.bold = True
    screen.draw(cell)
    screen.cursor.bold = False
    _pl(screen, mode_bg, next_bg)
    return len(cell) + 1


def _draw_session_indicator(draw_data: DrawData, screen: Screen, tab: TabBarData) -> int:
    session_name = tab.session_name
    if not session_name:
        return 0

    cell = f" {session_name} "
    screen.cursor.fg = as_rgb(FG)
    screen.cursor.bg = as_rgb(CURRENT)
    screen.draw(cell)
    _pl(screen, CURRENT, BG)
    return len(cell) + 1


def _tab_title(tab: TabBarData) -> str:
    boss = get_boss()
    cwd = None
    if boss:
        t = boss.tab_for_id(tab.tab_id)
        if t:
            cwd = t.get_cwd_of_active_window()
    if cwd:
        basename = os.path.basename(cwd)
        parent = os.path.basename(os.path.dirname(cwd))
        if parent and basename:
            return f"{parent}/{basename}"
        return basename or cwd
    return tab.title


def _draw_right_status(draw_data: DrawData, screen: Screen, is_last: bool) -> int:
    if not is_last:
        return screen.cursor.x

    DATE_FG = as_rgb(int("ffffff", 16))
    cells = [
        (DATE_FG, as_rgb(BG), datetime.datetime.now().strftime("\ue0b3 %a %b %-d %H:%M ")),
    ]

    right_status_length = 0
    for _, _, cell in cells:
        right_status_length += len(cell)

    draw_spaces = screen.columns - screen.cursor.x - right_status_length
    if draw_spaces > 0:
        screen.cursor.bg = as_rgb(BG)
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
    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

    if index == 1:
        has_session = bool(tab.session_name)
        mode_next_bg = CURRENT if has_session else BG
        before += _draw_mode_indicator(draw_data, screen, mode_next_bg)
        before += _draw_session_indicator(draw_data, screen, tab)
        if not has_session:
            # space after mode arrow when no session
            screen.cursor.bg = as_rgb(BG)
            screen.draw(" ")
            before += 1

    title = _tab_title(tab)
    cell = f" {index} {title} "

    if tab.is_active:
        # powerline arrow into active tab
        _pl(screen, BG, PURPLE)
        screen.cursor.fg = as_rgb(DARK)
        screen.cursor.bg = as_rgb(PURPLE)
        screen.cursor.bold = True
        screen.draw(cell)
        screen.cursor.bold = False
        _pl(screen, PURPLE, BG)
        end = screen.cursor.x
    else:
        screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
        screen.cursor.bg = as_rgb(BG)
        screen.draw(cell)
        end = screen.cursor.x

    _draw_right_status(draw_data, screen, is_last)
    return end
