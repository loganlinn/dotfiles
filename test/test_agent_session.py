"""Behavioral regressions for session routing, discovery, and transcript handling.

Run: uv run --no-project python -m unittest discover -s test -p test_agent_session.py
Kitty API cases: kitty +runpy 'import runpy; runpy.run_path("test/test_agent_session.py", run_name="__main__")'
"""

import importlib.util
from contextlib import closing
import io
import json
import os
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace as NS
import unittest
from unittest.mock import Mock, patch

try:
    import sqlite3
except ImportError:
    sqlite3 = None

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "config/kitty" / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    with patch.object(sys, "path", [str(ROOT / "config/kitty"), *sys.path]):
        spec.loader.exec_module(module)
    return module


session = load("agent_session")
hints = load("session_hints")
try:
    native = load("session_links")
except ImportError:
    native = None

SID = "01a146dc-e00d-76a3-ae6e-65169da8a47a"
OTHER = "01a146dc-e00d-76a3-ae6e-65169da8a47b"
URI = f"codex://threads/{SID}"


def window(wid=7, agent="codex", sid=SID, **variables):
    return dict(id=wid, tab_id=4, os_window_id=2, title="agent", cwd="/tmp",
                user_vars={f"{agent.upper()}_SESSION_ID": sid, **variables})


class CoreTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name)
        env = patch.dict(os.environ, {"CODEX_HOME": str(self.home), "CLAUDE_CONFIG_DIR": str(self.home)})
        env.start()
        self.addCleanup(env.stop)

    def write(self, path, *records):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("".join(json.dumps(record) + "\n" for record in records))
        return path

    def test_uri_and_id_selectors_agree(self):
        self.assertEqual(session.identity(uri=URI), session.identity(codex=SID))
        for host in ("sessions", "threads"):
            self.assertEqual(session.identity(uri=f"claude://{host}/{SID}"), ("claude", SID))
        self.assertEqual(session.identity(codex=SID.upper()), ("codex", SID))

    def test_invalid_or_ambiguous_selectors_cannot_become_launch_arguments(self):
        for uri in (URI + "/more", URI + "?cwd=/tmp", URI + "#resume", URI + "?", URI + "#",
                    "codex://evil/" + SID, "codex://threads/../../tmp", URI + "$(touch x)"):
            with self.subTest(uri=uri), self.assertRaises(ValueError):
                session.identity(uri=uri)
        for args in ({}, {"codex": SID, "claude": SID}, {"codex": "--last"}, {"codex": SID[:29]}):
            with self.subTest(args=args), self.assertRaises(ValueError):
                session.identity(**args)

    def test_matches_exact_current_session_and_preserves_all_user_vars(self):
        ws = [window(CODEX_TRANSCRIPT_PATH="/tmp/log", extra="useful"), window(8, sid=OTHER),
              dict(window(9), user_vars={"CODEX_PREV_SESSION_ID": SID})]
        data = session.gather("codex", SID, ws)
        self.assertEqual([w["id"] for w in data["windows"]], [7])
        self.assertEqual(data["windows"][0]["user_vars"]["extra"], "useful")
        self.assertEqual(data["transcript_path"], "/tmp/log")

    def test_duplicate_clients_require_selection_and_never_merge_metadata(self):
        ws = [window(CODEX_CWD="/one", CODEX_TRANSCRIPT_PATH="/one/log"),
              window(8, CODEX_CWD="/two", CODEX_TRANSCRIPT_PATH="/two/log")]
        data = session.gather("codex", SID, ws)
        self.assertIsNone(data["cwd"])
        with self.assertRaisesRegex(ValueError, "multiple"):
            session.select_window(data)
        selected = session.gather("codex", SID, ws, window_id=8)
        self.assertEqual(selected["cwd"], "/two")
        with self.assertRaisesRegex(ValueError, "does not belong"):
            session.gather("codex", SID, ws, window_id=999)

    @unittest.skipIf(sqlite3 is None, "This Kitty bundle lacks SQLite; covered by the uv test run")
    def test_codex_index_lookup_is_read_only_and_handles_future_version(self):
        db = self.home / "state_10.sqlite"
        with closing(sqlite3.connect(db)) as conn:
            conn.execute("CREATE TABLE threads (id TEXT, cwd TEXT, rollout_path TEXT, title TEXT)")
            conn.execute("INSERT INTO threads VALUES (?, ?, ?, ?)", (SID, "/space and $(literal)", "/t.jsonl", "hello"))
            conn.commit()
        before = db.read_bytes()
        data = session.gather("codex", SID)
        self.assertEqual(data["cwd"], "/space and $(literal)")
        self.assertEqual(data["transcript_path"], "/t.jsonl")
        self.assertEqual(db.read_bytes(), before)

    def test_corrupt_index_falls_back_to_archive_header(self):
        (self.home / "state_5.sqlite").write_text("broken")
        path = self.write(self.home / "archived_sessions" / f"rollout-date-{SID}.jsonl",
                          {"type": "session_meta", "payload": {"id": SID, "cwd": "/saved"}})
        data = session.gather("codex", SID)
        self.assertEqual(data["transcript_path"], str(path))
        if sqlite3 is not None:
            self.assertIn("index unavailable", data["warnings"][0])

    def test_claude_finds_cwd_after_non_message_records(self):
        path = self.write(self.home / "projects/project" / f"{SID}.jsonl",
                          {"type": "file-history-snapshot"},
                          {"sessionId": SID, "cwd": "/saved", "type": "user"})
        data = session.gather("claude", SID, [window(agent="claude", cwd="ignored")])
        self.assertEqual(data["transcript_path"], str(path))

    def test_explicit_transcript_rejects_wrong_session(self):
        path = self.write(self.home / "wrong.jsonl",
                          {"type": "session_meta", "payload": {"id": OTHER, "cwd": "/saved"}})
        with self.assertRaisesRegex(ValueError, "identity"):
            session.gather("codex", SID, transcript_path=str(path))

    def test_unknown_session_is_not_reported_found(self):
        self.assertFalse(session.gather("codex", SID)["found"])
        with self.assertRaisesRegex(ValueError, "unknown"):
            session.resume_cwd({})
        self.assertEqual(session.resume_cwd({}, self.home), str(self.home.resolve()))

    def test_hints_span_soft_wraps_and_exclude_query_suffixes(self):
        text = f"[{URI[:30]}\r\0{URI[30:]}] {URI}?x=1 claude://sessions/{OTHER}"
        marks = list(hints.mark(text, None, lambda *args: args, []))
        self.assertEqual([m[3] for m in marks], [URI, f"claude://sessions/{OTHER}"])
        self.assertEqual(text[marks[0][1]:marks[0][2]].replace("\r", "").replace("\0", ""), URI)

    def test_codex_transcript_does_not_repeat_event_messages_or_emit_controls(self):
        path = self.write(self.home / "transcript.jsonl",
                          {"type": "event_msg", "payload": {"type": "agent_message", "message": "duplicate"}},
                          {"type": "response_item", "payload": {"type": "message", "role": "assistant", "content": [
                              {"type": "output_text", "text": "hello\x1b]52;clipboard\x07"}]}},
                          {"type": "response_item", "payload": {"type": "function_call", "name": "tool", "arguments": "args"}})
        with path.open("a") as stream:
            stream.write('{"incomplete":')
        text = "".join(session.transcript_lines(dict(agent="codex", uri=URI, transcript_path=str(path))))
        self.assertNotIn("duplicate", text)
        self.assertNotIn("\x1b", text)
        self.assertNotIn("\x07", text)
        self.assertIn("function_call (tool)", text)

    def test_claude_transcript_renders_text_and_tool_output(self):
        path = self.write(self.home / "transcript.jsonl",
                          {"type": "assistant", "message": {"content": [{"type": "text", "text": "hello"}]}},
                          {"type": "user", "message": {"content": [{"type": "tool_result", "content": "result"}]}})
        text = "".join(session.transcript_lines(dict(agent="claude", uri=URI, transcript_path=str(path))))
        self.assertIn("hello", text)
        self.assertIn("result", text)

    def test_launch_preserves_literal_cwd_and_resume_argv(self):
        cwd = self.home / "space and $(literal)"
        cwd.mkdir()
        ws = [window(CODEX_CWD=str(cwd), CODEX_TRANSCRIPT_PATH="/tmp/log")]
        with patch.object(session, "kitty_windows", return_value=ws), patch.object(session, "rc", return_value="9") as rc, \
                patch("sys.stdout", io.StringIO()):
            status = session.cli(["--uri", URI, "--action", "resume", "--type", "window", "--source-window", "7"])
        self.assertEqual(status, 0)
        argv = rc.call_args.args
        self.assertIn(str(cwd.resolve()), argv)
        self.assertIn("window_id:7", argv)
        self.assertEqual(argv[-3:], ("codex", "resume", SID))

    def test_open_connection_error_never_triggers_duplicate_resume(self):
        with patch.object(session, "kitty_windows", side_effect=RuntimeError("connection denied")), \
                patch.object(session, "rc") as rc, patch("sys.stderr", io.StringIO()):
            self.assertEqual(session.cli(["--uri", URI, "--action", "open", "--cwd", "/tmp"]), 1)
        rc.assert_not_called()

    def test_open_focuses_with_both_window_and_session_guard(self):
        with patch.object(session, "kitty_windows", return_value=[window()]), patch.object(session, "rc") as rc:
            self.assertEqual(session.cli(["--uri", URI, "--action", "open"]), 0)
        self.assertEqual(rc.call_args.args[-1], f"id:7 and var:CODEX_SESSION_ID=^{SID}$")

    def test_not_found_info_exit_code_and_json(self):
        with patch("sys.stdout", io.StringIO()) as out:
            self.assertEqual(session.cli(["--uri", URI, "--no-kitty"]), 1)
        self.assertFalse(json.loads(out.getvalue())["found"])

    def test_app_server_handshake_ignores_notifications_and_does_not_resume(self):
        # A tiny real subprocess exercises buffering and the request ordering.
        fake = self.home / "codex"
        fake.write_text(f'''#!/usr/bin/env python3
import json, sys
first = json.loads(input())
assert first['method'] == 'initialize'
print(json.dumps({{'method': 'notification'}}), flush=True)
print(json.dumps({{'id': first['id'], 'result': {{}}}}), flush=True)
assert json.loads(input())['method'] == 'initialized'
request = json.loads(input())
assert request['method'] == 'thread/read'
assert request['params'] == {{'threadId': '{SID}', 'includeTurns': False}}
print(json.dumps({{'id': request['id'], 'result': {{'thread': {{'id': '{SID}', 'cwd': '/tmp'}}}}}}), flush=True)
sys.stdin.read()
''')
        fake.chmod(0o755)
        with patch.dict(os.environ, {"PATH": str(self.home) + os.pathsep + os.environ["PATH"]}):
            self.assertEqual(session.app_server_metadata(SID)["id"], SID)


