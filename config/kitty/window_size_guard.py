"""Keep the focused window comfortably large by borrowing from its neighbours.

This module has two roles:

* Watcher, loaded from kitty.common.conf with ``watcher window_size_guard.py``.
  It reacts to focus changes and to geometry changes (moving the OS window
  between a large display and the built-in one).
* Kitten, bound with ``kitten window_size_guard.py toggle``, which switches the
  mode on/off and carries the tunables.

The mode is dormant until switched on, so the watcher costs nothing when idle.
While on, a window that gains focus grows -- taking space from its split
siblings -- until it holds at least ``max(min_columns, width_share * tab
width)`` columns and the equivalent number of lines. Growing stops early rather
than squeezing any neighbour below ``floor_columns`` / ``floor_lines``.

State lives on the Boss because the watcher and the kitten are loaded as two
separate modules and so cannot share globals.
"""

from __future__ import annotations

from contextlib import suppress
from typing import TYPE_CHECKING, Any

from kittens.tui.handler import result_handler

if TYPE_CHECKING:
    from kitty.boss import Boss
    from kitty.tabs import Tab
    from kitty.window import Window

STATE_ATTR = "_logan_window_size_guard"

DEFAULTS: dict[str, Any] = {
    "active": False,
    # A window is too small below max(min_*, share * tab extent). The absolute
    # floor keeps things sane on the laptop display, the share keeps a single
    # window from being one skinny stripe of a large one.
    "min_columns": 100,
    "min_lines": 24,
    "width_share": 0.40,
    "height_share": 0.40,
    # Never shrink a neighbour past these while growing the focused window.
    "floor_columns": 40,
    "floor_lines": 8,
    "notify": True,
}

# kitty converts a cell increment into a bias fraction using the whole tab as
# the denominator, then applies it to the enclosing split pair, so a single
# request lands short in nested splits and overshoots at the root. Converge in
# small steps instead, re-measuring after each one.
STEP_CELLS = 8
MAX_STEPS = 32
RESIZE_DEBOUNCE = 0.15

# Marks our callbacks so _sync_hooks can recognise them regardless of which of
# this file's two module instances they came from.
HOOK_MARK = "_wsg_hook"

OPTIONS = {
    "min_columns": int,
    "min_lines": int,
    "width_share": float,
    "height_share": float,
    "floor_columns": int,
    "floor_lines": int,
}
ACTIONS = ("toggle", "on", "off", "status")


def _state(boss: Boss) -> dict[str, Any]:
    state = getattr(boss, STATE_ATTR, None)
    if state is None:
        state = dict(DEFAULTS, timers={}, last_signature=None)
        setattr(boss, STATE_ATTR, state)
    return state


