"""tab_bar_style custom"""
# pyright: reportMissingImports=false,reportGeneralTypeIssues=false,reportAttributeAccessIssue=false,reportCallIssue=false
# pylint: disable=E0401,C0116,C0103,W0603,R0913

import datetime
import os
from contextlib import suppress

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

opts = get_options()

REFRESH_TIME = 1

# Dracula palette
BG = int("282a36", 16)
FG = int("f8f8f2", 16)
CURRENT = int("44475a", 16)
COMMENT = int("6272a4", 16)
PURPLE = int("bd93f9", 16)
YELLOW = int("f1fa8c", 16)
ORANGE = int("ffb86c", 16)
RED = int("ff5555", 16)
DARK = int("21222c", 16)
INACTIVE_TAB_BG = int("2a2a37", 16)

NF_PL_LEFT_HARD_DIVIDER = "\ue0b0"
NF_PL_LEFT_SOFT_DIVIDER = "\ue0b1"
NF_PL_RIGHT_HARD_DIVIDER = "\ue0b2"
NF_PL_RIGHT_SOFT_DIVIDER = "\ue0b3"

# Name of the special keyboard mode for sequential keybinding.
# See: https://github.com/kovidgoyal/kitty/blob/81c3fa71a02e28758b7edb53b40a662e53f6defa/kitty/keys.py#L221
KEYBOARD_MODE_SEQUENCE = "__sequence__"
TAB_FLAG_STACK_ATTR = "_logan_tab_flag_stack"
TAB_FLAG_RED_AGE = 5


def _tab_flag_stack(boss=None) -> list[int]:
    boss = boss or get_boss()
    if boss is None:
        return []
    stack = getattr(boss, TAB_FLAG_STACK_ATTR, None)
    if not isinstance(stack, list):
        stack = []
        setattr(boss, TAB_FLAG_STACK_ATTR, stack)
    return stack


def _known_tab_ids(boss) -> set[int]:
    with suppress(Exception):
        return {tab.id for tab in boss.all_tabs}
    return set()


def _pruned_tab_flag_stack(boss=None) -> list[int]:
    boss = boss or get_boss()
    stack = _tab_flag_stack(boss)
    if boss is None:
        return stack
    known = _known_tab_ids(boss)
    if known:
        stack[:] = [tab_id for tab_id in stack if tab_id in known]
    return stack


def _mix_color(left: int, right: int, ratio: float) -> int:
    ratio = max(0.0, min(1.0, ratio))
    inv = 1.0 - ratio
    lr, lg, lb = (left >> 16) & 0xff, (left >> 8) & 0xff, left & 0xff
    rr, rg, rb = (right >> 16) & 0xff, (right >> 8) & 0xff, right & 0xff
    return (
        (round(lr * inv + rr * ratio) << 16)
        | (round(lg * inv + rg * ratio) << 8)
        | round(lb * inv + rb * ratio)
    )


def _tab_flag_color(tab_id: int) -> int | None:
    stack = _pruned_tab_flag_stack()
    with suppress(ValueError):
        age = stack.index(tab_id)
        ratio = min(age, TAB_FLAG_RED_AGE) / TAB_FLAG_RED_AGE
        if ratio <= 0.5:
            return _mix_color(YELLOW, ORANGE, ratio * 2)
        return _mix_color(ORANGE, RED, (ratio - 0.5) * 2)
    return None


def _mark_all_tab_bars_dirty(boss=None) -> None:
    boss = boss or get_boss()
    if boss is None:
        return
    with suppress(Exception):
        for tm in boss.all_tab_managers:
            tm.mark_tab_bar_dirty()


def _goto_tab_id(boss, tab_id: int) -> None:
    with suppress(Exception):
        for tab in boss.all_tabs:
            if tab.id == tab_id:
                boss.set_active_tab(tab)
                return


def _step_tab_flags(boss, action: str, stack: list[int]) -> None:
    if not stack:
        return

    tab = getattr(boss, "active_tab", None)
    current_id = getattr(tab, "id", None)
    if current_id in stack:
        index = stack.index(current_id)
        delta = 1 if action == "backward" else -1
        target_id = stack[(index + delta) % len(stack)]
    else:
        target_id = stack[0] if action == "backward" else stack[-1]
    _goto_tab_id(boss, target_id)


