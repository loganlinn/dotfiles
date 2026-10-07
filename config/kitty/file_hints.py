"""Hint prose paths and URLs; open through open-actions.conf or copy/paste.

Kitty's custom-marking API supplies text without terminal escape sequences.
Carriage returns and NUL padding mark soft wraps; newlines separate hard lines.
"""

import os
import re
from pathlib import Path


MARKDOWN_LINK = re.compile(r"!?\[[^\]\n]*\]\(")
TOKENS = re.compile(
    r'''(?:!?\[[^\]\n]*\]\()?(?:"[^"\n]+"|'[^'\n]+'|`[^`\n]+`|“[^”\n]+”|‘[^’\n]+’|[^\s<>"'`“”‘’][^\s<>"`“”‘’]*)'''
)
URL = re.compile(r"(?:[a-zA-Z][a-zA-Z0-9+.-]*://|mailto:)")
FILENAME = re.compile(r"[^/]+\.[a-zA-Z0-9]{1,16}$")
QUOTES = {'"': '"', "'": "'", "`": "`", "“": "”", "‘": "’"}
BRACKETS = {"(": ")", "[": "]", "{": "}"}
PUNCTUATION = ".,;:!?"


def exists(value):
    if URL.match(value):
        return False
    try:
        return Path(value).expanduser().exists()
    except (OSError, ValueError, RuntimeError):
        return False


def trim_span(text, start, end):
    if link := MARKDOWN_LINK.match(text, start, end):
        start = link.end()
    if start < end and QUOTES.get(text[start]) == text[end - 1]:
        # Explicit quotes disambiguate filenames with spaces or punctuation.
        return start + 1, end - 1
    while start < end:
        value = text[start:end]
        if exists(value):
            break
        first, last = value[0], value[-1]
        if last in PUNCTUATION:
            end -= 1
        elif last == "'" and value.count("'") % 2:
            end -= 1
        elif any(last == closing and value.count(closing) > value.count(opening)
                 for opening, closing in BRACKETS.items()):
            end -= 1
        elif first in BRACKETS and (
            last == BRACKETS[first] or value.count(first) > value.count(BRACKETS[first])
        ):
            start += 1
            if last == BRACKETS[first]:
                end -= 1
        elif first == last == "*":
            start += 1
            end -= 1
        else:
            break
    return start, end


def mark(text, args, Mark, extra_cli_args, *unused):
    # Match across soft wraps while keeping offsets in Kitty's original text.
    offsets = [i for i, char in enumerate(text) if char not in "\r\0"]
    plain = "".join(text[i] for i in offsets)
    index = 0
    for token in TOKENS.finditer(plain):
        start, end = trim_span(plain, *token.span())
        value = plain[start:end]
        if len(value) < args.minimum_match_length:
            continue
        if URL.match(value):
            if args.type == "path":
                continue
        elif not ("/" in value or FILENAME.fullmatch(value.rstrip(PUNCTUATION)) or exists(value)):
            continue
        yield Mark(index, offsets[start], offsets[end - 1] + 1, value, {})
        index += 1


def handle_result(args, data, target_window_id, boss, extra_cli_args, *unused):
    programs = data.get("programs") or ["default"]
    other_programs = [program for program in programs if program != "default"]
    if other_programs:
        from kittens.hints.main import handle_result as builtin_handler

        builtin_handler(args, {**data, "customize_processing": "", "programs": other_programs}, target_window_id, boss)
    if "default" not in programs:
        return
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    cwd = data["cwd"]
    for value in filter(None, data["match"]):
        if URL.match(value):
            url = value
        else:
            path = os.path.abspath(os.path.join(cwd, os.path.expanduser(value)))
            url = Path(path).as_uri()
        # The native hyperlink route applies open-actions.conf and handles
        # explicit remote file URLs, just like Kitty's hyperlink hints.
        window.open_url(url, hyperlink_id=1, cwd=cwd)
