#!/usr/bin/env python3
"""Project-aware kitty colors.

Loaded from kitty.common.conf with:

    watcher watcher.py

This colors the active border and the tab's active/inactive backgrounds from
the active window's project root. Project hues are generated on first use and
persisted in kitty's cache directory.
"""

from __future__ import annotations

import colorsys
import hashlib
import json
import os
from contextlib import suppress
from dataclasses import dataclass
from tempfile import NamedTemporaryFile
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from kitty.boss import Boss
    from kitty.fast_data_types import Color
    from kitty.tabs import Tab, TabManager
    from kitty.window import Window


ROOT_MARKERS = (
    ".git",
    ".jj",
    ".hg",
    ".svn",
    "pyproject.toml",
    "package.json",
    "pnpm-workspace.yaml",
    "yarn.lock",
    "Cargo.toml",
    "go.mod",
    "Gemfile",
    "flake.nix",
    "deno.json",
    "deno.jsonc",
    "mise.toml",
    ".mise.toml",
)

STATE_VERSION = 1
STATE_FILE = "project-color-watcher.json"
MIN_HUE_DISTANCE = 0.055
GOLDEN_RATIO_CONJUGATE = 0.6180339887498949

_state: dict[str, Any] | None = None
_last_active_border_root: str | None | object = object()
_last_tab_root: dict[int, str | None] = {}


@dataclass(frozen=True)
class Rgb:
    r: int
    g: int
    b: int

    @property
    def sharp(self) -> str:
        return f"#{self.r:02x}{self.g:02x}{self.b:02x}"

    @property
    def value(self) -> int:
        return (self.r << 16) | (self.g << 8) | self.b


@dataclass(frozen=True)
class ProjectColors:
    border: Rgb
    active_bg: Rgb
    active_fg: Rgb
    inactive_bg: Rgb
    inactive_fg: Rgb


def _state_path() -> str:
    from kitty.constants import cache_dir

    return os.path.join(cache_dir(), STATE_FILE)


def _load_state() -> dict[str, Any]:
    global _state
    if _state is not None:
        return _state
    ans: dict[str, Any] = {"version": STATE_VERSION, "projects": {}}
    with suppress(Exception):
        with open(_state_path(), encoding="utf-8") as f:
            raw = json.load(f)
        if isinstance(raw, dict) and isinstance(raw.get("projects"), dict):
            ans["projects"] = raw["projects"]
    _state = ans
    return ans


def _save_state() -> None:
    state = _load_state()
    path = _state_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with NamedTemporaryFile("w", encoding="utf-8", dir=os.path.dirname(path), delete=False) as f:
        tmp = f.name
        json.dump(state, f, indent=2, sort_keys=True)
        f.write("\n")
    os.replace(tmp, path)


def _hash_hue(text: str) -> float:
    raw = hashlib.sha256(text.encode("utf-8", "surrogateescape")).digest()
    return int.from_bytes(raw[:8], "big") / float(1 << 64)


def _hue_distance(a: float, b: float) -> float:
    d = abs(a - b) % 1.0
    return min(d, 1.0 - d)


def _project_hue(root: str) -> float:
    state = _load_state()
    projects = state["projects"]
    entry = projects.get(root)
    if isinstance(entry, dict) and isinstance(entry.get("hue"), (int, float)):
        return float(entry["hue"]) % 1.0

    hue = _hash_hue(root)
    existing = [
        float(v["hue"]) % 1.0
        for v in projects.values()
        if isinstance(v, dict) and isinstance(v.get("hue"), (int, float))
    ]
    for _ in range(16):
        if all(_hue_distance(hue, other) >= MIN_HUE_DISTANCE for other in existing):
            break
        hue = (hue + GOLDEN_RATIO_CONJUGATE) % 1.0
    projects[root] = {"hue": hue, "name": os.path.basename(root) or root}
    _save_state()
    return hue


def _as_rgb(color: "Color") -> Rgb:
    return Rgb(int(color.red), int(color.green), int(color.blue))


def _from_hls(hue: float, lightness: float, saturation: float) -> Rgb:
    r, g, b = colorsys.hls_to_rgb(hue, lightness, saturation)
    return Rgb(round(r * 255), round(g * 255), round(b * 255))


def _mix(top: Rgb, bottom: Rgb, alpha: float) -> Rgb:
    beta = 1.0 - alpha
    return Rgb(
        round(top.r * alpha + bottom.r * beta),
        round(top.g * alpha + bottom.g * beta),
        round(top.b * alpha + bottom.b * beta),
    )


def _relative_luminance(c: Rgb) -> float:
    def channel(v: int) -> float:
        x = v / 255.0
        return x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4

    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b)


def _contrast(a: Rgb, b: Rgb) -> float:
    la, lb = _relative_luminance(a), _relative_luminance(b)
    lighter, darker = max(la, lb), min(la, lb)
    return (lighter + 0.05) / (darker + 0.05)


def _readable_text(bg: Rgb, preferred: Rgb) -> Rgb:
    if _contrast(bg, preferred) >= 4.5:
        return preferred
    black, white = Rgb(0, 0, 0), Rgb(255, 255, 255)
    return black if _contrast(bg, black) >= _contrast(bg, white) else white


