#!/usr/bin/env python3
"""Build stable local previews. Discovery and rendering do not start a watcher."""

from __future__ import annotations

import base64
import fcntl
import hashlib
import html
import json
import mimetypes
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote, unquote, urlsplit

USAGE = "Usage: mdpreview [OPTIONS] [--] [PATH|-]"
HELP = (
    USAGE
    + """

Convert Markdown to HTML with Pandoc and open it in a browser.
Use GitHub Flavored Markdown, including Mermaid diagrams.
Mermaid and math rendering require browser access to their CDN libraries.

Arguments:
  PATH                A Markdown file or a directory to browse recursively.
  -                   Read Markdown from standard input, including a terminal.
                      With no PATH, use piped/redirected input, otherwise PWD.

Options:
  -h, --help          Show this information and exit.
  -o, --output PATH   Write to this HTML file, or this directory for a site.
  --open             Open the preview in a browser (default).
  --no-open          Generate the preview without opening a browser.
  -a, --all          Include hidden and ignored files in directory previews.
  --theme THEME      Use a CSS file or a named theme. Also accepts --theme=THEME.
  --                 Treat remaining arguments as paths.

Directory previews contain an index and a page for each Markdown file.
Discovery skips hidden and ignored files by default, like Glow.
The .git directory, cache, output directory, and symlinks are always skipped.
Directory previews report scan and render progress on standard error.
The command prints the absolute HTML path after a successful invocation.
--output does not change whether the browser opens. The last open flag wins.

Themes:
  Names use ${XDG_CONFIG_HOME:-$HOME/.config}/mdpreview/themes.
  A name can include or omit .css. Explicit CSS paths also work.
  MDPREVIEW_THEME sets the default theme. --theme has precedence.
  With no theme, use the built-in dark theme.

Cache:
  macOS: $HOME/Library/Caches/mdpreview
  Linux: ${XDG_CACHE_HOME:-$HOME/.cache}/mdpreview
  Repeated previews of the same source reuse the same HTML path.
  Standard input reuses one preview per working directory.
  Refresh the browser after rerunning the command to see new content.
  File watching and automatic browser refresh are not implemented.

Examples:
  mdpreview
  mdpreview ./docs
  mdpreview --no-open --output ./preview.html README.md
  mdpreview --no-open --output ./preview-site ./docs
  mdpreview --theme ocean README.md
  cat README.md | mdpreview
  mdpreview - < README.md
  mdpreview -- --notes.md

Exit status:
  0  The command succeeded.
  1  A required command is unavailable, or an operation failed.
  2  An argument, input path, or theme is invalid.
"""
)
MARKDOWN_SUFFIXES = {".md", ".markdown", ".mdown", ".mkd", ".mkdn"}


class PreviewError(Exception):
    def __init__(self, message: str, status: int = 1):
        super().__init__(message)
        self.status = status


@dataclass
class Options:
    path: str | None = None
    output: str | None = None
    theme: str = ""
    open_browser: bool = True
    all_files: bool = False


def parse_args(args: list[str]) -> Options | None:
    options = Options(theme=os.environ.get("MDPREVIEW_THEME", ""))
    parse_options = True
    index = 0
    while index < len(args):
        arg = args[index]
        index += 1
        if parse_options:
            if arg in ("-h", "--help"):
                return None
            if arg == "--":
                parse_options = False
                continue
            if arg in ("--open", "--no-open"):
                options.open_browser = arg == "--open"
                continue
            if arg in ("-a", "--all"):
                options.all_files = True
                continue
            flag, equals, value = arg.partition("=")
            if flag in ("--theme", "-o", "--output"):
                if not equals:
                    if index == len(args) or args[index].startswith("-"):
                        raise PreviewError(
                            f"{flag} requires a value. Use {flag}=PATH for a path that starts with '-'.",
                            2,
                        )
                    value = args[index]
                    index += 1
                if not value:
                    raise PreviewError(f"{flag} requires a nonempty value.", 2)
                if flag == "--theme":
                    options.theme = value
                else:
                    options.output = value
                continue
            if arg.startswith("-") and arg != "-" and not Path(arg).exists():
                raise PreviewError(
                    f"Unknown option: '{arg}'. For a path that starts with '-', use -- before the path.",
                    2,
                )
        if not arg:
            raise PreviewError(
                "The input path is empty. Specify a path or use - for standard input.",
                2,
            )
        if options.path is not None:
            raise PreviewError(
                f"Expected one Markdown input. Unexpected argument: '{arg}'.", 2
            )
        options.path = arg
    return options


