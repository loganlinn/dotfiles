"""Rename a named session in this Kitty process, without changing its file.

    kitty @ kitten rename_session.py "New name"
    kitty @ kitten rename_session.py
    kitty @ kitten --match id:WINDOW_ID rename_session.py "New name"

Without a name, Kitty prompts with the current name prefilled. Membership is
resolved from the target window, its tab, then its OS window. All members are
renamed across OS windows; titles, working directories and processes stay put.
Native switching and save_as_session . still use the original backing file.
Names cannot contain controls, path separators or reserved Kitty name syntax
(including session-file suffixes). The rename lasts until Kitty exits.

This uses private Kitty session APIs; upgrades may require compatibility fixes.
"""

import unicodedata

from kittens.tui.handler import result_handler
from kitty import session


def main(args):
    pass


def window_session(window):
    tab = window.tabref()
    manager = tab.tab_manager_ref() if tab is not None else None
    return (window.created_in_session_name
            or (tab.created_in_session_name if tab is not None else "")
            or (manager.created_in_session_name if manager is not None else ""))


def install_aliases():
    resolver = session.session_arg_to_name
    aliases = getattr(resolver, "_rename_session_aliases", None)
    if aliases is None:
        aliases = {}

        def resolve(arg):
            name = resolver(arg)
            return aliases.get(name, name)

        # Store state on Kitty's resolver: kittens can be loaded more than once.
        resolve._rename_session_aliases = aliases
        session.session_arg_to_name = resolve
    return aliases


def rename(boss, window, old, new):
    if boss.window_id_map.get(window.id) is not window or window_session(window) != old:
        raise ValueError("The target window disappeared or changed session")
    if not old:
        raise ValueError("The target window does not belong to a named session")
    if new == old:
        return
    if (not new.strip() or new != new.strip() or any(c in new for c in "/\\")
            or any(unicodedata.category(c) in {"Cc", "Cf", "Cs", "Zl", "Zp"} for c in new)):
        raise ValueError("Use a non-empty name without controls, path separators or surrounding whitespace")
    if new in {".", "..", "~", "none"} or new.startswith("-") or session.has_session_extension(new):
        raise ValueError("That name is reserved by Kitty's session syntax")

    aliases = getattr(session.session_arg_to_name, "_rename_session_aliases", {})
    original = next((name for name, current in aliases.items() if current == old), old)
    known = session.get_all_known_sessions()
    managers = tuple(boss.all_tab_managers)
    references = [(tm, [tm, *tm.tabs, *(w for t in tm for w in t)]) for tm in managers]
    occupied = {obj.created_in_session_name for _, objects in references for obj in objects}
    occupied.update(known)
    occupied.update(session.goto_session_history)
    occupied.update(name for name in aliases if name != original)
    occupied.update(aliases.values())
    if new in occupied:
        raise ValueError(f"A live or known session already uses {new!r}")

    # Resolve inherited memberships before changing any parent references.
    changes = [(tm, [obj for obj in objects if obj.created_in_session_name == old
                     or (hasattr(obj, "tabref") and window_session(obj) == old)])
               for tm, objects in references]
    path = session.seen_session_paths.get(old) or known.get(old)
    install_aliases()[original] = new
    if path:
        session.seen_session_paths.pop(old, None)
        session.seen_session_paths[new] = path
    session.goto_session_history[:] = [new if name == old else name for name in session.goto_session_history]
    for tm, objects in changes:
        for obj in objects:
            obj.created_in_session_name = new
    for tm, objects in changes:
        if objects:
            tm.mark_tab_bar_dirty()


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    if len(args) > 2:
        raise ValueError('Usage: kitty @ kitten rename_session.py ["New name"]')
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        raise ValueError("The target window no longer exists")
    old = window_session(window)
    if not old:
        raise ValueError("The target window does not belong to a named session")
    if len(args) == 2:
        rename(boss, window, old, args[1])
        return

    def renamed(new):
        if not new:  # get_line returns an empty string on cancellation.
            return
        try:
            rename(boss, window, old, new)
        except ValueError as error:
            boss.show_error("Cannot rename session", str(error))

    boss.get_line("Rename session", renamed, window=window, initial_value=old,
                  window_title="Rename session")