def _tab_extent(tab: Tab) -> tuple[int, int]:
    """Cells available to the tab's layout, as the layout itself measures them."""
    from kitty.fast_data_types import viewport_for_window

    central, _tab_bar, _width, _height, cell_width, cell_height = viewport_for_window(tab.os_window_id)
    return max(1, central.width // cell_width), max(1, central.height // cell_height)


def _targets(tab: Tab, state: dict[str, Any]) -> tuple[int, int]:
    width, height = _tab_extent(tab)
    columns = max(state["min_columns"], round(state["width_share"] * width))
    lines = max(state["min_lines"], round(state["height_share"] * height))
    # Asking for more than the tab can spare only burns iterations.
    columns = min(columns, max(1, width - state["floor_columns"]))
    lines = min(lines, max(1, height - state["floor_lines"]))
    return columns, lines


def _sizes(tab: Tab, is_horizontal: bool) -> dict[int, int]:
    attr = "columns" if is_horizontal else "lines"
    return {w.id: getattr(w.screen, attr) for w in tab.windows}


def _grow(boss: Boss, window: Window, tab: Tab, is_horizontal: bool, target: int, floor: int) -> None:
    attr = "columns" if is_horizontal else "lines"
    for _ in range(MAX_STEPS):
        current: int = getattr(window.screen, attr)
        if current >= target:
            return
        step = float(min(STEP_CELLS, target - current))
        before = _sizes(tab, is_horizontal)
        boss.resize_layout_window(window, step, is_horizontal)
        after = _sizes(tab, is_horizontal)
        if getattr(window.screen, attr) <= current:
            return  # the layout will not give us any more
        if any(
            size < floor and size < before.get(wid, size)
            for wid, size in after.items()
            if wid != window.id
        ):
            boss.resize_layout_window(window, -step, is_horizontal)
            return


def enforce(boss: Boss, window: Window | None) -> None:
    state = _state(boss)
    if not state["active"] or window is None:
        return
    tab = window.tabref()
    if tab is None or tab.current_layout.name == "stack" or tab.windows.num_groups < 2:
        return

    columns, lines = _targets(tab, state)
    signature = (window.id, window.screen.columns, window.screen.lines, columns, lines)
    if signature == state["last_signature"]:
        # Nothing has moved since we last gave up here. Bailing keeps our own
        # relayouts from feeding the on_resize handler forever.
        return
    _grow(boss, window, tab, True, columns, state["floor_columns"])
    _grow(boss, window, tab, False, lines, state["floor_lines"])
    state["last_signature"] = (window.id, window.screen.columns, window.screen.lines, columns, lines)


def _schedule_recheck(boss: Boss, os_window_id: int) -> None:
    from kitty.fast_data_types import add_timer, remove_timer

    timers = _state(boss)["timers"]
    pending = timers.pop(os_window_id, None)
    if pending is not None:
        with suppress(Exception):
            remove_timer(pending)

    def fire(timer_id: int | None) -> None:
        timers.pop(os_window_id, None)
        tab_manager = boss.os_window_map.get(os_window_id)
        tab = tab_manager.active_tab if tab_manager is not None else None
        if tab is not None:
            enforce(boss, tab.active_window)

    timers[os_window_id] = add_timer(fire, RESIZE_DEBOUNCE, False)


def _sync_hooks(boss: Boss) -> int:
    """Attach our callbacks to windows that kitty.conf's `watcher` never reached.

    The `watcher` option only applies to windows created after the config was
    loaded, so every window that predates it keeps a Watchers copy without us --
    which looks exactly like the mode being broken. The marker attribute is set
    on the functions themselves, so this stays idempotent whether a window got
    its copy from the watcher-loaded module or from this one (kitty loads the
    file twice, once per role).
    """
    installed = 0
    for window in boss.window_id_map.values():
        for event, hook in (("on_focus_change", on_focus_change), ("on_resize", on_resize)):
            hooks = getattr(window.watchers, event)
            if not any(getattr(h, HOOK_MARK, False) for h in hooks):
                hooks.append(hook)
                installed += 1
    return installed


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if not _state(boss)["active"]:
        return
    # A window created since the last sync has no hook of its own, but the blur
    # event on the window we are leaving arrives first and the dispatcher reads
    # the hook list when the timer fires, so patching here still catches it.
    _sync_hooks(boss)
    if data.get("focused"):
        enforce(boss, window)


def on_resize(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if not _state(boss)["active"]:
        return
    old = data.get("old_geometry")
    if old is not None and old.xnum == 0 and old.ynum == 0:
        return  # window creation, the focus event covers it
    _schedule_recheck(boss, window.os_window_id)


setattr(on_focus_change, HOOK_MARK, True)
setattr(on_resize, HOOK_MARK, True)


def _apply_options(state: dict[str, Any], argv: list[str]) -> list[str]:
    unknown: list[str] = []
    tokens = iter(argv)
    for token in tokens:
        if not token.startswith("--"):
            unknown.append(token)
            continue
        name, _, value = token[2:].partition("=")
        if name in ("notify", "no-notify"):
            state["notify"] = name == "notify"
            continue
        cast = OPTIONS.get(name.replace("-", "_"))
        if cast is None:
            unknown.append(token)
            continue
        try:
            state[name.replace("-", "_")] = cast(value or next(tokens, ""))
        except (ValueError, StopIteration):
            unknown.append(token)
    return unknown


def _announce(boss: Boss, window: Window | None, state: dict[str, Any]) -> None:
    if not state["notify"]:
        return
    body = "off"
    tab = window.tabref() if window is not None else None
    if state["active"]:
        body = "on"
        if tab is not None:
            columns, lines = _targets(tab, state)
            body = f"on · minimum {columns}×{lines} cells"
    # Go through the notification manager rather than the notify kitten: the
    # kitten would be run as a visible overlay window that has to be dismissed.
    with suppress(Exception):
        manager = boss.notification_manager
        cmd = manager.create_notification_cmd()
        cmd.title = "window size guard"
        cmd.body = body
        manager.notify_with_command(cmd, 0)


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    state = _state(boss)
    argv = list(args[1:])
    action = argv.pop(0) if argv and not argv[0].startswith("-") else "toggle"
    if action not in ACTIONS:
        boss.show_error("window_size_guard", f"Unknown action: {action}")
        return
    unknown = _apply_options(state, argv)
    if unknown:
        boss.show_error("window_size_guard", "Unknown options: " + " ".join(unknown))
        return

    if action != "status":
        state["active"] = not state["active"] if action == "toggle" else action == "on"
        state["last_signature"] = None
    window = boss.window_id_map.get(target_window_id) or boss.active_window
    if state["active"]:
        _sync_hooks(boss)
        enforce(boss, window)
    _announce(boss, window, state)
