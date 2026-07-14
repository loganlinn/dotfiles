"""Snap the splits layout into the shape of another layout.

Computes the window geometry a target layout (tall, fat, grid, horizontal,
vertical) would produce for the current tab, then rebuilds the splits
layout's pair tree so the same windows land at the same sizes — the target
layout's shape, with splits' per-pane resize flexibility.

Behavior by starting state:

- In splits: windows snap to the target layout's shape; you stay in splits.
- Already in the target layout: sizes are unchanged; you just land in splits.
- In any other layout: as if you switched to the target first, then snapped.
- Target ``splits``: freeze the current on-screen arrangement into splits.

Usage
-----
As a keybinding in kitty.conf::

    map kitty_mod+y>t kitten snap_splits.py tall
    map kitty_mod+y>g kitten snap_splits.py grid
    map kitty_mod+y>n kitten snap_splits.py --next
    map kitty_mod+y>p kitten snap_splits.py --prev
    map kitty_mod+y>c kitten snap_splits.py --next vertical tall fat

From a shell prompt inside kitty (needs remote control)::

    kitten @ kitten snap_splits.py tall

The target accepts the same forms as ``goto_layout``: a layout name with
optional ``;``-separated options, e.g. ``tall:bias=50;full_size=1;mirrored=false``.
Without explicit options the definition from ``enabled_layouts`` is used, so
the result is exactly what switching to that layout directly would show
(including any manual resizes that layout remembers for this tab).

``--next``/``--prev`` (mutually exclusive) cycle through a list of targets,
wrapping around. The list is the first of:

1. targets given on the command line (``--next vertical tall fat``)
2. ``$KITTY_SNAP_SPLITS_KITTEN_ENABLED_LAYOUTS``, comma-separated with
   optional opts (``tall:bias=60,grid,fat``) — read from kitty's own
   environment, falling back to kitty.conf's ``env`` directive (the kitty
   process does not see ``env`` directives itself, so the fallback makes
   ``env KITTY_SNAP_SPLITS_KITTEN_ENABLED_LAYOUTS=...`` in kitty.conf work
   even when kitty is launched from the desktop)
3. the tab's ``enabled_layouts`` setting minus the non-snappable layouts
   (splits, stack), when explicitly configured (i.e. not the ``*`` default)
4. tall, fat, grid, horizontal, vertical

Cycle entries may carry opts (``tall:bias=70``); splits and stack are not
allowed in a cycle since neither is a shape to snap to. The last snapped
target is remembered per tab (on the tab's WindowList, which tracks the tab
regardless of which window is focused and survives the tab being moved to
another OS window); in a tab that has not snapped yet, the cycle starts
from the current layout.

``-m``/``--match`` selects windows the same way kitty remote control
commands do (``id:3``, ``title:foo``, ``recent:1``, ...); the snap applies
to each matched window's tab. Without it, the invoking window's tab is used.

How it works
------------
The tab is switched to splits first (skipped when already there, which
also preserves ``last_used_layout``), so window visibility and margins are
on their normal basis even when coming from stack. Then the target layout
object's own ``do_layout`` computes real window geometries — no layout
math is duplicated here. The resulting rectangles are recursively
partitioned by guillotine cuts (every kitty layout except stack tiles the
screen this way) into a splits ``Pair`` tree whose biases reproduce each
cut position, the tree is installed on the splits layout object, and the
tab is relaid out. Nothing renders in between, so only the final
arrangement is ever shown.
"""

import os
import sys
from typing import TYPE_CHECKING, Union

from kittens.tui.handler import result_handler
from kitty.fast_data_types import get_options
from kitty.layout.base import lgd
from kitty.layout.interface import all_layouts
from kitty.layout.splits import Pair, Splits
from kitty.options.utils import DELETE_ENV_VAR

if TYPE_CHECKING:
    from kitty.boss import Boss
    from kitty.tabs import Tab
    from kitty.types import WindowGeometry

TARGETS = ("tall", "fat", "grid", "horizontal", "vertical", "splits")
NON_SNAP = ("splits", "stack")  # not shapes: freeze marker / overlapping windows
CYCLE = tuple(t for t in TARGETS if t not in NON_SNAP)
ENV_VAR = "KITTY_SNAP_SPLITS_KITTEN_ENABLED_LAYOUTS"
TOL = 1  # px slack when testing that a cut line does not slice any window

