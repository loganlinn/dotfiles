"""Run with Kitty +runpy to exercise its real launch argument parser."""

import importlib.util
import io
import json
import os
import shlex
import tempfile
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
    sid = "01a12e42-a881-7542-acf4-40dcc223c647"
    other = "01a12e42-b992-7542-acf4-40dcc223c648"

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        patcher = patch.object(vars_hook, "ROUTES", Path(self.tmp.name))
        patcher.start()
        self.addCleanup(patcher.stop)

    def payload(self, event="SessionStart", **fields):
        return dict(session_id=self.sid, hook_event_name=event,
                    cwd="/tmp/space and $(literal)", model="test-model",
                    permission_mode="default", transcript_path="/tmp/history.jsonl", **fields)

    def route(self, wid=42):
        return dict(endpoint="unix:/tmp/right-kitty", window_id=wid,
                    kitty_pid=os.getpid(), prefix=self.sid[:29])

    def window(self, wid=42, program="codex"):
        w = NS(id=wid, user_vars={}, child_title="project", title_updated=Mock(),
               child=NS(foreground_processes=[{"cmdline":[program]}]))
        def set_var(key, value):
            if value is None:
                w.user_vars.pop(key, None)
            else:
                w.user_vars[key] = value
        w.set_user_var = set_var
        return w

    def bind(self, w, sid=None):
        sid = sid or self.sid
        vars_hook.on_title_change(NS(listening_on="unix:/tmp/right-kitty"), w,
                                  {"from_child":True, "title":sid[:29]+"... | project"})

    def test_hook_uses_registered_endpoint_and_ownership_marker(self):
        cmd = vars_hook.command(self.payload(), self.route())
        self.assertEqual(cmd[:6], ["kitten", "@", "--to", "unix:/tmp/right-kitty", "set-user-vars", "--match"])
        self.assertEqual(cmd[6], f"id:42 and var:CODEX_SESSION_PREFIX=^{self.sid[:29]}$ and (not var:CODEX_SESSION_ID or var:CODEX_SESSION_ID=^{self.sid}$)")
        self.assertIn("CODEX_CWD=/tmp/space and $(literal)", cmd)
        self.assertIn(f"CODEX_SESSION_ID={self.sid}", cmd)

    def test_end_requires_full_session_ownership(self):
        cmd=vars_hook.command(self.payload("SessionEnd"), self.route())
        self.assertTrue(cmd[6].endswith(f"and var:CODEX_SESSION_ID=^{self.sid}$"))
        self.assertEqual(cmd[7:], ["CODEX_SESSION_ID", *vars_hook.FIELDS, f"CODEX_PREV_SESSION_ID={self.sid}"])

    def test_subagents_invalid_events_and_bad_routes_do_nothing(self):
        for payload in (self.payload(agent_id="child"), self.payload("Stop"), {}, []):
            self.assertIsNone(vars_hook.command(payload, self.route()))
        for route in ({}, {**self.route(),"window_id":0}, {**self.route(),"window_id":"42 or all"},
                      {**self.route(),"prefix":self.other[:29]}):
            self.assertIsNone(vars_hook.command(self.payload(), route))
        payload=self.payload()
        payload['session_id']='.* or all'
        self.assertIsNone(vars_hook.command(payload,self.route()))

    def test_absent_metadata_clears_stale_values(self):
        p=self.payload()
        p['model']=p['transcript_path']=None
        self.assertIn('CODEX_MODEL',vars_hook.command(p,self.route()))
        self.assertIn('CODEX_TRANSCRIPT_PATH',vars_hook.command(p,self.route()))

    def test_native_title_binds_route_and_preserves_visible_title(self):
        w=self.window()
        self.bind(w)
        self.assertEqual(w.child_title,'project')
        self.assertEqual(w.user_vars,{'CODEX_SESSION_PREFIX':self.sid[:29]})
        self.assertEqual(list(vars_hook.routes_for(self.payload())),[self.route()])
        w.title_updated.assert_called_once()

    def test_full_uuid_attention_titles_and_title_overrides(self):
        w=self.window()
        vars_hook.on_title_change(NS(listening_on='unix:/tmp/right-kitty'),w,
            {'from_child':True,'title':f'Action Required: {self.sid} | project'})
        self.assertEqual(w.child_title,'Action Required: project')
        vars_hook.on_title_change(None,w,{'from_child':False,'title':'manual title'})
        self.assertEqual(len(list(vars_hook.routes_for(self.payload()))),1)

    def test_unrelated_foreground_program_cannot_register_a_route(self):
        w=self.window(program='vim')
        self.bind(w)
        self.assertEqual(list(vars_hook.routes_for(self.payload())),[])
        self.assertEqual(w.user_vars,{})

    def test_session_switch_removes_old_route_and_metadata(self):
        w=self.window()
        self.bind(w)
        w.user_vars.update(CODEX_SESSION_ID=self.sid,CODEX_MODEL='old',CODEX_CWD='/old')
        self.bind(w,self.other)
        self.assertEqual(list(vars_hook.routes_for(self.payload())),[])
        self.assertEqual(w.user_vars,{'CODEX_SESSION_PREFIX':self.other[:29], 'CODEX_PREV_SESSION_ID':self.sid})

    def test_shell_return_and_window_close_remove_routes(self):
        for event in (vars_hook.on_cmd_startstop,vars_hook.on_close):
            w=self.window()
            self.bind(w)
            w.user_vars['CODEX_SESSION_ID']=self.sid
            event(None,w,{})
            self.assertEqual(w.user_vars,{'CODEX_PREV_SESSION_ID':self.sid})
            self.assertEqual(list(vars_hook.routes_for(self.payload())),[])

    def test_two_sessions_in_same_project_do_not_cross_route(self):
        a,b=self.window(),self.window(43)
        self.bind(a)
        self.bind(b,self.other)
        self.assertEqual([r['window_id'] for r in vars_hook.routes_for(self.payload())],[42])
        p={**self.payload(),'session_id':self.other}
        self.assertEqual([r['window_id'] for r in vars_hook.routes_for(p)],[43])

    def test_same_session_can_be_open_in_multiple_windows(self):
        self.bind(self.window())
        self.bind(self.window(43))
        self.assertEqual(sorted(r['window_id'] for r in vars_hook.routes_for(self.payload())),[42,43])

    def test_daemon_environment_is_ignored_even_when_wrong_or_missing(self):
        self.bind(self.window())
        for env in ({}, {'KITTY_WINDOW_ID':'2','KITTY_LISTEN_ON':'unix:/tmp/wrong'}):
            with patch.dict(os.environ,env,clear=True), patch('sys.stdin',io.StringIO(json.dumps(self.payload()))), \
                 patch.object(vars_hook.subprocess,'run',return_value=NS(returncode=0)) as run:
                vars_hook.main()
            self.assertEqual(run.call_args.args[0][3],'unix:/tmp/right-kitty')
            self.assertTrue(run.call_args.args[0][6].startswith('id:42 and '))

    def test_unregistered_sessions_never_fall_back_to_daemon_window(self):
        with patch.dict(os.environ,{'KITTY_WINDOW_ID':'2','KITTY_LISTEN_ON':'unix:/tmp/wrong'}), \
             patch('sys.stdin',io.StringIO(json.dumps(self.payload()))), \
             patch.object(vars_hook.time,'sleep'), patch.object(vars_hook.subprocess,'run') as run:
            vars_hook.main()
        run.assert_not_called()

    def test_failed_kitty_update_is_visible_on_stderr_without_model_context(self):
        self.bind(self.window())
        with patch('sys.stdin',io.StringIO(json.dumps(self.payload()))), \
             patch('sys.stdout',io.StringIO()) as out, patch('sys.stderr',io.StringIO()) as err, \
             patch.object(vars_hook.subprocess,'run',return_value=NS(returncode=1,stderr='No matching windows')):
            vars_hook.main()
        self.assertEqual(out.getvalue(),'')
        self.assertIn('No matching windows',err.getvalue())


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
