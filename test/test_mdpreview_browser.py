# /// script
# dependencies = ["playwright", "pymupdf"]
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
    import pymupdf
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
class BrowserTests(unittest.TestCase):
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


class LayoutBrowserTests(BrowserTests):
    TABLE = """| Address | Action | Reason |
| --- | --- | --- |
| `module.runtime.helm_release.cube` | Update | Only `images.lifecycleManager.tag`: r5 to r6 |
| `module.runtime.module.steel_runtime.terraform_data.steel_pod_security_gate` | Replace | Operator profile replaces Atlantis profile; reruns existing connectivity/security gate |
| `module.runtime.module.steel_runtime.terraform_data.steel_retirement_cleanup` | Update | Stores operator profile; destroy-only cleanup does not run |
"""

    def test_tables_use_window_width_and_stay_inside_small_viewports(self):
        self.page.set_viewport_size({"width": 1440, "height": 900})
        self.preview("# Reviewed plan\n\nProse stays readable.\n\n" + self.TABLE)
        prose = self.page.locator("p").bounding_box()
        table = self.page.locator("table").bounding_box()
        self.assertGreater(table["width"], prose["width"] + 200)
        self.assertGreaterEqual(table["x"], 23)
        self.assertLessEqual(table["x"] + table["width"], 1417)
        for width in (900, 390):
            self.page.set_viewport_size({"width": width, "height": 800})
            self.assertTrue(
                self.page.evaluate("document.documentElement.scrollWidth <= innerWidth")
            )
            self.assertTrue(
                self.page.locator(".mdpreview-table").evaluate(
                    "element => element.scrollWidth <= element.clientWidth + 1"
                )
            )
        self.assertEqual(self.errors, [])

    def test_pdf_keeps_table_cells_long_code_and_repeating_headers(self):
        token = "very_long_path/" * 30 + "command_end_marker"
        rows = "\n".join(
            f"| row_{index:03} | `{'long_identifier_' * 8}{index}` | reason_{index:03}_end |"
            for index in range(65)
        )
        self.preview(
            "# Print report\n\n"
            + self.TABLE
            + f"\n```bash\nexport VALUE={token}\n```\n\n"
            + "| Address | Action | Reason |\n| --- | --- | --- |\n"
            + rows
        )
        for paper in ("Letter", "A4"):
            with self.subTest(paper=paper):
                pdf = pymupdf.open(stream=self.page.pdf(format=paper), filetype="pdf")
                self.addCleanup(pdf.close)
                compact = "".join("".join(page.get_text().split()) for page in pdf)
                self.assertIn(token, compact)
                self.assertIn("rerunsexistingconnectivity/securitygate", compact)
                for index in range(65):
                    self.assertIn(f"row_{index:03}", compact)
                    self.assertIn(f"reason_{index:03}_end", compact)
                for page in pdf:
                    if "row_" in page.get_text():
                        self.assertIn("Address", page.get_text())
                    for word in page.get_text("words"):
                        self.assertGreaterEqual(word[0], 40)
                        self.assertLessEqual(word[2], page.rect.width - 40)
                    for block in page.get_text("dict")["blocks"]:
                        for line in block.get("lines", []):
                            for span in line["spans"]:
                                self.assertEqual(span["color"], 0x202124)
        self.assertEqual(self.errors, [])

    def test_print_overrides_custom_dark_themes(self):
        self.preview(
            "# Custom theme\n\n" + self.TABLE,
            "body { max-width: 30rem; background: #111; color: #eee; }"
            "code, th { color: pink; } table { display: block; overflow: auto; }",
        )
        self.page.emulate_media(media="print")
        self.assertEqual(
            self.page.locator("body").evaluate(
                "element => getComputedStyle(element).backgroundColor"
            ),
            "rgb(255, 255, 255)",
        )
        self.assertEqual(
            self.page.locator("code").first.evaluate(
                "element => getComputedStyle(element).color"
            ),
            "rgb(32, 33, 36)",
        )
        self.assertEqual(
            self.page.locator("table").evaluate(
                "element => getComputedStyle(element).display"
            ),
            "table",
        )


