#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "beautifulsoup4",
#     "html2text",
#     "lxml",
# ]
# ///
"""
Convert and fetch kitty HTML documentation as LLM-optimized markdown.

Usage:
    ./get_doc.py <doc-name>      # Fetch specific doc (e.g., "conf" or "conf.html")
    ./get_doc.py --list          # List all available docs
    ./get_doc.py --index         # Generate docs index
    ./get_doc.py --convert-all   # Convert all docs to markdown

Or using uv:
    uv run get_doc.py <doc-name>
"""

import argparse
import sys
from pathlib import Path
import platform
import re


def find_kitty_docs_path():
    """Find the kitty HTML documentation path based on the OS."""
    system = platform.system()

    if system == "Darwin":  # macOS
        path = Path("/Applications/kitty.app/Contents/Resources/doc/kitty/html")
    elif system == "Linux":
        # Try common Linux installation paths
        possible_paths = [
            Path("/usr/share/doc/kitty/html"),
            Path("/usr/local/share/doc/kitty/html"),
            Path.home() / ".local/share/doc/kitty/html",
        ]
        path = next((p for p in possible_paths if p.exists()), None)
    else:
        path = None

    if path and path.exists():
        return path
    else:
        print(f"Error: Could not find kitty documentation path for {system}", file=sys.stderr)
        print("Searched paths:", file=sys.stderr)
        if system == "Darwin":
            print(f"  - {path}", file=sys.stderr)
        elif system == "Linux":
            for p in possible_paths:
                print(f"  - {p}", file=sys.stderr)
        sys.exit(1)


def list_docs(html_path):
    """List all available HTML documentation files."""
    html_files = sorted(html_path.glob("**/*.html"))

    print("Available kitty documentation:\n")
    print("Core Documentation:")
    for html_file in html_files:
        if html_file.parent == html_path:
            rel_path = html_file.relative_to(html_path)
            print(f"  - {rel_path}")

    print("\nKittens:")
    kittens_path = html_path / "kittens"
    if kittens_path.exists():
        for html_file in sorted(kittens_path.glob("*.html")):
            rel_path = html_file.relative_to(html_path)
            print(f"  - {rel_path}")

    print("\nGenerated Documentation:")
    generated_path = html_path / "generated"
    if generated_path.exists():
        for html_file in sorted(generated_path.glob("*.html")):
            rel_path = html_file.relative_to(html_path)
            print(f"  - {rel_path}")


def html_to_markdown(html_content, title=""):
    """
    Convert HTML to clean markdown optimized for LLM consumption.
    Uses basic parsing to extract main content and convert to markdown.
    """
    from bs4 import BeautifulSoup
    import html2text

    soup = BeautifulSoup(html_content, "lxml")

    # Remove unwanted elements
    for element in soup.select("script, style, nav, .headerlink, .sidebar, .navigation"):
        element.decompose()

    # Extract main content
    main_content = soup.select_one("main, article, .document, .body")
    if not main_content:
        main_content = soup.find("body")

    if not main_content:
        return "Error: Could not extract main content from HTML"

    # Pre-process: Add language hints to code blocks for better conversion
    # Find all code blocks with language classes and add data attributes
    for code_block in soup.select("div[class*='highlight-']"):
        # Extract language from class like "highlight-conf" or "highlight-python"
        classes = code_block.get("class", [])
        for cls in classes:
            if cls.startswith("highlight-"):
                lang = cls.replace("highlight-", "")
                # Add as data attribute for later processing
                code_block["data-language"] = lang
                break

    # Pre-process: Convert action/option definition terms to proper headings
    # Look for <dt> elements with class "sig" (action/option definitions)
    for dt in soup.find_all("dt", class_="sig"):
        # Extract the action/option name from the span
        sig_name = dt.find("span", class_="sig-name")
        if sig_name:
            # Get the actual name text
            pre_element = sig_name.find("span", class_="pre")
            if pre_element:
                name = pre_element.get_text(strip=True)

                # Determine heading level based on context
                # Actions are h3, options are h2
                heading_level = "h3" if "action-" in dt.get("id", "") else "h2"

                # Create a new heading with backtick-enclosed name
                new_heading = soup.new_tag(heading_level)
                code_tag = soup.new_tag("code")
                code_tag.string = name
                new_heading.append(code_tag)

                # Replace the dt element with the heading
                dt.replace_with(new_heading)

                # Remove the empty dd that typically follows
                # (it's usually empty for actions)

    # Remove empty dd elements that followed dt definitions
    for dd in soup.find_all("dd"):
        if not dd.get_text(strip=True) and not dd.find_all():
            dd.decompose()

    # Configure html2text
    h = html2text.HTML2Text()
    h.ignore_links = False
    h.ignore_images = False
    h.ignore_emphasis = False
    h.body_width = 0  # Don't wrap lines
    h.single_line_break = False
    h.wrap_links = False
    h.skip_internal_links = False
    h.protect_links = True  # Protect links from being wrapped

    # Convert to markdown
    markdown = h.handle(str(main_content))

    # Post-process markdown for improvements
    markdown = post_process_markdown(markdown)

    # Add title if provided
    if title:
        markdown = f"# {title}\n\n{markdown}"

    return markdown


