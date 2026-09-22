# /// script
# dependencies = ["playwright"]
# ///
"""Browser integration: uv run test/test_mdpreview_browser.py.

Install Chromium with `uv run --with playwright playwright install chromium`,
or set MDPREVIEW_TEST_BROWSER to an existing Chromium executable.
These tests fetch the same public Mermaid CDN modules as a normal preview.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    sync_playwright = None

ROOT = Path(__file__).resolve().parents[1]
FLOW = "```mermaid\nflowchart LR\n  A[Markdown] --> B[Preview]\n```\n"
SEQUENCE = "```mermaid\nsequenceDiagram\n  Alice->>Bob: Hello\n```\n"
RENDERED = ".mermaid-diagram[data-rendered] > svg"


@unittest.skipUnless(
    sync_playwright and shutil.which("pandoc"), "Playwright and Pandoc are required"
)
class MermaidBrowserTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.playwright = sync_playwright().start()
        cls.addClassCleanup(cls.playwright.stop)
        cls.browser = cls.playwright.chromium.launch(
            executable_path=os.environ.get("MDPREVIEW_TEST_BROWSER"),
        )
        cls.addClassCleanup(cls.browser.close)

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="mdpreview-browser-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.context = self.browser.new_context()
        self.addCleanup(self.context.close)
        self.page = self.context.new_page()
        self.errors = []
        self.page.on("pageerror", lambda error: self.errors.append(str(error)))

    def preview(self, markdown, css=None):
        source = self.root / "source.md"
        source.write_text(markdown)
        env = dict(
            os.environ, HOME=str(self.root), XDG_CACHE_HOME=str(self.root / "cache")
        )
        env.pop("MDPREVIEW_THEME", None)
        args = [sys.executable, str(ROOT / "bin/mdpreview"), "--no-open"]
        if css is not None:
            theme = self.root / "theme.css"
            theme.write_text(css)
            args.extend(["--theme", str(theme)])
        result = subprocess.run(
            [*args, str(source)],
            capture_output=True,
            text=True,
            env=env,
            check=True,
        )
        self.page.goto(Path(result.stdout.strip()).as_uri())

    def test_valid_diagrams_render_on_both_sides_of_an_invalid_diagram(self):
        invalid = "```mermaid\nThis is not a Mermaid diagram.\n```\n"
        self.preview("# Mermaid\n\n" + FLOW + invalid + FLOW)
        self.page.wait_for_function(
            "document.querySelectorAll('.mermaid-diagram[data-rendered] > svg').length === 2"
        )
        self.assertEqual(self.page.locator(".mermaid-error").count(), 1)
        self.assertIn("This is not", self.page.locator("pre.mermaid").inner_text())
        self.assertEqual(self.page.locator("svg .node").count(), 4)
        for diagram in self.page.locator(".mermaid-diagram svg").all():
            self.assertIn("Markdown", diagram.text_content())
            self.assertGreater(diagram.bounding_box()["width"], 100)
            self.assertGreater(diagram.bounding_box()["height"], 20)
        self.assertEqual(self.errors, [])

    def test_custom_light_theme_and_html_labels(self):
        diagram = FLOW.replace("A[Markdown]", 'A["Markdown &amp; HTML"]')
        self.preview(diagram, "body { background: white; color: black; }")
        self.page.wait_for_selector(RENDERED)
        self.assertIn(
            "Markdown & HTML", self.page.locator("svg .nodeLabel").first.inner_text()
        )
        self.assertEqual(self.page.locator("pre.mermaid, .mermaid-error").count(), 0)
        self.assertEqual(self.errors, [])

    def test_local_image_is_visible_even_when_embedded_data_exceeds_source_limit(self):
        asset = self.root / "icon #&.svg"
        asset.write_text(
            '<svg xmlns="http://www.w3.org/2000/svg" width="80" height="60">'
            '<rect width="80" height="60" fill="red"/><!--'
            + "padding" * 8000
            + "--></svg>"
        )
        failures = []
        self.page.on("requestfailed", lambda request: failures.append(request.url))
        self.preview(
            '```mermaid\nflowchart LR\n  A@{ img: "icon%20%23%26.svg", label: "Icon", h: 60 }\n```\n'
        )
        self.page.wait_for_selector(RENDERED)
        image = self.page.locator(f"{RENDERED} image")
        self.assertEqual(image.count(), 1)
        href = image.get_attribute("href") or image.get_attribute("xlink:href")
        self.assertTrue(href.startswith("data:image/svg+xml;base64,"), href)
        self.assertGreater(len(href), 50000)
        # Decoding proves that the final SVG retained a usable image after sanitization.
        self.assertEqual(
            self.page.evaluate(
                """async url => {
            const image = new Image();
            image.src = url;
            await image.decode();
            return [image.naturalWidth, image.naturalHeight];
        }""",
                href,
            ),
            [80, 60],
        )
        self.assertEqual(self.page.locator("pre.mermaid, .mermaid-error").count(), 0)
        self.assertEqual(failures, [])
        self.assertEqual(self.errors, [])

    def test_missing_image_does_not_prevent_other_diagrams_rendering(self):
        missing = '```mermaid\nflowchart LR\n  A@{ img: "missing.svg" }\n```\n'
        self.preview(missing + FLOW)
        self.page.wait_for_selector(RENDERED)
        self.assertEqual(self.page.locator(".mermaid-error").count(), 1)
        self.assertIn(
            "Cannot read local Mermaid image",
            self.page.locator(".mermaid-error").inner_text(),
        )
        self.assertIn(
            'img: "missing.svg"', self.page.locator("pre.mermaid").inner_text()
        )
        self.assertEqual(self.errors, [])

    def test_css_color_spaces_and_transparency_choose_readable_themes(self):
        for background, expected in (
            ("oklch(0.2 0.02 270)", "rgb(211, 211, 211)"),
            ("color(display-p3 0.05 0.05 0.1)", "rgb(211, 211, 211)"),
            ("color-mix(in srgb, black 95%, white)", "rgb(211, 211, 211)"),
            ("rgba(0, 0, 0, 0.02)", "rgb(51, 51, 51)"),
        ):
            with self.subTest(background=background):
                self.preview(SEQUENCE, f"body {{ background: {background}; }}")
                self.page.wait_for_selector(RENDERED)
                fill = self.page.locator(f"{RENDERED} .messageText").evaluate(
                    "element => getComputedStyle(element).fill"
                )
                self.assertEqual(fill, expected)
        self.assertEqual(self.errors, [])

    def test_diagram_ids_do_not_replace_headings_or_temporary_id_collisions(self):
        self.preview(
            "# mdpreview mermaid 0\n\n# dmdpreview mermaid 1\n\n" + FLOW + FLOW
        )
        self.page.wait_for_function(
            "document.querySelectorAll('.mermaid-diagram[data-rendered] > svg').length === 2"
        )
        self.assertEqual(
            self.page.locator("h1").all_text_contents(),
            [
                "mdpreview mermaid 0",
                "dmdpreview mermaid 1",
            ],
        )
        self.assertEqual(self.page.locator("h1 > *, .mermaid-error").count(), 0)
        ids = self.page.locator("[id]").evaluate_all(
            "elements => elements.map(element => element.id)"
        )
        self.assertEqual(len(ids), len(set(ids)))
        self.assertEqual(self.errors, [])

    def test_offline_preview_preserves_source(self):
        self.context.route("https://cdn.jsdelivr.net/**", lambda route: route.abort())
        self.preview(FLOW)
        self.page.wait_for_selector(".mermaid-error")
        self.assertIn(
            "could not load", self.page.locator(".mermaid-error").inner_text()
        )
        self.assertIn(
            "A[Markdown] --> B[Preview]", self.page.locator("pre.mermaid").inner_text()
        )
        self.assertEqual(self.page.locator(".mermaid-diagram").count(), 0)
        self.assertEqual(self.errors, [])

    def test_other_fences_do_not_load_mermaid(self):
        requests = []
        self.page.on("request", lambda request: requests.append(request.url))
        self.preview("```text\nflowchart LR\n  A --> B\n```\n")
        self.assertIn("A --> B", self.page.locator("pre").inner_text())
        self.assertFalse(any("mermaid" in url for url in requests))
        self.assertEqual(self.errors, [])


if __name__ == "__main__":
    unittest.main()
