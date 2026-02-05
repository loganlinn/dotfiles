"""Custom kitty hints for selecting Claude Code chat messages.

Matches messages starting with ⏺ and continuing with 2-space indented lines.
"""

import re


def mark(text, args, Mark, extra_cli_args, *a):
    # Find message starts (⏺ at line beginning)
    starts = [m.start() for m in re.finditer(r"^⏺ ", text, re.MULTILINE)]
    if not starts:
        return

    for idx, start in enumerate(starts):
        # Find message end: next ⏺, or line not starting with 2 spaces (unless blank)
        # Scan line by line from after the first line
        first_newline = text.find("\n", start)
        if first_newline == -1:
            end = len(text)
        else:
            end = first_newline
            pos = first_newline + 1
            while pos < len(text):
                line_end = text.find("\n", pos)
                if line_end == -1:
                    line_end = len(text)
                line = text[pos:line_end]
                # Stop if: another message, or non-blank line without 2-space indent
                if line.startswith("⏺ "):
                    break
                if line and not line.startswith("  ") and line.strip():
                    break
                end = line_end
                pos = line_end + 1

        # Extract content (skip the ⏺ prefix)
        content = text[start + 2 : end]
        content = content.replace("\0", "")

        # Clean up: remove 2-space indent, preserve structure
        lines = content.split("\n")
        cleaned = []
        for line in lines:
            if line.startswith("  "):
                line = line[2:]
            cleaned.append(line.rstrip())
        mark_text = "\n".join(cleaned).strip()

        if mark_text:
            yield Mark(idx, start, end, mark_text, {})


def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    matches = [m for m in data["match"] if m]
    if not matches:
        return

    from kitty.clipboard import set_clipboard_string, set_primary_selection

    text = "\n\n".join(matches)
    programs = data.get("programs") or ("default",)

    for program in programs:
        if program == "-":
            w = boss.window_id_map.get(target_window_id)
            if w is not None:
                w.paste_text(text)
        elif program == "@":
            set_clipboard_string(text)
        elif program == "*":
            set_primary_selection(text)
        elif program.startswith("@"):
            boss.set_clipboard_buffer(program[1:], text)
        elif program == "default":
            boss.open_url(text)
        else:
            cwd = data.get("cwd")
            boss.open_url(text, program, cwd=cwd)
