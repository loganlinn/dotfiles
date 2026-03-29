"""Kitten: select a user_var name or value via hints and act on it.

All args are forwarded to hints (e.g. --program=@, --program=-).
Defaults to --program=@ (copy to clipboard) if not specified.

Each var produces two hints: one for the name, one for the value.
"""

from typing import List

from kittens.tui.handler import result_handler


def main(args: List[str]) -> str:
    pass


@result_handler(no_ui=True)
def handle_result(args: List[str], answer: str, target_window_id: int, boss) -> None:
    entries: dict[str, str] = {}
    for window in boss.all_windows:
        entries.update(window.user_vars)

    if not entries:
        return

    sorted_entries = sorted(entries.items())
    width = max(len(k) for k, _ in sorted_entries)

    # Two lines per var: key (padded) then value, blank line between groups
    lines = []
    for k, v in sorted_entries:
        lines.append(f"{k:<{width}}")
        lines.append(v)
        lines.append("")

    text = "\r\n".join(lines)

    # Forward all kitten args; default --program=@ if not specified
    hints_args = list(args[1:])
    if not any(a.startswith("--program") for a in hints_args):
        hints_args = ["--program=@"] + hints_args

    boss.run_kitten_with_metadata(
        "hints",
        args=["--type=line"] + hints_args,
        input_data=text.encode(),
    )
