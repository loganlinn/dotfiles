"""Run with: kitty +runpy 'import runpy; runpy.run_path("test/test_kitty_git_context.py", run_name="__main__")'."""

import importlib.util
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, patch


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("git_context", ROOT / "config/kitty/git_context.py")
git_context = importlib.util.module_from_spec(spec)
spec.loader.exec_module(git_context)


class GitContextTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="kitty git context ")
        cls.root = Path(cls.temp.name).resolve()
        cls.repo = cls.root / "repo with spaces"
        cls.repo.mkdir()
        cls.nested = cls.repo / "nested" / "dir"
        cls.nested.mkdir(parents=True)
        cls.git = git_context.which("git")
        cls.git_run("init", "--quiet", "--initial-branch=test-branch")
        cls.git_run("-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                    "-c", "commit.gpgsign=false", "commit", "--quiet", "--allow-empty", "-m", "fixture")
        cls.worktree = cls.root / "linked worktree"
        cls.git_run("worktree", "add", "--quiet", "-b", "linked-branch", str(cls.worktree))

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    @classmethod
    def git_run(cls, *args, cwd=None):
        return subprocess.run([cls.git, *args], cwd=cwd or cls.repo,
                              check=True, capture_output=True)

    def setUp(self):
        self.window = SimpleNamespace(id=1, child_is_remote=False, paste_text=Mock())
        self.other = SimpleNamespace(id=2, paste_text=Mock())
        self.manager = SimpleNamespace(create_notification_cmd=lambda: SimpleNamespace(),
                                       notify_with_command=Mock())
        self.boss = SimpleNamespace(window_id_map={1: self.window, 2: self.other},
                                    active_window=self.window,
                                    notification_manager=self.manager,
                                    run_background_process=Mock())
        self.cwd = str(self.nested)
        self.addCleanup(patch.stopall)
        patch.object(git_context, "CwdRequest", side_effect=lambda _: SimpleNamespace(cwd_of_child=self.cwd)).start()
        patch.object(git_context, "which", side_effect=lambda name: self.git if name == "git" else "/mock/gh").start()
        self.clipboard = patch.object(git_context, "set_clipboard_string").start()

    def invoke(self, action, field):
        git_context.handle_result(["git_context.py", action, field], None, 1, self.boss)

    def complete(self, stdout=None, stderr=b"", exit_code=0, error=None):
        args, kwargs = self.boss.run_background_process.call_args
        if error:
            # This is Kitty's documented-in-source descriptor ownership on failure.
            os.close(kwargs["stdout"])
            os.close(kwargs["stderr"])
            kwargs["notify_on_death"](-1, error)
        else:
            if stdout is None:
                cp = subprocess.run(args[0], cwd=kwargs["cwd"],
                                    stdout=kwargs["stdout"], stderr=kwargs["stderr"])
                exit_code = cp.returncode
            else:
                os.write(kwargs["stdout"], stdout)
                os.write(kwargs["stderr"], stderr)
            kwargs["notify_on_death"](exit_code << 8, None)
        for key in ("stdout", "stderr"):
            with self.assertRaises(OSError):
                os.fstat(kwargs[key])

    def assert_failed(self):
        self.window.paste_text.assert_not_called()
        self.clipboard.assert_not_called()
        self.manager.notify_with_command.assert_called_once()

    def test_real_git_paste_and_yank_values(self):
        for cwd, field, expected in (
            (self.repo, "branch", "test-branch"),
            (self.nested, "toplevel", str(self.repo)),
            (self.nested, "cdup", "../../"),
            (self.repo, "cdup", "./"),
            (self.worktree, "branch", "linked-branch"),
            (self.worktree, "toplevel", str(self.worktree)),
        ):
            for action in ("paste", "yank"):
                with self.subTest(cwd=cwd, field=field, action=action):
                    self.cwd = str(cwd)
                    self.invoke(action, field)
                    self.complete()
                    receiver = self.clipboard if action == "yank" else self.window.paste_text
                    receiver.assert_called_with(expected)
        self.manager.notify_with_command.assert_not_called()

    def test_delayed_paste_keeps_window_and_cwd(self):
        self.invoke("paste", "branch")
        self.window.paste_text.assert_not_called()
        self.boss.active_window = self.other
        self.cwd = str(self.worktree)
        self.complete()
        self.window.paste_text.assert_called_once_with("test-branch")
        self.other.paste_text.assert_not_called()

    def test_closed_window_discards_paste(self):
        self.invoke("paste", "branch")
        del self.boss.window_id_map[1]
        self.complete()
        self.window.paste_text.assert_not_called()
        self.other.paste_text.assert_not_called()

    def test_pr_json_and_open(self):
        for action, field, stdout, expected in (
            ("paste", "pr-number", b'{"number":123}\n', "123"),
            ("yank", "pr-url", b'{"url":"https://github.com/a/b/pull/123"}\n',
             "https://github.com/a/b/pull/123"),
        ):
            self.invoke(action, field)
            self.complete(stdout=stdout)
            receiver = self.clipboard if action == "yank" else self.window.paste_text
            receiver.assert_called_once_with(expected)
        self.window.paste_text.reset_mock()
        self.clipboard.reset_mock()
        self.invoke("open", "pr")
        args, kwargs = self.boss.run_background_process.call_args
        self.assertEqual(args[0][1:], ["pr", "view", "--web"])
        self.assertEqual(kwargs["env"]["GH_PROMPT_DISABLED"], "1")
        self.complete(stdout=b"")
        self.window.paste_text.assert_not_called()
        self.clipboard.assert_not_called()

    def test_gh_errors_preserve_input_and_clipboard(self):
        for detail in (b"no pull requests found", b"authentication required", b"network unavailable"):
            with self.subTest(detail=detail):
                self.manager.notify_with_command.reset_mock()
                self.invoke("yank", "pr-number")
                self.complete(stdout=b"", stderr=detail, exit_code=1)
                self.assert_failed()

    def test_invalid_pr_output_preserves_clipboard(self):
        for stdout in (b"not json", b"{}", b'{"number":true}', b'{"number":null}'):
            with self.subTest(stdout=stdout):
                self.manager.notify_with_command.reset_mock()
                self.invoke("yank", "pr-number")
                self.complete(stdout=stdout)
                self.assert_failed()

    def test_non_repository_and_detached_head(self):
        self.cwd = str(self.root)
        self.invoke("paste", "toplevel")
        self.complete()
        self.assert_failed()
        self.manager.notify_with_command.reset_mock()
        self.git_run("checkout", "--quiet", "--detach", cwd=self.worktree)
        try:
            self.cwd = str(self.worktree)
            self.invoke("paste", "branch")
            self.complete()
            self.assert_failed()
        finally:
            self.git_run("checkout", "--quiet", "linked-branch", cwd=self.worktree)

    def test_launch_failure_closes_files_and_notifies(self):
        self.invoke("paste", "branch")
        self.complete(error=FileNotFoundError("gone"))
        self.assert_failed()

    def test_missing_executable_remote_and_missing_cwd(self):
        with patch.object(git_context, "which", return_value=None):
            self.invoke("paste", "branch")
        self.assert_failed()
        self.manager.notify_with_command.reset_mock()
        self.window.child_is_remote = True
        self.invoke("paste", "branch")
        self.assert_failed()
        self.manager.notify_with_command.reset_mock()
        self.window.child_is_remote = False
        self.cwd = ""
        self.invoke("paste", "branch")
        self.assert_failed()
        self.boss.run_background_process.assert_not_called()

    def test_literal_whitespace_is_preserved(self):
        self.assertEqual(git_context.output_value("toplevel", b"/tmp/space at end \n"),
                         "/tmp/space at end ")


if __name__ == "__main__":
    unittest.main()