Rect = tuple[int, int, int, int]  # left, top, right, bottom
Item = tuple[int, Rect]  # window group id, slot rect

USAGE = f"""\
Usage: kitten snap_splits.py [-m EXPR] <target>[:opts]
       kitten snap_splits.py [-m EXPR] --next|--prev [<target>[:opts] ...]

Snap the splits layout into the shape of another layout.

target is one of: {', '.join(TARGETS)}, with optional layout opts,
e.g. tall, grid, tall:bias=50;full_size=1;mirrored=false, fat:mirrored=yes.
'splits' freezes the current window arrangement into the splits layout.
(stack overlaps windows and cannot be expressed as splits)

--next / --prev (mutually exclusive) cycle, wrapping around, through the
first of:
  1. targets given on the command line
  2. ${ENV_VAR} (comma-separated,
     from kitty's environment or kitty.conf's env directive)
  3. the tab's enabled_layouts setting minus {'/'.join(NON_SNAP)}, when
     explicitly configured
  4. {', '.join(CYCLE)}
{'/'.join(NON_SNAP)} cannot be part of a cycle. The last snapped target is
remembered per tab; when nothing has been snapped yet, the cycle starts
from the tab's current layout.

-m / --match EXPR selects windows as in kitty remote control commands
(id:3, title:foo, recent:1, ...); the snap applies to each matched
window's tab. Default: the tab the kitten was invoked from.

This kitten changes tab layouts, so it must run inside kitty:
    map kitty_mod+y>t kitten snap_splits.py tall     # keybinding in kitty.conf
    map kitty_mod+y>n kitten snap_splits.py --next tall grid fat
    kitten @ kitten snap_splits.py --next            # shell, needs remote control\
"""


def main(args: list[str]) -> None:
    """Only reached when run standalone (e.g. ``kitty +kitten snap_splits.py``),
    where there is no boss to act on; the real work happens in handle_result."""
    if any(a in ("-h", "--help") for a in args[1:]):
        print(USAGE)
        return
    print(USAGE, file=sys.stderr)
    print("\nNote: running this kitten standalone has no effect; use one of the forms above.", file=sys.stderr)
    raise SystemExit(1)


def slot_rect(geom: "WindowGeometry") -> Rect:
    """Full extent of a window's slot: content plus decoration spaces."""
    s = geom.spaces
    return geom.left - s.left, geom.top - s.top, geom.right + s.right, geom.bottom + s.bottom


def find_cut(items: list[Item], box: Rect) -> "tuple[bool, list[Item], list[Item], float] | None":
    """Find the best straight cut through box that cleanly bisects items.

    Returns (is_vertical_line, items_before, items_after, cut_position) for
    the valid cut closest to the center of the box (ties prefer a vertical
    line, i.e. side-by-side panes), or None if no straight cut exists.
    """
    best = None
    best_key = None
    for vertical_line in (True, False):
        lo, hi = (box[0], box[2]) if vertical_line else (box[1], box[3])
        a, b = (0, 2) if vertical_line else (1, 3)
        for pos in sorted({rect[b] for _, rect in items}):
            if pos <= lo + TOL or pos >= hi - TOL:
                continue
            one: list[Item] = []
            two: list[Item] = []
            gap_start, gap_end = lo, hi
            for item in items:
                rect = item[1]
                if (rect[a] + rect[b]) / 2 < pos:
                    if rect[b] > pos + TOL:
                        break  # straddles the cut
                    one.append(item)
                    gap_start = max(gap_start, rect[b])
                else:
                    if rect[a] < pos - TOL:
                        break
                    two.append(item)
                    gap_end = min(gap_end, rect[a])
            else:
                if one and two:
                    cut = (gap_start + gap_end) / 2
                    key = (abs(cut - (lo + hi) / 2) / (hi - lo), not vertical_line)
                    if best_key is None or key < best_key:
                        best_key, best = key, (vertical_line, one, two, cut)
    return best