def cache_root() -> Path:
    if sys.platform == "darwin":
        return Path.home() / "Library/Caches/mdpreview"
    xdg = Path(os.environ.get("XDG_CACHE_HOME", ""))
    # XDG requires absolute paths; a relative value must be ignored.
    base = xdg if xdg.is_absolute() else Path.home() / ".cache"
    return base / "mdpreview"


def resolve_theme(name: str) -> Path | None:
    if not name:
        return None
    directory = (
        Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
        / "mdpreview/themes"
    )
    candidates = [Path(name), directory / name, directory / (name + ".css")]
    for path in candidates:
        if path.is_file():
            if not os.access(path, os.R_OK):
                raise PreviewError(
                    f"Cannot read theme file: '{path}'. Check the file permissions.", 2
                )
            return path.resolve()
    raise PreviewError(
        f"Theme not found: '{name}'. Use a CSS file or a name from {directory}.", 2
    )


def require_command(name: str, package: str) -> str:
    command = shutil.which(name)
    if command is None:
        raise PreviewError(
            f"{name} is not installed or is not on PATH. Install {package} and try again."
        )
    return command


def log_progress(message: str) -> None:
    print(f"mdpreview: {message}", file=sys.stderr, flush=True)


def discover(
    root: Path, all_files: bool = False, exclude: tuple[Path, ...] = ()
) -> list[Path]:
    """Use ripgrep's ignore rules and NUL-delimited paths, including outside Git."""
    command = [require_command("rg", "ripgrep"), "--no-config", "--files", "--null"]
    if all_files:
        command += ["--hidden", "--no-ignore"]
    command += ["--glob", "!.git", "--glob", "!**/.git/**", "--", str(root)]
    result = subprocess.run(command, capture_output=True)
    if result.returncode not in (0, 1):
        raise PreviewError(
            f"Cannot scan '{root}': {result.stderr.decode(errors='replace').strip()}"
        )
    files = []
    for raw in result.stdout.split(b"\0"):
        if not raw:
            continue
        path = Path(os.fsdecode(raw))
        if path.is_symlink() or any(path.is_relative_to(item) for item in exclude):
            continue
        if path.suffix.lower() in MARKDOWN_SUFFIXES or path.name.lower() == "readme":
            files.append(path)
    return sorted(
        files, key=lambda path: (str(path.relative_to(root)).casefold(), str(path))
    )


