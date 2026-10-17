"""Session discovery and CLI shared with session_links.py. Standard library only."""

import argparse
from contextlib import closing, contextmanager
import json
import os
from pathlib import Path
import re
import selectors
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
from urllib.parse import urlsplit

UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
LINK = re.compile(rf"(?<![\w+.-])(?:codex://threads|claude://(?:sessions|threads))/({UUID})(?![\w/?#%-])", re.I)
ACTIONS = ("info", "open", "focus", "resume", "preview", "transcript", "uri", "resume-command")


def identity(uri=None, codex=None, claude=None):
    if sum(bool(x) for x in (uri, codex, claude)) != 1:
        raise ValueError("Specify exactly one of --uri, --codex-session, --claude-session")
    if uri:
        parsed = urlsplit(uri)
        agent = parsed.scheme.lower()
        hosts = {"codex": ("threads",), "claude": ("sessions", "threads")}
        if (agent not in hosts or parsed.netloc not in hosts[agent]
                or parsed.query or parsed.fragment or "?" in uri or "#" in uri):
            raise ValueError("Expected codex://threads/UUID or claude://sessions/UUID")
        sid = parsed.path.removeprefix("/")
    else:
        agent, sid = ("codex", codex) if codex else ("claude", claude)
    if not re.fullmatch(UUID, sid, re.I):
        raise ValueError("Session ID must be a full UUID")
    return agent, sid.lower()


def session_uri(agent, sid):
    return f"{agent}://{'threads' if agent == 'codex' else 'sessions'}/{sid}"


def resume_command(agent, sid):
    return [agent, "resume" if agent == "codex" else "--resume", sid]


def rc(endpoint, *args):
    cmd = ["kitty", "@"]
    if endpoint:
        cmd += ["--to", endpoint]
    result = subprocess.run(cmd + list(args), text=True, capture_output=True, timeout=10)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"Kitty exited {result.returncode}")
    return result.stdout.strip()


def kitty_windows(endpoint):
    # Never return child environments. Retain all user vars of matching windows only.
    return [dict(id=w["id"], tab_id=tab["id"], os_window_id=osw["id"],
                 title=w.get("title", ""), cwd=w.get("cwd"),
                 is_focused=w.get("is_focused", False), user_vars=w.get("user_vars", {}))
            for osw in json.loads(rc(endpoint, "ls"))
            for tab in osw["tabs"] for w in tab["windows"]]


@contextmanager
def transcript_file(path):
    path = Path(path).expanduser()
    if path.suffix == ".zst":
        # Optional; no dependency is needed for ordinary JSONL transcripts.
        with subprocess.Popen(["zstd", "-dc", "--", str(path)], stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL, text=True, errors="replace") as proc:
            try:
                yield proc.stdout
            finally:
                proc.stdout.close()
                if proc.poll() is None:
                    proc.terminate()
    else:
        with path.open(encoding="utf-8", errors="replace") as stream:
            yield stream


def records(path):
    with transcript_file(path) as stream:
        for line in stream:
            try:
                record = json.loads(line)
            except ValueError:
                continue  # Includes an in-progress final JSONL write.
            if isinstance(record, dict):
                yield record


def transcript_metadata(path, agent, sid):
    result = {}
    for index, record in enumerate(records(path)):
        if index >= 128:
            break
        if agent == "codex" and record.get("type") == "session_meta":
            payload = record.get("payload", {})
            if payload.get("id", "").lower() != sid:
                raise ValueError(f"Transcript identity does not match {sid}: {path}")
            return {"cwd": payload.get("cwd"), "transcript_path": str(path)}
        if agent == "claude" and record.get("sessionId", "").lower() == sid:
            result["transcript_path"] = str(path)
            if record.get("cwd"):
                result["cwd"] = record["cwd"]
                return result
    return result