class ReaderBrowserTests(BrowserTests):
    DOCUMENT = (
        "# Start marker\n\n[Jump to end](#end-marker)\n\n"
        + "\n\n".join(
            f"## Section {index}\n\n"
            + (f"Paragraph {index}. Readable document text. " * 16)
            for index in range(18)
        )
        + "\n\n"
        + LayoutBrowserTests.TABLE
        + "\n\n# End marker\n\nFinal paragraph.\n"
    )

    def on_screen(self, selector):
        return self.page.locator(selector).evaluate("""element => {
            const viewport = document.querySelector('.mdpreview-viewport').getBoundingClientRect();
            return Array.from(element.getClientRects()).some(rect =>
                rect.left >= viewport.left - 1 && rect.right <= viewport.right + 1 &&
                rect.top >= viewport.top - 1 && rect.bottom <= viewport.bottom + 1);
        }""")

    def test_facing_pages_navigation_last_page_and_narrow_windows(self):
        self.page.set_viewport_size({"width": 1440, "height": 900})
        self.preview(self.DOCUMENT)
        self.page.get_by_role("button", name="Two pages", exact=True).click()
        status = self.page.locator(".mdpreview-page-status")
        self.assertRegex(status.inner_text(), r"^Pages 1–2 of \d+$")
        self.assertTrue(self.on_screen("#start-marker"))
        # Check actual painting: an overlaid sheet can hide text despite valid rects.
        pixels = pymupdf.Pixmap(self.page.locator(".mdpreview-viewport").screenshot())
        samples = pixels.samples
        for side in (0, 1):
            painted = sum(
                samples[y * pixels.stride + x * pixels.n] > 100
                for y in range(pixels.height)
                for x in range(side * pixels.width // 2, (side + 1) * pixels.width // 2)
            )
            self.assertGreater(painted, 500)
        self.assertTrue(
            self.page.get_by_role("button", name="Previous pages").is_disabled()
        )
        self.page.get_by_role("button", name="Next pages").click()
        self.assertRegex(status.inner_text(), r"^Pages 3–4 of \d+$")
        self.assertFalse(self.on_screen("#start-marker"))
        self.page.keyboard.press("End")
        self.assertTrue(
            self.page.get_by_role("button", name="Next pages").is_disabled()
        )
        self.assertTrue(self.on_screen("#end-marker"))
        self.page.set_viewport_size({"width": 600, "height": 900})
        self.page.wait_for_function(
            "document.querySelector('.mdpreview-page-status').textContent.startsWith('Page ')"
        )
        self.page.keyboard.press("End")
        self.assertTrue(self.on_screen("#end-marker"))
        self.page.keyboard.press("Home")
        self.assertRegex(status.inner_text(), r"^Page 1 of \d+$")
        self.assertTrue(
            self.page.evaluate("document.documentElement.scrollWidth <= innerWidth")
        )
        self.page.keyboard.press("ArrowRight")
        self.assertRegex(status.inner_text(), r"^Page 2 of \d+$")
        self.assertEqual(self.errors, [])

    def test_hash_navigation_focus_and_printing_preserve_the_whole_document(self):
        self.page.set_viewport_size({"width": 1440, "height": 900})
        self.preview(self.DOCUMENT)
        baseline = pymupdf.open(stream=self.page.pdf(format="Letter"), filetype="pdf")
        self.addCleanup(baseline.close)
        self.page.get_by_role("button", name="Two pages", exact=True).click()
        self.page.get_by_role("link", name="Jump to end").click()
        self.page.wait_for_function("location.hash === '#end-marker'")
        self.page.wait_for_function(
            "document.querySelector('[data-turn=\"1\"]').disabled"
        )
        self.assertTrue(self.on_screen("#end-marker"))
        printed = pymupdf.open(stream=self.page.pdf(format="Letter"), filetype="pdf")
        self.addCleanup(printed.close)
        self.assertEqual(
            "".join(page.get_text() for page in printed),
            "".join(page.get_text() for page in baseline),
        )
        self.page.locator("#section-3").evaluate(
            "element => { element.tabIndex = 0; element.focus(); }"
        )
        self.assertTrue(self.on_screen("#section-3"))
        self.page.get_by_role("button", name="Scroll", exact=True).click()
        self.assertFalse(self.page.locator(".mdpreview-pagination").is_visible())
        self.assertEqual(self.errors, [])

    def test_saved_view_custom_theme_and_late_content_reflow(self):
        self.preview(
            self.DOCUMENT,
            "body { max-width: 40rem; margin: auto; background: white; color: black; }",
        )
        self.page.get_by_role("button", name="Two pages", exact=True).click()
        self.page.reload()
        self.assertEqual(
            self.page.get_by_role("button", name="Two pages", exact=True).get_attribute(
                "aria-pressed"
            ),
            "true",
        )
        before = self.page.locator(".mdpreview-page-status").inner_text()
        self.page.locator(".mdpreview-document").evaluate("""element => {
            for (let index = 0; index < 100; index++) {
                const p = document.createElement('p');
                p.textContent = 'Late content added after page load. '.repeat(10);
                element.append(p);
            }
        }""")
        self.page.wait_for_function(
            "before => document.querySelector('.mdpreview-page-status').textContent !== before",
            arg=before,
        )
        self.page.keyboard.press("End")
        self.assertTrue(self.on_screen(".mdpreview-document > p:last-child"))
        self.assertEqual(self.errors, [])

    def test_long_tables_and_code_fit_every_page_fragment(self):
        rows = "\n".join(
            f"| row_{index} | `{'long_identifier_' * 8}` | End of row {index} |"
            for index in range(60)
        )
        self.preview(
            "# Long content\n\n| Name | Address | Reason |\n| --- | --- | --- |\n"
            + rows
            + "\n\n```text\n"
            + ("long_command/" * 70 + "\n") * 30
            + "```\n"
        )
        self.page.get_by_role("button", name="Two pages", exact=True).click()
        failures = self.page.locator(".mdpreview-document").evaluate("""article => {
            const bounds = article.getBoundingClientRect();
            const style = getComputedStyle(article);
            const gap = parseFloat(style.columnGap);
            const stride = (bounds.width + gap) / Number(style.columnCount);
            const width = stride - gap;
            const failures = [];
            const walker = document.createTreeWalker(article, NodeFilter.SHOW_TEXT);
            while (walker.nextNode()) {
                if (!walker.currentNode.textContent.trim()) continue;
                const range = document.createRange();
                range.selectNodeContents(walker.currentNode);
                for (const rect of range.getClientRects()) {
                    const left = rect.left - bounds.left;
                    const column = Math.floor((left + 1) / stride);
                    if (rect.width > 0 && (left - column * stride < -1 ||
                        rect.right - bounds.left - column * stride > width + 1 ||
                        rect.top < bounds.top - 1 || rect.bottom > bounds.bottom + 1)) {
                        failures.push(walker.currentNode.textContent.slice(0, 80));
                    }
                }
            }
            return failures.slice(0, 5);
        }""")
        self.assertEqual(failures, [])


class MermaidBrowserTests(BrowserTests):
    def test_print_uses_prepared_light_diagrams(self):
        self.preview(FLOW + SEQUENCE)
        self.page.wait_for_function(
            "document.querySelectorAll('.mermaid-diagram[data-print-ready]').length === 2"
        )
        self.assertFalse(self.page.locator(".mermaid-print").first.is_visible())
        self.page.emulate_media(media="print")
        self.assertTrue(self.page.locator(".mermaid-print").first.is_visible())
        self.assertFalse(self.page.locator(RENDERED).first.is_visible())
        self.assertEqual(
            self.page.locator(".mermaid-print .messageText").evaluate(
                "element => getComputedStyle(element).fill"
            ),
            "rgb(51, 51, 51)",
        )
        self.assertEqual(self.errors, [])

    def test_valid_diagrams_render_on_both_sides_of_an_invalid_diagram(self):
        invalid = "```mermaid\nThis is not a Mermaid diagram.\n```\n"
        self.preview("# Mermaid\n\n" + FLOW + invalid + FLOW)
        self.page.wait_for_function(
            "document.querySelectorAll('.mermaid-diagram[data-rendered] > svg').length === 2"
        )
        self.assertEqual(self.page.locator(".mermaid-error").count(), 1)
        self.assertIn("This is not", self.page.locator("pre.mermaid").inner_text())
        self.assertEqual(self.page.locator(f"{RENDERED} .node").count(), 4)
        for diagram in self.page.locator(RENDERED).all():
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