def atomic_write(path: Path, data: bytes) -> None:
    """Replace one complete file, including when the destination is on another disk."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix=".mdpreview-", dir=path.parent, delete=False
        ) as stream:
            temporary = Path(stream.name)
            stream.write(data)
        temporary.replace(path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def relative_url(target: Path, page: Path) -> str:
    return quote(os.path.relpath(target, page.parent), safe="/")


def embed_mermaid_images(definition: str, source_dir: Path) -> str:
    """Embed local image-shape assets without rewriting quoted labels or comments."""
    double_quoted = r'"(?:\\.|[^"\\])*"'
    quoted = double_quoted + r"|'(?:''|[^'])*'"
    # Mermaid's shape lexer protects double-quoted text inside @{...}.
    tokens = re.compile(
        rf"%%[^\n]*|{quoted}|(?P<shape>@\{{(?:{double_quoted}|[^\"{{}}])*\}})",
        re.DOTALL,
    )
    fields = re.compile(
        rf"""(?P<key>(?<![\w.-])(?:img|"img"|'img')\s*:\s*)"""
        rf"(?P<value>{quoted}|[^,{{}}\n]+)|{quoted}",
        re.DOTALL,
    )

    def embed_field(match: re.Match) -> str:
        if match.group("key") is None:
            return match.group()
        value = match.group("value").strip()
        if value.startswith('"'):
            try:
                value = json.loads(value)
            except json.JSONDecodeError:
                return match.group()
        elif value.startswith("'"):
            value = value[1:-1].replace("''", "'")
        url = urlsplit(value)
        if (
            url.scheme not in ("", "file")
            or (url.netloc and not (url.scheme == "file" and url.netloc == "localhost"))
            or not url.path
        ):
            return match.group()
        path = (source_dir / unquote(url.path)).resolve()
        mime = mimetypes.guess_type(path.name)[0]
        if mime is None or not mime.startswith("image/"):
            raise ValueError(
                f"Unknown image format for local Mermaid image: '{value}'."
            )
        try:
            data = base64.b64encode(path.read_bytes()).decode("ascii")
        except OSError as error:
            raise ValueError(
                f"Cannot read local Mermaid image '{value}': {error.strerror}."
            ) from error
        uri = f"data:{mime};base64,{data}"
        if url.fragment:
            uri += "#" + url.fragment
        return match.group("key") + json.dumps(uri)

    def embed_shape(match: re.Match) -> str:
        shape = match.group("shape")
        return fields.sub(embed_field, shape) if shape else match.group()

    return tokens.sub(embed_shape, definition)


class PreviewLinks(HTMLParser):
    """Keep local links and images valid after moving HTML away from its source."""

    def __init__(self, source_dir: Path, page: Path, pages: dict[Path, Path]):
        super().__init__(convert_charrefs=False)
        self.source_dir = source_dir
        self.page = page
        self.pages = pages
        self.parts: list[str] = []
        self.has_mermaid = False
        self.mermaid_start: int | None = None
        self.mermaid_text: list[str] = []

    def rewrite_url(self, value: str, is_link: bool) -> str:
        url = urlsplit(value)
        if url.scheme or url.netloc or not url.path:
            return value
        source = (self.source_dir / unquote(url.path)).resolve()
        target = self.pages.get(source) if is_link else None
        path = relative_url(target, self.page) if target else source.as_uri()
        return (
            path
            + ("?" + url.query if url.query else "")
            + ("#" + url.fragment if url.fragment else "")
        )

    def start_tag(
        self, tag: str, attrs: list[tuple[str, str | None]], ending: str
    ) -> None:
        if tag == "pre" and "mermaid" in (dict(attrs).get("class") or "").split():
            self.has_mermaid = True
            self.mermaid_start = len(self.parts)
            self.mermaid_text = []
        rewritten = []
        changed = False
        if (
            tag == "input"
            and dict(attrs).get("type") == "checkbox"
            and "disabled" not in dict(attrs)
        ):
            rewritten.append(("disabled", None))
            changed = True
        for name, value in attrs:
            new_value = value
            if value and name in ("href", "src", "poster"):
                new_value = self.rewrite_url(value, name == "href" and tag == "a")
            changed |= value != new_value
            rewritten.append((name, new_value))
        if not changed:
            self.parts.append(self.get_starttag_text())
            return
        attributes = "".join(
            f" {name}"
            if value is None
            else f' {name}="{html.escape(value, quote=True)}"'
            for name, value in rewritten
        )
        self.parts.append(f"<{tag}{attributes}{ending}")

    def handle_starttag(self, tag, attrs):
        self.start_tag(tag, attrs, ">")

    def handle_startendtag(self, tag, attrs):
        self.start_tag(tag, attrs, " />")

    def handle_endtag(self, tag):
        if tag == "pre" and self.mermaid_start is not None:
            source = html.unescape("".join(self.mermaid_text))
            try:
                embedded = embed_mermaid_images(source, self.source_dir)
                attribute = (
                    f' data-mdpreview-source="{html.escape(embedded, quote=True)}"'
                    if embedded != source
                    else ""
                )
            except ValueError as error:
                attribute = (
                    f' data-mdpreview-error="{html.escape(str(error), quote=True)}"'
                )
            opening = self.parts[self.mermaid_start]
            self.parts[self.mermaid_start] = opening[:-1] + attribute + ">"
            self.mermaid_start = None
            self.mermaid_text = []
        self.parts.append(f"</{tag}>")

    def handle_data(self, data):
        if self.mermaid_start is not None:
            self.mermaid_text.append(data)
        self.parts.append(data)

    def handle_entityref(self, name):
        if self.mermaid_start is not None:
            self.mermaid_text.append(f"&{name};")
        self.parts.append(f"&{name};")

    def handle_charref(self, name):
        if self.mermaid_start is not None:
            self.mermaid_text.append(f"&#{name};")
        self.parts.append(f"&#{name};")

    def handle_comment(self, data):
        self.parts.append(f"<!--{data}-->")

    def handle_decl(self, decl):
        self.parts.append(f"<!{decl}>")

    def handle_pi(self, data):
        self.parts.append(f"<?{data}>")


def report_log(message: str, log: Path) -> None:
    lines = log.read_text(errors="replace").splitlines()
    detail = f"\n{lines[0]}" if lines else ""
    raise PreviewError(f"{message}{detail}\nFull error log: {log}")


def theme_header(theme: Path | None) -> str:
    if theme:
        return (
            f'<link rel="stylesheet" href="{html.escape(theme.as_uri(), quote=True)}">'
        )
    css = Path(__file__).with_name("default.css").read_text()
    return f"<style>\n{css}</style>"


def render_file(
    source: Path,
    destination: Path,
    staged: Path,
    pages: dict[Path, Path],
    header: Path,
    theme: Path | None,
    log: Path,
    source_dir: Path,
    index: Path | None = None,
) -> None:
    """Render one file without replacing its last successful preview."""
    command = [
        "pandoc",
        "-s",
        "-f",
        "gfm",
        "-t",
        "html5",
        "--mathjax",
        # Inline CSS does not disable Pandoc's light document theme like --css does.
        "-M",
        "document-css=false",
        "-V",
        "highlighting-css=",
        "-M",
        f"pagetitle={source.name}",
    ]
    if theme:
        command += ["-c", theme.as_uri()]
    else:
        command += ["-H", str(header)]
    command += ["-o", str(staged), "--", str(source)]
    with log.open("wb") as errors:
        result = subprocess.run(command, stderr=errors, stdout=subprocess.DEVNULL)
    if result.returncode:
        report_log(f"Pandoc could not convert '{source}'.", log)
    sys.stderr.write(log.read_text(errors="replace"))
    parser = PreviewLinks(source_dir, destination, pages)
    parser.feed(staged.read_text())
    parser.close()
    content = "".join(parser.parts)
    if index is not None:
        nav = f'<nav aria-label="Documents"><a href="{relative_url(index, destination)}">All documents</a></nav>'
        content = content.replace("<body>", f"<body>\n{nav}", 1)
    if parser.has_mermaid:
        script = Path(__file__).with_name("mermaid.js").read_text()
        before, closing, after = content.rpartition("</body>")
        content = (
            before + f'<script type="module">\n{script}</script>\n' + closing + after
        )
    staged.write_text(content)


def render_index(root: Path, pages: dict[Path, Path], index: Path, header: str) -> str:
    title = html.escape(root.name or str(root))
    entries = "\n".join(
        f'<li><a href="{relative_url(target, index)}">{html.escape(str(source.relative_to(root)))}</a></li>'
        for source, target in pages.items()
    )
    listing = (
        f'<ul id="documents">{entries}</ul>'
        if pages
        else "<p>No Markdown files found.</p>"
    )
    return f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — Markdown documents</title>{header}</head>
<body><main><h1>{title}</h1>
<p>{len(pages)} Markdown documents</p>
<label for="filter">Filter documents</label>
<input id="filter" type="search" placeholder="File name or path" autofocus>
{listing}</main>
<script>
document.getElementById('filter').addEventListener('input', function () {{
  const query = this.value.toLocaleLowerCase();
  document.querySelectorAll('#documents li').forEach(function (item) {{
    item.hidden = !item.textContent.toLocaleLowerCase().includes(query);
  }});
}});
</script></body></html>
"""


