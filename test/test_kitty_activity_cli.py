"""Run with uv run --no-project test/test_kitty_activity_cli.py."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("activity_hooks", ROOT / "lib/kitty_activity/hooks.py")
hooks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hooks)


class HooksTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def invoke(self, *args):
        with contextlib.redirect_stdout(io.StringIO()) as out, contextlib.redirect_stderr(io.StringIO()) as err:
            code = hooks.main(args)
        return code, out.getvalue(), err.getvalue()

    def test_mutating_commands_require_agent_before_accessing_configs(self):
        for action in ("install", "uninstall"):
            for flags in ((), ("--dry-run",), ("--preview",), ("--config-dir", str(self.root))):
                with self.subTest(action=action, flags=flags), \
                     contextlib.redirect_stdout(io.StringIO()) as out, \
                     contextlib.redirect_stderr(io.StringIO()) as err, \
                     patch.object(hooks, "plan") as plan, \
                     patch.object(hooks, "apply") as apply:
                    with self.assertRaises(SystemExit) as result:
                        hooks.main([action, *flags])
                    self.assertEqual(2, result.exception.code)
                    self.assertIn(f"usage: kitty-activity hooks {action}", err.getvalue())
                    self.assertIn("required", err.getvalue())
                    self.assertEqual("", out.getvalue())
                    plan.assert_not_called()
                    apply.assert_not_called()

    def test_install_uninstall_idempotent_preserves_user_changes_and_mode(self):
        for agent in ("claude", "codex"):
            path = self.root / agent / ("settings.json" if agent == "claude" else "hooks.json")
            path.parent.mkdir()
            original = {"custom": "kept", "hooks": {"Stop": [{"matcher": "custom", "hooks": [
                {"type": "command", "command": "echo user hook"}]}]}}
            path.write_text(json.dumps(original))
            path.chmod(0o640)
            flags = (agent, "--config-dir", str(path.parent))
            self.assertEqual(0, self.invoke("install", *flags)[0])
            first = path.read_bytes()
            mtime = path.stat().st_mtime_ns
            self.assertEqual(0, self.invoke("install", *flags)[0])
            self.assertEqual(first, path.read_bytes())
            self.assertEqual(mtime, path.stat().st_mtime_ns)
            self.assertEqual(0o640, path.stat().st_mode & 0o777)
            self.assertIn("installed", self.invoke("status", *flags)[1])
            edited = json.loads(first)
            edited["later"] = "preserved"
            path.write_text(json.dumps(edited))
            self.assertEqual(0, self.invoke("uninstall", *flags)[0])
            self.assertEqual({**original, "later": "preserved"}, json.loads(path.read_bytes()))
            removed = path.read_bytes()
            self.assertEqual(0, self.invoke("uninstall", *flags)[0])
            self.assertEqual(removed, path.read_bytes())

    def test_preview_creates_nothing_and_does_not_expose_user_content(self):
        missing = self.root / "missing"
        for agent in hooks.AGENTS:
            self.assertEqual(0, self.invoke("install", agent, "--config-dir", str(missing), "--preview")[0])
            self.assertFalse(missing.exists())
        file = self.root / "settings.json"
        file.write_text('{"apiKey": "SENSITIVE_TEST_VALUE"}')
        before = file.read_bytes()
        result = self.invoke("install", "claude", "--config-dir", str(self.root), "--dry-run")
        self.assertEqual(before, file.read_bytes())
        self.assertNotIn("SENSITIVE_TEST_VALUE", result[1])

    def test_symlink_is_retained_and_invalid_config_is_untouched(self):
        target = self.root / "actual.json"
        target.write_text('{}')
        link = self.root / "settings.json"
        link.symlink_to(target)
        self.assertEqual(0, self.invoke("install", "claude", "--config-dir", str(self.root))[0])
        self.assertTrue(link.is_symlink())
        self.assertIn("hooks", json.loads(target.read_bytes()))
        for bad in ("{", '{"hooks": []}', '{"hooks":{},"hooks":{}}', '{"hooks":{"Stop":[{}]}}'):
            target.write_text(bad)
            self.assertEqual(1, self.invoke("install", "claude", "--config-dir", str(self.root))[0])
            self.assertEqual(bad, target.read_text())

    def test_pi_install_uninstall_and_unowned_conflict(self):
        args = ("pi", "--config-dir", str(self.root))
        path = self.root / "extensions/kitty-activity.ts"
        self.assertEqual(0, self.invoke("install", *args)[0])
        first = path.read_bytes()
        self.assertEqual(0, self.invoke("install", *args)[0])
        self.assertEqual(first, path.read_bytes())
        self.assertEqual(0, self.invoke("uninstall", *args)[0])
        self.assertFalse(path.exists())
        self.assertEqual(0, self.invoke("uninstall", *args)[0])
        path.write_text("// user extension")
        self.assertEqual(1, self.invoke("install", *args)[0])
        self.assertEqual(1, self.invoke("uninstall", *args)[0])
        self.assertEqual("// user extension", path.read_text())

    def test_mixed_group_uninstall_removes_only_owned_handler(self):
        other = {"type": "command", "command": "echo keep"}
        data = {"hooks": {"Stop": [{"matcher": "x", "hooks": [other, {
            "type": "command", "command": hooks.command("claude")}]}]}}
        result, _ = hooks.transform(data, "claude", False)
        self.assertEqual({"hooks": {"Stop": [{"matcher": "x", "hooks": [other]}]}}, result)

    def test_all_preflights_configs_before_writing(self):
        env = {"CLAUDE_CONFIG_DIR": str(self.root / "claude"), "CODEX_HOME": str(self.root / "codex"),
               "PI_CODING_AGENT_DIR": str(self.root / "pi")}
        (self.root / "codex").mkdir()
        (self.root / "codex/hooks.json").write_text("invalid")
        with patch.dict(os.environ, env):
            self.assertEqual(1, self.invoke("install", "all")[0])
        self.assertFalse((self.root / "claude").exists())

    def test_state_mapping_and_subagent_isolation(self):
        for agent in ("claude", "codex"):
            for event, state in (("SessionStart", "idle"), ("UserPromptSubmit", "working"),
                                 ("PermissionRequest", "attention"), ("PostToolUse", "working"),
                                 ("Stop", "completed"), ("SessionEnd", "clear")):
                data = {"hook_event_name": event}
                self.assertEqual(state, hooks.event_state(agent, data))
                self.assertIsNone(hooks.event_state(agent, {**data, "agent_id": "child"}))
            for tool in ("AskUserQuestion", "functions.request_user_input"):
                self.assertEqual("attention", hooks.event_state(agent, {"hook_event_name": "PreToolUse", "tool_name": tool}))
        self.assertIsNone(hooks.event_state("claude", {"hook_event_name": "Notification", "notification_type": "auth_success"}))
        self.assertIsNone(hooks.event_state("codex", {"hook_event_name": "SubagentStop"}))

    def test_runtime_pins_instance_and_window_quietly(self):
        with patch.dict(os.environ, {"KITTY_LISTEN_ON": "unix:/tmp/one", "KITTY_WINDOW_ID": "17"}), \
             patch.object(sys, "stdin", io.StringIO('{"hook_event_name":"PermissionRequest"}')), \
             patch.object(hooks.subprocess, "run") as run:
            hooks.run_hook("codex")
            args = run.call_args.args[0]
            self.assertEqual(["kitten", "@", "kitten", "--to", "unix:/tmp/one"], args[:5])
            self.assertEqual(["event", "id:17", "17", "codex"], args[6:10])
            self.assertEqual({"hook_event_name":"PermissionRequest"}, json.loads(args[10]))
        with patch.dict(os.environ, {"KITTY_WINDOW_ID": ""}), patch.object(hooks.subprocess, "run") as run:
            hooks.run_hook("claude")
            run.assert_not_called()
        with patch.dict(os.environ, {"KITTY_LISTEN_ON": "x", "KITTY_WINDOW_ID": "17"}), \
             patch.object(sys, "stdin", io.StringIO('{"hook_event_name":"Stop"}')), \
             patch.object(hooks.subprocess, "run", side_effect=FileNotFoundError):
            hooks.run_hook("claude")  # Missing Kitty never fails the agent hook.


class CLITests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.capture = root / "capture"
        stub = root / "kitten"
        stub.write_text('#!/bin/bash\nprintf "%s\\n" "$@" > "$CAPTURE"\ncat > "$CAPTURE.stdin"\nexit "${STUB_EXIT:-0}"\n')
        stub.chmod(0o700)
        self.env = {**os.environ, "PATH": f"{root}:{os.environ['PATH']}", "CAPTURE": str(self.capture)}

    def cli(self, *args, input=""):
        return subprocess.run(["/bin/bash", str(ROOT / "bin/kitty-activity"), *args],
                              env=self.env, input=input, text=True, capture_output=True)

    def test_native_options_and_stdin_pass_through(self):
        result = self.cli("--to", "unix:/tmp/instance", "set", "attention", "-m", "state:self or id:42",
                          "--password-file", "-", "--password-env=RC_SECRET", "--use-password", "always", input="password\n")
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual(["@", "kitten", "--to", "unix:/tmp/instance",
                          "--password-file", "-", "--password-env=RC_SECRET", "--use-password", "always", str(ROOT / "lib/kitty_activity/bridge.py"), "attention", "state:self or id:42", self.env.get("KITTY_WINDOW_ID", "")], self.capture.read_text().splitlines())
        self.assertEqual("password\n", Path(f"{self.capture}.stdin").read_text())

    def test_native_defaults_clear_compatibility_and_remote_exit(self):
        self.assertEqual(0, self.cli("clear").returncode)
        self.assertEqual(["@", "kitten", str(ROOT / "lib/kitty_activity/bridge.py"), "clear", "", self.env.get("KITTY_WINDOW_ID", "")], self.capture.read_text().splitlines())
        self.assertEqual(0, self.cli("working", "--window-id", "3").returncode)
        self.assertIn("id:3", self.capture.read_text())
        self.env["STUB_EXIT"] = "7"
        self.assertEqual(7, self.cli("set", "idle").returncode)

    def test_status_routes_read_only_query_with_native_connection_options(self):
        self.env["KITTY_WINDOW_ID"] = "17"
        result = self.cli("status", "--match", "state:self or id:42", "--to", "unix:/tmp/one",
                          "--password-file", "-", input="password\n")
        self.assertEqual(0, result.returncode, result.stderr)
        self.assertEqual(["@", "kitten", "--to", "unix:/tmp/one", "--password-file", "-",
                          str(ROOT / "lib/kitty_activity/status.py"), "state:self or id:42", "17"],
                         self.capture.read_text().splitlines())
        self.assertEqual("password\n", Path(f"{self.capture}.stdin").read_text())

    def test_invalid_arguments_do_not_contact_kitty(self):
        for args in (("status", "clear"), ("status", "set"), ("set",), ("set", "clear"), ("set", "working", "idle"), ("set", "working", "--to"),
                     ("set", "idle", "--window-id=all"), ("set", "unknown"), ("set", "idle", "OTHER=value")):
            result = self.cli(*args)
            self.assertEqual(2, result.returncode, result.stderr)
            self.assertFalse(self.capture.exists())


if __name__ == "__main__":
    unittest.main()
