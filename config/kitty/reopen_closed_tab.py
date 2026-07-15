"""Record closed tabs and reopen the latest one in the current OS window."""

import fcntl
import json
import os
import sys
import time
from collections.abc import Mapping
from contextlib import suppress
from secrets import token_hex
from typing import Any, TypedDict, cast

from kittens.tui.handler import result_handler

HISTORY_NAME = "closed-tabs.jsonl"
INSTANCE_ATTR = "_reopen_closed_tab_instance_id"
CONSUMED_ATTR = "_reopen_closed_tab_consumed_ids"


class ClosedTabRecord(TypedDict):
    active_window_id: int
    closed_at_ns: int
    closed_tab_id: str
    event: str
    kitty_instance_id: str
    kitty_ls_self: list[dict[str, Any]]
    kitty_pid: int
    os_window_id: int
    platform_window_id: int | None
    session: str
    tab_id: int
    tab_index: int
    tab_title: str
    version: int
    window_ids: list[int]

USAGE = """\
Usage: kitten reopen_closed_tab.py close|reopen

This kitten must run from a kitty keybinding:
    map kitty_mod+space>k>t kitten reopen_closed_tab.py close
    map cmd+shift+t kitten reopen_closed_tab.py reopen
"""


def main(args: list[str]) -> None:
    if any(arg in {"-h", "--help"} for arg in args[1:]):
        print(USAGE)
        return
    print(USAGE, file=sys.stderr)
    raise SystemExit(1)


def history_path() -> str:
    from kitty.constants import runtime_dir

    return os.path.join(runtime_dir(), HISTORY_NAME)


def instance_id(boss: Any) -> str:
    ans = getattr(boss, INSTANCE_ATTR, "")
    if not ans:
        ans = token_hex(16)
        setattr(boss, INSTANCE_ATTR, ans)
    return ans


def consumed_ids(boss: Any) -> set[str]:
    ans = getattr(boss, CONSUMED_ATTR, None)
    if ans is None:
        ans = set()
        setattr(boss, CONSUMED_ATTR, ans)
    return ans