def local_metadata(agent, sid, warnings):
    if agent == "codex":
        home = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser()
        dbs = sorted((p for p in home.glob("state_*.sqlite")
                      if re.fullmatch(r"state_\d+\.sqlite", p.name)),
                     key=lambda p: int(p.stem.split("_")[1]), reverse=True)
        if dbs:
            try:
                import sqlite3
            except ImportError:
                # Some Kitty bundles omit the shared SQLite library. Rollout
                # headers still work in that interpreter; the CLI uses uv's.
                sqlite3 = None
        else:
            sqlite3 = None
        if sqlite3 is not None:
            try:
                with closing(sqlite3.connect(dbs[0].resolve().as_uri() + "?mode=ro", uri=True, timeout=1)) as conn:
                    conn.row_factory = sqlite3.Row
                    columns = {r[1] for r in conn.execute("PRAGMA table_info(threads)")}
                    wanted = [c for c in ("id", "cwd", "rollout_path", "title", "model", "archived") if c in columns]
                    if "id" in wanted:
                        row = conn.execute(f"SELECT {','.join(wanted)} FROM threads WHERE id = ?", (sid,)).fetchone()
                        if row:
                            result = dict(row)
                            result.pop("id")
                            result["transcript_path"] = result.pop("rollout_path", None)
                            return result, f"sqlite:{dbs[0]}"
            except sqlite3.Error as exc:
                warnings.append(f"Codex index unavailable: {exc}")
        paths = [p for directory in ("sessions", "archived_sessions")
                 for p in (home / directory).glob(f"**/*-{sid}.jsonl*")
                 if p.name.endswith((".jsonl", ".jsonl.zst"))]
    else:
        home = Path(os.environ.get("CLAUDE_CONFIG_DIR", "~/.claude")).expanduser()
        paths = list((home / "projects").glob(f"*/{sid}.jsonl"))
    if len(paths) > 1:
        raise ValueError(f"Multiple transcripts for {sid}; specify --transcript-path")
    if paths:
        return transcript_metadata(paths[0], agent, sid), f"transcript:{paths[0]}"
    return {}, None