def build_preview(
    options: Options,
    source: Path | None,
    stdin: bytes | None,
    theme: Path | None,
    entry: Path,
    output: Path | None,
) -> Path:
    """Build all pages first, then publish and remove only previously generated pages."""
    directory = source is not None and source.is_dir()
    if directory:
        site = output or entry / "site"
        index = site / "index.html"
        log_progress(f"Scanning {source}")
        files = discover(source, options.all_files, (cache_root().resolve(), site))
        noun = "file" if len(files) == 1 else "files"
        log_progress(f"Found {len(files)} Markdown {noun}.")
        pages = {
            path: site / "pages" / (str(path.relative_to(source)) + ".html")
            for path in files
        }
    else:
        if source is None:
            source = entry / "stdin.md"
            atomic_write(source, stdin or b"")
        index = output or entry / (source.stem + ".html")
        pages = {source: index}

    links = dict(pages)
    if directory:
        # Directory links prefer a README; the root itself opens the index.
        for path in pages:
            if path.stem.lower() == "readme":
                links.setdefault(path.parent, pages[path])
        links[source] = index

    manifest_path = entry / "manifest.json"
    previous = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    with tempfile.TemporaryDirectory(prefix=".build-", dir=entry) as temporary:
        stage = Path(temporary)
        header = stage / "header.html"
        header.write_text(theme_header(theme))
        rendered = []
        for number, (path, target) in enumerate(pages.items()):
            staged = stage / f"{number}.html"
            source_dir = Path.cwd() if stdin is not None else path.parent
            if directory:
                log_progress(
                    f"[{number + 1}/{len(pages)}] Rendering {path.relative_to(source)}"
                )
            render_file(
                path,
                target,
                staged,
                links,
                header,
                theme,
                entry / "pandoc.log",
                source_dir,
                index if directory else None,
            )
            rendered.append((target, staged))
        if directory:
            log_progress(f"Writing index and pages to {site}")
            staged_index = stage / "index.html"
            staged_index.write_text(
                render_index(source, pages, index, header.read_text())
            )
            rendered.append((index, staged_index))
        for target, staged in rendered:
            atomic_write(target, staged.read_bytes())

    if directory:
        removed = 0
        for old in previous.get("pages", {}).values():
            stale = Path(old)
            if (
                stale not in pages.values()
                and stale.is_relative_to(site / "pages")
                and stale.suffix == ".html"
            ):
                try:
                    stale.unlink()
                except FileNotFoundError:
                    pass
                else:
                    removed += 1
        if removed:
            noun = "page" if removed == 1 else "pages"
            log_progress(f"Removed {removed} stale {noun}.")
    manifest = {
        "version": 1,
        "source": str(Path.cwd()) if stdin is not None else str(source),
        "kind": "directory" if directory else "stdin" if stdin is not None else "file",
        "entrypoint": str(index),
        "theme": str(theme) if theme else None,
        "all_files": options.all_files,
        "pages": {str(path): str(target) for path, target in pages.items()},
    }
    atomic_write(
        manifest_path,
        (json.dumps(manifest, ensure_ascii=True, indent=2) + "\n").encode(),
    )
    if directory:
        log_progress(f"Preview ready: {index}")
    return index