def append_jsonl(path: str, data: Mapping[str, Any]) -> None:
    raw = (json.dumps(data, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n").encode()
    fd = os.open(path, os.O_APPEND | os.O_CLOEXEC | os.O_CREAT | os.O_WRONLY, 0o600)
    try:
        os.fchmod(fd, 0o600)
        fcntl.flock(fd, fcntl.LOCK_EX)
        while raw:
            written = os.write(fd, raw)
            if written < 1:
                raise OSError("failed to append closed-tab history")
            raw = raw[written:]
    finally:
        os.close(fd)


def sanitized_ls_self(boss: Any, window: Any, tab: Any) -> list[dict[str, Any]]:
    snapshot = list(boss.list_os_windows(window, tab_filter=lambda candidate: candidate is tab))
    for os_window in snapshot:
        for tab_data in os_window.get("tabs", ()):
            for window_data in tab_data.get("windows", ()):
                window_data.pop("env", None)
    return snapshot


def tab_record(boss: Any, tab: Any) -> ClosedTabRecord:
    from kitty.session import default_save_as_session_opts
    from kitty.utils import platform_window_id

    tm = tab.tab_manager_ref()
    if tm is None:
        raise RuntimeError("tab no longer belongs to an OS window")
    try:
        tab_index = tm.tabs.index(tab)
    except ValueError as error:
        raise RuntimeError("tab no longer belongs to its OS window") from error
    window = tab.active_window
    if window is None:
        raise RuntimeError("tab has no active window")
    session = "\n".join(tab.serialize_state_as_session("", None, default_save_as_session_opts()))
    if not session.strip():
        raise RuntimeError("Kitty produced an empty tab session")
    return {
        "active_window_id": window.id,
        "closed_at_ns": time.time_ns(),
        "closed_tab_id": token_hex(16),
        "event": "closed",
        "kitty_instance_id": instance_id(boss),
        "kitty_ls_self": sanitized_ls_self(boss, window, tab),
        "kitty_pid": os.getpid(),
        "os_window_id": tm.os_window_id,
        "platform_window_id": platform_window_id(tm.os_window_id),
        "session": session,
        "tab_id": tab.id,
        "tab_index": tab_index,
        "tab_title": tab.name or tab.title,
        "version": 1,
        "window_ids": [candidate.id for candidate in tab],
    }


def record_and_close(boss: Any, tab: Any) -> None:
    try:
        append_jsonl(history_path(), tab_record(boss, tab))
    except Exception as error:
        boss.show_error("Failed to record closed tab", str(error))
        return
    boss.close_tab_no_confirm(tab)


def tab_for_id(boss: Any, tab_id: int) -> Any | None:
    return next((tab for tab in boss.all_tabs if tab.id == tab_id), None)


def close_tab(boss: Any, target_window_id: int) -> None:
    from kitty.fast_data_types import get_options

    window = boss.window_id_map.get(target_window_id) or boss.window_for_dispatch or boss.active_window
    tab = window.tabref() if window is not None else None
    if tab is None:
        return

    # Mirror Boss.confirm_tab_close: preserve Kitty's running-process prompt before logging.
    msg, running = boss.close_windows_with_confirmation_msg(tab, tab.active_window)
    threshold = get_options().confirm_os_window_close[0]
    count = running if threshold < 0 else len(tab)
    if threshold == 0 or count < abs(threshold):
        record_and_close(boss, tab)
        return

    if tab is not boss.active_tab:
        tm = tab.tab_manager_ref()
        if tm is not None:
            tm.set_active_tab(tab)
    if tab.confirm_close_window_id and tab.confirm_close_window_id in boss.window_id_map:
        confirmation = boss.window_id_map[tab.confirm_close_window_id]
        if confirmation in tab:
            tab.set_active_window(confirmation)
            return

    def confirmed(allowed: bool, tab_id: int) -> None:
        current = tab_for_id(boss, tab_id)
        if current is None:
            return
        current.confirm_close_window_id = 0
        if allowed:
            record_and_close(boss, current)

    detail = msg or f"It has {count} windows."
    confirmation = boss.confirm(
        f"Are you sure you want to close this tab? {detail}",
        confirmed,
        tab.id,
        window=tab.active_window,
        title="Close tab?",
    )
    tab.confirm_close_window_id = confirmation.id


def latest_record(boss: Any, os_window_id: int) -> ClosedTabRecord | None:
    try:
        with open(history_path(), "rb") as history:
            fcntl.flock(history.fileno(), fcntl.LOCK_SH)
            lines = history.readlines()
    except OSError:
        return None
    used = consumed_ids(boss)
    current_instance_id = instance_id(boss)
    for raw in reversed(lines):
        with suppress(UnicodeDecodeError, json.JSONDecodeError, TypeError):
            data = json.loads(raw)
            if not isinstance(data, dict):
                continue
            record_id = data.get("closed_tab_id")
            if (
                data.get("version") == 1
                and data.get("event") == "closed"
                and data.get("kitty_instance_id") == current_instance_id
                and data.get("os_window_id") == os_window_id
                and isinstance(record_id, str)
                and record_id not in used
                and isinstance(data.get("session"), str)
            ):
                return cast(ClosedTabRecord, data)
    return None


def reopen_tab(boss: Any, target_window_id: int) -> None:
    from kitty.fast_data_types import get_options
    from kitty.session import parse_session

    window = boss.window_id_map.get(target_window_id) or boss.window_for_dispatch or boss.active_window
    tab = window.tabref() if window is not None else None
    tm = tab.tab_manager_ref() if tab is not None else None
    if tm is None:
        return
    record = latest_record(boss, tm.os_window_id)
    if record is None:
        boss.ring_bell_if_allowed(tm.os_window_id)
        return
    try:
        sessions = tuple(parse_session(record["session"], get_options()))
        if len(sessions) != 1 or len(sessions[0].tabs) != 1:
            raise ValueError("history entry must contain exactly one tab")
        previous_ids = {candidate.id for candidate in tm.tabs}
        tm.add_tabs_from_session(sessions[0])
        added = [candidate for candidate in tm.tabs if candidate.id not in previous_ids]
        if len(added) != 1:
            raise ValueError("history entry did not create exactly one tab")
        restored = added[0]
        current_index = tm.tabs.index(restored)
        target_index = max(0, min(record.get("tab_index", current_index), len(tm.tabs) - 1))
        while current_index > target_index:
            tm.swap_tabs(current_index, current_index - 1)
            current_index -= 1
        tm.set_active_tab(restored)
    except Exception as error:
        boss.show_error("Failed to reopen closed tab", str(error))
        return
    consumed_ids(boss).add(record["closed_tab_id"])


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Any) -> None:
    action = args[1] if len(args) > 1 else ""
    if action == "close":
        close_tab(boss, target_window_id)
    elif action == "reopen":
        reopen_tab(boss, target_window_id)
    else:
        boss.show_error("reopen_closed_tab", f"Unknown action: {action or '(missing)'}")
