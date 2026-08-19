from __future__ import annotations

import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "bin" / "pub"


def load_cli():
    loader = importlib.machinery.SourceFileLoader("pub_cli", str(SCRIPT))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError("Could not load pub")
    module = importlib.util.module_from_spec(spec)
    sys.modules[loader.name] = module
    loader.exec_module(module)
    return module


CLI = load_cli()


def write_executable(path: Path, content: str) -> None:
    path.write_text(content)
    path.chmod(path.stat().st_mode | stat.S_IXUSR)


class FakeTarget:
    """In-process byte-preserving snapshot store for the fake: scheme."""

    scheme = "fake"

    def __init__(self) -> None:
        self.store: dict[str, bytes] = {}
        self.counter = 0

    def create(self, name: str, content: bytes, *, public: bool):
        self.counter += 1
        identifier = f"doc{self.counter}"
        self.store[identifier] = content
        uri = CLI.TargetURI("fake", identifier, (("file", name),))
        return CLI.Created(uri, f"https://fake.example/{identifier}")

    def read(self, uri):
        return self.store.get(uri.identifier)

    def update(self, uri, content: bytes) -> None:
        if uri.identifier not in self.store:
            raise CLI.CliError(
                "target_missing",
                "gone",
                details={"missing": "container"},
            )
        self.store[uri.identifier] = content

    def rename(self, uri, new_name: str, content: bytes):
        self.update(uri, content)
        return uri.with_param("file", new_name)

    def web_url(self, uri):
        return f"https://fake.example/{uri.identifier}"

    def normalize(self, ref):
        if ref.startswith("fake:"):
            return CLI.parse_uri(ref)
        return None

    def doctor(self):
        return [{"name": "fake", "ok": True, "detail": None}]


class PubTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = Path(tempfile.mkdtemp(prefix="pub-test-"))
        self.addCleanup(self._cleanup_temp)
        self.state_home = self.temp / "state"
        self.work = self.temp / "work"
        self.work.mkdir()
        patcher = mock.patch.dict(
            os.environ, {"XDG_STATE_HOME": str(self.state_home)}
        )
        patcher.start()
        self.addCleanup(patcher.stop)
        self.target = FakeTarget()
        CLI.TARGET_REGISTRY["fake"] = lambda: self.target
        CLI._TARGET_CACHE.clear()
        self.addCleanup(CLI.TARGET_REGISTRY.pop, "fake", None)
        self.addCleanup(CLI._TARGET_CACHE.clear)

    def _cleanup_temp(self) -> None:
        import shutil

        shutil.rmtree(self.temp, ignore_errors=True)

    def write(self, name: str, content: str) -> Path:
        path = self.work / name
        path.write_text(content)
        return path

    def run_main(self, *argv: str) -> tuple[int, str, str]:
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            try:
                code = CLI.main(list(argv))
            except SystemExit as exc:
                code = exc.code if isinstance(exc.code, int) else 0
        return code, out.getvalue(), err.getvalue()

    def run_json(self, *argv: str) -> tuple[int, dict]:
        code, out, _ = self.run_main("--json", *argv)
        return code, json.loads(out)

    def publish(self, path: Path, *extra: str) -> dict:
        code, payload = self.run_json(
            "publish", str(path), "--target", "fake", *extra
        )
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["ok"], payload)
        return payload["data"]

    def file_uri(self, path: Path) -> str:
        document = CLI.load_document(str(path))
        assert document.tag is not None
        return CLI.serialize_uri(document.tag.uri)


class UriTests(unittest.TestCase):
    def test_round_trip_canonical(self) -> None:
        for text in (
            "gist:90b892b5069e95c2f893fab46177334a?file=zshrc.local",
            "gist:abc123def4567890?file=notes-%2Ddraft.md",
            "fake:doc1?file=a%20b.md",
            "fake:doc1",
        ):
            self.assertEqual(
                CLI.serialize_uri(CLI.parse_uri(text)), text
            )

    def test_double_dash_is_encoded(self) -> None:
        encoded = CLI.encode_param_value("notes--draft.md")
        self.assertEqual(encoded, "notes-%2Ddraft.md")
        self.assertNotIn("--", encoded)
        self.assertEqual(CLI.decode_param_value(encoded), "notes--draft.md")

    def test_triple_dash_has_no_double_dash(self) -> None:
        encoded = CLI.encode_param_value("a---b")
        self.assertNotIn("--", encoded)
        self.assertEqual(CLI.decode_param_value(encoded), "a---b")

    def test_control_characters_are_rejected(self) -> None:
        with self.assertRaises(CLI.CliError):
            CLI.encode_param_value("bad\nname")

    def test_invalid_uri_is_rejected(self) -> None:
        for text in ("nope", "gist:", "gist:id?file", "gist:id?FILE=x"):
            with self.assertRaises(CLI.CliError):
                CLI.parse_uri(text)

    def test_serialized_uri_is_comment_safe(self) -> None:
        uri = CLI.parse_uri("gist:abc123?file=notes-%2Ddraft.md")
        self.assertNotIn("--", CLI.serialize_uri(uri))


