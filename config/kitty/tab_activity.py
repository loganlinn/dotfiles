"""Kitty watcher entry point for native activity adapters."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
try:
    from kitty_activity_state import (
        ensure_timer, on_close, on_cmd_startstop, on_resize, on_title_change,
    )
finally:
    sys.path.pop(0)


def on_load(boss, data):
    ensure_timer(boss)
