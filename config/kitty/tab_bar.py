"""tab_bar_style custom"""
# pyright: reportMissingImports=false,reportGeneralTypeIssues=false,reportAttributeAccessIssue=false,reportCallIssue=false
# pylint: disable=E0401,C0116,C0103,W0603,R0913

import datetime
import os
from contextlib import suppress

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, get_options, add_timer, monotonic
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

opts = get_options()

REFRESH_TIME = 1
ACTIVITY_VAR = "tab_activity"
PULSE_SECONDS = 2
INDEX_DIM_RATIO = 0.45

# Dracula palette
BG = int("282a36", 16)
FG = int("f8f8f2", 16)
CURRENT = int("44475a", 16)
COMMENT = int("6272a4", 16)
CYAN = int("8be9fd", 16)
GREEN = int("50fa7b", 16)
PINK = int("ff79c6", 16)
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


def _tab_activity(tab_id: int) -> str:
    boss = get_boss()
    tab = boss.tab_for_id(tab_id) if boss else None
    state = "idle"
    if tab is not None:
        for window in tab:
            explicit = window.user_vars.get(ACTIVITY_VAR)
            if window.needs_attention or explicit == "attention":
                return "attention"
            if explicit == "working" or (
                explicit != "idle" and window.has_running_program
            ):
                state = "working"
    return state


def _index_colors(state: str, fg: int, bg: int, pulse_bright: bool) -> tuple[int, int]:
    if state == "attention":
        return RED, DARK
    if state == "working" and pulse_bright:
        return fg, bg
    return _mix_color(fg, bg, INDEX_DIM_RATIO), bg


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
    _mark_all_tab_bars_dirty()


# https://github.com/kovidgoyal/kitty/blob/81c3fa71a02e28758b7edb53b40a662e53f6defa/kitty/tab_bar.py
class DrawTabContext:
    def __init__(self):
        self.timer_id = None
        self.pulse_bright = False
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

    def _draw_segment(self, label: str, fg: int, bg: int, next_bg: int, bold: bool = False) -> int:
        start = self.screen.cursor.x
        self.screen.cursor.fg = as_rgb(fg)
        self.screen.cursor.bg = as_rgb(bg)
        self.screen.cursor.bold = bold
        self.screen.draw(f" {label} ")
        self.screen.cursor.bold = False
        self.screen.cursor.fg = as_rgb(bg)
        self.screen.cursor.bg = as_rgb(next_bg)
        self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
        return self.screen.cursor.x - start

    def _get_os_window_index(self) -> str:
        boss = get_boss()
        if boss:
            # Match the 1-based ordering used by Boss.nth_os_window().
            for index, os_window_id in enumerate(boss.os_window_map, 1):
                if os_window_id == self.tab.os_window_id:
                    return str(index)
        return ""

    def _get_mode_label(self) -> str:
        boss = get_boss()
        mode = boss.mappings.current_keyboard_mode_name if boss and boss.mappings else ""
        return "SEQ" if mode == KEYBOARD_MODE_SEQUENCE else mode or ""

    def _get_session_name(self) -> str:
        boss = get_boss()
        if boss:
            t = boss.tab_for_id(self.tab.tab_id)
            if t:
                tm = t.tab_manager_ref()
                if tm:
                    return getattr(tm, "created_in_session_name", "") or ""
        return ""

    def _draw_left_status(self, next_tab_bg: int) -> int:
        start = self.screen.cursor.x
        session_name = self._get_session_name()
        segments = [
            (self._get_os_window_index(), FG, CURRENT, False),
            (session_name, FG, CURRENT, False),
        ]
        segments = [segment for segment in segments if segment[0]]
        for index, (label, fg, bg, bold) in enumerate(segments):
            next_bg = segments[index + 1][2] if index + 1 < len(segments) else next_tab_bg
            self._draw_segment(label, fg, bg, next_bg, bold)

        return self.screen.cursor.x - start

    def _get_instance_group(self) -> str:
        boss = get_boss()
        group = getattr(getattr(boss, "args", None), "instance_group", "") or "default"
        return "" if group == "default" else group

    def _get_window_status(self) -> tuple[str, ...]:
        boss = get_boss()
        if boss is None:
            return ()
        window = boss.active_window
        if window is None:
            return ()

        return f"WIN:{window.id}", f"TAB:{window.tab_id}"

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
        mode = self._get_mode_label()
        instance_group = self._get_instance_group()
        window_status = self._get_window_status()
        cells = [
            (
                as_rgb(YELLOW if mode else CURRENT),
                as_rgb(BG),
                NF_PL_RIGHT_HARD_DIVIDER,
            ),
        ]
        if mode:
            cells.extend(
                [
                    (as_rgb(DARK), as_rgb(YELLOW), f" {mode} "),
                    (as_rgb(CURRENT), as_rgb(YELLOW), NF_PL_RIGHT_HARD_DIVIDER),
                ]
            )
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
        for label in window_status:
            cells.extend(
                [
                    (
                        as_rgb(PURPLE),
                        as_rgb(CURRENT),
                        f" {label} ",
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

    def _draw_index(self, idx: str, activity: str, fg: int, bg: int) -> None:
        fg, bg = _index_colors(activity, fg, bg, self.pulse_bright)
        self.screen.cursor.fg = as_rgb(fg)
        self.screen.cursor.bg = as_rgb(bg)
        self.screen.draw(idx)

    def draw(self) -> int:
        if self.timer_id is None:
            self.timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)

        activity = _tab_activity(self.tab.tab_id)
        flag_bg = _tab_flag_color(self.tab.tab_id)
        if self.tab_index == 1:
            # Sample once per draw pass; never request a redraw for the pulse.
            self.pulse_bright = bool(int(monotonic() / PULSE_SECONDS) % 2)
            self.prev_tab_was_active = False
            next_tab_bg = flag_bg if flag_bg is not None else PURPLE if self.tab.is_active else INACTIVE_TAB_BG
            self.before += self._draw_left_status(next_tab_bg)

        prefix, name = self._tab_title()
        idx = f" {self.tab_index} "
        if flag_bg is not None:
            prefix = " " + prefix
        prev_is_active = self.extra_data.prev_tab is not None and self.extra_data.prev_tab.is_active

        if self.tab.is_active:
            self.screen.cursor.fg = as_rgb(INACTIVE_TAB_BG)
            self.screen.cursor.bg = as_rgb(flag_bg or PURPLE)
            if self.tab_index != 1:
                self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            self.screen.cursor.bold = True
            self._draw_index(idx, activity, DARK, flag_bg or PURPLE)
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
            if flag_bg is not None and self.tab_index != 1:
                self.screen.cursor.fg = as_rgb(INACTIVE_TAB_BG)
                self.screen.draw(NF_PL_LEFT_HARD_DIVIDER)
            elif not prev_is_active and self.tab_index != 1:
                self.screen.cursor.fg = as_rgb(CURRENT)
                self.screen.draw(NF_PL_LEFT_SOFT_DIVIDER)
            self.screen.cursor.bold = flag_bg is not None
            self._draw_index(idx, activity, DARK if flag_bg is not None else FG, number_bg)
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
