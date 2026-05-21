"""Open ssh sessions to multiple hosts in a new OS window with the
broadcast kitten enabled by default.

Invoke from a kitty mapping:

    map kitty_mod+space>s>c kitten cssh.py host1 host2

Or from a shell inside kitty (remote control):

    kitten @ kitten cssh.py [--no-broadcast] [-o "ssh args"] host ...
"""

from __future__ import annotations

import argparse
import shlex

from kittens.tui.handler import result_handler


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss
) -> None:
    parser = argparse.ArgumentParser(prog="cssh", add_help=False)
    parser.add_argument(
        "--broadcast",
        action=argparse.BooleanOptionalAction,
        default=True,
    )
    # csshX/cssh use -o/--options; tmux-cssh uses -sa/--ssh_args. Expose
    # --ssh-args (plus -o for muscle memory).
    parser.add_argument("-o", "--ssh-args", default="")
    parser.add_argument("hosts", nargs="+")
    try:
        opts = parser.parse_args(args[1:])
    except SystemExit:
        boss.show_error("cssh", "usage: cssh.py [--no-broadcast] [-o ARGS] host ...")
        return

    extra = shlex.split(opts.ssh_args)
    targets = [_normalize(t, boss) for t in opts.hosts]
    first, *rest = targets

    from kitty.launch import launch, parse_launch_args

    title = "ssh: " + ", ".join(targets)
    spec, _ = parse_launch_args([
        "--type=os-window",
        f"--os-window-title={title}",
        f"--tab-title={first}",
        "--copy-env",
    ])
    new_window = launch(boss, spec, ["ssh", *extra, first])
    if new_window is None:
        boss.show_error("cssh", f"failed to open window for {first}")
        return
    target_tab = new_window.tabref()

    for t in rest:
        spec, _ = parse_launch_args([
            "--type=window",
            f"--tab-title={t}",
            "--copy-env",
        ])
        launch(boss, spec, ["ssh", *extra, t], target_tab=target_tab)

    if opts.broadcast:
        spec, _ = parse_launch_args([
            "--type=overlay-main",
            "--allow-remote-control",
        ])
        launch(
            boss,
            spec,
            ["kitten", "broadcast", "--match-tab", f"window_id:{new_window.id}"],
            target_tab=target_tab,
        )


def _normalize(target: str, boss) -> str:
    # openssh has no inline-password syntax; strip ":password" and warn.
    if "@" not in target:
        return target
    user_part, host = target.split("@", 1)
    if ":" not in user_part:
        return target
    user, _password = user_part.split(":", 1)
    boss.show_error(
        "cssh",
        f"password in {target!r} ignored (use ssh keys or sshpass)",
    )
    return f"{user}@{host}"