class TagTests(unittest.TestCase):
    MD = ("<!--", "-->")
    HASH = ("#", "")

    def test_style_detection(self) -> None:
        cases = {
            "a.md": self.MD,
            "a.py": self.HASH,
            "a.ts": ("//", ""),
            "a.sql": ("--", ""),
            "a.clj": (";", ""),
            "a.tex": ("%", ""),
            "a.json": None,
            "a.unknownext": None,
        }
        for name, expected in cases.items():
            self.assertEqual(
                CLI.detect_style(Path(name), ""), expected, name
            )

    def test_shebang_detection(self) -> None:
        self.assertEqual(
            CLI.detect_style(Path("tool"), "#!/usr/bin/env bash\n"),
            self.HASH,
        )
        self.assertEqual(
            CLI.detect_style(
                Path("tool"), "#!/usr/bin/env -S mise x uv -- uv run\n"
            ),
            self.HASH,
        )
        self.assertIsNone(CLI.detect_style(Path("tool"), "plain text\n"))
        self.assertIsNone(
            CLI.detect_style(Path("tool"), "#!/usr/bin/env node\n")
        )

    def test_markdown_insert_at_eof_with_blank_line(self) -> None:
        uri = CLI.parse_uri("fake:doc1?file=a.md")
        tagged = CLI.insert_tag("# Title\n\nBody\n", self.MD, uri)
        self.assertEqual(
            tagged,
            "# Title\n\nBody\n\n<!-- x-pub: fake:doc1?file=a.md -->\n",
        )

    def test_script_insert_after_shebang_and_comment_block(self) -> None:
        uri = CLI.parse_uri("fake:doc1?file=t.sh")
        text = "#!/bin/sh\n# vim: ft=sh\necho hi\n"
        tagged = CLI.insert_tag(text, self.HASH, uri)
        self.assertEqual(
            tagged,
            "#!/bin/sh\n# vim: ft=sh\n# x-pub: fake:doc1?file=t.sh\necho hi\n",
        )

    def test_round_trip_insert_detect_unlink(self) -> None:
        uri = CLI.parse_uri("fake:doc1?file=x")
        for style, text in (
            (self.MD, "# Title\n\nBody\n"),
            (self.HASH, "#!/bin/sh\necho hi\n"),
            (("//", ""), "const x = 1;\n"),
        ):
            tagged = CLI.insert_tag(text, style, uri)
            match = CLI.find_tag(tagged, style)
            self.assertIsNotNone(match, style)
            self.assertEqual(CLI.serialize_uri(match.uri), "fake:doc1?file=x")
            self.assertEqual(CLI.remove_tag(tagged, style), text, style)

    def test_window_excludes_middle_of_file(self) -> None:
        lines = [f"line {i}" for i in range(20)]
        lines[10] = "<!-- x-pub: fake:doc1 -->"
        self.assertIsNone(CLI.find_tag("\n".join(lines) + "\n", self.MD))

    def test_window_includes_last_five_lines(self) -> None:
        lines = [f"line {i}" for i in range(20)]
        lines[17] = "<!-- x-pub: fake:doc1 -->"
        match = CLI.find_tag("\n".join(lines) + "\n", self.MD)
        self.assertIsNotNone(match)

    def test_two_tags_are_ambiguous(self) -> None:
        text = "<!-- x-pub: fake:doc1 -->\nbody\n<!-- x-pub: fake:doc2 -->\n"
        with self.assertRaises(CLI.CliError) as caught:
            CLI.find_tag(text, self.MD)
        self.assertEqual(caught.exception.code, "ambiguous_tag")

    def test_wrong_comment_leader_does_not_match(self) -> None:
        self.assertIsNone(CLI.find_tag("# x-pub: fake:doc1\n", self.MD))
        self.assertIsNone(
            CLI.find_tag("<!-- x-pub: fake:doc1\n", self.MD)
        )

    def test_invalid_tag_uri_raises(self) -> None:
        with self.assertRaises(CLI.CliError) as caught:
            CLI.find_tag("<!-- x-pub: not_a_uri -->\n", self.MD)
        self.assertEqual(caught.exception.code, "invalid_tag")


class RoutingTests(unittest.TestCase):
    def test_json_status_stays_status(self) -> None:
        self.assertEqual(
            CLI.normalize_argv(["--json", "status", "f.md"]),
            ["--json", "status", "f.md"],
        )

    def test_file_routes_to_publish(self) -> None:
        self.assertEqual(
            CLI.normalize_argv(["notes.md"]), ["publish", "notes.md"]
        )

    def test_publish_flag_routes_to_publish(self) -> None:
        self.assertEqual(
            CLI.normalize_argv(["--public", "notes.md"]),
            ["publish", "--public", "notes.md"],
        )

    def test_double_dash_escape_publishes_literal_name(self) -> None:
        values = CLI.normalize_argv(["publish", "--", "status"])
        self.assertEqual(values, ["publish", "--", "status"])
        parser, _ = CLI.build_parser()
        namespace = parser.parse_args(values)
        self.assertEqual(namespace.command, "publish")
        self.assertEqual(namespace.files, ["status"])

    def test_help_is_not_routed(self) -> None:
        self.assertEqual(CLI.normalize_argv(["--help"]), ["--help"])

    def test_empty_argv_is_untouched(self) -> None:
        self.assertEqual(CLI.normalize_argv([]), [])


