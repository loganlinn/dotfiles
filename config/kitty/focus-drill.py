"""Drill-down window focuser for kitty: OS window -> tab -> window.

Presents a full-screen overlay menu that drills through the three levels of
kitty's window hierarchy. Each level shows single-key labels, so any window
(pane) in any tab in any OS window can be focused with up to three keystrokes.
Levels that have only a single choice are auto-selected (no keystroke spent),
unless ``--no-skip`` is given.

Usage
-----
As a keybinding in kitty.conf (runs in an overlay over the current window)::

    map kitty_mod+p>w kitten focus-drill.py

Or straight from a shell prompt inside kitty::

    kitten focus-drill

Both modes require remote control to be reachable (this config uses
``allow_remote_control socket-only`` + ``listen_on``), which kitty exports to
every window via ``KITTY_LISTEN_ON``.

Flags
-----
``--no-skip``        Always show every level, even ones with a single choice.
``--keys=CHARS``     Override the label key alphabet (default home-row first).
``--include-self``   Also list the window the kitten is running in (the
                     transient overlay window is always hidden regardless).

How it works
------------
``main()`` reads the window tree via ``kitten @ ls``, runs the selection UI,
then focuses the chosen window with ``kitten @ focus-window --match id:N`` --
a single command that activates the window, its tab, and raises its OS window.
The focus call is issued while the overlay is still alive; it reliably survives
the overlay teardown (verified, including same-tab targets), so no
``handle_result`` hook is needed and the same code path works when launched
either from a keybinding or directly from a shell.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys

from kitty.constants import kitten_exe
from kitty.fast_data_types import wcswidth
from kitty.key_encoding import EventType, KeyEvent
from kittens.tui.handler import Handler
from kittens.tui.loop import Loop
from kittens.tui.operations import styled

# Home-row first so the common cases land under resting fingers.
DEFAULT_KEYS = "asdfghjkl;qwertyuiopzxcvbnm1234567890"


class Options:
    def __init__(self, argv: list[str]) -> None:
        self.skip_single = True
        self.include_self = False
        self.keys = DEFAULT_KEYS
        for arg in argv:
            if arg in ("--no-skip", "--no-skip-single"):
                self.skip_single = False
            elif arg == "--include-self":
                self.include_self = True
            elif arg.startswith("--keys="):
                value = arg.split("=", 1)[1]
                if value:
                    self.keys = value


def get_tree(opts: Options) -> list[dict]:
    """Return the OS-window tree from ``kitten @ ls``, minus the kitten's own
    window (the overlay in keybinding mode, the current window otherwise) and
    any tabs/OS windows left empty by that filtering."""
    cp = subprocess.run(
        [kitten_exe(), "@", "ls"], capture_output=True
    )
    if cp.returncode != 0:
        msg = cp.stderr.decode("utf-8", "replace").strip() or "kitten @ ls failed"
        raise SystemExit(
            f"focus-drill: could not query kitty windows: {msg}\n"
            "Remote control must be reachable (allow_remote_control + listen_on, "
            "or run via a `map ... kitten focus-drill.py` binding)."
        )
    tree: list[dict] = json.loads(cp.stdout)

    self_id = None
    if not opts.include_self:
        env_id = os.environ.get("KITTY_WINDOW_ID")
        if env_id and env_id.isdigit():
            self_id = int(env_id)

    pruned: list[dict] = []
    for osw in tree:
        tabs = []
        for tab in osw["tabs"]:
            windows = [
                w
                for w in tab["windows"]
                if not (w.get("is_self") or (self_id is not None and w["id"] == self_id))
            ]
            if windows:
                tabs.append({**tab, "windows": windows})
        if tabs:
            pruned.append({**osw, "tabs": tabs})
    return pruned


def focus_window(window_id: int) -> None:
    cp = subprocess.run(
        [kitten_exe(), "@", "focus-window", "--match", f"id:{window_id}"],
        capture_output=True,
    )
    if cp.returncode != 0:
        sys.stderr.write(cp.stderr.decode("utf-8", "replace"))


def os_window_summary(osw: dict) -> str:
    titles = [t["title"] for t in osw["tabs"]]
    shown = ", ".join(titles[:3])
    if len(titles) > 3:
        shown += ", …"
    return shown


def truncate(text: str, width: int) -> str:
    if width <= 1 or wcswidth(text) <= width:
        return text
    out = ""
    used = 0
    for ch in text:
        w = wcswidth(ch)
        if used + w > width - 1:
            break
        out += ch
        used += w
    return out + "…"


# Each step knows how to enumerate its candidates and describe them.
STEP_OS, STEP_TAB, STEP_WINDOW = 0, 1, 2


class FocusDrill(Handler):
    def __init__(self, tree: list[dict], opts: Options) -> None:
        self.tree = tree
        self.opts = opts
        self.os_choice: dict | None = None
        self.tab_choice: dict | None = None
        self.candidates: list[tuple[str, dict]] = []
        self.label_map: dict[str, dict] = {}
        self.key_steps: list[int] = []  # steps where a key was actually pressed
        self.step = STEP_OS
        self.result: int | None = None

    # -- lifecycle --------------------------------------------------------
    def initialize(self) -> None:
        self.cmd.set_cursor_visible(False)
        self.cmd.set_line_wrapping(False)
        self.cmd.set_window_title("focus-drill")
        self.enter_step(STEP_OS)

    def finalize(self) -> None:
        self.cmd.set_cursor_visible(True)

    def on_resize(self, screen_size) -> None:
        super().on_resize(screen_size)
        self.draw_screen()

    # -- navigation -------------------------------------------------------
    def items_for(self, step: int) -> list[dict]:
        if step == STEP_OS:
            return self.tree
        if step == STEP_TAB:
            assert self.os_choice is not None
            return self.os_choice["tabs"]
        assert self.tab_choice is not None
        return self.tab_choice["windows"]

    def enter_step(self, step: int) -> None:
        self.step = step
        items = self.items_for(step)
        if not items:
            self.cancel()
            return
        if self.opts.skip_single and len(items) == 1:
            self.choose(items[0], by_key=False)
            return
        labels = self.opts.keys
        self.candidates = [(labels[i], it) for i, it in enumerate(items) if i < len(labels)]
        self.label_map = {label: it for label, it in self.candidates}
        self.draw_screen()

    def choose(self, item: dict, by_key: bool) -> None:
        if by_key:
            self.key_steps.append(self.step)
        if self.step == STEP_OS:
            self.os_choice = item
            self.enter_step(STEP_TAB)
        elif self.step == STEP_TAB:
            self.tab_choice = item
            self.enter_step(STEP_WINDOW)
        else:
            self.result = item["id"]
            self.quit_loop(0)

    def back(self) -> None:
        if not self.key_steps:
            self.cancel()
            return
        target = self.key_steps.pop()
        if target <= STEP_OS:
            self.os_choice = None
            self.tab_choice = None
        elif target <= STEP_TAB:
            self.tab_choice = None
        self.enter_step(target)

    def cancel(self) -> None:
        self.result = None
        self.quit_loop(1)

    # -- rendering --------------------------------------------------------
    def draw_screen(self) -> None:
        self.cmd.clear_screen()
        width = self.screen_size.cols
        titles = ["OS window", "tab", "window"]

        crumbs = []
        if self.os_choice is not None:
            crumbs.append(f"OS {self.os_choice['id']}")
        if self.tab_choice is not None:
            crumbs.append(self.tab_choice["title"])
        crumb = styled(" › ".join(crumbs), dim=True) if crumbs else ""
        header = styled(f"Focus a {titles[self.step]}", bold=True, fg="green")
        self.print(truncate(f"{header}  {crumb}".rstrip(), width))
        self.print()

        for label, item in self.candidates:
            self.print(truncate(self.render_item(label, item), width))

        self.print()
        hint = "  ".join(
            (
                styled("a–z", fg="green", fg_intense=True) + " select",
                styled("⌫", italic=True) + " back",
                styled("esc", italic=True) + " cancel",
            )
        )
        self.cmd.set_cursor_position(0, self.screen_size.rows - 1)
        self.write(truncate(hint, width))

    def render_item(self, label: str, item: dict) -> str:
        key = styled(f" {label} ", fg="black", bg="green", bold=True)
        focused = item.get("is_focused")
        marker = styled("●", fg="yellow") if focused else " "

        if self.step == STEP_OS:
            n = len(item["tabs"])
            title = f"OS window {item['id']}"
            meta = styled(f"  ({n} tab{'s' if n != 1 else ''}) {os_window_summary(item)}", dim=True)
        elif self.step == STEP_TAB:
            n = len(item["windows"])
            title = item["title"] or "(untitled tab)"
            meta = styled(f"  ({n} window{'s' if n != 1 else ''})", dim=True)
        else:
            title = item["title"] or "(untitled)"
            meta = styled(f"  {item.get('cwd', '')}", dim=True)

        return f"  {key} {marker} {title}{meta}"

    # -- input ------------------------------------------------------------
    def on_text(self, text: str, in_bracketed_paste: bool = False) -> None:
        item = self.label_map.get(text.lower())
        if item is not None:
            self.choose(item, by_key=True)

    def on_key(self, key_event: KeyEvent) -> None:
        if key_event.type is EventType.RELEASE:
            return
        if key_event.matches("esc"):
            self.cancel()
        elif key_event.matches("backspace"):
            self.back()

    def on_interrupt(self) -> None:
        self.cancel()

    on_eot = on_interrupt


def main(args: list[str]) -> None:
    opts = Options(args[1:])
    tree = get_tree(opts)

    if not tree:
        raise SystemExit("focus-drill: no other windows to focus")

    # Degenerate case: exactly one window anywhere -> focus it, no UI.
    all_windows = [w for osw in tree for tab in osw["tabs"] for w in tab["windows"]]
    if len(all_windows) == 1:
        focus_window(all_windows[0]["id"])
        return

    loop = Loop()
    handler = FocusDrill(tree, opts)
    loop.loop(handler)

    if handler.result is not None:
        focus_window(handler.result)
    raise SystemExit(0 if handler.result is not None else loop.return_code)


if __name__ == "__main__":
    main(sys.argv)