def build_tree(items: list[Item], box: Rect, bw: int) -> Union[Pair, int]:
    """Recursively convert tiled window rects into a splits Pair tree.

    box is the rect the splits layout will hand this subtree, and bw the
    half-gap splits reserves around a cut; biases are chosen so that
    Pair.layout_pair's ``int(bias * size) - bw`` arithmetic reproduces each
    cut position exactly.
    """
    if len(items) == 1:
        return items[0][0]
    cut = find_cut(items, box)
    if cut is None:
        raise ValueError("window arrangement cannot be divided by straight cuts")
    vertical_line, one, two, pos = cut
    left, top, right, bottom = box
    pair = Pair(horizontal=vertical_line)
    if vertical_line:
        k = round(pos - left)
        pair.bias = (k + 0.5) / (right - left)
        pair.one = build_tree(one, (left, top, left + k - bw, bottom), bw)
        pair.two = build_tree(two, (left + k + bw, top, right, bottom), bw)
    else:
        k = round(pos - top)
        pair.bias = (k + 0.5) / (bottom - top)
        pair.one = build_tree(one, (left, top, right, top + k - bw), bw)
        pair.two = build_tree(two, (left, top + k + bw, right, bottom), bw)
    return pair


def cycle_target(tab: "Tab", forwards: bool, targets: list[str]) -> str:
    """Next/previous snap target from targets, positioned by the last spec
    snapped in this tab (exact match, then by base layout name), falling
    back to the tab's current layout, then to the ends of the list."""
    def index_of(spec: str | None) -> "int | None":
        if not spec:
            return None
        if spec in targets:
            return targets.index(spec)
        base = spec.partition(":")[0]
        for i, t in enumerate(targets):
            if t.partition(":")[0] == base:
                return i
        return None

    idx = index_of(getattr(tab.windows, "_snap_splits_last", None))
    if idx is None:
        idx = index_of(tab.current_layout.name)
    if idx is None:
        return targets[0] if forwards else targets[-1]
    return targets[(idx + (1 if forwards else -1)) % len(targets)]


def env_cycle() -> "list[str] | None":
    """Cycle list from $KITTY_SNAP_SPLITS_KITTEN_ENABLED_LAYOUTS, or None if
    unset/empty. kitty.conf's ``env`` directive only seeds child-process
    environments, so it is consulted as a fallback to make it usable here."""
    raw = os.environ.get(ENV_VAR)
    if not raw:
        raw = get_options().env.get(ENV_VAR)
        if raw == DELETE_ENV_VAR:  # a bare `env VAR` directive means unset, not a value
            raw = None
    if raw is None:
        return None
    return [t.strip().lower() for t in raw.split(",") if t.strip()] or None


def default_cycle(tab: "Tab") -> list[str]:
    """Cycle list from the tab's enabled_layouts minus non-snappable
    layouts — unless enabled_layouts is the expanded ``*`` default, which
    is indistinguishable from unset and falls back to the built-in order."""
    enabled = list(tab.enabled_layouts)
    if enabled != sorted(all_layouts):
        filtered = [t for t in enabled if t.partition(":")[0] not in NON_SNAP]
        if filtered:
            return filtered
    return list(CYCLE)


def validate_cycle(cycle: list[str], source: str) -> "str | None":
    """Error message for the first invalid cycle entry, or None."""
    for t in cycle:
        base = t.partition(":")[0]
        if base in NON_SNAP:
            return f"{base!r} cannot be part of a cycle{source}"
        if base not in TARGETS:
            return f"invalid cycle target{source}: {t!r}"
    return None


def resolve_layout_spec(tab: "Tab", spec: str) -> str:
    """Match spec against enabled_layouts the way goto_layout does, falling
    back to the spec itself so explicit options always win."""
    base = spec.partition(":")[0]
    candidates = [c for c in tab.enabled_layouts if c.partition(":")[0] == base]
    if spec in candidates:
        return spec
    prefix = [c for c in candidates if c.startswith(spec)]
    if len(prefix) == 1:
        return prefix[0]
    if ":" in spec or not candidates:
        return spec
    return candidates[0]


def recover_tree(groups: tuple) -> Union[Pair, int]:
    """Build a Pair tree reproducing the groups' current geometries."""
    items = []
    for g in groups:
        if g.geometry is None:
            raise ValueError(f"window group {g.id} has no geometry yet")
        items.append((g.id, slot_rect(g.geometry)))
    box = (
        lgd.central.left,
        lgd.central.top,
        lgd.central.left + lgd.central.width,
        lgd.central.top + lgd.central.height,
    )
    bw = groups[0].effective_border() if lgd.draw_minimal_borders else 0
    return build_tree(items, box, bw)