class SensitiveTests(PubTestCase):
    def test_sensitive_basenames_refuse(self) -> None:
        for name in (".env", "server.pem", "id_rsa.pub", "my-secrets.md"):
            path = self.write(name, "# content\n")
            code, payload = self.run_json("publish", str(path), "--target", "fake")
            self.assertEqual(code, 1, name)
            self.assertEqual(payload["error"]["code"], "sensitive_content")

    def test_sensitive_content_refuses(self) -> None:
        markers = (
            "-----BEGIN RSA PRIVATE KEY-----",
            "AKIA" + "A" * 16,
            "ghp_" + "a" * 36,
        )
        for marker in markers:
            path = self.write("doc.md", f"note\n{marker}\n")
            code, payload = self.run_json("publish", str(path), "--target", "fake")
            self.assertEqual(code, 1, marker)
            self.assertEqual(payload["error"]["code"], "sensitive_content")

    def test_force_does_not_cover_sensitive(self) -> None:
        path = self.write(".env", "X=1\n")
        code, payload = self.run_json(
            "publish", str(path), "--target", "fake", "--force"
        )
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "sensitive_content")

    def test_allow_sensitive_publishes(self) -> None:
        path = self.write(".envrc", "export X=1\n")
        data = self.publish(path, "--allow-sensitive")
        self.assertTrue(data["created"])

    def test_guard_applies_to_updates_too(self) -> None:
        path = self.write("doc.md", "clean\n")
        self.publish(path)
        path.write_text(path.read_text() + "ghp_" + "b" * 36 + "\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "sensitive_content")


class PublishFlowTests(PubTestCase):
    def test_create_ends_byte_identical(self) -> None:
        path = self.write("doc.md", "# Title\n\nBody\n")
        data = self.publish(path)
        self.assertTrue(data["created"])
        self.assertEqual(data["state_before"], "untracked")
        local = path.read_bytes()
        self.assertIn(b"x-pub: fake:doc1?file=doc.md", local)
        self.assertEqual(self.target.store["doc1"], local)
        record = CLI.load_state("fake:doc1?file=doc.md")
        self.assertIsNotNone(record)
        self.assertEqual(record["base_sha256"], CLI.sha256_hex(local))
        self.assertEqual(record["last_seen_path"], str(path.resolve()))
        self.assertIsNone(CLI.load_journal(path.resolve()))

    def test_publish_is_idempotent(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        data = self.publish(path)
        self.assertEqual(data["state_before"], "synced")
        self.assertEqual(len(self.target.store), 1)

    def test_ahead_publish_updates_remote(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text().replace("Body", "New body"))
        data = self.publish(path)
        self.assertEqual(data["state_before"], "ahead")
        self.assertEqual(self.target.store["doc1"], path.read_bytes())

    def test_behind_refuses_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.target.store["doc1"] += b"remote edit\n"
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "remote_changed")
        self.assertEqual(payload["error"]["details"]["state"], "behind")

    def test_diverged_refuses_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.target.store["doc1"] += b"remote edit\n"
        path.write_text(path.read_text() + "local edit\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["details"]["state"], "diverged")

    def test_unknown_refuses_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        CLI.delete_state(self.file_uri(path))
        path.write_text(path.read_text() + "local edit\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["details"]["state"], "unknown")

    def test_force_overwrites_diverged_remote(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.target.store["doc1"] += b"remote edit\n"
        path.write_text(path.read_text() + "local edit\n")
        code, payload = self.run_json("sync", str(path), "--force")
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state_before"], "diverged")
        self.assertEqual(self.target.store["doc1"], path.read_bytes())

    def test_sync_never_creates(self) -> None:
        path = self.write("doc.md", "Body\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "untracked")
        self.assertEqual(self.target.store, {})

    def test_unsupported_filetype_refuses_create(self) -> None:
        path = self.write("data.json", "{}\n")
        code, payload = self.run_json("publish", str(path), "--target", "fake")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "unsupported_filetype")

    def test_missing_target_reports_missing(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        del self.target.store["doc1"]
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "target_missing")

    def test_batch_continues_past_failures(self) -> None:
        good = self.write("good.md", "Body\n")
        self.publish(good)
        bad = self.write("bad.md", "Body\n")
        code, payload = self.run_json("sync", str(good), str(bad))
        self.assertEqual(code, 1)
        results = payload["data"]["results"]
        self.assertEqual(len(results), 2)
        self.assertTrue(results[0]["ok"])
        self.assertFalse(results[1]["ok"])
        self.assertEqual(results[1]["error"]["code"], "untracked")

    def test_mid_run_change_aborts_create(self) -> None:
        path = self.write("doc.md", "Body\n")
        original_create = self.target.create

        def racing_create(name, content, *, public):
            path.write_text("editor race\n")
            return original_create(name, content, public=public)

        self.target.create = racing_create
        code, payload = self.run_json("publish", str(path), "--target", "fake")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "file_changed_during_run")
        entry = CLI.load_journal(path.resolve())
        self.assertIsNotNone(entry)
        self.assertEqual(entry["phase"], "created")


class JournalTests(PubTestCase):
    def test_creating_entry_blocks_publish(self) -> None:
        path = self.write("doc.md", "Body\n")
        CLI.save_journal(path.resolve(), {"phase": "creating", "scheme": "fake"})
        code, payload = self.run_json("publish", str(path), "--target", "fake")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "pending_create")
        self.assertIn("gh gist list", payload["error"]["message"])

    def test_created_entry_with_tag_self_heals(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        uri = self.file_uri(path)
        CLI.save_journal(
            path.resolve(), {"phase": "created", "uri": uri, "scheme": "fake"}
        )
        data = self.publish(path)
        self.assertEqual(data["state_before"], "synced")
        self.assertIsNone(CLI.load_journal(path.resolve()))

    def test_created_entry_without_tag_points_to_link(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.target.store["doc9"] = path.read_bytes()
        CLI.save_journal(
            path.resolve(),
            {"phase": "created", "uri": "fake:doc9?file=doc.md", "scheme": "fake"},
        )
        code, payload = self.run_json("publish", str(path), "--target", "fake")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "pending_create")
        self.assertIn("pub link", payload["error"]["message"])
        code, payload = self.run_json(
            "link", str(path), "fake:doc9?file=doc.md"
        )
        self.assertEqual(code, 0, payload)
        self.assertIsNone(CLI.load_journal(path.resolve()))
        data = self.publish(path)
        self.assertEqual(data["state_before"], "ahead")


class PullTests(PubTestCase):
    def tagged_remote(self, path: Path, extra: str) -> bytes:
        """Remote content: current local bytes plus an edit, tag intact."""
        content = path.read_bytes() + extra.encode()
        self.target.store["doc1"] = content
        return content

    def test_pull_behind_overwrites_local(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        remote = self.tagged_remote(path, "remote edit\n")
        code, payload = self.run_json("pull", str(path))
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state_before"], "behind")
        self.assertEqual(path.read_bytes(), remote)
        record = CLI.load_state(self.file_uri(path))
        self.assertEqual(record["base_sha256"], CLI.sha256_hex(remote))

    def test_pull_refuses_ahead_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text() + "local edit\n")
        code, payload = self.run_json("pull", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "local_changed")
        self.assertEqual(payload["error"]["details"]["state"], "ahead")

    def test_pull_refuses_unknown_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.tagged_remote(path, "remote edit\n")
        CLI.delete_state(self.file_uri(path))
        code, payload = self.run_json("pull", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["details"]["state"], "unknown")

    def test_pull_identity_check_refuses_untagged_remote(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.target.store["doc1"] = b"remote content without tag\n"
        code, payload = self.run_json("pull", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "pull_identity")

    def test_forced_pull_of_untagged_remote_warns(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        self.target.store["doc1"] = b"remote content without tag\n"
        code, payload = self.run_json("pull", str(path), "--force")
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state"], "untracked")
        self.assertTrue(
            any("untracked" in note for note in payload["data"]["notes"])
        )
        self.assertEqual(path.read_bytes(), b"remote content without tag\n")

    def test_forced_pull_migrates_to_retargeted_tag(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        other_uri = CLI.parse_uri("fake:doc7?file=doc.md")
        retargeted = CLI.insert_tag(
            "different remote\n", ("<!--", "-->"), other_uri
        ).encode()
        self.target.store["doc1"] = retargeted
        self.target.store["doc7"] = retargeted
        code, payload = self.run_json("pull", str(path), "--force")
        self.assertEqual(code, 0, payload)
        self.assertEqual(path.read_bytes(), retargeted)
        migrated = CLI.load_state("fake:doc7?file=doc.md")
        self.assertIsNotNone(migrated)
        self.assertEqual(migrated["base_sha256"], CLI.sha256_hex(retargeted))
        self.assertIsNone(CLI.load_state("fake:doc1?file=doc.md"))


class LinkUnlinkTests(PubTestCase):
    def test_link_matching_content_records_base(self) -> None:
        remote = b"# Shared\n\nBody\n"
        self.target.store["doc5"] = remote
        path = self.write("shared.md", remote.decode())
        code, payload = self.run_json(
            "link", str(path), "fake:doc5?file=shared.md"
        )
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["matched"])
        record = CLI.load_state("fake:doc5?file=shared.md")
        self.assertEqual(record["base_sha256"], CLI.sha256_hex(remote))
        data = self.publish(path)
        self.assertEqual(data["state_before"], "ahead")
        self.assertEqual(self.target.store["doc5"], path.read_bytes())

    def test_link_mismatch_records_no_base(self) -> None:
        self.target.store["doc5"] = b"remote version\n"
        path = self.write("shared.md", "local version\n")
        code, payload = self.run_json(
            "link", str(path), "fake:doc5?file=shared.md"
        )
        self.assertEqual(code, 0, payload)
        self.assertFalse(payload["data"]["matched"])
        record = CLI.load_state("fake:doc5?file=shared.md")
        self.assertIsNone(record["base_sha256"])
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["details"]["state"], "unknown")

    def test_link_tagged_file_with_other_uri_refuses(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        code, payload = self.run_json("link", str(path), "fake:doc5")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "already_linked")

    def test_unlink_restores_bytes_and_deletes_owned_state(self) -> None:
        original = "# Title\n\nBody\n"
        path = self.write("doc.md", original)
        self.publish(path)
        uri = self.file_uri(path)
        code, payload = self.run_json("unlink", str(path))
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["state_deleted"])
        self.assertEqual(path.read_text(), original)
        self.assertIsNone(CLI.load_state(uri))

    def test_unlink_of_stray_copy_keeps_state(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        uri = self.file_uri(path)
        copy = self.write("copy.md", path.read_text())
        code, payload = self.run_json("unlink", str(copy))
        self.assertEqual(code, 0, payload)
        self.assertFalse(payload["data"]["state_deleted"])
        self.assertIsNotNone(CLI.load_state(uri))
        self.assertNotIn("x-pub", copy.read_text())


class SharedUriGuardTests(PubTestCase):
    def test_copy_refuses_without_force(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        copy = self.write("copy.md", path.read_text() + "copy edit\n")
        code, payload = self.run_json("sync", str(copy))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "shared_uri")

    def test_force_transfers_ownership(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        copy = self.write("copy.md", path.read_text() + "copy edit\n")
        code, payload = self.run_json("sync", str(copy), "--force")
        self.assertEqual(code, 0, payload)
        record = CLI.load_state(self.file_uri(copy))
        self.assertEqual(record["last_seen_path"], str(copy.resolve()))

    def test_moved_file_proceeds_with_note(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        moved = self.work / "moved.md"
        path.rename(moved)
        moved.write_text(moved.read_text() + "edit after move\n")
        code, payload = self.run_json("sync", str(moved))
        self.assertEqual(code, 0, payload)
        self.assertTrue(
            any("moved" in note for note in payload["data"]["notes"])
        )
        record = CLI.load_state(self.file_uri(moved))
        self.assertEqual(record["last_seen_path"], str(moved.resolve()))


class StateBootstrapTests(PubTestCase):
    def test_synced_contact_records_base_and_path(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        uri = self.file_uri(path)
        CLI.delete_state(uri)
        code, payload = self.run_json("status", str(path))
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state"], "synced")
        record = CLI.load_state(uri)
        self.assertEqual(record["base_sha256"], CLI.sha256_hex(path.read_bytes()))
        self.assertEqual(record["last_seen_path"], str(path.resolve()))


class StatusTests(PubTestCase):
    def test_untracked_named_file(self) -> None:
        path = self.write("plain.md", "Body\n")
        code, payload = self.run_json("status", str(path))
        self.assertEqual(code, 0)
        self.assertEqual(payload["data"]["state"], "untracked")

    def test_check_clean_exits_zero(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        code, _ = self.run_json("status", str(path), "--check")
        self.assertEqual(code, 0)

    def test_check_stale_exits_three(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text() + "edit\n")
        code, _ = self.run_json("status", str(path), "--check")
        self.assertEqual(code, 3)

    def test_check_counts_named_untracked_as_stale(self) -> None:
        path = self.write("plain.md", "Body\n")
        code, _ = self.run_json("status", str(path), "--check")
        self.assertEqual(code, 3)

    def test_check_error_outranks_stale(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        stale = self.write("stale.md", "Body\n")
        self.publish(stale)
        stale.write_text(stale.read_text() + "edit\n")

        def broken_read(uri):
            raise CLI.CliError("target_error", "boom")

        self.target.read = broken_read
        code, _ = self.run_json(
            "status", str(path), str(stale), "--check"
        )
        self.assertEqual(code, 1)

    def test_state_scan_reports_local_missing(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.unlink()
        code, payload = self.run_json("status")
        self.assertEqual(code, 0, payload)
        results = payload["data"]["results"]
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["state"], "local_missing")

    def test_state_scan_uses_state_uri(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text("tag removed\n")
        code, payload = self.run_json("status")
        self.assertEqual(code, 0, payload)
        self.assertNotEqual(
            payload["data"]["results"][0]["state"], "untracked"
        )


class DiffTests(PubTestCase):
    def test_identical_exits_zero(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        code, out, _ = self.run_main("diff", str(path))
        self.assertEqual(code, 0)
        self.assertEqual(out, "")

    def test_different_exits_one_with_remote_as_a(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text().replace("Body", "Changed"))
        code, out, _ = self.run_main("diff", str(path))
        self.assertEqual(code, 1)
        self.assertIn("a/doc.md", out)
        self.assertIn("b/doc.md", out)
        self.assertIn("+Changed", out)

    def test_error_exits_two(self) -> None:
        path = self.write("plain.md", "Body\n")
        code, _, err = self.run_main("diff", str(path))
        self.assertEqual(code, 2)
        self.assertIn("x-pub", err)


GH_SHIM = """#!/usr/bin/env python3
import json, os, sys, time
from pathlib import Path

DIR = Path(os.environ["PUB_TEST_GH_DIR"])
CALLS = DIR / "calls.jsonl"
STORE = DIR / "gists.json"
CONTROL = DIR / "control.json"


def load(path, default):
    try:
        return json.loads(path.read_text())
    except FileNotFoundError:
        return default


def main():
    argv = sys.argv[1:]
    stdin = sys.stdin.read() if "--input" in argv else ""
    with CALLS.open("a") as handle:
        handle.write(json.dumps({
            "argv": argv,
            "stdin": stdin,
            "GITHUB_TOKEN": os.environ.get("GITHUB_TOKEN"),
            "GH_TOKEN": os.environ.get("GH_TOKEN"),
        }) + "\\n")
    if argv[:2] == ["auth", "status"]:
        print("Logged in to github.com; scopes: gist, repo")
        return 0
    if argv[:1] != ["api"]:
        print("gh shim: unexpected: " + " ".join(argv), file=sys.stderr)
        return 1
    control = load(CONTROL, {})
    if control.get("fail") == "auth":
        print("gh: HTTP 401: Bad credentials", file=sys.stderr)
        return 1
    rest = argv[1:]
    hostname, method, endpoint = None, "GET", None
    index = 0
    while index < len(rest):
        arg = rest[index]
        if arg in ("--hostname", "--method"):
            if arg == "--hostname":
                hostname = rest[index + 1]
            else:
                method = rest[index + 1]
            index += 2
        elif arg == "--input":
            index += 2
        else:
            endpoint = arg
            index += 1
    if hostname != "github.com":
        print("gh shim: hostname not pinned", file=sys.stderr)
        return 1
    gists = load(STORE, {})
    if endpoint == "/gists" and method == "POST":
        if control.get("create_delay"):
            time.sleep(float(control["create_delay"]))
        gists = load(STORE, {})
        payload = json.loads(stdin)
        gist_id = "ab12cd34ef56ab12" + format(len(gists), "04x")
        gists[gist_id] = {
            "public": payload.get("public", False),
            "files": {
                name: spec["content"]
                for name, spec in payload["files"].items()
            },
        }
        STORE.write_text(json.dumps(gists))
        print(json.dumps({
            "id": gist_id,
            "html_url": "https://gist.github.com/user/" + gist_id,
        }))
        return 0
    if endpoint and endpoint.startswith("/gists/"):
        gist_id = endpoint.split("/")[2]
        if gist_id not in gists:
            print("gh: Not Found (HTTP 404)", file=sys.stderr)
            return 1
        if method == "GET":
            print(json.dumps({
                "id": gist_id,
                "html_url": "https://gist.github.com/user/" + gist_id,
                "files": {
                    name: {
                        "content": content,
                        "truncated": bool(control.get("truncated")),
                    }
                    for name, content in gists[gist_id]["files"].items()
                },
            }))
            return 0
        if method == "PATCH":
            payload = json.loads(stdin)
            files = gists[gist_id]["files"]
            for name, spec in payload["files"].items():
                new_name = spec.get("filename", name)
                files.pop(name, None)
                files[new_name] = spec["content"]
            STORE.write_text(json.dumps(gists))
            print(json.dumps({"id": gist_id}))
            return 0
    print("gh shim: unhandled: " + " ".join(argv), file=sys.stderr)
    return 1


sys.exit(main())
"""


class GistShimTestCase(PubTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.gh_dir = self.temp / "gh"
        self.gh_dir.mkdir()
        write_executable(self.gh_dir / "gh", GH_SHIM)
        patcher = mock.patch.dict(
            os.environ,
            {
                "PATH": f"{self.gh_dir}{os.pathsep}{os.environ['PATH']}",
                "PUB_TEST_GH_DIR": str(self.gh_dir),
                "GITHUB_TOKEN": "leak-me-not",
                "GH_TOKEN": "keep-me",
            },
        )
        patcher.start()
        self.addCleanup(patcher.stop)

    def calls(self) -> list[dict]:
        path = self.gh_dir / "calls.jsonl"
        if not path.exists():
            return []
        return [
            json.loads(line)
            for line in path.read_text().splitlines()
            if line.strip()
        ]

    def api_calls(self) -> list[dict]:
        return [call for call in self.calls() if call["argv"][:1] == ["api"]]

    def set_control(self, **kwargs) -> None:
        (self.gh_dir / "control.json").write_text(json.dumps(kwargs))

    def gists(self) -> dict:
        path = self.gh_dir / "gists.json"
        return json.loads(path.read_text()) if path.exists() else {}


class GistTargetTests(GistShimTestCase):
    def test_create_flow_payloads_and_env(self) -> None:
        original = "# Title\n\nBody\n"
        path = self.write("doc.md", original)
        code, payload = self.run_json("publish", str(path))
        self.assertEqual(code, 0, payload)
        data = payload["data"]
        self.assertTrue(data["created"])
        self.assertTrue(data["uri"].startswith("gist:"))
        for call in self.api_calls():
            self.assertIn("--hostname", call["argv"])
            hostname = call["argv"][call["argv"].index("--hostname") + 1]
            self.assertEqual(hostname, "github.com")
            self.assertIsNone(call["GITHUB_TOKEN"])
            self.assertEqual(call["GH_TOKEN"], "keep-me")
        posts = [
            call
            for call in self.api_calls()
            if "POST" in call["argv"] and "/gists" in call["argv"]
        ]
        self.assertEqual(len(posts), 1)
        post_payload = json.loads(posts[0]["stdin"])
        self.assertEqual(
            post_payload,
            {"public": False, "files": {"doc.md": {"content": original}}},
        )
        patches = [
            call for call in self.api_calls() if "PATCH" in call["argv"]
        ]
        self.assertEqual(len(patches), 1)
        patch_payload = json.loads(patches[0]["stdin"])
        self.assertEqual(
            patch_payload["files"]["doc.md"]["content"],
            path.read_text(),
        )
        gist_id = data["uri"].removeprefix("gist:").split("?")[0]
        self.assertEqual(
            self.gists()[gist_id]["files"]["doc.md"], path.read_text()
        )

    def test_public_flag_rides_creation(self) -> None:
        path = self.write("doc.md", "Body\n")
        code, _ = self.run_json("publish", str(path), "--public")
        self.assertEqual(code, 0)
        posts = [call for call in self.api_calls() if "POST" in call["argv"]]
        self.assertTrue(json.loads(posts[0]["stdin"])["public"])

    def test_truncated_read_is_too_large(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        self.set_control(truncated=True)
        path.write_text(path.read_text() + "edit\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "too_large")

    def test_size_limit_refuses_before_any_write(self) -> None:
        path = self.write("big.md", "x" * (901 * 1024) + "\n")
        code, payload = self.run_json("publish", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "too_large")
        self.assertEqual(self.api_calls(), [])
        self.assertIsNone(CLI.load_journal(path.resolve()))

    def test_missing_file_within_gist(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        gist_id = list(self.gists())[0]
        store = self.gists()
        store[gist_id]["files"] = {"other.md": "something\n"}
        (self.gh_dir / "gists.json").write_text(json.dumps(store))
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "target_missing")
        code, payload = self.run_json("status", str(path))
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state"], "missing")

    def test_gist_gone_is_missing(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        (self.gh_dir / "gists.json").write_text("{}")
        code, payload = self.run_json("status", str(path))
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state"], "missing")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "target_missing")

    def test_auth_failure_is_reported(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        self.set_control(fail="auth")
        path.write_text(path.read_text() + "edit\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "target_error")

    def test_rename_rides_one_patch_and_rekeys_state(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        old_uri = self.file_uri(path)
        renamed = self.work / "renamed.md"
        path.rename(renamed)
        renamed.write_text(renamed.read_text() + "edit\n")
        code, payload = self.run_json(
            "publish", str(renamed), "--rename"
        )
        self.assertEqual(code, 0, payload)
        new_uri = self.file_uri(renamed)
        self.assertIn("file=renamed.md", new_uri)
        self.assertIsNone(CLI.load_state(old_uri))
        record = CLI.load_state(new_uri)
        self.assertEqual(
            record["base_sha256"], CLI.sha256_hex(renamed.read_bytes())
        )
        patches = [
            call for call in self.api_calls() if "PATCH" in call["argv"]
        ]
        rename_patch = json.loads(patches[-1]["stdin"])
        self.assertEqual(
            rename_patch["files"]["doc.md"]["filename"], "renamed.md"
        )
        gist_id = list(self.gists())[0]
        self.assertEqual(
            self.gists()[gist_id]["files"]["renamed.md"],
            renamed.read_text(),
        )
        self.assertIsNone(CLI.load_journal(renamed.resolve()))

    def test_name_mismatch_without_rename_warns(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.run_json("publish", str(path))
        moved = self.work / "other.md"
        path.rename(moved)
        moved.write_text(moved.read_text() + "edit\n")
        code, payload = self.run_json("sync", str(moved))
        self.assertEqual(code, 0, payload)
        self.assertTrue(
            any("differs" in note for note in payload["data"]["notes"])
        )
        self.assertIn("file=doc.md", payload["data"]["uri"])

    def test_link_resolves_single_file_gist(self) -> None:
        store = {"ab12cd34ef56ab12ffff": {"public": False, "files": {"notes.md": "Body\n"}}}
        (self.gh_dir / "gists.json").write_text(json.dumps(store))
        path = self.write("notes.md", "Body\n")
        code, payload = self.run_json(
            "link",
            str(path),
            "https://gist.github.com/user/ab12cd34ef56ab12ffff",
        )
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["matched"])
        self.assertEqual(
            payload["data"]["uri"], "gist:ab12cd34ef56ab12ffff?file=notes.md"
        )

    def test_link_multi_file_gist_lists_candidates(self) -> None:
        store = {
            "ab12cd34ef56ab12ffff": {
                "public": False,
                "files": {"a.md": "A\n", "b.md": "B\n"},
            }
        }
        (self.gh_dir / "gists.json").write_text(json.dumps(store))
        path = self.write("notes.md", "Body\n")
        code, payload = self.run_json(
            "link", str(path), "gist:ab12cd34ef56ab12ffff"
        )
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "ambiguous_file")
        self.assertEqual(
            payload["error"]["details"]["candidates"], ["a.md", "b.md"]
        )

    def test_doctor_reports_green(self) -> None:
        code, payload = self.run_json("doctor")
        self.assertEqual(code, 0, payload)
        data = payload["data"]
        self.assertTrue(data["ready"])
        self.assertTrue(data["state"]["writable"])
        checks = {check["name"]: check for check in data["targets"]["gist"]["checks"]}
        self.assertTrue(checks["gh on PATH"]["ok"])
        self.assertTrue(checks["gh auth (github.com)"]["ok"])


class ConcurrencyTests(GistShimTestCase):
    def test_racing_untagged_creates_serialize(self) -> None:
        self.set_control(create_delay=0.5)
        path = self.write("doc.md", "Body\n")
        env = os.environ.copy()
        commands = [
            [sys.executable, str(SCRIPT), "--json", "publish", str(path)]
            for _ in range(2)
        ]
        processes = [
            subprocess.Popen(
                command,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            for command in commands
        ]
        outputs = [process.communicate(timeout=120) for process in processes]
        for process, (stdout, stderr) in zip(processes, outputs):
            self.assertEqual(process.returncode, 0, (stdout, stderr))
        posts = [call for call in self.api_calls() if "POST" in call["argv"]]
        self.assertEqual(len(posts), 1)
        payloads = [json.loads(stdout)["data"] for stdout, _ in outputs]
        created = [data for data in payloads if data.get("created")]
        synced = [
            data for data in payloads if data.get("state_before") == "synced"
        ]
        self.assertEqual(len(created), 1)
        self.assertEqual(len(synced), 1)
        self.assertEqual(
            path.read_text().count("x-pub"), 1
        )


class SkillTests(PubTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.home = self.temp / "home"
        self.home.mkdir()
        patcher = mock.patch.dict(os.environ, {"HOME": str(self.home)})
        patcher.start()
        self.addCleanup(patcher.stop)
        self.skill_dir = self.home / ".claude" / "skills" / "pub-sync"
        self.skill_file = self.skill_dir / "SKILL.md"

    def test_embedded_skill_has_version_marker(self) -> None:
        self.assertTrue(
            CLI.SKILL_MD.endswith("<!-- pub-skill-version: 1 -->\n")
        )
        self.assertIn("x-pub", CLI.SKILL_MD)
        self.assertIn("pub sync", CLI.SKILL_MD)

    def test_install_status_uninstall(self) -> None:
        code, payload = self.run_json("skill", "install")
        self.assertEqual(code, 0, payload)
        self.assertEqual(self.skill_file.read_text(), CLI.SKILL_MD)
        code, payload = self.run_json("skill", "status", "--user")
        self.assertEqual(code, 0)
        self.assertEqual(
            payload["data"]["locations"][0]["state"], "current"
        )
        code, payload = self.run_json("skill", "uninstall")
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["removed"])
        self.assertFalse(self.skill_file.exists())
        self.assertFalse(self.skill_dir.exists())

    def test_reinstall_over_current_is_ok(self) -> None:
        self.run_json("skill", "install")
        code, payload = self.run_json("skill", "install")
        self.assertEqual(code, 0, payload)

    def test_foreign_file_refused_without_force(self) -> None:
        self.skill_dir.mkdir(parents=True)
        self.skill_file.write_text("someone else's skill\n")
        code, payload = self.run_json("skill", "install")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "skill_file_foreign")
        code, payload = self.run_json("skill", "uninstall")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "skill_file_foreign")
        code, payload = self.run_json("skill", "install", "--force")
        self.assertEqual(code, 0, payload)
        self.assertEqual(self.skill_file.read_text(), CLI.SKILL_MD)

    def test_symlinked_skill_dir_refused(self) -> None:
        real_dir = self.temp / "elsewhere"
        real_dir.mkdir()
        self.skill_dir.parent.mkdir(parents=True)
        self.skill_dir.symlink_to(real_dir)
        code, payload = self.run_json("skill", "install")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "skill_dir_symlink")
        code, payload = self.run_json("skill", "uninstall")
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "skill_dir_symlink")

    def test_uninstall_keeps_dir_with_user_files(self) -> None:
        self.run_json("skill", "install")
        extra = self.skill_dir / "notes.txt"
        extra.write_text("mine\n")
        code, payload = self.run_json("skill", "uninstall")
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["removed"])
        self.assertFalse(payload["data"]["removed_dir"])
        self.assertTrue(extra.exists())

    def test_dir_location_is_resolved(self) -> None:
        destination = self.temp / "agent-skills"
        destination.mkdir()
        code, payload = self.run_json(
            "skill", "install", "--dir", str(destination)
        )
        self.assertEqual(code, 0, payload)
        installed = destination.resolve() / "pub-sync" / "SKILL.md"
        self.assertEqual(payload["data"]["path"], str(installed))
        self.assertEqual(installed.read_text(), CLI.SKILL_MD)

    def test_show_prints_embedded_skill(self) -> None:
        code, out, _ = self.run_main("skill", "show")
        self.assertEqual(code, 0)
        self.assertEqual(out, CLI.SKILL_MD)


class PublishAsTests(PubTestCase):
    def test_as_creates_under_published_name(self) -> None:
        path = self.write("___quilted-walrus.md", "# Plan\n\nBody\n")
        code, payload = self.run_json(
            "publish", str(path), "--target", "fake",
            "--as", "clickhouse-plan.md",
        )
        self.assertEqual(code, 0, payload)
        data = payload["data"]
        self.assertTrue(data["created"])
        self.assertTrue(data["uri"].endswith("?file=clickhouse-plan.md"))
        self.assertEqual(path.name, "___quilted-walrus.md")
        self.assertIn("file=clickhouse-plan.md", path.read_text())
        self.assertEqual(self.target.store["doc1"], path.read_bytes())

    def test_as_renames_synced_tagged_file(self) -> None:
        # The primary use-case: content unchanged, only the published
        # name is wrong. A synced state must not block the rename.
        path = self.write("___raspy-onion.md", "Body\n")
        self.publish(path)
        code, payload = self.run_json(
            "publish", str(path), "--as", "migration-plan.md"
        )
        self.assertEqual(code, 0, payload)
        data = payload["data"]
        self.assertEqual(data["state_before"], "synced")
        self.assertTrue(data["uri"].endswith("?file=migration-plan.md"))
        self.assertEqual(data["renamed_to"], "migration-plan.md")
        self.assertIn("file=migration-plan.md", path.read_text())
        self.assertIsNone(
            CLI.load_state("fake:doc1?file=___raspy-onion.md")
        )
        record = CLI.load_state("fake:doc1?file=migration-plan.md")
        self.assertEqual(
            record["base_sha256"], CLI.sha256_hex(path.read_bytes())
        )
        self.assertEqual(self.target.store["doc1"], path.read_bytes())
        self.assertIsNone(CLI.load_journal(path.resolve()))

    def test_as_matching_current_name_is_noop(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        code, payload = self.run_json(
            "publish", str(path), "--as", "doc.md"
        )
        self.assertEqual(code, 0, payload)
        self.assertEqual(payload["data"]["state_before"], "synced")
        self.assertNotIn("notes", payload["data"])

    def test_steady_state_sync_is_quiet_about_deliberate_name(self) -> None:
        path = self.write("___scratch-name.md", "Body\n")
        self.publish(path, "--as", "plan.md")
        path.write_text(path.read_text() + "edit\n")
        code, payload = self.run_json("sync", str(path))
        self.assertEqual(code, 0, payload)
        self.assertTrue(payload["data"]["uri"].endswith("?file=plan.md"))
        self.assertNotIn("notes", payload["data"])

    def test_as_conflicts_with_rename(self) -> None:
        path = self.write("doc.md", "Body\n")
        code, payload = self.run_json(
            "publish", str(path), "--as", "x.md", "--rename"
        )
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "usage_error")

    def test_as_single_file_only(self) -> None:
        first = self.write("a.md", "A\n")
        second = self.write("b.md", "B\n")
        code, payload = self.run_json(
            "publish", str(first), str(second), "--target", "fake",
            "--as", "x.md",
        )
        self.assertEqual(code, 1)
        self.assertEqual(payload["error"]["code"], "usage_error")

    def test_as_rejects_invalid_names(self) -> None:
        path = self.write("doc.md", "Body\n")
        for bad in ("a/b.md", "..", "bad\nname", ""):
            code, payload = self.run_json(
                "publish", str(path), "--target", "fake", "--as", bad
            )
            self.assertEqual(code, 1, bad)
            self.assertIn(
                payload["error"]["code"],
                {"invalid_filename", "usage_error"},
            )

    def test_as_routes_through_default_command(self) -> None:
        parser, _ = CLI.build_parser()
        namespace = parser.parse_args(
            CLI.normalize_argv(["notes.md", "--as", "plan.md"])
        )
        self.assertEqual(namespace.command, "publish")
        self.assertEqual(namespace.publish_as, "plan.md")


class GistPublishAsTests(GistShimTestCase):
    def test_as_create_payload_uses_published_name(self) -> None:
        path = self.write("___fuzzy-lemur.md", "# Plan\n")
        code, payload = self.run_json(
            "publish", str(path), "--as", "atlantis-plan.md"
        )
        self.assertEqual(code, 0, payload)
        posts = [call for call in self.api_calls() if "POST" in call["argv"]]
        post_payload = json.loads(posts[0]["stdin"])
        self.assertEqual(list(post_payload["files"]), ["atlantis-plan.md"])
        gist_id = next(iter(self.gists()))
        self.assertEqual(
            self.gists()[gist_id]["files"]["atlantis-plan.md"],
            path.read_text(),
        )
        self.assertIn("file=atlantis-plan.md", payload["data"]["uri"])

    def test_as_rename_rides_one_patch(self) -> None:
        path = self.write("___fuzzy-lemur.md", "# Plan\n")
        self.run_json("publish", str(path))
        code, payload = self.run_json(
            "publish", str(path), "--as", "atlantis-plan.md"
        )
        self.assertEqual(code, 0, payload)
        patches = [
            call for call in self.api_calls() if "PATCH" in call["argv"]
        ]
        rename_patch = json.loads(patches[-1]["stdin"])
        spec = rename_patch["files"]["___fuzzy-lemur.md"]
        self.assertEqual(spec["filename"], "atlantis-plan.md")
        self.assertEqual(spec["content"], path.read_text())
        gist_id = next(iter(self.gists()))
        self.assertEqual(
            list(self.gists()[gist_id]["files"]), ["atlantis-plan.md"]
        )


class OpenFlagTests(PubTestCase):
    def open_calls(self, *argv: str) -> list:
        with mock.patch.object(CLI.webbrowser, "open") as opened:
            code, _, _ = self.run_main(*argv)
        self.assertEqual(code, 0)
        return opened.call_args_list

    def test_explicit_open_opens_the_gist(self) -> None:
        path = self.write("doc.md", "Body\n")
        calls = self.open_calls(
            "publish", str(path), "--target", "fake", "--open"
        )
        self.assertEqual(
            [call.args[0] for call in calls], ["https://fake.example/doc1"]
        )

    def test_no_open_suppresses(self) -> None:
        path = self.write("doc.md", "Body\n")
        calls = self.open_calls(
            "publish", str(path), "--target", "fake", "--no-open"
        )
        self.assertEqual(calls, [])

    def test_non_interactive_default_does_not_open(self) -> None:
        # run_main captures stdout in a StringIO, so isatty is False.
        path = self.write("doc.md", "Body\n")
        calls = self.open_calls("publish", str(path), "--target", "fake")
        self.assertEqual(calls, [])

    def test_interactive_default_opens(self) -> None:
        self.assertTrue(CLI.auto_open_enabled(None, False, False) is False)
        tty_stdout = mock.Mock()
        tty_stdout.isatty.return_value = True
        with mock.patch.object(CLI.sys, "stdout", tty_stdout):
            self.assertTrue(CLI.auto_open_enabled(None, False, False))
            self.assertFalse(CLI.auto_open_enabled(None, True, False))
            self.assertFalse(CLI.auto_open_enabled(None, False, True))
            with mock.patch.dict(os.environ, {"PUB_NO_OPEN": "1"}):
                self.assertFalse(CLI.auto_open_enabled(None, False, False))
                self.assertTrue(CLI.auto_open_enabled(True, False, False))

    def test_sync_supports_open_flag(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text() + "edit\n")
        calls = self.open_calls("sync", str(path), "--open")
        self.assertEqual(len(calls), 1)

    def test_batch_opens_each_url_once(self) -> None:
        first = self.write("a.md", "A\n")
        second = self.write("b.md", "B\n")
        calls = self.open_calls(
            "publish", str(first), str(second), "--target", "fake", "--open"
        )
        self.assertEqual(len(calls), 2)


class OutputTests(PubTestCase):
    def test_publish_line_is_structured(self) -> None:
        path = self.write("doc.md", "Body\n")
        code, out, err = self.run_main(
            "publish", str(path), "--target", "fake"
        )
        self.assertEqual(code, 0, err)
        self.assertIn("✓", out)
        self.assertIn("published (new)", out)
        self.assertIn("https://fake.example/doc1", out)
        self.assertIn("unlisted, not private", out)
        self.assertNotIn("\x1b[", out)

    def test_noop_publish_reports_already_synced(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        code, out, _ = self.run_main("sync", str(path))
        self.assertEqual(code, 0)
        self.assertIn("already synced", out)

    def test_status_line_shows_state(self) -> None:
        path = self.write("doc.md", "Body\n")
        self.publish(path)
        path.write_text(path.read_text() + "edit\n")
        code, out, _ = self.run_main("status", str(path))
        self.assertEqual(code, 0)
        self.assertIn("ahead", out)
        self.assertIn("!", out)

    def test_batch_failures_go_to_stderr(self) -> None:
        good = self.write("good.md", "Body\n")
        self.publish(good)
        bad = self.write("bad.md", "Body\n")
        code, out, err = self.run_main("sync", str(good), str(bad))
        self.assertEqual(code, 1)
        self.assertIn("already synced", out)
        self.assertIn("✗", err)
        self.assertIn("bad.md", err)

    def test_quiet_suppresses_success_output(self) -> None:
        path = self.write("doc.md", "Body\n")
        code, out, _ = self.run_main(
            "--quiet", "publish", str(path), "--target", "fake"
        )
        self.assertEqual(code, 0)
        self.assertEqual(out, "")

    def test_empty_list_prints_hint(self) -> None:
        code, out, _ = self.run_main("list")
        self.assertEqual(code, 0)
        self.assertIn("nothing tracked yet", out)

    def test_doctor_output_is_sectioned(self) -> None:
        _, out, _ = self.run_main("doctor")
        self.assertIn("state", out)
        self.assertIn("skill", out)
        self.assertIn("✓", out)


class HelpTests(unittest.TestCase):
    def normalized_help(self, *argv: str) -> str:
        completed = subprocess.run(
            [sys.executable, str(SCRIPT), *argv, "--help"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)
        return " ".join(completed.stdout.split())

    def test_top_level_help_documents_the_contracts(self) -> None:
        output = self.normalized_help()
        self.assertIn("unlisted, not private", output)
        self.assertIn("pub publish -- status", output)
        self.assertIn("recreating the gist", output)

    def test_publish_help_documents_visibility(self) -> None:
        output = self.normalized_help("publish")
        self.assertIn("creation only", output)
        self.assertIn("--allow-sensitive", output)


if __name__ == "__main__":
    unittest.main(verbosity=2)
