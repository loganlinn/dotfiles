"""Exercise preview files, links, cache lifecycle, and the packaged CLI contract."""

from __future__ import annotations

import base64
import json
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "lib"))
from mdpreview import cli  # noqa: E402

PANDOC = shutil.which("pandoc")
RIPGREP = shutil.which("rg")


class CacheTests(unittest.TestCase):
    def test_native_cache_locations(self):
        with patch.dict(
            os.environ, {"HOME": "/test/home", "XDG_CACHE_HOME": "/test/cache"}
        ):
            with patch.object(sys, "platform", "darwin"):
                self.assertEqual(
                    cli.cache_root(), Path("/test/home/Library/Caches/mdpreview")
                )
            with patch.object(sys, "platform", "linux"):
                self.assertEqual(cli.cache_root(), Path("/test/cache/mdpreview"))
                for value in ("", "relative/cache"):
                    with patch.dict(os.environ, {"XDG_CACHE_HOME": value}):
                        self.assertEqual(
                            cli.cache_root(), Path("/test/home/.cache/mdpreview")
                        )


class MermaidAssetsTests(unittest.TestCase):
    def test_only_image_shape_fields_embed_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            image = root / "icon's.svg"
            image.write_text('<svg xmlns="http://www.w3.org/2000/svg"/>')
            uri = (
                "data:image/svg+xml;base64,"
                + base64.b64encode(image.read_bytes()).decode()
            )
            for value in (
                '"icon\'s.svg"',
                "'icon''s.svg'",
                "icon's.svg",
                "icon%27s.svg",
                json.dumps(image.as_uri()),
            ):
                with self.subTest(value=value):
                    source = "flowchart LR\n  A@{ img: " + value + ', label: "Icon" }\n'
                    self.assertIn(uri, cli.embed_mermaid_images(source, root))
            for source in (
                "flowchart LR\n  A[\"Example @{ img: 'missing.svg' }\"]\n",
                'flowchart LR\n  %% A@{ img: "missing.svg" }\n  A --> B\n',
                'flowchart LR\n  A@{ label: "img: missing.svg", shape: rect }\n',
                'flowchart LR\n  A@{ img: "https://example.com/icon.svg" }\n',
                'flowchart LR\n  A@{ img: "' + uri + '" }\n',
            ):
                with self.subTest(source=source):
                    self.assertEqual(cli.embed_mermaid_images(source, root), source)