def post_process_markdown(markdown):
    """
    Post-process converted markdown to fix common issues.
    - Remove angle brackets from links (html2text adds these)
    - Convert internal .html links to .md
    - Convert indented code blocks to fenced code blocks
    - Improve code formatting
    - Clean up excessive whitespace
    """
    # Step 1: Remove angle brackets from links
    # html2text creates links like [text](<url>) which is invalid markdown
    # Convert to [text](url)
    # Use a more sophisticated pattern that handles escaped brackets and backticks in link text
    markdown = re.sub(
        r'\[((?:[^\]]|\\\])+?)\]\(<([^>]+)>\)',
        r'[\1](\2)',
        markdown
    )

    # Also handle cases where link text contains unescaped brackets (like [`key`])
    # These are tricky because the link text itself has brackets
    # Pattern: [`text`](<url>) where text can contain ]
    markdown = re.sub(
        r'\[`([^`]+)`\]\(<([^>]+)>\)',
        r'[`\1`](\2)',
        markdown
    )

    # Step 2: Convert internal HTML links to markdown links
    # First handle links with backtick-enclosed text that may contain brackets
    markdown = re.sub(
        r'\[`([^`]+)`\]\(([^)]+?)\.html(#[^)]+)?\)',
        lambda m: f'[`{m.group(1)}`]({m.group(2)}.md{m.group(3) if m.group(3) else ""})',
        markdown
    )

    # Then handle regular links
    # Pattern: [text](file.html) or [text](path/file.html) or [text](file.html#anchor)
    markdown = re.sub(
        r'\[([^\]]+)\]\(([^)]+?)\.html(#[^)]+)?\)',
        lambda m: f'[{m.group(1)}]({m.group(2)}.md{m.group(3) if m.group(3) else ""})',
        markdown
    )

    # Step 3: Convert indented code blocks (4+ spaces) to fenced code blocks
    # This makes them more readable and better for syntax highlighting
    markdown = convert_indented_to_fenced_code(markdown)

    # Step 4: Clean up excessive newlines (3 or more -> 2)
    markdown = re.sub(r"\n{3,}", "\n\n", markdown)

    # Step 5: Clean up spaces before newlines
    markdown = re.sub(r" +\n", "\n", markdown)

    # Step 6: Fix common formatting issues with code blocks
    # Ensure code blocks have proper spacing
    markdown = re.sub(r"```(\w+)\n\n", r"```\1\n", markdown)

    return markdown