@unittest.skipIf(native is None, "Run with kitty +runpy for native API cases")
class NativeTests(unittest.TestCase):
    def setUp(self):
        self.source = NS(id=7, tab_id=4, os_window_id=2, title="test", cwd_of_child="/tmp", user_vars={
            "CODEX_SESSION_ID": SID, "CODEX_CWD": "/tmp", "CODEX_TRANSCRIPT_PATH": "/tmp/log"},
            tabref=Mock(return_value=NS()), screen=NS(has_selection=lambda: False), paste_text=Mock())
        self.boss = NS(all_windows=[self.source], window_id_map={7: self.source},
                       set_active_window=Mock(), show_error=Mock(), choose_entry=Mock(),
                       run_kitten_with_metadata=Mock(), display_scrollback=Mock())

    def test_real_kitty_loader_imports_without_file_global(self):
        from kittens.runner import import_kitten_main_module
        handler = import_kitten_main_module(str(ROOT / "config/kitty"), "session_links.py")
        self.assertTrue(handler["end"].no_ui)

    def test_open_focuses_using_native_api_without_metadata_io(self):
        with patch.object(native.session, "gather") as gather:
            native.act(self.boss, self.source, "codex", SID, "open", "tab")
        gather.assert_not_called()
        self.boss.set_active_window.assert_called_once_with(7, switch_os_window_if_needed=True)

    def test_multiple_clients_present_picker_and_recheck_identity(self):
        other = NS(**{**vars(self.source), "id": 8})
        self.boss.all_windows.append(other)
        native.act(self.boss, self.source, "codex", SID, "open", "tab")
        callback = self.boss.choose_entry.call_args.args[2]
        other.user_vars = {"CODEX_SESSION_ID": OTHER}
        callback(8)
        self.boss.set_active_window.assert_not_called()
        self.boss.show_error.assert_called_once()

    def test_native_resume_uses_real_kitty_launch_parser_and_literal_argv(self):
        with patch.object(native, "launch") as launch, patch.object(native, "which", return_value="/bin/codex"):
            native.act(self.boss, self.source, "codex", SID, "resume", "window")
        self.boss.show_error.assert_not_called()
        args, kwargs = launch.call_args
        self.assertEqual(args[1].type, "window")
        self.assertEqual(args[1].source_window, "id:7")
        self.assertEqual(args[2], ["/bin/codex", "resume", SID])
        self.assertIs(kwargs["rc_from_window"], self.source)

    def test_mouse_capture_restores_previous_handler(self):
        previous = Mock(return_value=False)
        self.source.open_url_handler = previous
        self.source.mouse_click_url = lambda: self.source.open_url_handler(self.boss, self.source, URI, 0, "/tmp")
        self.assertEqual(native.mouse_uri(self.source, self.boss), URI)
        self.assertIs(self.source.open_url_handler, previous)
        previous.assert_not_called()
        self.source.mouse_click_url = lambda: self.source.open_url_handler(self.boss, self.source, "https://example.com", 1, "/tmp")
        self.assertIsNone(native.mouse_uri(self.source, self.boss))
        previous.assert_called_once()

    def test_shift_selection_does_not_open_a_session(self):
        self.source.screen.has_selection = lambda: True
        with patch.object(native, "mouse_uri") as mouse:
            native.handle_result(["session_links.py", "--mouse", "--action", "resume"], None, 7, self.boss)
        mouse.assert_not_called()

    def test_current_paste_does_not_send_enter(self):
        native.handle_result(["session_links.py", "--current", "--action", "paste"], None, 7, self.boss)
        self.source.paste_text.assert_called_once_with(URI)

    def test_hints_dispatch_targets_origin_window(self):
        hints.handle_result([], {"match": [URI]}, 7, self.boss, ["preview", "tab"])
        call = self.boss.run_kitten_with_metadata.call_args
        self.assertIs(call.kwargs["window"], self.source)
        self.assertEqual(call.kwargs["args"], ["--uri", URI, "--action", "preview", "--type", "tab"])


if __name__ == "__main__":
    unittest.main()