def _colors_for_root(root: str) -> ProjectColors:
    from kitty.fast_data_types import get_options

    opts = get_options()
    hue = _project_hue(root)
    bg = _as_rgb(opts.background)
    fg = _as_rgb(opts.foreground)
    inactive_tab_bg = _as_rgb(opts.inactive_tab_background)
    inactive_tab_fg = _as_rgb(opts.inactive_tab_foreground)
    dark = _relative_luminance(bg) < 0.35

    if dark:
        accent = _from_hls(hue, 0.62, 0.72)
        border = _from_hls(hue, 0.66, 0.82)
        active_bg = _mix(accent, bg, 0.42)
        inactive_bg = _mix(accent, inactive_tab_bg, 0.22)
    else:
        accent = _from_hls(hue, 0.42, 0.70)
        border = _from_hls(hue, 0.35, 0.78)
        active_bg = _mix(accent, bg, 0.24)
        inactive_bg = _mix(accent, inactive_tab_bg, 0.16)

    return ProjectColors(
        border=border,
        active_bg=active_bg,
        active_fg=_readable_text(active_bg, fg),
        inactive_bg=inactive_bg,
        inactive_fg=_readable_text(inactive_bg, inactive_tab_fg),
    )


def _find_project_root(cwd: str | None) -> str | None:
    if not cwd:
        return None
    with suppress(Exception):
        cwd = os.path.realpath(os.path.expanduser(cwd))
    if not os.path.isdir(cwd):
        cwd = os.path.dirname(cwd)
    previous = ""
    current = cwd
    while current and current != previous:
        for marker in ROOT_MARKERS:
            if os.path.exists(os.path.join(current, marker)):
                return current
        previous, current = current, os.path.dirname(current)
    return None


def _cwd_for_window(window: "Window") -> str | None:
    with suppress(Exception):
        from kitty.window import CwdRequest, CwdRequestType

        cwd = CwdRequest(window, CwdRequestType.last_reported).cwd_of_child
        if cwd:
            return cwd
    with suppress(Exception):
        if window.cwd_of_child:
            return window.cwd_of_child
    with suppress(Exception):
        if window.child.current_cwd:
            return window.child.current_cwd
    with suppress(Exception):
        return window.child.cwd
    return None


def _active_tab_for(window: "Window") -> "Tab | None":
    with suppress(Exception):
        return window.tabref()
    return None


def _startup_active_border_color(boss: "Boss") -> str:
    color = boss.color_settings_at_startup.get("active_border_color")
    return "none" if color is None else _as_rgb(color).sharp


def _call_remote_control(boss: "Boss", window: "Window", args: tuple[str, ...]) -> None:
    with suppress(Exception):
        boss.call_remote_control(window, ("!" + args[0],) + args[1:])


def _apply_window_border(boss: "Boss", window: "Window", root: str | None) -> None:
    global _last_active_border_root
    if _last_active_border_root == root:
        return
    _last_active_border_root = root
    color = _colors_for_root(root).border.sharp if root else _startup_active_border_color(boss)
    _call_remote_control(
        boss,
        window,
        ("set-colors", f"--match-window=id:{window.id}", f"active_border_color={color}"),
    )


def _apply_tab_colors(boss: "Boss", window: "Window", root: str | None) -> None:
    tab = _active_tab_for(window)
    if tab is None or _last_tab_root.get(tab.id) == root:
        return
    _last_tab_root[tab.id] = root
    if root:
        colors = _colors_for_root(root)
        args = (
            "set-tab-color",
            f"--match=id:{tab.id}",
            f"active_bg={colors.active_bg.sharp}",
            f"active_fg={colors.active_fg.sharp}",
            f"inactive_bg={colors.inactive_bg.sharp}",
            f"inactive_fg={colors.inactive_fg.sharp}",
        )
    else:
        args = (
            "set-tab-color",
            f"--match=id:{tab.id}",
            "active_bg=NONE",
            "active_fg=NONE",
            "inactive_bg=NONE",
            "inactive_fg=NONE",
        )
    _call_remote_control(boss, window, args)


def _apply_window(boss: "Boss", window: "Window", *, apply_border: bool = True) -> None:
    root = _find_project_root(_cwd_for_window(window))
    if apply_border and _is_active_window(boss, window):
        _apply_window_border(boss, window, root)
    _apply_tab_colors(boss, window, root)


def _apply_tab_manager(boss: "Boss", tab_manager: "TabManager") -> None:
    for tab in tab_manager:
        window = tab.active_window
        if window is not None:
            _apply_window(boss, window, apply_border=False)


def _apply_active_border(boss: "Boss") -> None:
    window = boss.active_window
    if window is not None:
        root = _find_project_root(_cwd_for_window(window))
        _apply_window_border(boss, window, root)


def _is_active_window(boss: "Boss", window: "Window") -> bool:
    with suppress(Exception):
        return boss.active_window is window
    return False


def on_load(boss: "Boss", data: dict[str, Any]) -> None:
    _load_state()
    for window in boss.all_windows:
        _apply_window(boss, window, apply_border=False)
    _apply_active_border(boss)


def on_resize(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    _apply_window(boss, window)


def on_focus_change(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    if data.get("focused"):
        _apply_window(boss, window)


def on_title_change(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    _apply_window(boss, window)


def on_cmd_startstop(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    if not data.get("is_start"):
        _apply_window(boss, window)


def on_set_user_var(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    _apply_window(boss, window)


def on_color_scheme_preference_change(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    global _last_active_border_root
    _last_active_border_root = object()
    _last_tab_root.clear()
    _apply_window(boss, window)


def on_tab_bar_dirty(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    tab_manager = data.get("tab_manager")
    if tab_manager is not None:
        _apply_tab_manager(boss, tab_manager)
    _apply_active_border(boss)


def on_close(boss: "Boss", window: "Window", data: dict[str, Any]) -> None:
    tab = _active_tab_for(window)
    if tab is not None:
        _last_tab_root.pop(tab.id, None)