def convert_indented_to_fenced_code(markdown):
    """
    Convert indented code blocks (4 spaces) to fenced code blocks.
    This improves readability and enables syntax highlighting.
    """
    lines = markdown.split("\n")
    result = []
    in_code_block = False
    code_block_lines = []

    for i, line in enumerate(lines):
        # Check if this line is indented code (starts with 4+ spaces)
        # Allow empty lines within code blocks
        is_code_line = line.startswith("    ") if line else False

        if is_code_line:
            if not in_code_block:
                # Start of a new code block
                in_code_block = True
                code_block_lines = [line[4:]]  # Remove 4-space indent
            else:
                # Continue code block
                code_block_lines.append(line[4:] if len(line) >= 4 else "")
        elif in_code_block and line.strip() == "":
            # Empty line might be part of code block or separator
            # Look ahead to see if next line is also code
            next_is_code = i + 1 < len(lines) and lines[i + 1].startswith("    ")
            if next_is_code:
                # Keep empty line as part of code block
                code_block_lines.append("")
            else:
                # Empty line ends the code block
                # Don't output empty or whitespace-only code blocks
                if any(line.strip() for line in code_block_lines):
                    lang = guess_code_language(code_block_lines)
                    # Only output if lang detection didn't return None (skip signal)
                    if lang is not None:
                        result.append(f"```{lang}")
                        result.extend(code_block_lines)
                        result.append("```")
                    else:
                        # Was a false positive, add lines as regular text
                        result.extend(["    " + line for line in code_block_lines])

                in_code_block = False
                code_block_lines = []
                result.append(line)
        else:
            if in_code_block:
                # End of code block
                # Don't output empty or whitespace-only code blocks
                if any(line.strip() for line in code_block_lines):
                    lang = guess_code_language(code_block_lines)
                    # Only output if lang detection didn't return None (skip signal)
                    if lang is not None:
                        result.append(f"```{lang}")
                        result.extend(code_block_lines)
                        result.append("```")
                    else:
                        # Was a false positive, add lines as regular text
                        result.extend(["    " + line for line in code_block_lines])

                # Reset
                in_code_block = False
                code_block_lines = []

            # Add the current non-code line
            result.append(line)

    # Handle any remaining code block at end of file
    if in_code_block and any(line.strip() for line in code_block_lines):
        lang = guess_code_language(code_block_lines)
        # Only output if lang detection didn't return None (skip signal)
        if lang is not None:
            result.append(f"```{lang}")
            result.extend(code_block_lines)
            result.append("```")
        else:
            # Was a false positive, add lines as regular text
            result.extend(["    " + line for line in code_block_lines])

    return "\n".join(result)


def guess_code_language(code_lines):
    """
    Guess the language of a code block based on its content.
    Returns language identifier for syntax highlighting.
    """
    if not code_lines:
        return ""

    code_text = "\n".join(code_lines).strip()

    # Skip code blocks that are just single words or identifiers (likely false positives)
    # These are probably definition names that got caught as code
    if len(code_text) < 3 or ("\n" not in code_text and " " not in code_text):
        return None  # Signal to skip this block

    # Check for kitty.conf syntax
    if any(keyword in code_text for keyword in ["map ", "font_family", "mouse_map", "background ", "foreground ", "include ", "font_size "]):
        return "conf"

    # Check for shell/bash
    if code_text.strip().startswith("#!") or any(keyword in code_text for keyword in ["#!/bin/", "export ", "function ", "echo "]):
        return "bash"

    # Check for Python
    if any(keyword in code_text for keyword in ["def ", "import ", "class ", "from ", "if __name__"]):
        return "python"

    # Check for JSON
    if code_text.strip().startswith("{") and ":" in code_text:
        return "json"

    # Default to no language (plain text)
    return ""