def update_tab_flags(boss, action: str) -> None:
    stack = _pruned_tab_flag_stack(boss)
    if action == "clear":
        stack.clear()
        _mark_all_tab_bars_dirty(boss)
        return
    if action in {"backward", "forward"}:
        _step_tab_flags(boss, action, stack)
        return

    tab = getattr(boss, "active_tab", None)
    if tab is None:
        return
    if action == "toggle" and tab.id in stack:
        stack.remove(tab.id)
    else:
        with suppress(ValueError):
            stack.remove(tab.id)
        stack.insert(0, tab.id)
    _mark_all_tab_bars_dirty(boss)


def _redraw_tab_bar(_):
    tm = get_boss().active_tab_manager
    if tm is not None:
        tm.mark_tab_bar_dirty()


# https://github.com/kovidgoyal/kitty/blob/81c3fa71a02e28758b7edb53b40a662e53f6defa/kitty/tab_bar.py
class DrawTabContext:
    def __init__(self):
        self.timer_id = None
        self.prev_tab_was_active = False

    def set_context(
        self,
        draw_data: DrawData,
        screen: Screen,
        tab: TabBarData,
        before: int,
        max_title_length: int,
        tab_index: int,
        is_last: bool,
        extra_data: ExtraData,
    ):
        self.draw_data = draw_data
        self.screen = screen
        self.tab = tab
        self.before = before
        self.max_title_length = max_title_length
        self.tab_index = tab_index
        self.is_last = is_last
        self.extra_data = extra_data

    def _draw_mode_indicator(self, next_bg: int) -> int:
        boss = get_boss()
        mode = boss.mappings.current_keyboard_mode_name if boss and boss.mappings else ""
        if mode == "" or mode is None:
            return 0
        elif mode == KEYBOARD_MODE_SEQUENCE:
            label = "SEQ"
        else:
            label = mode

        cell = f" {label} "
        self.screen.cursor.fg = as_rgb(DARK)
        self.screen.cursor.bg = as_rgb(PURPLE)
        self.screen.cursor.bold = True
        self.screen.draw(cell)
        self.screen.cursor.bold = False
        self.screen.cursor.fg = as_rgb(PURPLE)
        self.screen.cursor.bg = as_rgb(next_bg)
        self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
        return len(cell) + 1

    def _get_session_name(self) -> str:
        boss = get_boss()
        if boss:
            t = boss.tab_for_id(self.tab.tab_id)
            if t:
                tm = t.tab_manager_ref()
                if tm:
                    return getattr(tm, "created_in_session_name", "") or ""
        return ""

    def _draw_session_indicator(self, next_bg: int = BG) -> int:
        session_name = self._get_session_name()
        if not session_name:
            return 0

        cell = f" {session_name} "
        self.screen.cursor.fg = as_rgb(FG)
        self.screen.cursor.bg = as_rgb(CURRENT)
        self.screen.draw(cell)
        self.screen.cursor.fg = as_rgb(CURRENT)
        self.screen.cursor.bg = as_rgb(next_bg)
        self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
        return len(cell) + 1

    def _get_instance_group(self) -> str:
        boss = get_boss()
        group = getattr(getattr(boss, "args", None), "instance_group", "") or "default"
        return "" if group == "default" else group

    def _tab_title(self) -> tuple[str, str]:
        """Return (prefix, name) for the tab title. prefix includes trailing /."""
        boss = get_boss()
        if boss:
            t = boss.tab_for_id(self.tab.tab_id)
            if t and t.name:
                return "", t.name
            if t:
                cwd = t.get_cwd_of_active_window(oldest=True)
                if cwd:
                    name = os.path.basename(cwd)
                    parent = os.path.basename(os.path.dirname(cwd))
                    if parent and name:
                        return f"{parent}/", name
                    return "", name or cwd
        return "", self.tab.title

    def _draw_right_status(self) -> int:
        if not self.is_last:
            return self.screen.cursor.x

        date = datetime.datetime.now().strftime("%a %b %-d %H:%M")
        instance_group = self._get_instance_group()
        cells = [
            (
                as_rgb(CURRENT),
                as_rgb(BG),
                NF_PL_RIGHT_HARD_DIVIDER,
            ),
        ]
        if instance_group:
            cells.extend(
                [
                    (
                        as_rgb(YELLOW),
                        as_rgb(CURRENT),
                        f" {instance_group} ",
                    ),
                    (
                        as_rgb(FG),
                        as_rgb(CURRENT),
                        NF_PL_RIGHT_SOFT_DIVIDER,
                    ),
                ]
            )
        cells.append(
            (
                as_rgb(FG),
                as_rgb(CURRENT),
                f" {date} ",
            )
        )

        right_status_length = 0
        for _, _, cell in cells:
            right_status_length += len(cell)

        draw_spaces = self.screen.columns - self.screen.cursor.x - right_status_length
        if draw_spaces > 0:
            self.screen.cursor.bg = as_rgb(BG)
            self.screen.draw(" " * draw_spaces)

        for fg, bg, cell in cells:
            self.screen.cursor.fg = fg
            self.screen.cursor.bg = bg
            self.screen.draw(cell)
        self.screen.cursor.fg = 0
        self.screen.cursor.bg = 0

        self.screen.cursor.x = max(self.screen.cursor.x, self.screen.columns - right_status_length)
        return self.screen.cursor.x

    def draw(self) -> int:
        if self.timer_id is None:
            self.timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

        if self.tab_index == 1:
            self.prev_tab_was_active = False
            has_session = bool(self._get_session_name())
            mode_next_bg = CURRENT if has_session else INACTIVE_TAB_BG
            self.before += self._draw_mode_indicator(mode_next_bg)
            self.before += self._draw_session_indicator()
            # space after mode arrow when no session
            if not has_session:
                self.screen.cursor.fg = as_rgb(CURRENT)
                self.screen.cursor.bg = as_rgb(INACTIVE_TAB_BG)
                self.screen.draw(" ")
                self.before += 1

        prefix, name = self._tab_title()
        idx = f" {self.tab_index} "
        flag_bg = _tab_flag_color(self.tab.tab_id)
        if flag_bg is not None:
            prefix = " " + prefix
        prev_is_active = self.extra_data.prev_tab is not None and self.extra_data.prev_tab.is_active

        if self.tab.is_active:
            self.screen.cursor.fg = as_rgb(INACTIVE_TAB_BG)
            self.screen.cursor.bg = as_rgb(flag_bg or PURPLE)
            self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            self.screen.cursor.bg = as_rgb(flag_bg or PURPLE)
            self.screen.cursor.fg = as_rgb(DARK)
            self.screen.cursor.bold = True
            self.screen.draw(idx)
            self.screen.cursor.bold = False
            self.screen.cursor.bg = as_rgb(PURPLE)
            self.screen.cursor.fg = as_rgb(int("3a3450", 16))
            self.screen.draw(prefix)
            self.screen.cursor.fg = as_rgb(DARK)
            self.screen.cursor.bold = True
            self.screen.draw(f"{name} ")
            self.screen.cursor.bold = False
            self.screen.cursor.fg = as_rgb(PURPLE)
            self.screen.cursor.bg = as_rgb(BG if self.is_last else INACTIVE_TAB_BG)
            self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            end = self.screen.cursor.x
        else:
            number_bg = flag_bg or INACTIVE_TAB_BG
            self.screen.cursor.bg = as_rgb(number_bg)
            if flag_bg is not None:
                self.screen.cursor.fg = as_rgb(INACTIVE_TAB_BG)
                self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            elif not prev_is_active:
                self.screen.cursor.fg = as_rgb(CURRENT)
                self.screen.draw(NF_PL_LEFT_SOFT_DIVIDER)
            self.screen.cursor.fg = as_rgb(DARK if flag_bg is not None else FG)
            self.screen.cursor.bold = flag_bg is not None
            self.screen.draw(idx)
            self.screen.cursor.bold = False
            self.screen.cursor.bg = as_rgb(INACTIVE_TAB_BG)
            self.screen.cursor.fg = as_rgb(int("b0b4c8", 16))
            self.screen.draw(prefix)
            self.screen.cursor.fg = as_rgb(int("c0c4d8", 16))
            self.screen.draw(f"{name} ")
            if self.is_last:
                self.screen.cursor.fg = as_rgb(INACTIVE_TAB_BG)
                self.screen.cursor.bg = as_rgb(BG)
                self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            end = self.screen.cursor.x

        self.prev_tab_was_active = self.tab.is_active
        self._draw_right_status()
        return end


_ctx = DrawTabContext()


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
    _ctx.set_context(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data)
    return _ctx.draw()
