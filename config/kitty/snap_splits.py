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

From a shell prompt inside kitty (needs remote control; supports --match
to target another window's tab)::

    kitten @ kitten snap_splits.py tall

The target accepts the same forms as ``goto_layout``: a layout name with
optional options, e.g. ``tall:bias=70;full_size=2``. Without explicit
options the definition from ``enabled_layouts`` is used, so the result is
exactly what switching to that layout directly would show (including any
manual resizes that layout remembers for this tab).

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

import sys
from typing import TYPE_CHECKING, Union

from kittens.tui.handler import result_handler
from kitty.layout.base import lgd
from kitty.layout.splits import Pair, Splits

if TYPE_CHECKING:
    from kitty.boss import Boss
    from kitty.tabs import Tab
    from kitty.types import WindowGeometry

TARGETS = ("tall", "fat", "grid", "horizontal", "vertical", "splits")
TOL = 1  # px slack when testing that a cut line does not slice any window

Rect = tuple[int, int, int, int]  # left, top, right, bottom
Item = tuple[int, Rect]  # window group id, slot rect

USAGE = f"""\
Usage: kitten snap_splits.py <target>[:opts]

Snap the splits layout into the shape of another layout.

target is one of: {', '.join(TARGETS)}, with optional layout opts,
e.g. tall, grid, tall:bias=70;full_size=2, fat:mirrored=yes.
'splits' freezes the current window arrangement into the splits layout.
(stack overlaps windows and cannot be expressed as splits)

This kitten changes the active tab's layout, so it must run inside kitty:
    map kitty_mod+y>t kitten snap_splits.py tall    # keybinding in kitty.conf
    kitten @ kitten snap_splits.py tall             # shell, needs remote control\
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


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: "Boss") -> None:
    w = boss.window_id_map.get(target_window_id)
    tab = (w.tabref() if w is not None else None) or boss.active_tab
    if tab is None:
        return
    spec = (args[1] if len(args) > 1 else "").lower()
    base = spec.partition(":")[0]
    if base not in TARGETS:
        boss.show_error("snap_splits", USAGE)
        return

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
            boss.show_error("snap_splits", str(e))
            return

    if root is not None:
        splits = tab.current_layout
        assert isinstance(root, Pair) and isinstance(splits, Splits)
        splits.pairs_root = root
        splits._maximized_biases = {}  # saved biases refer to the old tree
    tab.relayout()