def app_server_metadata(sid, timeout=10):
    """Initialize a temporary stdio server and read metadata, without resuming a turn."""
    with tempfile.TemporaryFile() as errors, subprocess.Popen(
        ["codex", "app-server"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=errors,
    ) as proc, selectors.DefaultSelector() as selector:
        selector.register(proc.stdout, selectors.EVENT_READ)
        pending = b""
        deadline = time.monotonic() + timeout

        def send(message):
            proc.stdin.write(json.dumps(message).encode() + b"\n")
            proc.stdin.flush()

        def response(request_id):
            nonlocal pending
            while True:
                while b"\n" in pending:
                    line, pending = pending.split(b"\n", 1)
                    message = json.loads(line)
                    if message.get("id") == request_id:
                        if "error" in message:
                            raise RuntimeError(message["error"].get("message", str(message["error"])))
                        return message["result"]
                remaining = deadline - time.monotonic()
                if remaining <= 0 or not selector.select(remaining):
                    raise RuntimeError("Codex app-server timed out")
                chunk = os.read(proc.stdout.fileno(), 65536)
                if not chunk:
                    errors.seek(0)
                    detail = errors.read(65536).decode("utf-8", "replace").strip()[-2000:]
                    raise RuntimeError(f"Codex app-server closed before responding: {detail}")
                pending += chunk
        try:
            send({"id": 1, "method": "initialize", "params": {
                "clientInfo": {"name": "agent-session", "version": "1"}}})
            response(1)
            send({"method": "initialized"})
            send({"id": 2, "method": "thread/read", "params": {"threadId": sid, "includeTurns": False}})
            return response(2)["thread"]
        finally:
            proc.stdin.close()
            if proc.poll() is None:
                proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()


def gather(agent, sid, windows=(), *, window_id=None, transcript_path=None, app_server=False):
    matches = [w for w in windows if w["user_vars"].get(f"{agent.upper()}_SESSION_ID", "").lower() == sid]
    selected = [w for w in matches if w["id"] == window_id] if window_id else matches
    if window_id and not selected:
        raise ValueError(f"Window {window_id} does not belong to {session_uri(agent, sid)}")
    result = dict(agent=agent, session_id=sid, uri=session_uri(agent, sid),
                  cwd=None, transcript_path=None, windows=matches, sources=[], warnings=[])
    # Do not collapse conflicting metadata from several live clients.
    if len(selected) == 1:
        window = selected[0]
        values = window["user_vars"]
        for field in ("cwd", "transcript_path", "model", "permission_mode"):
            result[field] = values.get(f"{agent.upper()}_{field.upper()}")
        result["cwd"] = result["cwd"] or window.get("cwd")
        result["window_id"] = window["id"]
        result["sources"].append("kitty-user-vars")
    if not result["cwd"] or not result["transcript_path"]:
        metadata, source = local_metadata(agent, sid, result["warnings"]) if not transcript_path else ({}, None)
        for key, value in metadata.items():
            if not result.get(key):
                result[key] = value
        if source:
            result["sources"].append(source)
    if app_server:
        if agent != "codex":
            raise ValueError("--app-server is only supported for Codex")
        thread = app_server_metadata(sid)
        if thread["id"] != sid:
            raise ValueError("Codex app-server returned a different thread")
        result["app_server"] = thread
        for key, remote in (("cwd", "cwd"), ("transcript_path", "path"), ("model", "model")):
            if not result.get(key):
                result[key] = thread.get(remote)
        result["sources"].append("codex-app-server")
    if transcript_path:
        path = Path(transcript_path).expanduser().resolve()
        metadata = transcript_metadata(path, agent, sid)
        if not metadata:
            raise ValueError(f"No matching session metadata in {path}")
        result["transcript_path"] = str(path)
        result["cwd"] = result["cwd"] or metadata.get("cwd")
        result["sources"].append(f"transcript:{path}")
    result["resume_command"] = resume_command(agent, sid)
    result["found"] = bool(matches or result["sources"])
    return result


def select_window(data, window_id=None):
    matches = [w for w in data["windows"] if not window_id or w["id"] == window_id]
    if not matches:
        raise ValueError("No matching Kitty window")
    if len(matches) != 1:
        raise ValueError("Session is in multiple Kitty windows; choose --window-id from: " +
                         ", ".join(str(w["id"]) for w in matches))
    return matches[0]


def resume_cwd(data, override=None):
    cwd = override or data.get("cwd")
    if not cwd:
        raise ValueError("Session working directory is unknown; specify --cwd")
    path = Path(cwd).expanduser().resolve()
    if not path.is_dir():
        raise ValueError(f"Session working directory no longer exists: {path}; specify --cwd")
    return str(path)


def clean_text(text):
    # Render transcript content as text, never as terminal control/OSC sequences.
    return "".join(c for c in text if c in "\n\t" or (ord(c) >= 32 and not 127 <= ord(c) <= 159))


def content_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(content_text(item) for item in content)
    if isinstance(content, dict):
        for key in ("text", "thinking", "content"):
            if key in content:
                return content_text(content[key])
        return json.dumps(content, ensure_ascii=False, indent=2)
    return ""


def transcript_lines(data):
    path = data.get("transcript_path")
    if not path:
        raise ValueError("No transcript found; specify --transcript-path")
    yield f"{data['uri']}\n{path}\n\n"
    for record in records(path):
        if data["agent"] == "codex":
            if record.get("type") != "response_item":
                continue  # event_msg often duplicates response_item messages.
            item = record.get("payload", {})
            role = item.get("role") or item.get("type", "event")
            body = content_text(item.get("content", item.get("output", item.get("arguments", ""))))
            if item.get("name"):
                role += f" ({item['name']})"
        else:
            if record.get("type") not in ("user", "assistant"):
                continue
            message = record.get("message", {})
            role = message.get("role", record["type"])
            body = content_text(message.get("content", ""))
        if body:
            yield clean_text(f"## {role}\n\n{body}\n\n")


def preview(data):
    # A temporary file keeps large transcripts out of argv and memory; less reads
    # plain text without -r/-R. Its lifetime is exactly the overlay's lifetime.
    with tempfile.TemporaryFile(mode="w+", encoding="utf-8") as stream:
        for text in transcript_lines(data):
            stream.write(clean_text(text))
        stream.seek(0)
        if shutil.which("less"):
            subprocess.run(["less", "-+F", "-+X"], stdin=stream, check=True,
                           env={**os.environ, "LESSSECURE": "1"})
        else:
            shutil.copyfileobj(stream, sys.stdout)
            input("\nPress Enter to close")


def preview_command(data, kitty="kitty"):
    # argv is passed directly to launch. Python repr quotes data, never a shell.
    module = str(Path(__file__).resolve())
    payload = {key: data.get(key) for key in ("agent", "uri", "transcript_path")}
    return [kitty, "+runpy", f"import runpy; runpy.run_path({module!r})['preview']({payload!r})"]


def parser():
    p = argparse.ArgumentParser(prog="agent-session", description="Look up, focus, resume, or preview a Codex/Claude session.")
    source = p.add_mutually_exclusive_group(required=True)
    source.add_argument("--uri")
    source.add_argument("--codex-session", metavar="UUID")
    source.add_argument("--claude-session", metavar="UUID")
    p.add_argument("--action", choices=ACTIONS, default="info",
                   help="open focuses an existing window or resumes; resume always launches (default: info)")
    p.add_argument("--type", choices=("tab", "window", "os-window"), default="tab", help="resume destination (default: tab)")
    p.add_argument("--window-id", type=int, help="choose a matching session window when several exist")
    p.add_argument("--source-window", type=int, help="Kitty window to launch beside or overlay")
    p.add_argument("--to", default=os.environ.get("KITTY_LISTEN_ON"), help="Kitty remote-control endpoint")
    p.add_argument("--no-kitty", action="store_true", help="look up local records without querying Kitty")
    p.add_argument("--cwd", help="override the working directory when resuming")
    p.add_argument("--transcript-path", help="explicit transcript with matching session metadata")
    p.add_argument("--app-server", action="store_true", help="also query a temporary Codex stdio app-server with thread/read")
    return p


def cli(argv=None):
    args = parser().parse_args(argv)
    try:
        agent, sid = identity(args.uri, args.codex_session, args.claude_session)
        if args.action in ("uri", "resume-command"):
            print(session_uri(agent, sid) if args.action == "uri" else shlex.join(resume_command(agent, sid)))
            return 0
        windows, connection_error = [], None
        if not args.no_kitty:
            try:
                windows = kitty_windows(args.to)
            except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
                connection_error = str(exc)
        data = gather(agent, sid, windows, window_id=args.window_id,
                      transcript_path=args.transcript_path, app_server=args.app_server)
        if connection_error:
            data["warnings"].append(connection_error)
        if args.action == "info":
            print(json.dumps(data, indent=2, ensure_ascii=False))
            return 0 if data["found"] else 1
        if args.action == "transcript":
            for text in transcript_lines(data):
                print(clean_text(text), end="")
            return 0
        if connection_error or args.no_kitty:
            raise ValueError(connection_error or "This action requires a Kitty connection")
        if args.action == "focus" or (args.action == "open" and data["windows"]):
            window = select_window(data, args.window_id)
            # Recheck ownership at action time; do not focus a reused/switching pane.
            match = f"id:{window['id']} and var:{agent.upper()}_SESSION_ID=^{sid}$"
            rc(args.to, "focus-window", "--match", match)
            return 0
        source = args.source_window or int(os.environ.get("KITTY_WINDOW_ID", "0"))
        source_window = next((w for w in windows if w["id"] == source), None)
        if args.source_window and not source_window:
            raise ValueError(f"Source window {source} does not exist on this Kitty connection")
        launch = ["launch", f"--type={'overlay' if args.action == 'preview' else args.type}"]
        if source_window:
            launch += ["--source-window", f"id:{source}", "--match", f"window_id:{source}"]
            if args.action != "preview":
                launch += ["--next-to", f"id:{source}"]
        if args.action == "preview":
            if not data["transcript_path"] or not Path(data["transcript_path"]).expanduser().is_file():
                raise ValueError("No readable transcript found; specify --transcript-path")
            command = preview_command(data)
        else:
            launch += ["--cwd", resume_cwd(data, args.cwd)]
            command = data["resume_command"]
        print(rc(args.to, *launch, "--title", f"{agent}: {sid[:8]}", "--", *command))
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"agent-session: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(cli())
