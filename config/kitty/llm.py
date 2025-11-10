#!/usr/bin/env python3

import json
import sys
from pprint import pprint

from kittens.tui.handler import kitten_ui
from kittens.tui.loop import debug


@kitten_ui(allow_remote_control=True)
def main(args: list[str]) -> str:
    debug("HI")
    cp = main.remote_control(["ls"], capture_output=True)
    pprint(cp)
    if cp.returncode != 0:
        sys.stderr.buffer.write(cp.stderr)
        raise SystemExit(cp.returncode)
    output = json.loads(cp.stdout)
    pprint(output)
    # open a new tab with a title specified by the user
    title = input("Enter the name of tab: ")
    window_id = main.remote_control(
        ["launch", "--type=tab", "--tab-title", title], check=True, capture_output=True
    ).stdout.decode()
    return window_id


# def handle_result(
#     args: list[str], answer: str, target_window_id: int, boss: Boss
# ) -> None:
#     pprint(boss.window_id_map)