def open_preview(path: Path, log: Path, *, show_progress: bool = False) -> None:
    opener = shutil.which("open" if sys.platform == "darwin" else "xdg-open")
    if opener is None:
        if show_progress:
            log_progress("No browser opener found. Open the HTML path manually.")
        return
    if show_progress:
        log_progress("Opening preview in the browser.")
    with log.open("wb") as errors:
        result = subprocess.run(
            [opener, str(path)], stderr=errors, stdout=subprocess.DEVNULL
        )
    if result.returncode:
        report_log(
            f"Could not open the preview in a browser. Open this file: {path}", log
        )
    sys.stderr.write(log.read_text(errors="replace"))


def run(options: Options) -> Path:
    path = options.path
    if path is None:
        # /dev/null is not piped Markdown. This also lets headless callers use PWD.
        path = "." if stat.S_ISCHR(os.fstat(sys.stdin.fileno()).st_mode) else "-"
    stdin = None
    source = None
    if path == "-":
        stdin = sys.stdin.buffer.read()
        if not stdin:
            raise PreviewError(
                "Standard input is empty. Specify a path or pipe Markdown to standard input.",
                2,
            )
    else:
        source = Path(path).resolve()
        if not source.exists():
            raise PreviewError(f"Input path not found: '{path}'.", 2)
        if not source.is_file() and not source.is_dir():
            raise PreviewError(
                f"Input is not a regular file or directory: '{path}'.", 2
            )
        if not os.access(source, os.R_OK):
            raise PreviewError(
                f"Cannot read input path: '{path}'. Check the file permissions.", 2
            )
    theme = resolve_theme(options.theme)
    output = Path(options.output).resolve() if options.output is not None else None
    directory = source is not None and source.is_dir()
    if options.output == "-":
        raise PreviewError("--output requires a filesystem path, not '-'.", 2)
    if output is not None:
        if directory and output.exists() and not output.is_dir():
            raise PreviewError(
                f"Directory input requires an output directory: '{output}'.", 2
            )
        if not directory and output.is_dir():
            raise PreviewError(f"File input requires an output file: '{output}'.", 2)
        if (
            output == source
            or output == theme
            or (directory and source.is_relative_to(output))
        ):
            raise PreviewError(
                "The output must not replace the input path, its parent, or the theme.",
                2,
            )
    require_command("pandoc", "pandoc")
    kind = "directories" if directory else "stdin" if source is None else "files"
    identity = str(source or Path.cwd()) + "\0" + str(output or "")
    key = hashlib.sha256(os.fsencode(identity)).hexdigest()
    entry = cache_root().resolve() / "v1" / kind / key
    try:
        entry.mkdir(parents=True, exist_ok=True, mode=0o700)
    except OSError as error:
        raise PreviewError(
            f"Cannot create cache directory '{entry}': {error.strerror}."
        ) from error
    # A second invocation cannot interleave a rebuild of the same preview.
    with (entry / "build.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            if directory:
                log_progress("Waiting for another invocation to finish this preview.")
            fcntl.flock(lock, fcntl.LOCK_EX)
        result = build_preview(options, source, stdin, theme, entry, output)
        if options.open_browser:
            open_preview(result, entry / "open.log", show_progress=directory)
    return result


def main(args: list[str] | None = None) -> int:
    try:
        options = parse_args(sys.argv[1:] if args is None else args)
        if options is None:
            print(HELP, end="")
            return 0
        os.umask(0o077)
        result = run(options)
        print(result)
        return 0
    except PreviewError as error:
        print(f"mdpreview: {error}", file=sys.stderr)
        if error.status == 2:
            print(
                f"\n{USAGE}\nRun 'mdpreview --help' for details and examples.",
                file=sys.stderr,
            )
        return error.status
    except (OSError, ValueError) as error:
        print(f"mdpreview: {error}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    raise SystemExit(main())
