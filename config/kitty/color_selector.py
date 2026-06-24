"""Interactive color selector kitten.

Use from a shell:
    kitty +kitten color_selector.py
    kitty +kitten color_selector.py --palette ansi --format hex
    kitty +kitten color_selector.py --preview --columns 3 --swatch-lines 4

Use from kitty.conf:
    map kitty_mod+p>c kitten color_selector.py --format hex
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import sys
from typing import Any

from kitty.fast_data_types import Color
from kitty.rgb import color_from_int
from kittens.tui.handler import Handler, result_handler
from kittens.tui.loop import EventType, Loop
from kittens.tui.operations import MouseTracking, styled


RUNNING_AS_OVERLAY_KITTEN = __name__ == "kitten"

PALETTES = ("theme", "ansi")
OUTPUTS = ("text", "json")
ENVELOPES = ("auto", "bare", "full")
FORMATS = (
    "all",
    "hex",
    "rgb",
    "rgb-csv",
    "ansi",
    "ansi-fg",
    "ansi-bg",
    "sgr-fg",
    "sgr-bg",
    "ansi256-fg",
    "ansi256-bg",
    "kitty",
    "name",
    "index",
)
FORMAT_ALIASES = {
    "ansi": "ansi-fg",
    "ansi256": "ansi256-fg",
    "sgr": "sgr-fg",
    "config": "kitty",
}

THEME_COLOR_KEYS = (
    "foreground",
    "background",
    "selection_foreground",
    "selection_background",
    "cursor",
    "cursor_text_color",
    "url_color",
    "active_tab_foreground",
    "active_tab_background",
    "inactive_tab_foreground",
    "inactive_tab_background",
    "tab_bar_background",
    "tab_bar_margin_color",
    "active_border_color",
    "inactive_border_color",
    "bell_border_color",
    "visual_bell_color",
    "window_title_bar_active_foreground",
    "window_title_bar_active_background",
    "window_title_bar_inactive_foreground",
    "window_title_bar_inactive_background",
    "mark1_foreground",
    "mark1_background",
    "mark2_foreground",
    "mark2_background",
    "mark3_foreground",
    "mark3_background",
) + tuple(f"color{i}" for i in range(16))

XTERM_BASE_16 = (
    (0, 0, 0),
    (128, 0, 0),
    (0, 128, 0),
    (128, 128, 0),
    (0, 0, 128),
    (128, 0, 128),
    (0, 128, 128),
    (192, 192, 192),
    (128, 128, 128),
    (255, 0, 0),
    (0, 255, 0),
    (255, 255, 0),
    (0, 0, 255),
    (255, 0, 255),
    (0, 255, 255),
    (255, 255, 255),
)
CUBE_STEPS = (0, 95, 135, 175, 215, 255)
DEFAULT_PREVIEW_TEXT = (
    "$ printf '%s\\n' \"the daemon paints stderr at dawn\"\n"
    "fork() dreams in pipes; grep chases fire through /tmp;\n"
    "cron whispers in hex, and stdout keeps the receipt."
)
MIN_COLUMN_WIDTH = 12


class ColorItem:
    def __init__(
        self,
        palette: str,
        key: str,
        label: str,
        color: Color,
        index: int | None = None,
    ) -> None:
        self.palette = palette
        self.key = key
        self.label = label
        self.color = color
        self.index = index


class Layout:
    def __init__(
        self,
        columns: int = 1,
        cell_width: int = 12,
        cell_height: int = 3,
        grid_top: int = 4,
        grid_lines: int = 1,
        visible_rows: int = 1,
        total_rows: int = 1,
    ) -> None:
        self.columns = columns
        self.cell_width = cell_width
        self.cell_height = cell_height
        self.grid_top = grid_top
        self.grid_lines = grid_lines
        self.visible_rows = visible_rows
        self.total_rows = total_rows


class CLIOptions(argparse.Namespace):
    palette: str
    format: str
    output: str
    envelope: str
    query: str
    initial: str
    action: str
    columns: int
    swatch_lines: int
    preview: bool
    preview_hidden: bool
    preview_menu: bool
    preview_fg: str
    preview_bg: str
    preview_text: str


class PreviewState:
    def __init__(self, opts: CLIOptions) -> None:
        explicit = (
            opts.preview
            or opts.preview_hidden
            or opts.preview_menu
            or bool(opts.preview_fg)
            or bool(opts.preview_bg)
            or bool(opts.preview_text)
        )
        self.enabled = explicit
        self.visible = explicit and not opts.preview_hidden
        self.menu_visible = opts.preview_menu
        self.fg = as_color(opts.preview_fg) if opts.preview_fg else None
        self.bg = as_color(opts.preview_bg) if opts.preview_bg else None
        self.fg_label = opts.preview_fg if self.fg is not None else ""
        self.bg_label = opts.preview_bg if self.bg is not None else ""
        self.text = preview_text(opts.preview_text)

    def show(self) -> None:
        self.enabled = True
        self.visible = True

    def hide(self) -> None:
        self.visible = False

    def toggle_menu(self) -> None:
        self.menu_visible = not self.menu_visible

    def set_fg(self, item: ColorItem) -> None:
        self.show()
        self.fg = item.color
        self.fg_label = item.key

    def set_bg(self, item: ColorItem) -> None:
        self.show()
        self.bg = item.color
        self.bg_label = item.key

    def set_text(self, item: ColorItem) -> None:
        self.show()
        self.text = (
            f"$ tput setaf {item.index if item.index is not None else item.key}\n"
            f"{item.key} {color_to_hex(item.color)}: "
            "pipes glow, tmux redraws the moon, and awk finds the bright field."
        )

    def reset(self) -> None:
        self.enabled = False
        self.visible = False
        self.menu_visible = False
        self.fg = None
        self.bg = None
        self.fg_label = ""
        self.bg_label = ""
        self.text = DEFAULT_PREVIEW_TEXT


def color_to_hex(color: Color) -> str:
    return f"#{color.red:02x}{color.green:02x}{color.blue:02x}"


def color_to_rgb(color: Color) -> dict[str, int]:
    return {"r": color.red, "g": color.green, "b": color.blue}


def color_to_rgb_text(color: Color) -> str:
    return f"rgb({color.red}, {color.green}, {color.blue})"


def sgr_truecolor(color: Color, background: bool = False) -> str:
    base = 48 if background else 38
    return f"{base};2;{color.red};{color.green};{color.blue}"


def ansi_truecolor(color: Color, background: bool = False) -> str:
    return f"\x1b[{sgr_truecolor(color, background)}m"


def sgr_ansi256(index: int, background: bool = False) -> str:
    base = 48 if background else 38
    return f"{base};5;{max(0, min(index, 255))}"


def ansi_256(index: int, background: bool = False) -> str:
    return f"\x1b[{sgr_ansi256(index, background)}m"


def xterm_color(index: int) -> Color:
    if index < 16:
        return Color(*XTERM_BASE_16[index])
    if index < 232:
        offset = index - 16
        r = CUBE_STEPS[offset // 36]
        g = CUBE_STEPS[(offset // 6) % 6]
        b = CUBE_STEPS[offset % 6]
        return Color(r, g, b)
    gray = 8 + (index - 232) * 10
    return Color(gray, gray, gray)


def nearest_ansi256(color: Color) -> int:
    target = (color.red, color.green, color.blue)
    best = 0
    best_distance = 1 << 60
    for i in range(256):
        candidate = xterm_color(i)
        distance = (
            (target[0] - candidate.red) ** 2
            + (target[1] - candidate.green) ** 2
            + (target[2] - candidate.blue) ** 2
        )
        if distance < best_distance:
            best = i
            best_distance = distance
    return best


def text_fg_for(color: Color) -> Color:
    return Color(0, 0, 0) if color.luminance > 0.45 else Color(255, 255, 255)


def fit(text: str, width: int) -> str:
    if width <= 0:
        return ""
    if len(text) <= width:
        return text.ljust(width)
    if width == 1:
        return text[:1]
    return text[: width - 1] + "~"


def pad_visible(text: str, visible_width: int, width: int) -> str:
    if visible_width >= width:
        return text
    return text + " " * (width - visible_width)


def clamp(value: int, low: int, high: int) -> int:
    return max(low, min(value, high))


def control_repr(value: str) -> str:
    return value.replace("\x1b", "\\x1b")


def normalize_format(name: str) -> str:
    value = FORMAT_ALIASES.get(name, name)
    if value not in FORMATS:
        raise argparse.ArgumentTypeError(
            f"invalid format {name!r}; choose one of: {', '.join(FORMATS)}"
        )
    return value


def positive_int(name: str, value: str) -> int:
    try:
        ans = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f"{name} must be an integer") from None
    if ans < 1:
        raise argparse.ArgumentTypeError(f"{name} must be >= 1")
    return ans


def preview_text(value: str) -> str:
    if not value:
        return DEFAULT_PREVIEW_TEXT
    return value.replace("\\n", "\n")


def parse_args(argv: list[str]) -> CLIOptions:
    parser = argparse.ArgumentParser(
        prog=argv[0] if argv else "color_selector.py",
        description="Pick a kitty/theme or ANSI terminal color interactively.",
    )
    parser.add_argument(
        "--palette",
        "-p",
        choices=PALETTES,
        default="ansi",
        help="Initial palette to show.",
    )
    parser.add_argument(
        "--format",
        "-f",
        type=normalize_format,
        default="all",
        help="Returned color format.",
    )
    parser.add_argument(
        "--output",
        "-o",
        choices=OUTPUTS,
        default="text",
        help="Return text or JSON.",
    )
    parser.add_argument(
        "--envelope",
        choices=ENVELOPES,
        default="auto",
        help="Return bare values or a metadata envelope.",
    )
    parser.add_argument(
        "--query",
        "-q",
        default="",
        help="Initial filter query.",
    )
    parser.add_argument(
        "--initial",
        "-i",
        default="",
        help="Initial selected color name, index, or hex value.",
    )
    parser.add_argument(
        "--columns",
        type=lambda value: positive_int("--columns", value),
        default=4,
        help="Maximum color columns to show.",
    )
    parser.add_argument(
        "--swatch-lines",
        "--swatch-height",
        dest="swatch_lines",
        type=lambda value: positive_int("--swatch-lines", value),
        default=3,
        help="Terminal rows used by each color swatch.",
    )
    parser.add_argument(
        "--action",
        choices=("paste", "copy", "none"),
        default="paste",
        help="Default kitty handle_result action.",
    )
    parser.add_argument(
        "--no-paste",
        action="store_const",
        dest="action",
        const="none",
        help="Alias for --action=none.",
    )
    parser.add_argument(
        "--preview",
        action="store_true",
        help="Show the preview pane at startup.",
    )
    parser.add_argument(
        "--preview-hidden",
        action="store_true",
        help="Initialize preview state but keep the preview pane hidden.",
    )
    parser.add_argument(
        "--preview-menu",
        action="store_true",
        help="Show the preview operations menu at startup.",
    )
    parser.add_argument(
        "--preview-fg",
        default="",
        help="Initial preview foreground color.",
    )
    parser.add_argument(
        "--preview-bg",
        default="",
        help="Initial preview background color.",
    )
    parser.add_argument(
        "--preview-text",
        default="",
        help="Initial preview text. Use literal \\n for line breaks.",
    )
    return parser.parse_args(argv[1:], namespace=CLIOptions())


def default_kitty_os() -> str:
    system = platform.system().lower()
    if system == "darwin":
        return "macos"
    if system == "linux":
        return "linux"
    return system or "unknown"


def config_dir() -> str:
    if path := os.environ.get("KITTY_CONFIG_DIRECTORY"):
        return path
    try:
        from kitty.constants import config_dir as kitty_config_dir

        return kitty_config_dir
    except Exception:
        return os.path.expanduser("~/.config/kitty")


def as_color(value: Any) -> Color | None:
    if isinstance(value, Color):
        return value
    if isinstance(value, int):
        return color_from_int(value)
    if isinstance(value, str):
        try:
            return Color.parse_color(value)
        except Exception:
            return None
    return None


def colors_from_options() -> dict[str, Color]:
    ans: dict[str, Color] = {}
    old_kitty_os = os.environ.get("KITTY_OS")
    os.environ.setdefault("KITTY_OS", default_kitty_os())
    try:
        from kitty.config import load_config

        path = os.path.join(config_dir(), "kitty.conf")
        if os.path.exists(path):
            opts = load_config(path)
        else:
            from kitty.fast_data_types import get_options

            opts = get_options()
        for key in THEME_COLOR_KEYS + tuple(f"color{i}" for i in range(16, 256)):
            color = as_color(getattr(opts, key, None))
            if color is not None:
                ans[key] = color
    except Exception:
        try:
            from kitty.fast_data_types import get_options

            opts = get_options()
            for key in THEME_COLOR_KEYS + tuple(f"color{i}" for i in range(16, 256)):
                color = as_color(getattr(opts, key, None))
                if color is not None:
                    ans[key] = color
        except Exception:
            pass
    finally:
        if old_kitty_os is None:
            os.environ.pop("KITTY_OS", None)
        else:
            os.environ["KITTY_OS"] = old_kitty_os
    return ans


def colors_from_basic_env() -> dict[str, Color]:
    raw = os.environ.get("KITTY_BASIC_COLORS")
    if not raw:
        return {}
    try:
        data = json.loads(raw)
    except Exception:
        return {}
    ans: dict[str, Color] = {}
    for key, value in data.items():
        color = as_color(value)
        if color is not None:
            ans[key] = color
    return ans


def build_palettes() -> dict[str, list[ColorItem]]:
    configured = colors_from_options()
    configured.update(colors_from_basic_env())

    theme: list[ColorItem] = []
    seen_theme: set[str] = set()
    for key in THEME_COLOR_KEYS:
        color = configured.get(key)
        if color is not None and key not in seen_theme:
            index = int(key[5:]) if key.startswith("color") and key[5:].isdigit() else None
            theme.append(ColorItem("theme", key, key, color, index))
            seen_theme.add(key)
    if not theme:
        for i in range(16):
            key = f"color{i}"
            theme.append(ColorItem("theme", key, key, xterm_color(i), i))

    ansi: list[ColorItem] = []
    for i in range(256):
        key = f"color{i}"
        color = configured.get(key) or xterm_color(i)
        ansi.append(ColorItem("ansi", key, f"ansi {i}", color, i))

    return {"theme": theme, "ansi": ansi}


def item_matches(item: ColorItem, query: str) -> bool:
    if not query:
        return True
    q = query.lower().strip()
    haystack = " ".join(
        (
            item.key,
            item.label,
            color_to_hex(item.color),
            str(item.index if item.index is not None else ""),
            f"{item.color.red},{item.color.green},{item.color.blue}",
        )
    ).lower()
    return all(part in haystack for part in q.split())


def format_values(item: ColorItem) -> dict[str, Any]:
    ansi_index = item.index if item.index is not None else nearest_ansi256(item.color)
    rgb = color_to_rgb(item.color)
    values: dict[str, Any] = {
        "hex": color_to_hex(item.color),
        "rgb": f"rgb({rgb['r']}, {rgb['g']}, {rgb['b']})",
        "rgb-csv": f"{rgb['r']},{rgb['g']},{rgb['b']}",
        "ansi": ansi_truecolor(item.color),
        "ansi-fg": ansi_truecolor(item.color),
        "ansi-bg": ansi_truecolor(item.color, background=True),
        "sgr-fg": sgr_truecolor(item.color),
        "sgr-bg": sgr_truecolor(item.color, background=True),
        "ansi256-fg": ansi_256(ansi_index),
        "ansi256-bg": ansi_256(ansi_index, background=True),
        "kitty": f"{item.key} {color_to_hex(item.color)}",
        "name": item.key,
        "index": "" if item.index is None else str(item.index),
    }
    values["all"] = {
        key: value
        for key, value in values.items()
        if key not in {"all", "ansi"}
        and not (key.startswith("ansi256") and item.index is None)
    }
    return values


def selected_payload(item: ColorItem, opts: CLIOptions) -> dict[str, Any]:
    values = format_values(item)
    requested = normalize_format(opts.format)
    return {
        "ok": True,
        "version": 1,
        "palette": item.palette,
        "key": item.key,
        "label": item.label,
        "index": item.index,
        "rgb": color_to_rgb(item.color),
        "hex": color_to_hex(item.color),
        "format": requested,
        "output": opts.output,
        "envelope": opts.envelope,
        "action": opts.action,
        "value": values[requested],
        "formats": values["all"],
    }


def cancelled_payload(opts: CLIOptions) -> dict[str, Any]:
    return {
        "ok": False,
        "cancelled": True,
        "version": 1,
        "format": opts.format,
        "output": opts.output,
        "envelope": opts.envelope,
        "action": opts.action,
    }


def display_value(value: Any) -> str:
    if isinstance(value, str):
        return control_repr(value)
    return json.dumps(value, sort_keys=True)


def render_text(payload: dict[str, Any], opts: CLIOptions) -> str:
    if not payload.get("ok"):
        return "" if opts.envelope != "full" else "ok=false\ncancelled=true\n"

    envelope = opts.envelope
    if envelope == "auto":
        envelope = "full" if opts.format == "all" else "bare"

    if envelope == "bare" and opts.format != "all":
        value = payload["value"]
        return value if isinstance(value, str) else str(value)

    if envelope == "bare":
        return "\n".join(
            f"{key}={display_value(value)}"
            for key, value in payload["formats"].items()
        )

    lines = [
        "ok=true",
        f"palette={payload['palette']}",
        f"name={payload['key']}",
        f"hex={payload['hex']}",
        f"format={payload['format']}",
    ]
    value = payload["value"]
    if payload["format"] == "all":
        lines.extend(
            f"{key}={display_value(value)}"
            for key, value in payload["formats"].items()
        )
    else:
        lines.append(f"value={display_value(value)}")
    return "\n".join(lines)


def render_json(payload: dict[str, Any], opts: CLIOptions) -> str:
    envelope = opts.envelope
    if envelope == "auto":
        envelope = "full"
    if envelope == "bare" and payload.get("ok"):
        data = payload["formats"] if opts.format == "all" else payload["value"]
    elif envelope == "bare":
        data = None
    else:
        data = payload
    return json.dumps(data, indent=2, sort_keys=True)


def render_payload(payload: dict[str, Any], opts: CLIOptions) -> str:
    if opts.output == "json":
        return render_json(payload, opts)
    return render_text(payload, opts)


class ColorSelector(Handler):
    mouse_tracking = MouseTracking.buttons_only

    def __init__(self, opts: CLIOptions, palettes: dict[str, list[ColorItem]]) -> None:
        self.opts = opts
        self.palettes = palettes
        self.palette = opts.palette
        self.query = opts.query
        self.search_active = bool(self.query)
        self.selection = 0
        self.scroll_row = 0
        self.layout = Layout()
        self.hitboxes: list[tuple[int, int, int, int, int]] = []
        self.result: dict[str, Any] | None = None
        self.status = ""
        self.preview = PreviewState(opts)

    @property
    def items(self) -> list[ColorItem]:
        return self.palettes[self.palette]

    @property
    def filtered(self) -> list[ColorItem]:
        return [item for item in self.items if item_matches(item, self.query)]

    def initialize(self) -> None:
        self.cmd.set_window_title("kitty color selector")
        self.cmd.set_cursor_visible(False)
        self.apply_initial_selection()
        self.draw()

    def finalize(self) -> None:
        self.cmd.set_cursor_visible(True)

    def apply_initial_selection(self) -> None:
        target = (self.opts.initial or "").strip().lower()
        if not target:
            return
        target_hex = target if target.startswith("#") else f"#{target}" if re.fullmatch(r"[0-9a-f]{6}", target) else ""
        for idx, item in enumerate(self.filtered):
            if (
                item.key.lower() == target
                or item.label.lower() == target
                or str(item.index) == target
                or (target_hex and color_to_hex(item.color).lower() == target_hex)
            ):
                self.selection = idx
                return

    def current_item(self) -> ColorItem | None:
        items = self.filtered
        if not items:
            return None
        self.selection = clamp(self.selection, 0, len(items) - 1)
        return items[self.selection]

    def reset_selection(self) -> None:
        self.selection = 0
        self.scroll_row = 0

    def preview_height(self, terminal_height: int) -> int:
        if not self.preview.visible:
            return 0
        text_rows = max(1, len(self.preview.text.splitlines()))
        return min(text_rows + 3, max(4, terminal_height // 3))

    def menu_height(self) -> int:
        return 3 if self.preview.menu_visible else 0

    def visible_layout(self, item_count: int) -> Layout:
        width = max(20, self.screen_size.cols)
        height = max(10, self.screen_size.rows)
        grid_top = 4
        reserved = grid_top + self.preview_height(height) + self.menu_height()
        grid_lines = max(1, height - reserved)
        cell_height = max(1, self.opts.swatch_lines)
        visible_rows = max(1, grid_lines // cell_height)
        max_fit_columns = max(1, width // MIN_COLUMN_WIDTH)
        columns = max(1, min(self.opts.columns, max_fit_columns, max(1, item_count)))
        cell_width = max(1, width // columns)
        total_rows = max(1, (item_count + columns - 1) // columns)
        return Layout(
            columns=columns,
            cell_width=cell_width,
            cell_height=cell_height,
            grid_top=grid_top,
            grid_lines=visible_rows * cell_height,
            visible_rows=visible_rows,
            total_rows=total_rows,
        )

    def position_for_index(self, index: int) -> tuple[int, int]:
        total_rows = max(1, self.layout.total_rows)
        return index // total_rows, index % total_rows

    def index_at(self, column: int, row: int, item_count: int) -> int | None:
        if column < 0 or row < 0:
            return None
        index = column * max(1, self.layout.total_rows) + row
        return index if index < item_count else None

    def ensure_visible(self) -> None:
        item_count = len(self.filtered)
        self.layout = self.visible_layout(item_count)
        _, row = self.position_for_index(self.selection)
        if row < self.scroll_row:
            self.scroll_row = row
        elif row >= self.scroll_row + self.layout.visible_rows:
            self.scroll_row = row - self.layout.visible_rows + 1
        max_scroll = max(0, self.layout.total_rows - self.layout.visible_rows)
        self.scroll_row = clamp(self.scroll_row, 0, max_scroll)

    def move(self, delta: int) -> None:
        items = self.filtered
        if not items:
            return
        self.selection = clamp(self.selection + delta, 0, len(items) - 1)
        self.status = ""
        self.draw()

    def move_vertical(self, delta: int) -> None:
        items = self.filtered
        if not items:
            return
        column, row = self.position_for_index(self.selection)
        target = self.index_at(column, row + delta, len(items))
        if target is not None:
            self.selection = target
            self.status = ""
            self.draw()

    def move_horizontal(self, delta: int) -> None:
        items = self.filtered
        if not items:
            return
        column, row = self.position_for_index(self.selection)
        target_column = column + delta
        target = self.index_at(target_column, row, len(items))
        if target is None and 0 <= target_column < self.layout.columns:
            last_row = self.layout.total_rows - 1
            while last_row >= 0:
                target = self.index_at(target_column, last_row, len(items))
                if target is not None:
                    break
                last_row -= 1
        if target is not None:
            self.selection = target
            self.status = ""
            self.draw()

    def move_page(self, direction: int) -> None:
        self.move_vertical(direction * self.layout.visible_rows)

    def switch_palette(self) -> None:
        self.palette = "ansi" if self.palette == "theme" else "theme"
        self.reset_selection()
        self.status = ""
        self.draw()

    def cycle_format(self) -> None:
        order = ("all", "hex", "rgb", "ansi-fg", "ansi-bg", "ansi256-fg", "kitty")
        idx = order.index(self.opts.format) if self.opts.format in order else 0
        self.opts.format = order[(idx + 1) % len(order)]
        self.status = f"format={self.opts.format}"
        self.draw()

    def cycle_output(self) -> None:
        self.opts.output = "json" if self.opts.output == "text" else "text"
        self.status = f"output={self.opts.output}"
        self.draw()

    def cycle_envelope(self) -> None:
        idx = ENVELOPES.index(self.opts.envelope)
        self.opts.envelope = ENVELOPES[(idx + 1) % len(ENVELOPES)]
        self.status = f"envelope={self.opts.envelope}"
        self.draw()

    def choose(self) -> None:
        item = self.current_item()
        if item is None:
            self.cmd.bell()
            return
        self.result = selected_payload(item, self.opts)
        self.quit_loop(0)

    def cancel(self) -> None:
        self.result = cancelled_payload(self.opts)
        self.quit_loop(1)

    def copy_current(self) -> None:
        item = self.current_item()
        if item is None:
            self.cmd.bell()
            return
        payload = selected_payload(item, self.opts)
        text = render_payload(payload, self.opts)
        self.cmd.write_to_clipboard(text)
        self.status = f"copied {item.key}"
        self.draw()

    def apply_preview_operation(self, operation: str) -> None:
        item = self.current_item()
        if item is None:
            self.cmd.bell()
            return
        if operation == "show":
            self.preview.show()
        elif operation == "hide":
            self.preview.hide()
        elif operation == "set_fg":
            self.preview.set_fg(item)
        elif operation == "set_bg":
            self.preview.set_bg(item)
        elif operation == "set_text":
            self.preview.set_text(item)
        elif operation == "reset":
            self.preview.reset()
        elif operation == "toggle_menu":
            self.preview.toggle_menu()
        self.status = f"preview {operation}"
        self.draw()

    def on_resize(self, screen_size) -> None:  # type: ignore[override]
        self.screen_size = screen_size
        self.draw()

    def on_interrupt(self) -> None:
        self.cancel()

    def on_eot(self) -> None:
        self.cancel()

    def on_text(self, text: str, in_bracketed_paste: bool = False) -> None:
        if self.search_active:
            if text and text >= " ":
                self.query += text
                self.reset_selection()
                self.status = ""
                self.draw()
            return

        key = text.lower()
        if key == "/":
            self.search_active = True
            self.status = ""
            self.draw()
        elif key in ("q",):
            self.cancel()
        elif key in ("h", "a"):
            if self.preview.menu_visible and key == "h":
                self.apply_preview_operation("hide")
            else:
                self.move_horizontal(-1)
        elif key in ("l", "d"):
            self.move_horizontal(1)
        elif key in ("k", "w"):
            self.move_vertical(-1)
        elif key in ("j", "s"):
            if self.preview.menu_visible and key == "s":
                self.apply_preview_operation("show")
            else:
                self.move_vertical(1)
        elif key == "t":
            self.switch_palette()
        elif key == "f":
            if self.preview.menu_visible:
                self.apply_preview_operation("set_fg")
            else:
                self.cycle_format()
        elif key == "b" and self.preview.menu_visible:
            self.apply_preview_operation("set_bg")
        elif key == "x" and self.preview.menu_visible:
            self.apply_preview_operation("set_text")
        elif key == "r" and self.preview.menu_visible:
            self.apply_preview_operation("reset")
        elif key == "m":
            self.apply_preview_operation("toggle_menu")
        elif key == "o":
            self.cycle_output()
        elif key == "e":
            self.cycle_envelope()
        elif key == "y":
            self.copy_current()

    def on_key(self, key_event) -> None:  # type: ignore[override]
        if key_event.type is EventType.RELEASE:
            return
        if key_event.matches("enter"):
            self.choose()
        elif key_event.matches("esc"):
            if self.preview.menu_visible:
                self.apply_preview_operation("toggle_menu")
            elif self.search_active or self.query:
                self.search_active = False
                self.query = ""
                self.reset_selection()
                self.draw()
            else:
                self.cancel()
        elif key_event.matches("tab"):
            self.switch_palette()
        elif key_event.matches("backspace"):
            if self.search_active and self.query:
                self.query = self.query[:-1]
                self.reset_selection()
                self.draw()
            elif self.search_active:
                self.search_active = False
                self.draw()
        elif key_event.matches("left"):
            self.move_horizontal(-1)
        elif key_event.matches("right"):
            self.move_horizontal(1)
        elif key_event.matches("up"):
            self.move_vertical(-1)
        elif key_event.matches("down"):
            self.move_vertical(1)
        elif key_event.matches("page_up"):
            self.move_page(-1)
        elif key_event.matches("page_down"):
            self.move_page(1)
        elif key_event.matches("home"):
            self.selection = 0
            self.draw()
        elif key_event.matches("end"):
            items = self.filtered
            if items:
                self.selection = len(items) - 1
                self.draw()

    def on_click(self, mouse_event) -> None:  # type: ignore[override]
        x, y = mouse_event.cell_x, mouse_event.cell_y
        for x1, y1, x2, y2, idx in self.hitboxes:
            if x1 <= x < x2 and y1 <= y < y2:
                self.selection = idx
                self.choose()
                return

    def draw_header(self, width: int) -> list[str]:
        active = f"[{self.palette.upper()}]"
        inactive = "ANSI" if self.palette == "theme" else "THEME"
        search = self.query or ""
        prompt = "/" if self.search_active else ""
        lines = [
            fit("kitty color selector", 20)
            + " "
            + active
            + " "
            + inactive
            + "  "
            + fit(f"format={self.opts.format}", 14)
            + " "
            + fit(f"output={self.opts.output}", 11)
            + " "
            + fit(f"env={self.opts.envelope}", 10),
            fit(f"filter: {prompt}{search}", width),
            fit("Enter choose | arrows/hjkl move | Tab/t palette | / filter | f format | m preview | y copy | Esc", width),
            "-" * width,
        ]
        return [fit(line, width) for line in lines]

    def cell_text(self, item: ColorItem, selected: bool, line_number: int) -> str:
        marker = ">" if selected else " "
        if self.palette == "ansi":
            label = f"{item.index:03d}" if item.index is not None else item.key
        else:
            label = item.key
        hex_value = color_to_hex(item.color)
        rgb = f"{item.color.red},{item.color.green},{item.color.blue}"
        if self.layout.cell_height == 1:
            return f"{marker} {label} {hex_value}"
        if line_number == 0:
            return f"{marker} {label}"
        if line_number == 1:
            return f"  {hex_value}"
        if line_number == 2:
            return f"  {rgb}"
        return ""

    def draw_grid(self, items: list[ColorItem], width: int) -> list[str]:
        lines: list[str] = []
        columns = self.layout.columns
        cell_width = self.layout.cell_width
        cell_height = self.layout.cell_height
        self.hitboxes = []
        for visible_row in range(self.layout.visible_rows):
            absolute_row = self.scroll_row + visible_row
            row_items: list[tuple[int | None, ColorItem | None]] = []
            for column in range(columns):
                idx = self.index_at(column, absolute_row, len(items))
                row_items.append((idx, items[idx] if idx is not None else None))
                if idx is not None:
                    x1 = column * cell_width
                    y1 = self.layout.grid_top + visible_row * cell_height
                    self.hitboxes.append((x1, y1, x1 + cell_width, y1 + cell_height, idx))

            for cell_line in range(cell_height):
                line = ""
                visible_width = 0
                for idx, item in row_items:
                    if item is None:
                        line += " " * cell_width
                    else:
                        selected = idx == self.selection
                        line += styled(
                            fit(self.cell_text(item, selected, cell_line), cell_width),
                            fg=text_fg_for(item.color),
                            bg=item.color,
                            bold=True if selected else None,
                        )
                    visible_width += cell_width
                lines.append(pad_visible(line, visible_width, width))
        return lines

    def draw_preview_menu(self, item: ColorItem | None, width: int) -> list[str]:
        if not self.preview.menu_visible:
            return []
        name = item.key if item is not None else "no color"
        hex_value = color_to_hex(item.color) if item is not None else ""
        return [
            "-" * width,
            fit(f"preview menu: {name} {hex_value}", width),
            fit("show s | hide h | set_fg f | set_bg b | set_text x | reset r | toggle_menu m", width),
        ]

    def draw_preview(self, item: ColorItem | None, width: int, rows: int) -> list[str]:
        if rows <= 0 or not self.preview.visible:
            return []
        fg = self.preview.fg or (item.color if item is not None else None)
        bg = self.preview.bg
        fg_label = self.preview.fg_label or (item.key if item is not None else "focused color")
        bg_label = self.preview.bg_label or "default"
        lines = [
            "-" * width,
            fit(f"preview fg={fg_label} bg={bg_label}", width),
        ]
        text_rows = rows - len(lines)
        text_lines = self.preview.text.splitlines() or [""]
        for raw in text_lines[:text_rows]:
            rendered = fit(raw, width)
            if fg is not None or bg is not None:
                rendered = styled(rendered, fg=fg, bg=bg)
            lines.append(rendered)
        while len(lines) < rows:
            filler = " " * width
            lines.append(styled(filler, fg=fg, bg=bg) if fg is not None or bg is not None else filler)
        return lines[:rows]

    @Handler.atomic_update
    def draw(self) -> None:
        self.ensure_visible()
        width = max(1, self.screen_size.cols)
        height = max(1, self.screen_size.rows)
        items = self.filtered
        item = self.current_item()
        lines = self.draw_header(width)
        if items:
            lines.extend(self.draw_grid(items, width))
        else:
            self.hitboxes = []
            lines.append(fit("No colors match the current filter.", width))

        while len(lines) < self.layout.grid_top + self.layout.grid_lines:
            lines.append("")

        preview_rows = self.preview_height(height)
        menu = self.draw_preview_menu(item, width)
        before_preview = max(0, height - len(menu) - preview_rows)
        while len(lines) < before_preview:
            lines.append("")
        lines.extend(menu)
        lines.extend(self.draw_preview(item, width, preview_rows))
        lines = lines[:height]
        self.cmd.clear_screen()
        self.write("\r\n".join(lines))


def main(args: list[str]) -> dict[str, Any] | None:
    opts = parse_args(args)
    palettes = build_palettes()
    loop = Loop()
    handler = ColorSelector(opts, palettes)
    loop.loop(handler)

    payload = handler.result
    if RUNNING_AS_OVERLAY_KITTEN:
        return payload if payload and payload.get("ok") else payload

    if payload is not None:
        text = render_payload(payload, opts)
        if text:
            sys.stdout.write(text)
            if not text.endswith("\n"):
                sys.stdout.write("\n")
    raise SystemExit(loop.return_code)


@result_handler(has_ready_notification=True)
def handle_result(
    args: list[str], data: dict[str, Any] | None, target_window_id: int, boss
) -> None:
    if not data or not data.get("ok"):
        return
    action = data.get("action") or "paste"
    value = render_payload(data, parse_args(args))
    if action == "none":
        return
    if action == "copy":
        from kitty.clipboard import set_clipboard_string

        set_clipboard_string(value)
        return
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        w.paste_text(value)


help_text = "Pick a kitty/theme or ANSI terminal color"
usage = ""


def option_text() -> str:
    return """\
