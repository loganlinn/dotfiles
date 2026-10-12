"""Run with Kitty +runpy to exercise its real launch argument parser."""

import importlib.util
import io
import json
import os
import shlex
from pathlib import Path
from types import SimpleNamespace as NS
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / "config/kitty" / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


vars_hook = load("codex_user_vars", "codex-user-vars.py")
fork = load("kitty_fork", "fork.py")


class SessionVarsTests(unittest.TestCase):
    env = {"KITTY_LISTEN_ON": "unix:/tmp/kitty-test", "KITTY_WINDOW_ID": "42"}

    def payload(self, event="SessionStart", **fields):
        return dict(session_id="session-123", hook_event_name=event,
                    cwd="/tmp/space and $(literal)", model="test-model",
                    permission_mode="default", transcript_path="/tmp/history.jsonl", **fields)

    def test_start_targets_origin_and_preserves_literal_metadata(self):
        cmd = vars_hook.command(self.payload(), self.env)
        self.assertEqual(cmd[:7], ["kitten", "@", "--to", "unix:/tmp/kitty-test",
                                   "set-user-vars", "--match", "id:42"])
        self.assertIn("CODEX_CWD=/tmp/space and $(literal)", cmd)
        self.assertIn("CODEX_SESSION_ID=session-123", cmd)
        self.assertIn("CODEX_MODEL=test-model", cmd)
        self.assertFalse(any(value.startswith("CLAUDE_") for value in cmd))

    def test_prompt_refresh_does_not_overwrite_another_session(self):
        cmd = vars_hook.command(self.payload("UserPromptSubmit"), self.env)
        self.assertEqual(cmd[6], "id:42 and (not var:CODEX_SESSION_ID or var:CODEX_SESSION_ID=^session-123$)")

    def test_end_removes_current_fields_and_retains_previous_with_ownership_check(self):
        cmd = vars_hook.command(self.payload("SessionEnd"), self.env)
        self.assertEqual(cmd[6], "id:42 and var:CODEX_SESSION_ID=^session-123$")
        self.assertEqual(cmd[7:], ["CODEX_SESSION_ID", *vars_hook.FIELDS,
                                   "CODEX_PREV_SESSION_ID=session-123"])

    def test_subagents_non_lifecycle_events_and_missing_context_do_nothing(self):
        for payload in [self.payload(agent_id="child"), self.payload("SubagentStart"),
                        self.payload("Stop"), self.payload("Interrupt"), [], {}]:
            self.assertIsNone(vars_hook.command(payload, self.env))
        for env in [{}, {**self.env, "KITTY_WINDOW_ID": "0"},
                    {**self.env, "KITTY_WINDOW_ID": "-1"},
                    {**self.env, "KITTY_WINDOW_ID": "42 or all"}]:
            self.assertIsNone(vars_hook.command(self.payload(), env))

    def test_absent_metadata_clears_stale_values_and_invalid_session_is_ignored(self):
        p = self.payload()
        p["model"] = p["transcript_path"] = None
        self.assertIn("CODEX_MODEL", vars_hook.command(p, self.env))
        self.assertIn("CODEX_TRANSCRIPT_PATH", vars_hook.command(p, self.env))
        p["session_id"] = ".* or all"
        self.assertIsNone(vars_hook.command(p, self.env))

    def test_main_is_silent_on_invalid_input_or_unavailable_kitty(self):
        for raw in ["invalid", json.dumps(self.payload())]:
            with patch.dict(os.environ, self.env), patch("sys.stdin", io.StringIO(raw)), \
                 patch("sys.stdout", io.StringIO()) as stdout, \
                 patch.object(vars_hook.subprocess, "run", side_effect=OSError):
                vars_hook.main()
                self.assertEqual(stdout.getvalue(), "")