@unittest.skipUnless(PANDOC and RIPGREP, "Pandoc and ripgrep are required")
class PreviewTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="mdpreview-tests-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.docs = self.root / "docs & notes"
        self.docs.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.record = self.root / "opened"
        for name in ("open", "xdg-open"):
            path = self.bin / name
            path.write_text(
                '#!/bin/sh\nprintf "%s\\n" "$1" >> "$MDPREVIEW_OPEN_RECORD"\n'
            )
            path.chmod(0o755)
        self.env = dict(os.environ)
        self.env.pop("MDPREVIEW_THEME", None)
        self.env.update(
            {
                "HOME": str(self.root / "home"),
                "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
                "XDG_CACHE_HOME": str(self.root / "cache"),
                "XDG_CONFIG_HOME": str(self.root / "config"),
                "MDPREVIEW_OPEN_RECORD": str(self.record),
                "TMPDIR": str(self.root / "nonexistent-temporary-directory"),
            }
        )

    def write(self, name, text):
        path = self.docs / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def invoke(self, *args, data=None, success=True):
        stdin = {"stdin": subprocess.DEVNULL} if data is None else {"input": data}
        result = subprocess.run(
            [sys.executable, str(ROOT / "bin/mdpreview"), *map(str, args)],
            cwd=self.docs,
            env=self.env,
            capture_output=True,
            text=True,
            **stdin,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def preview(self, *args, **kwargs):
        result = self.invoke("--no-open", *args, **kwargs)
        path = Path(result.stdout.rstrip("\n"))
        self.assertTrue(path.is_file(), result.stdout)
        return path

    def test_default_directory_rebuild_add_delete_and_keep_unowned_files(self):
        first = self.write("README.md", "# Original\n")
        self.write("nested/second.markdown", "# Second\n")
        index = self.preview()
        self.assertEqual(index.name, "index.html")
        self.assertIn("README.md", index.read_text())
        self.assertIn("nested/second.markdown", index.read_text())
        self.assertIn("docs &amp; notes", index.read_text())
        user_file = index.parent / "pages/keep.html"
        user_file.write_text("Unrelated content")
        first.unlink()
        self.write("new.MD", "# New\n")
        self.assertEqual(self.preview(), index)
        self.assertFalse((index.parent / "pages/README.md.html").exists())
        self.assertTrue((index.parent / "pages/new.MD.html").exists())
        self.assertEqual(user_file.read_text(), "Unrelated content")
        self.assertNotIn("README.md", index.read_text())
        self.assertFalse(self.record.exists())
        self.assertEqual(list(self.root.rglob(".build-*")), [])
        self.assertEqual(list(self.root.rglob(".mdpreview-*")), [])
        manifest = json.loads(next(self.root.rglob("manifest.json")).read_text())
        self.assertEqual(manifest["entrypoint"], str(index))
        self.assertEqual(manifest["kind"], "directory")

    def test_links_images_raw_html_and_fragments(self):
        source = self.write(
            "README.md",
            """# Readme

[Next](nested/notes%20%23%25.md#part)
[Directory](nested/)
[Here](#readme)
[Remote](https://example.com/file.md#section)
![Diagram](images/diagram%20%26.svg)
<img src="images/diagram%20%26.svg" alt="raw">
""",
        )
        self.write("nested/notes #%.md", "# Part\n\n[Back](../README.md)\n")
        self.write("nested/README.md", "# Nested directory\n")
        asset = self.write("images/diagram &.svg", "<svg/>")
        index = self.preview(self.docs)
        rendered = (index.parent / "pages/README.md.html").read_text()
        self.assertIn('href="nested/notes%20%23%25.md.html#part"', rendered)
        self.assertIn('href="nested/README.md.html"', rendered)
        self.assertIn('href="#readme"', rendered)
        self.assertIn('href="https://example.com/file.md#section"', rendered)
        self.assertEqual(rendered.count(f'src="{asset.as_uri()}"'), 2)
        nested = (index.parent / "pages/nested/notes #%.md.html").read_text()
        self.assertIn('href="../README.md.html"', nested)
        self.assertIn('href="../../index.html"', nested)
        single = self.preview(source)
        self.assertIn(f'src="{asset.as_uri()}"', single.read_text())
        self.assertIn(
            (self.docs / "nested/notes #%.md").as_uri() + "#part", single.read_text()
        )

    def test_ignore_rules_all_and_symlink_cycles(self):
        subprocess.run(
            ["git", "init", "--quiet", str(self.docs)], check=True, env=self.env
        )
        self.write(".gitignore", "ignored/\n")
        self.write(".ignore", "also-ignored.md\n")
        self.write("README", "# Visible\n")
        self.write("ignored/secret.md", "# Ignored\n")
        self.write("also-ignored.md", "# Ignored\n")
        self.write(".hidden/file.md", "# Hidden\n")
        self.write(".git/internal.md", "# Git metadata\n")
        (self.docs / "cycle").symlink_to(self.docs, target_is_directory=True)
        (self.docs / "alias.md").symlink_to(self.docs / "README")
        index = self.preview(self.docs)
        self.assertIn("README", index.read_text())
        for name in (
            "secret.md",
            "also-ignored.md",
            ".hidden/file.md",
            "internal.md",
            "alias.md",
            "cycle",
        ):
            self.assertNotIn(name, index.read_text())
        self.assertEqual(self.preview("--all", self.docs), index)
        for name in ("secret.md", "also-ignored.md", ".hidden/file.md"):
            self.assertIn(name, index.read_text())
        for name in ("internal.md", "alias.md", "cycle"):
            self.assertNotIn(name, index.read_text())

    def test_file_cache_identity_and_updates(self):
        first = self.write("one/notes.md", "# First\n")
        second = self.write("two/notes.md", "# Second\n")
        output = self.preview(first)
        self.assertNotEqual(output, self.preview(second))
        alias = self.docs / "alias.md"
        alias.symlink_to(first)
        self.assertEqual(output, self.preview(alias))
        first.write_text("# Updated\n")
        self.assertEqual(output, self.preview(first))
        self.assertIn("Updated", output.read_text())
        self.assertEqual(len(list(self.root.rglob("manifest.json"))), 2)

    def test_explicit_output_and_browser_flags_are_independent(self):
        source = self.write("notes.md", "# Content\n")
        chosen = self.root / "chosen output/result.html"
        self.assertEqual(self.preview("--output", chosen, source), chosen)
        self.assertFalse(self.record.exists())
        self.assertIn("--bg:", chosen.read_text())
        self.invoke("--no-open", "--open", "-o", chosen, source)
        self.assertEqual(self.record.read_text(), f"{chosen}\n")
        self.invoke("--open", "--no-open", f"--output={chosen}", source)
        self.assertEqual(self.record.read_text(), f"{chosen}\n")
        site = self.root / "chosen site"
        self.assertEqual(self.preview("-o", site, self.docs), site / "index.html")

    def test_stdin_reuses_a_working_directory_preview_and_resolves_images(self):
        asset = self.write("image.svg", "<svg/>")
        output = self.preview(data="# First\n\n![Image](image.svg)\n")
        self.assertIn(asset.as_uri(), output.read_text())
        self.assertEqual(self.preview("-", data="# Second\n"), output)
        self.assertIn("Second", output.read_text())
        self.assertNotIn("First", output.read_text())
        self.assertEqual(len(list(self.root.rglob("manifest.json"))), 1)
        source = self.write("selected.md", "# Explicit input\n")
        self.assertIn(
            "Explicit input", self.preview(source, data="# Ignored stdin\n").read_text()
        )
        result = self.invoke("-", data="", success=False)
        self.assertEqual(result.returncode, 2)

    def test_failed_directory_rebuild_preserves_previous_preview(self):
        self.write("a.md", "# Original\n")
        broken = self.write("z.md", "# Last\n")
        index = self.preview(self.docs)
        manifest = next(self.root.rglob("manifest.json"))
        original = {
            path: path.read_bytes()
            for path in [index, manifest, *index.parent.rglob("pages/*.html")]
        }
        self.write("a.md", "# Changed\n")
        self.write("new.md", "# New\n")
        broken.write_text("FAIL_CONVERSION\n")
        converter = self.bin / "pandoc"
        converter.write_text(
            '#!/bin/bash\nif /usr/bin/grep -q FAIL_CONVERSION "${!#}"; then\n'
            '  echo "Conversion failed for test" >&2\n  exit 23\nfi\n'
            f'exec {shlex.quote(PANDOC)} "$@"\n'
        )
        converter.chmod(0o755)
        result = self.invoke(self.docs, success=False)
        self.assertIn("Conversion failed for test", result.stderr)
        self.assertIn("pandoc.log", result.stderr)
        self.assertNotIn("Preview ready:", result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertFalse(self.record.exists())
        for path, content in original.items():
            self.assertEqual(path.read_bytes(), content, str(path))
        self.assertFalse((index.parent / "pages/new.md.html").exists())
        self.assertEqual(list(self.root.rglob(".build-*")), [])

    def test_empty_directory_and_colliding_source_stems(self):
        index = self.preview(self.docs)
        self.assertIn("No Markdown files found", index.read_text())
        self.write("index.md", "# Markdown index\n")
        self.write("index.markdown", "# Another index\n")
        self.write('odd "< &\n雪.md', "# Unusual filename\n")
        self.assertEqual(self.preview(self.docs), index)
        self.assertIn(
            "Markdown index", (index.parent / "pages/index.md.html").read_text()
        )
        self.assertIn(
            "Another index", (index.parent / "pages/index.markdown.html").read_text()
        )
        self.assertIn("odd &quot;&lt; &amp;\n雪.md", index.read_text())
        self.assertIn("%22%3C%20%26%0A%E9%9B%AA.md.html", index.read_text())

    def test_rejects_output_that_would_replace_input_or_theme(self):
        source = self.write("notes.md", "# Keep this\n")
        theme = self.write("custom.css", "body { color: blue; }\n")
        for args in (
            ("-o", source, source),
            ("--theme", theme, "-o", theme, source),
            ("-o", self.docs, source),
            ("-o", source, self.docs),
            ("-o", self.docs, self.docs),
            ("-o", self.root, self.docs),
            ("--output=-", source),
        ):
            result = self.invoke(*args, success=False)
            self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(source.read_text(), "# Keep this\n")
        self.assertEqual(theme.read_text(), "body { color: blue; }\n")

    def test_output_directory_is_excluded_from_recursive_discovery(self):
        self.write("notes.md", "# Source\n")
        output = self.docs / "generated"
        output.mkdir()
        (output / "unrelated.md").write_text("# Keep out of the index\n")
        index = self.preview("--all", "-o", output, self.docs)
        self.assertNotIn("unrelated.md", index.read_text())
        self.assertIn("notes.md", index.read_text())

    def test_custom_theme_path_is_a_valid_url(self):
        source = self.write("notes.md", "# Content\n")
        theme = self.write("theme #&.css", "body { color: blue; }\n")
        output = self.preview("--theme", theme, source)
        self.assertIn(f'href="{theme.as_uri()}"', output.read_text())

    def test_github_markdown_features(self):
        source = self.write(
            "github.md",
            """# 123. Hello, world!

www.example.com and ~~removed~~ and :smile:.

- [x] Done
- [ ] Pending

| Feature | Support |
| --- | --- |
| GFM | Yes |

> [!NOTE]
> A useful note.

> [!TIP]
> A useful tip.

> [!IMPORTANT]
> An important point.

> [!WARNING]
> A warning.

> [!CAUTION]
> A caution.

A footnote[^source] and $x^2$ and $`y^2`$.

[^source]: Reference text.

```math
E = mc^2
```

<details>
<summary>More</summary>

**Details**

</details>
""",
        )
        rendered = self.preview(source).read_text()
        self.assertIn('id="123-hello-world"', rendered)
        self.assertIn('href="http://www.example.com"', rendered)
        self.assertIn("<del>removed</del>", rendered)
        self.assertIn('class="emoji"', rendered)
        self.assertIn('disabled type="checkbox" checked=""', rendered)
        self.assertIn('disabled type="checkbox" />Pending', rendered)
        self.assertIn("<table>", rendered)
        for kind in ("note", "tip", "important", "warning", "caution"):
            self.assertIn(f'<div class="{kind}">', rendered)
        self.assertIn('role="doc-noteref"', rendered)
        self.assertIn("Reference text.", rendered)
        self.assertEqual(rendered.count('class="math inline"'), 2)
        self.assertIn('class="math display"', rendered)
        self.assertIn("<strong>Details</strong>", rendered)
        self.assertNotIn("mermaid.esm.min.mjs", rendered)

    def test_mermaid_in_file_stdin_directory_and_custom_theme(self):
        markdown = "```mermaid\nflowchart LR\n  A[Markdown] --> B[Preview]\n```\n"
        source = self.write("diagram.md", markdown)
        theme = self.write("light.css", "body { background: white; color: black; }\n")
        outputs = [
            self.preview(source),
            self.preview("-", data=markdown),
            self.preview("--theme", theme, source),
        ]
        index = self.preview(self.docs)
        outputs.append(index.parent / "pages/diagram.md.html")
        for output in outputs:
            rendered = output.read_text()
            self.assertIn('<pre class="mermaid"><code>flowchart LR', rendered)
            self.assertIn("A[Markdown] --&gt; B[Preview]", rendered)
            self.assertEqual(rendered.count("mermaid.esm.min.mjs"), 1)
            self.assertIn('<script type="module">', rendered)
            self.assertLess(
                rendered.index("mermaid.esm.min.mjs"), rendered.rindex("</body>")
            )
        self.assertNotIn("mermaid.esm.min.mjs", index.read_text())

    def test_mermaid_source_stays_escaped_and_other_fences_stay_code(self):
        rendered = self.preview(
            "-", data='```mermaid\nflowchart LR\n  A["</script><img src=x>"]\n```\n'
        ).read_text()
        self.assertIn("&lt;/script&gt;&lt;img src=x&gt;", rendered)
        self.assertNotIn("</script><img", rendered)
        rendered = self.preview(
            "-", data="```text\nmermaid\nflowchart LR\n  A --> B\n```\n"
        ).read_text()
        self.assertIn("flowchart LR", rendered)
        self.assertNotIn("mermaid.esm.min.mjs", rendered)

    def test_mermaid_embeds_images_relative_to_file_stdin_and_directory_sources(self):
        asset = self.write(
            "images/icon #&.svg", '<svg xmlns="http://www.w3.org/2000/svg"/>'
        )
        image_uri = (
            "data:image/svg+xml;base64," + base64.b64encode(asset.read_bytes()).decode()
        )
        markdown = '```mermaid\nflowchart LR\n  A@{ img: "../images/icon%20%23%26.svg" }\n```\n'
        source = self.write("nested/diagram.md", markdown)
        file_html = self.preview(source).read_text()
        stdin_html = self.preview(
            "-", data=markdown.replace("../images/", "images/")
        ).read_text()
        index = self.preview(self.docs)
        directory_html = (index.parent / "pages/nested/diagram.md.html").read_text()
        for rendered in (file_html, stdin_html, directory_html):
            self.assertIn("data-mdpreview-source=", rendered)
            self.assertIn(image_uri, rendered)
            self.assertIn("img: &quot;", rendered)
            self.assertIn("images/icon%20%23%26.svg&quot; }", rendered)
            self.assertNotIn("data-mdpreview-error=", rendered)

    def test_mermaid_missing_image_keeps_source_and_does_not_fail_conversion(self):
        rendered = self.preview(
            "-", data='```mermaid\nflowchart LR\n  A@{ img: "missing.svg" }\n```\n'
        ).read_text()
        self.assertIn('data-mdpreview-error="Cannot read local Mermaid image', rendered)
        self.assertIn("img: &quot;missing.svg&quot;", rendered)
        self.assertNotIn("data-mdpreview-source=", rendered)

    def test_recursive_discovery_excludes_other_cache_entries(self):
        self.env["HOME"] = str(self.docs / "home")
        self.env["XDG_CACHE_HOME"] = str(self.docs / "cache")
        self.preview("-", data="# Cached stdin\n")
        self.write("notes.md", "# Source\n")
        index = self.preview("--all", self.docs)
        self.assertNotIn("stdin.md", index.read_text())
        self.assertIn("notes.md", index.read_text())

    def test_concurrent_rebuilds_share_a_stable_output_and_serialize_conversion(self):
        source = self.write("notes.md", "# Content\n")
        self.env["MDPREVIEW_TEST_ACTIVE"] = str(self.root / "converter-active")
        converter = self.bin / "pandoc"
        converter.write_text(
            '#!/bin/sh\nset -eu\nmkdir "$MDPREVIEW_TEST_ACTIVE"\n'
            "trap 'rmdir \"$MDPREVIEW_TEST_ACTIVE\"' EXIT\n"
            "sleep 0.1\n"
            f'{shlex.quote(PANDOC)} "$@"\n'
        )
        converter.chmod(0o755)
        with ThreadPoolExecutor(max_workers=2) as executor:
            futures = [executor.submit(self.preview, source) for _ in range(2)]
            paths = [future.result() for future in futures]
        self.assertEqual(paths[0], paths[1])
        self.assertIn("Content", paths[0].read_text())
        self.assertEqual(list(self.root.rglob(".build-*")), [])
        self.assertFalse((self.root / "converter-active").exists())


if __name__ == "__main__":
    unittest.main()