def snap(tab: "Tab", spec: str) -> "str | None":
    """Snap one tab to spec; returns an error message, or None on success."""
    base = spec.partition(":")[0]
    splits_name = resolve_layout_spec(tab, "splits")
    if splits_name not in tab.enabled_layouts:
        tab.enabled_layouts.append(splits_name)  # this tab only, until config reload

    groups = tuple(tab.windows.iter_all_layoutable_groups())
    root = None
    if base == "splits" and len(groups) > 1:
        # Freeze the current on-screen arrangement, whatever layout drew it.
        try:
            tab.current_layout._set_dimensions(tab.windows)
            root = recover_tree(groups)
        except ValueError:
            root = None  # e.g. overlapping stack windows; plain switch below

    if tab._current_layout_name != splits_name:
        # Switching first normalizes visibility and margins (matters when
        # coming from stack); skipping it when already in splits preserves
        # _last_used_layout for the last_used_layout/toggle_layout actions.
        tab.goto_layout(splits_name)

    if base != "splits" and len(groups) > 1:
        try:
            target = tab.create_layout_object(resolve_layout_spec(tab, spec))
            target._set_dimensions(tab.windows)
            target.do_layout(tab.windows)
            root = recover_tree(groups)
        except ValueError as e:
            tab.relayout()  # restore geometry mutated by target.do_layout
            return str(e)

    if root is not None:
        splits = tab.current_layout
        assert isinstance(root, Pair) and isinstance(splits, Splits)
        splits.pairs_root = root
        splits._maximized_biases = {}  # saved biases refer to the old tree
    tab.relayout()
    if base != "splits":
        # Cycle state for --next/--prev. Stored on the WindowList rather than
        # the Tab: take_over_from transfers it, so state survives the tab
        # being detached/moved to another OS window.
        setattr(tab.windows, "_snap_splits_last", spec)
    return None


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: "Boss") -> None:
    w = boss.window_id_map.get(target_window_id)

    def usage_error(msg: str = "") -> None:
        boss.show_error("snap_splits", (msg + "\n\n" if msg else "") + USAGE)

    match_expr: "str | None" = None
    flags: list[str] = []
    targets: list[str] = []
    argv = args[1:]
    i = 0
    while i < len(argv):
        a = argv[i]
        low = a.lower()
        if low in ("-m", "--match") or low.startswith(("-m=", "--match=")):
            if "=" in a:
                expr = a.split("=", 1)[1]
            else:
                i += 1
                if i == len(argv):
                    usage_error(f"{a} requires a window match expression")
                    return
                expr = argv[i]
            if not expr:
                usage_error(f"{a.split('=', 1)[0]} requires a window match expression")
                return
            if match_expr is not None:
                usage_error("only one --match expression is allowed")
                return
            match_expr = expr
        elif low in ("--next", "--prev"):
            flags.append(low)
        else:
            targets.append(low)
        i += 1

    if len(flags) > 1:
        usage_error("--next and --prev are mutually exclusive")
        return
    cycle: "list[str] | None" = None  # None with flags → per-tab default_cycle
    direct_spec = ""
    if flags:
        if targets:
            cycle, source = targets, ""
        else:
            cycle, source = env_cycle(), f" (from ${ENV_VAR})"
        if cycle is not None:
            cycle = list(dict.fromkeys(cycle))  # dups would trap cycling at the first occurrence
            err = validate_cycle(cycle, source)
            if err:
                usage_error(err)
                return
    elif len(targets) == 1:
        direct_spec = targets[0]
        if direct_spec.partition(":")[0] not in TARGETS:
            usage_error(f"invalid target: {direct_spec!r}")
            return
    else:
        usage_error("" if not targets else "multiple targets need --next or --prev")
        return

    if match_expr is not None:
        try:
            matched = list(boss.match_windows(match_expr, w))
        except Exception as e:
            boss.show_error("snap_splits", f"bad --match expression {match_expr!r}: {e}")
            return
        tabs = [t for t in dict.fromkeys(x.tabref() for x in matched) if t is not None]
        if not tabs:
            boss.show_error("snap_splits", f"no windows matched {match_expr!r}")
            return
    else:
        tab = (w.tabref() if w is not None else None) or boss.active_tab
        if tab is None:
            return
        tabs = [tab]

    errors = []
    for tab in tabs:
        if flags:
            spec = cycle_target(tab, flags[0] == "--next", cycle if cycle is not None else default_cycle(tab))
        else:
            spec = direct_spec
        err = snap(tab, spec)
        if err is not None:
            errors.append(err if len(tabs) == 1 else f"tab {tab.effective_title or tab.id}: {err}")
    if errors:
        boss.show_error("snap_splits", "\n".join(errors))