def get_doc(doc_name, html_path, cache_path):
    """Fetch and convert a specific documentation file."""
    # Normalize doc name
    if not doc_name.endswith(".html"):
        doc_name = f"{doc_name}.html"

    # Find the HTML file
    html_file = None
    for pattern in [doc_name, f"**/{doc_name}"]:
        matches = list(html_path.glob(pattern))
        if matches:
            html_file = matches[0]
            break

    if not html_file or not html_file.exists():
        print(f"Error: Documentation file '{doc_name}' not found", file=sys.stderr)
        print("Use --list to see available documentation", file=sys.stderr)
        sys.exit(1)

    # Check cache
    rel_path = html_file.relative_to(html_path)
    cache_file = cache_path / rel_path.with_suffix(".md")

    if cache_file.exists() and cache_file.stat().st_mtime > html_file.stat().st_mtime:
        # Cache is up to date
        return cache_file.read_text()

    # Convert HTML to markdown
    html_content = html_file.read_text()
    title = html_file.stem.replace("-", " ").title()
    markdown = html_to_markdown(html_content, title)

    # Cache the result
    cache_file.parent.mkdir(parents=True, exist_ok=True)
    cache_file.write_text(markdown)

    return markdown


def generate_index(html_path, cache_path):
    """Generate an index of all available documentation."""
    html_files = sorted(html_path.glob("**/*.html"))

    index_content = ["# Kitty Documentation Index\n"]
    index_content.append("This index lists all available kitty documentation.\n")

    # Organize by category
    categories = {
        "Core": [],
        "Kittens": [],
        "Generated": [],
    }

    for html_file in html_files:
        rel_path = html_file.relative_to(html_path)

        # Skip index and search pages
        if rel_path.stem in ["index", "search", "genindex"]:
            continue

        doc_id = str(rel_path.with_suffix("")).replace("/", "/")
        title = html_file.stem.replace("-", " ").title()

        if "kittens" in str(rel_path):
            categories["Kittens"].append(f"- `{doc_id}` - {title}")
        elif "generated" in str(rel_path):
            categories["Generated"].append(f"- `{doc_id}` - {title}")
        else:
            categories["Core"].append(f"- `{doc_id}` - {title}")

    for category, items in categories.items():
        if items:
            index_content.append(f"\n## {category}\n")
            index_content.extend(items)

    index_text = "\n".join(index_content)

    # Save index
    index_file = cache_path / "INDEX.md"
    index_file.write_text(index_text)

    return index_text


def convert_all(html_path, cache_path):
    """Convert all documentation files to markdown."""
    html_files = list(html_path.glob("**/*.html"))

    print(f"Converting {len(html_files)} documentation files...")

    for i, html_file in enumerate(html_files, 1):
        # Skip index and search pages
        if html_file.stem in ["index", "search", "genindex"]:
            continue

        rel_path = html_file.relative_to(html_path)
        print(f"[{i}/{len(html_files)}] Converting {rel_path}...", end=" ")

        try:
            # Read and convert
            html_content = html_file.read_text()
            title = html_file.stem.replace("-", " ").title()
            markdown = html_to_markdown(html_content, title)

            # Save to cache
            cache_file = cache_path / rel_path.with_suffix(".md")
            cache_file.parent.mkdir(parents=True, exist_ok=True)
            cache_file.write_text(markdown)

            print("✓")
        except Exception as e:
            print(f"✗ ({e})")

    print("\nGenerating index...")
    generate_index(html_path, cache_path)
    print("Done!")


def main():
    parser = argparse.ArgumentParser(
        description="Convert and fetch kitty HTML documentation as markdown"
    )
    parser.add_argument("doc_name", nargs="?", help="Documentation file to fetch")
    parser.add_argument("--list", action="store_true", help="List available docs")
    parser.add_argument("--index", action="store_true", help="Generate docs index")
    parser.add_argument("--convert-all", action="store_true", help="Convert all docs")

    args = parser.parse_args()

    # Find kitty docs path
    html_path = find_kitty_docs_path()

    # Set up cache directory
    script_dir = Path(__file__).parent
    skill_dir = script_dir.parent
    cache_path = skill_dir / "docs"
    cache_path.mkdir(exist_ok=True)

    # Handle commands
    if args.list:
        list_docs(html_path)
    elif args.index:
        index = generate_index(html_path, cache_path)
        print(index)
    elif args.convert_all:
        convert_all(html_path, cache_path)
    elif args.doc_name:
        markdown = get_doc(args.doc_name, html_path, cache_path)
        print(markdown)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