--palette -p
choices=theme,ansi
default=ansi
Initial palette to show.

--format -f
default=all
Returned color format. Choices: all, hex, rgb, rgb-csv, ansi-fg, ansi-bg,
sgr-fg, sgr-bg, ansi256-fg, ansi256-bg, kitty, name, index.

--output -o
choices=text,json
default=text
Return text or JSON.

--envelope
choices=auto,bare,full
default=auto
Return a bare value/object or a metadata envelope.

--query -q
Initial filter query.

--initial -i
Initial selected color name, index, or hex value.

--columns
default=4
Maximum color columns to show. The picker may use fewer columns on narrow
terminals.

--swatch-lines --swatch-height
default=3
Terminal rows used by each color swatch.

--action
choices=paste,copy,none
default=paste
Default kitty handle_result action.

--no-paste
Alias for --action=none.

--preview
Show the preview pane at startup.

--preview-hidden
Initialize preview state but keep the preview pane hidden.

--preview-menu
Show the preview operations menu at startup.

--preview-fg
Initial preview foreground color.

--preview-bg
Initial preview background color.

--preview-text
Initial preview text. Use literal \\n for line breaks. If omitted, a canned
terminal/unix sample is used when preview is enabled.
"""


if __name__ == "__main__":
    main(sys.argv)
elif __name__ == "__doc__":
    cd = sys.cli_docs  # type: ignore[attr-defined]
    cd["usage"] = usage
    cd["options"] = option_text
    cd["help_text"] = help_text
    cd["short_desc"] = help_text
