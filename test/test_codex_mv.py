from __future__ import annotations

import contextlib
import importlib.machinery
import importlib.util
import io
import json
from pathlib import Path
import shutil
import sqlite3
import subprocess
import tempfile
import tomllib
import unittest
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "codex-mv"
loader = importlib.machinery.SourceFileLoader("codex_mv", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
CLI = importlib.util.module_from_spec(spec)
loader.exec_module(CLI)


class MigrationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="codex-mv-test-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.old = self.root / "old"
        self.old.mkdir()
        self.new = self.root / "new"
        self.home = self.root / "home"
        self.home.mkdir()
        self.db = self.home / "state_5.sqlite"
        self.config = self.home / "config.toml"
        with contextlib.closing(sqlite3.connect(self.db)) as con, con:
            con.execute("CREATE TABLE threads (id TEXT PRIMARY KEY, cwd TEXT)")
        guard = mock.patch.object(CLI, "live_codex_processes", return_value=[])
        self.live = guard.start()
        self.addCleanup(guard.stop)

    def call(self, *args):
        with contextlib.redirect_stderr(io.StringIO()), contextlib.redirect_stdout(io.StringIO()):
            return CLI.main([str(arg) for arg in args])

    def move(self, *options):
        return self.call("-y", "--codex-home", self.home, *options, self.old, self.new)

    def backup(self):
        backups = list((self.home / ".codex-mv-backups").iterdir())
        self.assertEqual(len(backups), 1)
        return backups[0]

    def add_session(self, name="a", cwd=None, archived=False, parent_cwd=None):
        cwd = str(cwd or self.old)
        path = self.home / ("archived_sessions" if archived else "sessions") / f"rollout-{name}.jsonl"
        path.parent.mkdir(parents=True, exist_ok=True)
        records = [{"type": "session_meta", "payload": {"id": name, "cwd": cwd}}]
        if parent_cwd is not None:
            records.append({"type": "session_meta", "payload": {
                "id": "parent", "cwd": str(parent_cwd)}})
        records.append({"type": "event_msg", "payload": {"text": "keep transcript"}})
        path.write_text("".join(json.dumps(record) + "\n" for record in records))
        with contextlib.closing(sqlite3.connect(self.db)) as con, con:
            con.execute("INSERT INTO threads VALUES (?, ?)", (name, cwd))
        return path

    def db_cwd(self, name="a"):
        with contextlib.closing(sqlite3.connect(self.db)) as con:
            return con.execute("SELECT cwd FROM threads WHERE id = ?", (name,)).fetchone()[0]

    def records(self, path):
        with CLI.read_rollout(str(path)) as fh:
            return [json.loads(line) for line in fh]

    def assert_cwd(self, path, cwd, name="a"):
        self.assertEqual(CLI.session_meta_cwd(str(path)), str(cwd))
        self.assertEqual(self.db_cwd(name), str(cwd))

    def test_forward_and_undo_keep_database_and_transcript_consistent(self):
        path = self.add_session()
        before = path.read_bytes()
        self.move()
        self.assertFalse(self.old.exists())
        self.assertTrue(self.new.is_dir())
        self.assert_cwd(path, self.new)
        self.call("-y", "--undo", self.backup())
        self.assertTrue(self.old.is_dir())
        self.assertFalse(self.new.exists())
        self.assert_cwd(path, self.old)
        self.assertEqual(path.read_bytes(), before)

    def test_dry_run_undo_does_not_change_any_file_or_directory(self):
        path = self.add_session()
        self.config.write_text(f'[projects.{json.dumps(str(self.old))}]\ntrust_level = "trusted"\n')
        self.move()
        backup = self.backup()
        before = {p.relative_to(self.root): p.read_bytes()
                  for p in self.root.rglob("*") if p.is_file()}
        self.call("--dry-run", "--undo", backup, "-y")
        after = {p.relative_to(self.root): p.read_bytes()
                 for p in self.root.rglob("*") if p.is_file()}
        self.assertEqual(before, after)
        self.assertTrue(self.new.is_dir())
        self.assertFalse(self.old.exists())
        self.assert_cwd(path, self.new)

    def test_destination_trust_collision_aborts_before_mutation(self):
        path = self.add_session()
        self.config.write_text(
            f'[projects.{json.dumps(str(self.old))}]\ntrust_level = "trusted"\n'
            f'[projects.{json.dumps(str(self.new))}]\ntrust_level = "untrusted"\n')
        before = self.config.read_bytes()
        with self.assertRaisesRegex(ValueError, "Destination project entries"):
            self.move()
        self.assertTrue(self.old.is_dir())
        self.assertFalse(self.new.exists())
        self.assertEqual(self.config.read_bytes(), before)
        self.assert_cwd(path, self.old)
        self.assertFalse((self.home / ".codex-mv-backups").exists())

    def test_quoted_paths_round_trip_without_changing_other_config(self):
        self.old.rename(self.root / 'old"\\folder')
        self.old = self.root / 'old"\\folder'
        self.new = self.root / 'new"\\folder'
        self.add_session()
        original = ('# untouched\nmodel = "example"\n'
                    f'[projects.{json.dumps(str(self.old))}] # keep comment\n'
                    'trust_level = "trusted"\n')
        self.config.write_text(original)
        self.move()
        parsed = tomllib.loads(self.config.read_text())
        self.assertEqual(parsed["projects"], {str(self.new): {"trust_level": "trusted"}})
        self.assertIn("# untouched", self.config.read_text())
        self.assertIn("# keep comment", self.config.read_text())
        self.call("-y", "--undo", self.backup())
        self.assertEqual(self.config.read_text(), original)

    def test_literal_toml_key_and_subtable_are_relocated(self):
        self.config.write_text(f"[projects.'{self.old}']\ntrust_level = \"trusted\"\n"
                               f"[projects.'{self.old}'.extra]\nvalue = 1\n")
        self.move()
        self.assertEqual(tomllib.loads(self.config.read_text())["projects"], {
            str(self.new): {"trust_level": "trusted", "extra": {"value": 1}}})

    def test_occupied_old_directory_prevents_all_undo_changes(self):
        path = self.add_session()
        self.move()
        self.old.mkdir()
        unrelated = self.old / "unrelated"
        unrelated.write_text("do not touch")
        with self.assertRaises(SystemExit):
            self.call("-y", "--undo", self.backup())
        self.assertTrue(self.new.is_dir())
        self.assertEqual(unrelated.read_text(), "do not touch")
        self.assert_cwd(path, self.new)

    def test_undo_includes_new_sessions_and_subdirectories(self):
        self.add_session()
        self.move()
        path = self.add_session("fresh", self.new / "subdir", archived=True)
        self.call("-y", "--undo", self.backup())
        self.assert_cwd(path, self.old / "subdir", "fresh")

    def test_undo_restores_each_fork_record_exactly(self):
        for parent in (self.root / "other", self.new, self.old / "child"):
            with self.subTest(parent=parent):
                path = self.add_session(str(len(list(self.home.rglob('*.jsonl')))), parent_cwd=parent)
                original = self.records(path)
                entry = {"metadata": CLI.rollout_meta_cwds(str(path))}
                CLI.rewrite_rollout(str(path), str(self.old), str(self.new))
                CLI.restore_rollout(str(path), entry, str(self.old), str(self.new))
                self.assertEqual(self.records(path), original)

    def test_fork_history_survives_cli_move_and_undo(self):
        path = self.add_session(parent_cwd=self.root / "other")
        original = self.records(path)
        self.move()
        manifest = json.loads((self.backup() / "manifest.json").read_text())
        self.assertEqual(len(manifest["rollouts"][0]["metadata"]), 2)
        self.call("-y", "--undo", self.backup())
        self.assertEqual(self.records(path), original)

    def test_version_one_backup_preserves_unrelated_fork_metadata(self):
        path = self.add_session(parent_cwd=self.root / "other")
        original = self.records(path)
        self.move()
        manifest_path = self.backup() / "manifest.json"
        manifest = json.loads(manifest_path.read_text())
        manifest["version"] = 1
        for entry in manifest["rollouts"]:
            del entry["metadata"]
        manifest_path.write_text(json.dumps(manifest))
        self.call("-y", "--undo", self.backup())
        self.assertEqual(self.records(path), original)

    def test_archived_sessions_migrate_and_undo(self):
        path = self.add_session(archived=True)
        self.move()
        self.assert_cwd(path, self.new)
        self.call("-y", "--undo", self.backup())
        self.assert_cwd(path, self.old)

    @unittest.skipUnless(CLI.zstd is not None or shutil.which("zstd"), "zstd required")
    def test_compressed_sessions_remain_compressed_and_undo_after_archive(self):
        path = self.add_session(parent_cwd=self.root / "other")
        original = self.records(path)
        compressed = Path(str(path) + ".zst")
        CLI.compress_rollout(str(path), str(compressed))
        path.unlink()
        self.move()
        self.assertFalse(path.exists())
        self.assert_cwd(compressed, self.new)
        archived = self.home / "archived_sessions" / compressed.name
        archived.parent.mkdir()
        compressed.rename(archived)
        self.call("-y", "--undo", self.backup())
        self.assert_cwd(archived, self.old)
        self.assertEqual(self.records(archived), original)

    def test_compression_without_decoder_aborts_before_move(self):
        path = self.add_session()
        path.rename(str(path) + ".zst")
        with mock.patch.object(CLI, "zstd", None), mock.patch.object(CLI.shutil, "which", return_value=None):
            with self.assertRaisesRegex(RuntimeError, "Compressed rollouts require"):
                self.move()
        self.assertTrue(self.old.exists())
        self.assertFalse(self.new.exists())

    def test_backups_are_unique_even_with_identical_timestamps(self):
        path = self.add_session()
        with mock.patch.object(CLI, "datetime") as date:
            date.now.return_value.strftime.return_value = "20260919-120000"
            date.now.return_value.isoformat.return_value = "2026-09-19T12:00:00"
            self.move()
            first = self.backup()
            original = (first / "manifest.json").read_bytes()
            self.call("-y", "--codex-home", self.home, self.new, self.root / "newer")
        backups = list((self.home / ".codex-mv-backups").iterdir())
        self.assertEqual(len(backups), 2)
        self.assertEqual((first / "manifest.json").read_bytes(), original)
        second = next(p for p in backups if p != first)
        self.call("-y", "--undo", second)
        self.call("-y", "--undo", first)
        self.assert_cwd(path, self.old)

    def test_unavailable_process_inspection_prevents_migration(self):
        path = self.add_session()
        self.live.side_effect = RuntimeError("inspection unavailable")
        with self.assertRaises(SystemExit):
            self.move()
        self.assertTrue(self.old.exists())
        self.assertFalse(self.new.exists())
        self.assert_cwd(path, self.old)

    def test_live_session_prevents_migration(self):
        self.add_session()
        self.live.return_value = [{"pid": 123, "ppid": 1, "tty": "ttys001",
                                   "cwd": str(self.old), "rollout": None, "started": None}]
        with self.assertRaises(SystemExit):
            self.move()
        self.assertTrue(self.old.exists())
        self.assertFalse(self.new.exists())


class MacProcessTests(unittest.TestCase):
    def result(self, stdout="", returncode=0, stderr=""):
        return subprocess.CompletedProcess([], returncode, stdout, stderr)

    def test_mac_guard_checks_all_rollouts_for_app_server(self):
        outputs = [self.result("999991 1 ?? /Applications/Codex.app/codex\n"),
                   self.result("p999991\nfcwd\nn/elsewhere\nf3\nn/home/sessions/other.jsonl\n"
                               "f4\nn/home/sessions/project.jsonl\n")]
        with mock.patch.object(CLI.sys, "platform", "darwin"), \
                mock.patch.object(CLI.subprocess, "run", side_effect=outputs), \
                mock.patch.object(CLI, "session_meta_cwd", side_effect=["/other", "/project"]):
            found = CLI.live_codex_processes("/project")
        self.assertEqual([p["pid"] for p in found], [999991])
        self.assertEqual(found[0]["rollout"], "/home/sessions/project.jsonl")

    def test_mac_guard_matches_process_cwd(self):
        outputs = [self.result("999991 1 ttys001 /usr/local/bin/codex\n"),
                   self.result("p999991\nfcwd\nn/project/subdir\n")]
        with mock.patch.object(CLI.subprocess, "run", side_effect=outputs):
            found = CLI._mac_live_codex_processes("/project")
        self.assertEqual(len(found), 1)
        self.assertEqual(found[0]["tty"], "ttys001")

    def test_mac_guard_fails_closed_for_unreadable_live_process(self):
        outputs = [self.result("999991 1 ?? /usr/local/bin/codex\n"),
                   self.result(returncode=1, stderr="denied"), self.result("999991\n")]
        with mock.patch.object(CLI.subprocess, "run", side_effect=outputs):
            with self.assertRaisesRegex(RuntimeError, "Cannot inspect Codex process"):
                CLI._mac_live_codex_processes("/project")

    def test_mac_guard_tolerates_process_exit(self):
        outputs = [self.result("999991 1 ?? /usr/local/bin/codex\n"),
                   self.result(returncode=1), self.result(returncode=1)]
        with mock.patch.object(CLI.subprocess, "run", side_effect=outputs):
            self.assertEqual(CLI._mac_live_codex_processes("/project"), [])


if __name__ == "__main__":
    unittest.main()