class ForkTests(unittest.TestCase):
    def test_codex_fork_preserves_settings_without_replaying_session_or_prompt(self):
        self.assertEqual(fork._codex_fork_command([
            "/bin/codex", "-p", "work", "resume", "--last", "--all", "--worktree",
            "--config", 'model="test"', "old-id", "old prompt", "--model=test-model",
            "--cd", "/old", "--image", "old.png", "--search", "--no-daemon",
        ], "current-id"), [
            "/bin/codex", "fork", "current-id", "-p", "work", "--config",
            'model="test"', "--model=test-model", "--search", "--no-daemon",
        ])

    def test_wrappers_attached_options_and_end_of_options(self):
        self.assertEqual(fork._codex_fork_command([
            "node", "/pkg/codex.js", "-mtest", "-pwork", "--", "--search",
        ], "current-id"), ["node", "/pkg/codex.js", "fork", "current-id", "-mtest", "-pwork"])
        self.assertEqual(fork._agent_command(["node", "/pkg/claude-code/cli.js"]), ("claude", 2))
        self.assertEqual(fork._agent_command(["zsh"]), (None, 0))

    def test_claude_flags_keep_original_behavior(self):
        self.assertEqual(fork._strip_session_flags([
            "claude", "--model", "test", "--resume=old", "--session-id", "old",
            "--fork-session", "--continue", "--permission-mode", "default",
        ]), ["claude", "--model", "test", "--permission-mode", "default"])

    def window(self, agent="codex", vars=None):
        proc = dict(cmdline=[agent, "--model", "test"], cwd="/process/cwd")
        return NS(id=42, user_vars=vars or {}, child=NS(foreground_processes=[proc], pid=None,
                  foreground_environ={"FROM_PROCESS": "current"}, environ={"FROM_LAUNCH": "original"}),
                  cwd_of_child="/fallback", tabref=lambda: "source-tab")

    def test_codex_launch_uses_foreground_agent_even_with_stale_claude_var(self):
        w = self.window(vars={"CODEX_SESSION_ID": "parent", "CODEX_CWD": "/session/cwd",
                              "CLAUDE_SESSION_ID": "stale"})
        boss = NS(window_id_map={42: w}, show_error=Mock())
        with patch("kitty.launch.launch") as launch:
            fork.handle_result(["fork.py"], "", 42, boss)
        opts = launch.call_args.args[1]
        self.assertEqual(opts.cwd, "/session/cwd")
        self.assertEqual(opts.add_to_session, ".")
        self.assertEqual(opts.source_window, "id:42")
        self.assertEqual(opts.next_to, "id:42")
        self.assertEqual(opts.var, [])
        self.assertEqual(launch.call_args.args[2], ["codex", "fork", "parent", "--model", "test"])
        self.assertEqual(launch.call_args.kwargs, {"target_tab": "source-tab", "rc_from_window": w})
        boss.show_error.assert_not_called()

    def test_claude_fork_still_preseeds_new_id(self):
        w = self.window("claude", {"CLAUDE_SESSION_ID": "parent"})
        boss = NS(window_id_map={42: w}, show_error=Mock())
        with patch("kitty.launch.launch") as launch, patch.object(fork.uuid, "uuid4", return_value="new-id"):
            fork.handle_result(["fork.py"], "", 42, boss)
        self.assertEqual(launch.call_args.args[1].var, ["CLAUDE_SESSION_ID=new-id"])
        self.assertEqual(launch.call_args.args[2][-5:],
                         ["--resume", "parent", "--fork-session", "--session-id", "new-id"])

    def test_missing_session_cannot_launch_a_picker(self):
        boss = NS(window_id_map={42: self.window()}, show_error=Mock())
        with patch("kitty.launch.launch") as launch:
            fork.handle_result(["fork.py"], "", 42, boss)
        launch.assert_not_called()
        boss.show_error.assert_called_once()

    def shell_window(self, name="zsh", *, at_prompt=True, secondary=False):
        w = self.window(name, {"CODEX_SESSION_ID": "stale-agent-id"})
        w.at_prompt = at_prompt
        lines = ["\x1b]133;A\x07prompt", "pending input"]
        if secondary:
            lines[1] = "\x1b]133;A;k=s\x07continuation input"
        w.screen = NS(cursor=NS(y=1), line=lambda y: NS(as_ansi=lambda: lines[y]))
        w.write_to_child = Mock()
        w.paste_text = Mock()
        return w

    def test_zsh_prompt_uses_native_clone_without_losing_pending_input(self):
        w = self.shell_window("-zsh")
        boss = NS(window_id_map={42: w}, show_error=Mock())
        calls = Mock()
        calls.attach_mock(w.write_to_child, "write")
        calls.attach_mock(w.paste_text, "paste")
        with patch("kitty.launch.launch") as launch:
            fork.handle_result(["fork.py", "--type=tab", "--title", "a 'quoted' title"], "", 42, boss)
        launch.assert_not_called()
        self.assertEqual([c[0] for c in calls.mock_calls], ["write", "paste", "write"])
        self.assertEqual(w.write_to_child.call_args_list[0].args, ("\x1bQ",))
        self.assertEqual(w.write_to_child.call_args_list[1].args, ("\r",))
        self.assertEqual(shlex.split(w.paste_text.call_args.args[0]), [
            "clone-in-kitty", "--type=window", "--add-to-session=.",
            "--type=tab", "--title", "a 'quoted' title",
        ])
        boss.show_error.assert_not_called()

    def test_busy_programs_other_shells_and_secondary_prompts_get_sibling_shell(self):
        for w in (self.shell_window("nvim", at_prompt=False),
                  self.shell_window("zsh", at_prompt=False),
                  self.shell_window("bash"), self.shell_window(secondary=True)):
            with self.subTest(window=w):
                boss = NS(window_id_map={42: w}, show_error=Mock())
                with patch("kitty.launch.launch") as launch:
                    fork.handle_result(["fork.py", "--type=tab"], "", 42, boss)
                opts = launch.call_args.args[1]
                self.assertEqual(opts.type, "tab")
                self.assertEqual(opts.cwd, "current")
                self.assertEqual(opts.source_window, "id:42")
                self.assertEqual(opts.add_to_session, ".")
                self.assertTrue(opts.copy_env)
                self.assertEqual(launch.call_args.args[2], [])
                self.assertEqual(launch.call_args.kwargs["base_env"], {"FROM_PROCESS": "current"})
                w.write_to_child.assert_not_called()
                w.paste_text.assert_not_called()
                boss.show_error.assert_not_called()

    def test_unreadable_process_environment_uses_original_launch_environment(self):
        w = self.shell_window("sleep", at_prompt=False)
        w.child.foreground_environ = {}
        boss = NS(window_id_map={42: w}, show_error=Mock())
        with patch("kitty.launch.launch") as launch:
            fork.handle_result(["fork.py"], "", 42, boss)
        self.assertEqual(launch.call_args.kwargs["base_env"], {"FROM_LAUNCH": "original"})

    def test_custom_claude_launch_options_retain_new_session_id(self):
        w = self.window("claude", {"CLAUDE_SESSION_ID": "parent"})
        boss = NS(window_id_map={42: w}, show_error=Mock())
        with patch("kitty.launch.launch") as launch, patch.object(fork.uuid, "uuid4", return_value="new-id"):
            fork.handle_result(["fork.py", "--type=tab"], "", 42, boss)
        opts = launch.call_args.args[1]
        self.assertEqual(opts.type, "tab")
        self.assertEqual(opts.var, ["CLAUDE_SESSION_ID=new-id"])
        self.assertTrue(opts.copy_env)


if __name__ == "__main__":
    unittest.main()
