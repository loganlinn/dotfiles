"""Run with installed Kitty +runpy, as in test_kitty_git_context.py."""

import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path
from types import MethodType, SimpleNamespace
from unittest.mock import Mock, patch

from kittens.hints.main import Mark, parse_hints_args


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("file_hints", ROOT / "config/kitty/file_hints.py")
file_hints = importlib.util.module_from_spec(spec)
spec.loader.exec_module(file_hints)


class FileHintsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="kitty-file-hints-")
        self.addCleanup(self.temporary.cleanup)
        self.cwd = Path(self.temporary.name)
        previous = Path.cwd()
        os.chdir(self.cwd)
        self.addCleanup(os.chdir, previous)
        self.options, _ = parse_hints_args(["--type=regex"])
        self.window = Mock()
        self.boss = SimpleNamespace(window_id_map={7: self.window})

    def marks(self, text, kind="regex"):
        self.options.type = kind
        marks = list(file_hints.mark(text, self.options, Mark, []))
        for item in marks:
            self.assertEqual(
                text[item.start:item.end].replace("\r", "").replace("\0", ""), item.text
            )
        return marks

    def matches(self, text, kind="regex"):
        return [item.text for item in self.marks(text, kind)]

    def data(self, *matches, programs=None):
        return {
            "customize_processing": "file_hints.py",
            "type": "regex",
            "match": list(matches),
            "groupdicts": [{} for _ in matches],
            "cwd": str(self.cwd),
            "programs": programs or [],
            "multiple_joiner": "auto",
            "extra_cli_args": [],
        }

    def test_screenshot_trims_unmatched_parenthesis_and_period(self):
        path = "output/cubesandbox-prod-green-promotion-20261006/session-inspection/analysis.md"
        text = f"Full investigation and evidence {path}). No production changes made."
        self.assertEqual(self.matches(text), [path])

    def test_prose_markdown_and_balanced_parentheses(self):
        self.assertEqual(
            self.matches("(docs/report.md). [Read more](docs/design(v2).md). docs/draft.md, README.md!"),
            ["docs/report.md", "docs/design(v2).md", "docs/draft.md", "README.md"],
        )
        self.assertEqual(self.matches("docs/(draft).md docs/name(v2).md"),
                         ["docs/(draft).md", "docs/name(v2).md"])

    def test_preserves_existing_filename_punctuation(self):
        for name in ("draft.md.", "draft.md)", "(draft).md"):
            (self.cwd / name).touch()
            self.assertEqual(self.matches(name), [name])

    def test_quoted_paths_with_spaces_and_literal_punctuation(self):
        for quote, closing in (("`", "`"), ('"', '"'), ("'", "'"), ("“", "”")):
            self.assertEqual(self.matches(f"See {quote}docs/a file(v2).md{closing}."),
                             ["docs/a file(v2).md"])
        self.assertEqual(self.matches('"draft.md."'), ["draft.md."])

    def test_urls_preserve_balanced_parentheses_and_query_strings(self):
        self.assertEqual(
            self.matches("https://example.com/wiki/Title_(detail)). https://example.com/?a=1&b=2."),
            ["https://example.com/wiki/Title_(detail)", "https://example.com/?a=1&b=2"],
        )

    def test_apostrophes_inside_filenames_and_urls(self):
        self.assertEqual(self.matches("docs/it's-a-file.md https://example.com/what's-new."),
                         ["docs/it's-a-file.md", "https://example.com/what's-new"])

    def test_path_mode_keeps_urls_out_of_copy_hints(self):
        self.assertEqual(self.matches("docs/file.md https://example.com/page", "path"), ["docs/file.md"])

    def test_soft_wraps_padding_and_unicode_keep_correct_offsets(self):
        self.assertEqual(self.matches("évidence docs/lo\0\rnger/日本語.md).\0\0\nnext"),
                         ["docs/longer/日本語.md"])
        self.assertEqual(self.matches("docs/first.md\0\nsecond.md"), ["docs/first.md", "second.md"])

    def test_plain_prose_and_short_tokens_are_not_hinted(self):
        self.assertEqual(self.matches("Here is some prose, and version 3."), [])

    def test_open_resolves_paths_against_source_window_cwd(self):
        relative = "docs/a #100%.md"
        data = self.data(relative)
        file_hints.handle_result([], data, 7, self.boss, [])
        self.window.open_url.assert_called_once_with(
            (self.cwd / relative).as_uri(), hyperlink_id=1, cwd=str(self.cwd)
        )

    def test_home_paths_and_urls(self):
        with patch.dict(os.environ, {"HOME": str(self.cwd)}):
            file_hints.handle_result([], self.data("~/README.md", "https://example.com/a.md"), 7, self.boss, [])
        self.assertEqual(self.window.open_url.call_args_list[0].args, ((self.cwd / "README.md").as_uri(),))
        self.assertEqual(self.window.open_url.call_args_list[1].args, ("https://example.com/a.md",))

    def test_closed_window_and_cancel_do_nothing(self):
        file_hints.handle_result([], self.data(""), 7, self.boss, [])
        file_hints.handle_result([], self.data("README.md"), 999, self.boss, [])
        self.window.open_url.assert_not_called()

    def test_copy_and_paste_use_kitty_handlers_without_opening(self):
        data = self.data("docs/report.md", programs=["-", "@"])
        with patch("kittens.hints.main.set_clipboard_string") as clipboard:
            file_hints.handle_result([], data, 7, self.boss, [])
        self.window.paste_text.assert_called_once_with("docs/report.md")
        clipboard.assert_called_once_with("docs/report.md")
        self.window.open_url.assert_not_called()

    @unittest.skipUnless(shutil.which("pandoc"), "Pandoc is required for the render check")
    def test_installed_kitty_marking_dispatch_and_real_render(self):
        from kittens.hints.main import handle_result, load_custom_processor
        from kitty.boss import Boss
        from kitty.config import load_config
        from kitty.constants import kitty_exe
        from kitty.fast_data_types import set_options
        from kitty.launch import parse_launch_args
        from kitty.window import Window

        source = self.cwd / "docs/README.md"
        source.parent.mkdir()
        source.write_text("# Kitty hints rendered this\n")
        sample = "Evidence docs/README.md). See https://example.com/review."
        env = dict(os.environ)
        env.pop("KITTY_DEVELOP_FROM", None)
        result = subprocess.run(
            [kitty_exe(), "+runpy", "from kittens.hints.main import custom_marking; custom_marking()",
             "--type=regex", "--customize-processing", str(ROOT / "config/kitty/file_hints.py")],
            input=sample, env=env, text=True, capture_output=True, check=True, timeout=10,
        )
        marks = json.loads(result.stdout)
        self.assertEqual([item["text"] for item in marks], ["docs/README.md", "https://example.com/review"])
        self.assertIn("mark", load_custom_processor("file_hints.py"))

        set_options(load_config(str(ROOT / "config/kitty/kitty.common.conf")))
        self.addCleanup(set_options, None)
        window = SimpleNamespace(open_url_handler=None)
        window.open_url = MethodType(Window.open_url, window)
        boss = SimpleNamespace(window_id_map={7: window}, dispatch_action=Mock(),
                               drain_actions=Mock(), listening_on=None)
        boss.open_url = MethodType(Boss.open_url, boss)
        with patch("kitty.window.get_boss", return_value=boss), patch("kitty.boss.open_url") as browser:
            handle_result([], self.data(*(item["text"] for item in marks)), 7, boss)
        browser.assert_called_once()
        self.assertEqual(browser.call_args.args[0], "https://example.com/review")
        action = boss.dispatch_action.call_args.args[0]
        self.assertEqual(action.func, "launch")
        options, command = parse_launch_args(action.args)
        self.assertEqual(options.type, "background")
        self.assertEqual(command, [str(ROOT / "bin/mdpreview"), "--", str(source)])

        # Test Kitty dispatch independently of mdpreview's dependency lookup.
        pandoc = Path(shutil.which("pandoc")).resolve()
        env.update(HOME=str(self.cwd / "home"), PATH=f"{pandoc.parent}:/usr/bin:/bin")
        result = subprocess.run(
            [command[0], "--no-open", *command[1:]], env=env,
            text=True, capture_output=True, check=True, timeout=30,
        )
        self.assertIn("Kitty hints rendered this", Path(result.stdout.strip()).read_text())


if __name__ == "__main__":
    unittest.main()
