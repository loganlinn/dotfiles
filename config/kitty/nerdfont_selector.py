"""Interactive Nerd Font glyph selector kitten.

Use from a shell:
    kitty +kitten nerdfont_selector.py
    kitty +kitten nerdfont_selector.py --query branch --format class
    kitty +kitten nerdfont_selector.py --columns 6 --glyph-scale 3 --format unicode

Use from kitty.conf:
    map kitty_mod+p>n kitten nerdfont_selector.py --format glyph
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from typing import Any

from kittens.tui.handler import Handler, result_handler
from kittens.tui.loop import EventType, Loop
from kittens.tui.operations import MouseTracking, styled


RUNNING_AS_OVERLAY_KITTEN = __name__ == "kitten"

DATA_FILENAME = "nerdfont_glyphnames.json"
OUTPUTS = ("text", "json")
ENVELOPES = ("auto", "bare", "full")
LAYOUTS = ("row", "column")
TEXT_SIZE_CODE = 66
FORMATS = (
    "all",
    "glyph",
    "class",
    "key",
    "name",
    "prefix",
    "codepoint",
    "unicode",
    "html",
    "python",
)
FORMAT_ALIASES = {
    "char": "glyph",
    "icon": "glyph",
    "css": "class",
    "css-class": "class",
    "nf": "class",
    "utf": "codepoint",
    "utf-hex": "codepoint",
    "hex": "codepoint",
    "u": "unicode",
    "py": "python",
}
PREFIX_ORDER = (
    "pl",
    "ple",
    "pom",
    "seti",
    "dev",
    "cod",
    "fa",
    "fae",
    "iec",
    "md",
    "oct",
    "custom",
    "linux",
    "weather",
)
PREFIX_LABELS = {
    "cod": "Codicons",
    "custom": "Custom",
    "dev": "Devicons",
    "fa": "Font Awesome",
    "fae": "Font Awesome Extension",
    "iec": "IEC Power",
    "linux": "Linux",
    "md": "Material Design",
    "oct": "Octicons",
    "pl": "Powerline",
    "ple": "Powerline Extra",
    "pom": "Pomodoro",
    "seti": "Seti UI",
    "weather": "Weather",
}
MIN_COLUMN_WIDTH = 18


class IconItem:
    def __init__(self, key: str, code: str, index: int) -> None:
        self.key = key
        self.code = code.lower()
        self.index = index
        self.codepoint = int(self.code, 16)
        self.glyph = chr(self.codepoint)
        self.prefix, sep, name = key.partition("-")
        self.name = name if sep else key
        self.css_class = f"nf-{key}"
        self.label = self.name.replace("_", " ").replace("-", " ")
        self.family = PREFIX_LABELS.get(self.prefix, self.prefix.upper())


class Layout:
    def __init__(
        self,
        columns: int = 1,
        cell_width: int = 18,
        cell_height: int = 4,
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
    format: str
    output: str
    envelope: str
    query: str
    initial: str
    action: str
    columns: int
    card_lines: int
    glyph_scale: int
    glyph_width: int
    layout: str
    details: bool
    data: str


def fit(text: str, width: int) -> str:
    if width <= 0:
        return ""
    if len(text) <= width:
        return text.ljust(width)
    if width == 1:
        return text[:1]
    return text[: width - 1] + "~"


def center(text: str, width: int) -> str:
    if len(text) >= width:
        return fit(text, width)
    left = (width - len(text)) // 2
    return (" " * left + text).ljust(width)


def pad_visible(text: str, visible_width: int, width: int) -> str:
    if visible_width >= width:
        return text
    return text + " " * (width - visible_width)


def clamp(value: int, low: int, high: int) -> int:
    return max(low, min(value, high))


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


def bounded_int(name: str, value: str, low: int, high: int) -> int:
    ans = positive_int(name, value)
    if not low <= ans <= high:
        raise argparse.ArgumentTypeError(f"{name} must be between {low} and {high}")
    return ans


def cursor_forward(cells: int) -> str:
    if cells <= 0:
        return ""
    return f"\033[{cells}C"


def text_size(text: str, scale: int, width: int) -> str:
    if scale <= 1 and width <= 1:
        return text
    metadata = [f"s={scale}"]
    if width > 0:
        metadata.append(f"w={width}")
    return f"\033]{TEXT_SIZE_CODE};{':'.join(metadata)};{text}\a"


def parse_args(argv: list[str]) -> CLIOptions:
    parser = argparse.ArgumentParser(
        prog=argv[0] if argv else "nerdfont_selector.py",
        description="Pick a Nerd Font glyph interactively.",
    )
    parser.add_argument(
        "--format",
        "-f",
        type=normalize_format,
        default="glyph",
        help="Returned glyph format.",
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
        help="Initial selected glyph class, key, name, codepoint, or glyph.",
    )
    parser.add_argument(
        "--columns",
        type=lambda value: positive_int("--columns", value),
        default=5,
        help="Maximum glyph columns to show.",
    )
    parser.add_argument(
        "--card-lines",
        "--cell-lines",
        dest="card_lines",
        type=lambda value: positive_int("--card-lines", value),
        default=4,
        help="Terminal rows used by each glyph card.",
    )
    parser.add_argument(
        "--glyph-scale",
        type=lambda value: bounded_int("--glyph-scale", value, 1, 7),
        default=2,
        help="Scale the displayed glyph using kitty's text sizing protocol.",
    )
    parser.add_argument(
        "--glyph-width",
        type=lambda value: bounded_int("--glyph-width", value, 1, 7),
        default=1,
        help="Scaled-cell width reserved for the displayed glyph.",
    )
    parser.add_argument(
        "--layout",
        choices=LAYOUTS,
        default="row",
        help="Grid fill order.",
    )
    parser.add_argument(
        "--details",
        action="store_true",
        help="Show the selected glyph details pane at startup.",
    )
    parser.add_argument(
        "--data",
        default="",
        help=f"Path to {DATA_FILENAME}.",
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
    return parser.parse_args(argv[1:], namespace=CLIOptions())


def config_dir() -> str:
    if path := os.environ.get("KITTY_CONFIG_DIRECTORY"):
        return path
    try:
        from kitty.constants import config_dir as kitty_config_dir

        return kitty_config_dir
    except Exception:
        return os.path.expanduser("~/.config/kitty")


def candidate_data_paths(opts: CLIOptions) -> list[str]:
    ans: list[str] = []
    for value in (
        opts.data,
        os.environ.get("NERDFONT_PICKER_DATA", ""),
        os.path.join(config_dir(), DATA_FILENAME),
        os.path.expanduser(f"~/.config/kitty/{DATA_FILENAME}"),
        os.path.expanduser(f"~/.dotfiles/config/kitty/{DATA_FILENAME}"),
    ):
        if value and value not in ans:
            ans.append(value)
    return ans


def add_item(items: list[IconItem], seen: set[str], key: str, code: str) -> None:
    key = key.removeprefix("nf-")
    if not key or key == "METADATA" or key in seen:
        return
    if not re.fullmatch(r"[0-9a-fA-F]{4,6}", code):
        return
    seen.add(key)
    items.append(IconItem(key, code, len(items)))


def load_json_catalog(path: str) -> tuple[list[IconItem], dict[str, Any]]:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    items: list[IconItem] = []
    seen: set[str] = set()
    metadata: dict[str, Any] = {"source": path}
    if isinstance(data, dict) and isinstance(data.get("glyphs"), list):
        metadata.update(data.get("metadata") if isinstance(data.get("metadata"), dict) else {})
        for entry in data["glyphs"]:
            if isinstance(entry, dict):
                add_item(items, seen, str(entry.get("key", "")), str(entry.get("code", "")))
            elif isinstance(entry, list | tuple) and len(entry) >= 2:
                add_item(items, seen, str(entry[0]), str(entry[1]))
    elif isinstance(data, dict):
        metadata.update(data.get("METADATA") if isinstance(data.get("METADATA"), dict) else {})
        for key, val in data.items():
            if isinstance(val, dict):
                add_item(items, seen, str(key), str(val.get("code", "")))
    elif isinstance(data, list):
        for entry in data:
            if isinstance(entry, dict):
                add_item(items, seen, str(entry.get("key", "")), str(entry.get("code", "")))
    if not items:
        raise ValueError(f"no Nerd Font glyphs found in {path}")
    return items, metadata


def load_nix_catalog(data_dir: str) -> tuple[list[IconItem], dict[str, Any]]:
    items: list[IconItem] = []
    seen: set[str] = set()
    pattern = re.compile(r'^\s*"([^"]+)"\s*=\s*"(.+)"\s*;\s*$')
    for name in sorted(os.listdir(data_dir)):
        if not name.endswith(".nix") or name == "default.nix":
            continue
        prefix = name[:-4]
        path = os.path.join(data_dir, name)
        with open(path, encoding="utf-8") as f:
            for line in f:
                m = pattern.match(line)
                if m is None:
                    continue
                glyph = m.group(2)
                if not glyph:
                    continue
                add_item(items, seen, f"{prefix}-{m.group(1)}", f"{ord(glyph[0]):x}")
    if not items:
        raise ValueError(f"no Nerd Font glyphs found in {data_dir}")
    return items, {"source": data_dir}


def load_catalog(opts: CLIOptions) -> tuple[list[IconItem], dict[str, Any]]:
    errors: list[str] = []
    for path in candidate_data_paths(opts):
        if not os.path.exists(path):
            continue
        try:
            return load_json_catalog(path)
        except Exception as e:
            errors.append(f"{path}: {e}")
    nix_dir = os.path.expanduser("~/.dotfiles/lib/nerdfonts")
    if os.path.isdir(nix_dir):
        try:
            return load_nix_catalog(nix_dir)
        except Exception as e:
            errors.append(f"{nix_dir}: {e}")
    if errors:
        raise SystemExit("Failed to load Nerd Font glyph data:\n" + "\n".join(errors))
    raise SystemExit(
        f"Could not find {DATA_FILENAME}. Pass --data or set NERDFONT_PICKER_DATA."
    )


def prefix_rank(prefix: str) -> int:
    try:
        return PREFIX_ORDER.index(prefix)
    except ValueError:
        return len(PREFIX_ORDER)


def normalized_words(value: str) -> tuple[str, ...]:
    return tuple(filter(None, re.split(r"[_\-\s]+", value.lower())))


def item_score(item: IconItem, query: str) -> tuple[int, int, str]:
    q = query.lower().strip()
    if not q:
        return (0, item.index, item.key)
    q_words = normalized_words(q)
    name = item.name.lower()
    key = item.key.lower()
    code = item.code.lower()
    if q in (item.glyph, code, f"u+{code}", item.css_class.lower(), key, name):
        return (0, prefix_rank(item.prefix), item.key)
    words = normalized_words(item.name)
    if q_words and all(word in words for word in q_words):
        return (1, prefix_rank(item.prefix), item.key)
    if q in name:
        return (2, prefix_rank(item.prefix), item.key)
    if q in key or q in item.css_class.lower():
        return (3, prefix_rank(item.prefix), item.key)
    return (4, item.index, item.key)


def item_matches(item: IconItem, query: str) -> bool:
    if not query:
        return True
    q = query.lower().strip()
    haystack = " ".join(
        (
            item.glyph,
            item.key,
            item.css_class,
            item.prefix,
            item.family,
            item.name,
            item.label,
            item.code,
            f"u+{item.code}",
        )
    ).lower()
    return all(part in haystack for part in q.split())


def filtered_items(items: list[IconItem], query: str) -> list[IconItem]:
    matches = [item for item in items if item_matches(item, query)]
    if query.strip():
        matches.sort(key=lambda item: item_score(item, query))
    return matches


def python_escape(codepoint: int) -> str:
    if codepoint <= 0xFFFF:
        return f"\\u{codepoint:04x}"
    return f"\\U{codepoint:08x}"


def format_values(item: IconItem) -> dict[str, Any]:
    values: dict[str, Any] = {
        "glyph": item.glyph,
        "class": item.css_class,
        "key": item.key,
        "name": item.name,
        "prefix": item.prefix,
        "codepoint": item.code,
        "unicode": f"U+{item.code.upper()}",
        "html": f"&#x{item.code};",
        "python": python_escape(item.codepoint),
    }
    values["all"] = {key: value for key, value in values.items() if key != "all"}
    return values


def selected_payload(item: IconItem, opts: CLIOptions, metadata: dict[str, Any]) -> dict[str, Any]:
    values = format_values(item)
    requested = normalize_format(opts.format)
    return {
        "ok": True,
        "version": 1,
        "metadata": metadata,
        "key": item.key,
        "class": item.css_class,
        "prefix": item.prefix,
        "family": item.family,
        "name": item.name,
        "label": item.label,
        "glyph": item.glyph,
        "codepoint": item.code,
        "unicode": f"U+{item.code.upper()}",
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
        return value.replace("\x1b", "\\x1b")
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
        f"class={payload['class']}",
        f"key={payload['key']}",
        f"name={payload['name']}",
        f"codepoint={payload['codepoint']}",
        f"unicode={payload['unicode']}",
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
    return json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True)


def render_payload(payload: dict[str, Any], opts: CLIOptions) -> str:
    if opts.output == "json":
        return render_json(payload, opts)
    return render_text(payload, opts)


class NerdFontSelector(Handler):
    mouse_tracking = MouseTracking.buttons_only

    def __init__(self, opts: CLIOptions, items: list[IconItem], metadata: dict[str, Any]) -> None:
        self.opts = opts
        self.all_items = items
        self.metadata = metadata
        self.query = opts.query
        self.search_active = bool(self.query)
        self.selection = 0
        self.scroll_row = 0
        self.layout = Layout(cell_height=opts.card_lines)
        self.hitboxes: list[tuple[int, int, int, int, int]] = []
        self.result: dict[str, Any] | None = None
        self.status = ""
        self.details_visible = opts.details

    @property
    def filtered(self) -> list[IconItem]:
        return filtered_items(self.all_items, self.query)

    def initialize(self) -> None:
        self.cmd.set_window_title("kitty Nerd Font selector")
        self.cmd.set_cursor_visible(False)
        self.apply_initial_selection()
        self.draw()

    def finalize(self) -> None:
        self.cmd.set_cursor_visible(True)

    def apply_initial_selection(self) -> None:
        target = (self.opts.initial or "").strip().lower()
        if not target:
            return
        normalized = target.removeprefix("nf-").removeprefix("u+")
        for idx, item in enumerate(self.filtered):
            if (
                item.glyph == target
                or item.key.lower() == normalized
                or item.css_class.lower() == target
                or item.name.lower() == target
                or item.code.lower() == normalized
            ):
                self.selection = idx
                return

    def current_item(self) -> IconItem | None:
        items = self.filtered
        if not items:
            return None
        self.selection = clamp(self.selection, 0, len(items) - 1)
        return items[self.selection]

    def reset_selection(self) -> None:
        self.selection = 0
        self.scroll_row = 0

    def detail_height(self) -> int:
        return 5 if self.details_visible else 0

    def glyph_width(self) -> int:
        return max(1, self.opts.glyph_scale) * max(1, self.opts.glyph_width)

    def render_glyph(self, item: IconItem) -> str:
        return text_size(item.glyph, self.opts.glyph_scale, self.opts.glyph_width)

    def visible_layout(self, item_count: int) -> Layout:
        width = max(20, self.screen_size.cols)
        height = max(10, self.screen_size.rows)
        grid_top = 4
        reserved = grid_top + self.detail_height()
        grid_lines = max(1, height - reserved)
        cell_height = max(1, self.opts.card_lines, self.opts.glyph_scale + 2)
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
        if self.opts.layout == "column":
            total_rows = max(1, self.layout.total_rows)
            return index // total_rows, index % total_rows
        columns = max(1, self.layout.columns)
        return index % columns, index // columns

    def index_at(self, column: int, row: int, item_count: int) -> int | None:
        if column < 0 or row < 0:
            return None
        if self.opts.layout == "column":
            index = column * max(1, self.layout.total_rows) + row
        else:
            index = row * max(1, self.layout.columns) + column
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

    def cycle_format(self) -> None:
        order = ("glyph", "class", "codepoint", "unicode", "html", "python", "name", "all")
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

    def toggle_details(self) -> None:
        self.details_visible = not self.details_visible
        self.status = "details=on" if self.details_visible else "details=off"
        self.draw()

    def choose(self) -> None:
        item = self.current_item()
        if item is None:
            self.cmd.bell()
            return
        self.result = selected_payload(item, self.opts, self.metadata)
        self.quit_loop(0)

    def cancel(self) -> None:
        self.result = cancelled_payload(self.opts)
        self.quit_loop(1)

    def copy_current(self) -> None:
        item = self.current_item()
        if item is None:
            self.cmd.bell()
            return
        payload = selected_payload(item, self.opts, self.metadata)
        text = render_payload(payload, self.opts)
        self.cmd.write_to_clipboard(text)
        self.status = f"copied {item.css_class}"
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
        elif key == "q":
            self.cancel()
        elif key in ("h", "a"):
            self.move_horizontal(-1)
        elif key in ("l", "d"):
            if key == "d":
                self.toggle_details()
            else:
                self.move_horizontal(1)
        elif key in ("k", "w"):
            self.move_vertical(-1)
        elif key in ("j", "s"):
            self.move_vertical(1)
        elif key == "f":
            self.cycle_format()
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
            if self.search_active or self.query:
                self.search_active = False
                self.query = ""
                self.reset_selection()
                self.draw()
            else:
                self.cancel()
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

    def draw_header(self, width: int, item_count: int, total_count: int) -> list[str]:
        search = self.query or ""
        prompt = "/" if self.search_active else ""
        meta_bits = []
        if version := self.metadata.get("version"):
            meta_bits.append(f"nf={version}")
        if self.opts.glyph_scale > 1:
            meta_bits.append(f"glyph_scale={self.opts.glyph_scale}")
        if self.status:
            meta_bits.append(self.status)
        lines = [
            fit(
                "kitty Nerd Font selector"
                + "  "
                + fit(f"format={self.opts.format}", 16)
                + " "
                + fit(f"output={self.opts.output}", 12)
                + " "
                + fit(f"env={self.opts.envelope}", 10)
                + ("  " + " ".join(meta_bits) if meta_bits else ""),
                width,
            ),
            fit(f"filter: {prompt}{search}", width),
            fit(
                f"{item_count}/{total_count} | Enter choose | arrows/hjkl move | / filter | f format | d details | y copy | Esc",
                width,
            ),
            "-" * width,
        ]
        return [fit(line, width) for line in lines]

    def cell_text(self, item: IconItem, selected: bool, line_number: int) -> tuple[str, int]:
        marker = ">" if selected else " "
        prefix = f"{marker} "
        detail_rows = (item.css_class, item.code, item.label)
        glyph_width = self.glyph_width()
        if self.layout.cell_height == 1 or self.opts.glyph_scale == 1:
            text = f"{prefix}{item.glyph} {item.css_class}"
            return fit(text, self.layout.cell_width), self.layout.cell_width
        if line_number == 0:
            available = max(0, self.layout.cell_width - len(prefix) - glyph_width - 1)
            detail = fit(item.family, available) if available else ""
            gap = " " if detail else ""
            visible = len(prefix) + glyph_width + len(gap) + len(detail)
            return prefix + self.render_glyph(item) + gap + detail, min(visible, self.layout.cell_width)

        if line_number < self.opts.glyph_scale:
            detail_idx = line_number - 1
            detail = detail_rows[detail_idx] if detail_idx < len(detail_rows) else ""
            available = max(0, self.layout.cell_width - len(prefix) - glyph_width - 1)
            detail = fit(detail, available) if available else ""
            gap = " " if detail else ""
            visible = len(prefix) + glyph_width + len(gap) + len(detail)
            return " " * len(prefix) + cursor_forward(glyph_width) + gap + detail, min(visible, self.layout.cell_width)

        detail_idx = line_number - 1
        detail = detail_rows[detail_idx] if detail_idx < len(detail_rows) else ""
        text = f"  {detail}" if detail else ""
        return fit(text, self.layout.cell_width), self.layout.cell_width

    def draw_grid(self, items: list[IconItem], width: int) -> list[str]:
        lines: list[str] = []
        columns = self.layout.columns
        cell_width = self.layout.cell_width
        cell_height = self.layout.cell_height
        self.hitboxes = []
        for visible_row in range(self.layout.visible_rows):
            absolute_row = self.scroll_row + visible_row
            row_items: list[tuple[int | None, IconItem | None]] = []
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
                        text, used = self.cell_text(item, selected, cell_line)
                        text += " " * max(0, cell_width - used)
                        if selected:
                            line += styled(text, fg="cyan", bold=True, reverse=True)
                        elif cell_line == 0:
                            line += styled(text, fg="cyan")
                        else:
                            line += text
                    visible_width += cell_width
                lines.append(pad_visible(line, visible_width, width))
        return lines

    def draw_details(self, item: IconItem | None, width: int) -> list[str]:
        if not self.details_visible:
            return []
        if item is None:
            return ["-" * width, fit("No glyph selected.", width), "", "", ""]
        values = format_values(item)
        return [
            "-" * width,
            fit(f"{item.glyph}  {item.css_class}  {values['unicode']}  {item.family}", width),
            fit(f"name={item.name}  key={item.key}  codepoint={item.code}", width),
            fit(f"html={values['html']}  python={values['python']}", width),
            fit(f"current value={display_value(values[normalize_format(self.opts.format)])}", width),
        ]

    @Handler.atomic_update
    def draw(self) -> None:
        self.ensure_visible()
        width = max(1, self.screen_size.cols)
        height = max(1, self.screen_size.rows)
        items = self.filtered
        item = self.current_item()
        lines = self.draw_header(width, len(items), len(self.all_items))
        if items:
            lines.extend(self.draw_grid(items, width))
        else:
            self.hitboxes = []
            lines.append(fit("No glyphs match the current filter.", width))

        before_details = max(0, height - self.detail_height())
        while len(lines) < before_details:
            lines.append("")
        lines.extend(self.draw_details(item, width))
        lines = lines[:height]
        self.cmd.clear_screen()
        self.write("\r\n".join(lines))


def main(args: list[str]) -> dict[str, Any] | None:
    opts = parse_args(args)
    items, metadata = load_catalog(opts)
    loop = Loop()
    handler = NerdFontSelector(opts, items, metadata)
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


help_text = "Pick a Nerd Font glyph"
usage = ""


def option_text() -> str:
    return """\
--format -f
default=glyph
Returned glyph format. Choices: all, glyph, class, key, name, prefix,
codepoint, unicode, html, python.

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
Initial selected glyph class, key, name, codepoint, or glyph.

--columns
default=5
Maximum glyph columns to show. The picker may use fewer columns on narrow
terminals.

--card-lines --cell-lines
default=4
Terminal rows used by each glyph card. The picker reserves more rows if needed
for the configured glyph scale.

--glyph-scale
default=2
Scale the displayed glyph using kitty's text sizing protocol. Must be between
1 and 7.

--glyph-width
default=1
Scaled-cell width reserved for the displayed glyph. Must be between 1 and 7.

--layout
choices=row,column
default=row
Grid fill order.

--details
Show the selected glyph details pane at startup.

--data
Path to nerdfont_glyphnames.json.

--action
choices=paste,copy,none
default=paste
Default kitty handle_result action.

--no-paste
Alias for --action=none.
"""


if __name__ == "__main__":
    main(sys.argv)
elif __name__ == "__doc__":
    cd = sys.cli_docs  # type: ignore[attr-defined]
    cd["usage"] = usage
    cd["options"] = option_text
    cd["help_text"] = help_text
    cd["short_desc"] = help_text
