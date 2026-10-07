# mdpreview

`mdpreview` renders Markdown with Pandoc and opens the result in a browser.
A directory produces a filterable index with links to its documents.

```sh
mdpreview                               # Browse PWD and its subdirectories
mdpreview ./docs                        # Browse a specific directory
mdpreview README.md                     # Preview one file
mdpreview file:///path/to/README.md      # Preview a local file URI
mdpreview https://example.com/README.md  # Download and preview Markdown
cat README.md | mdpreview                # Preview standard input
mdpreview --no-open README.md            # Print the HTML path without a browser
mdpreview --no-render-links README.md    # Leave links pointing to source files
mdpreview -o ./preview.html README.md    # Choose the HTML file
mdpreview -o ./preview-site ./docs       # Choose a directory for the site
mdpreview --all ./docs                   # Include hidden and ignored files
```

`--output` and `-o` accept an HTML filename for file or stdin input.
For directory input, they accept a directory for the generated site.
Use a dedicated output directory. The command replaces generated files on each run.
`--output` does not change browser behavior. `--open` and `--no-open` control it, and the last flag wins.
Successful invocations print the absolute HTML path as plain text.
Directory previews report scanning, file counts, rendering progress, and completion on stderr.
Progress appears immediately, including in redirected logs.
The stdout stream contains only the HTML path.

Without a path, piped or redirected input takes precedence over PWD.
A terminal or `/dev/null` selects PWD. An explicit `-` always reads stdin and rejects empty input.
An explicit file or directory takes precedence over stdin.

Inputs also accept `file://` URIs with an empty host or `localhost`, and HTTP(S) URLs.
File URI paths are percent-decoded and share the same cache and link traversal as local paths.
HTTP(S) inputs are fetched on each invocation with a 30-second network timeout and normal
TLS certificate verification. Supply a URL serving Markdown, such as a repository's raw-file URL.
Redirects are followed; relative hyperlinks, images, and Mermaid image paths use the final
URL as their base. Fragment-only links still navigate within the preview.
Remote hyperlinks remain online links and do not trigger recursive downloads.
Failed downloads preserve the last successful preview.

Directory discovery uses ripgrep ignore rules, including `.gitignore` in Git repositories and `.ignore` files.
It includes `.md`, `.markdown`, `.mdown`, `.mkd`, `.mkdn`, and extensionless `README` files, without regard to case.
`--all` includes hidden and ignored files. Discovery always skips `.git`, symlinks, the cache, and the generated output directory.
The selected directory is the search root. The command does not expand the search to the Git repository root.

`--render-links` is on by default. Hyperlinks to existing local Markdown files
point to generated HTML previews, including links in raw HTML and local `file:` URLs.
Linked documents are followed transitively, even outside the selected directory
or its discovery ignore rules. Relative links resolve from each document's directory
(PWD for stdin). Query strings and fragments are preserved.
Missing targets, remote URLs, images, and examples inside code blocks do not trigger renders.
`--no-render-links` disables this behavior, including links between directory pages.
When both forms are supplied, the last flag wins.

When a directory has a discovered README, links to that directory open its preview.
Links to the search root open the index.
These directory shortcuts also respect `--no-render-links`.
Local images and other local links use absolute `file:` URLs to their original files.
These previews require access to the source files. They are not portable website exports.

Themes retain the existing behavior:

- `--theme PATH` selects a CSS file.
- `--theme NAME` resolves `${XDG_CONFIG_HOME:-$HOME/.config}/mdpreview/themes/NAME[.css]`.
- `MDPREVIEW_THEME` supplies the default selection.
- With no theme, each HTML page includes the built-in dark CSS.

Custom CSS remains an external file, so relative resources in that CSS retain their original base directory.

## Markdown support

Documents use the Pandoc `gfm` reader for GitHub Flavored Markdown.
This supports tables, task lists, strikethrough, automatic links, and GitHub-style heading anchors.
The reader also supports GitHub alerts, footnotes, emoji shortcodes, and math.
The built-in theme gives each alert type a distinct color.

Fenced code blocks with the `mermaid` language render as diagrams in the browser.
This works with file, stdin, and directory previews, including custom themes.
The renderer selects a light or dark diagram theme from the page background.
This includes CSS color spaces such as `oklch()` and transparent backgrounds.

Local Mermaid `img:` paths resolve from the Markdown file's directory, or PWD for stdin.
These images are embedded in the HTML so the browser can display them from the cache.

Missing images and invalid diagrams retain their source and show an error beside it.
Other diagrams on the page still render.

Mermaid uses version 12.0.0 from jsDelivr. Math uses the MathJax CDN selected by Pandoc.
These features need JavaScript and network access unless the browser has cached the required libraries.
Documents without Mermaid blocks do not load Mermaid.

GitHub adds services beyond the GFM syntax specification.
This preview does not reproduce repository-aware issue links, mentions, GitHub's HTML sanitization, or its exact visual design.
GeoJSON, TopoJSON, and STL viewers are not included.
GitHub can use a different Mermaid version, so support for new diagram syntax can differ.

References: [GFM specification](https://github.github.com/gfm/),
[GitHub diagrams](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams),
[Pandoc Markdown variants](https://pandoc.org/MANUAL.html#markdown-variants),
and [Mermaid usage](https://mermaid.js.org/config/usage.html).

## Cache and rebuilds

The cache uses the native application cache directory:

- macOS: `~/Library/Caches/mdpreview`
- Linux and other Unix systems: `${XDG_CACHE_HOME:-$HOME/.cache}/mdpreview`

When `XDG_CACHE_HOME` is set on macOS, previews still use the native cache location.
On other Unix systems, a relative `XDG_CACHE_HOME` is ignored, as required by the XDG specification.
Cache entries contain generated HTML, conversion logs, a lock, and a versioned manifest.
All these files can be recreated. The command does not use `TMPDIR` for preview storage.

An entry key contains the canonical source path, input kind, and explicit output path.
For HTTP(S) inputs, the requested URL (without its fragment) replaces the source path in the key.
It excludes content, timestamps, and theme selection. A rebuild therefore retains the same browser URL.
Stdin uses one entry per working directory and output selection.
This keeps repeated invocations from accumulating abandoned preview directories.
Even with matching filenames, previews of different source paths remain separate.

Directory pages use `pages/<relative-source-path>.html`. The original extension remains part of the path to prevent collisions.
For example, `notes.md` and `notes.markdown` produce distinct pages.
The site entrypoint is `index.html`.
Additional linked pages use `linked/<source-path-hash>/<source-name>.html` inside
the site for directory previews, or inside the cache entry for file and stdin previews.
They do not add entries to the directory index.

One coordinator runs at most five `mdpreview` conversion subprocesses at a time.
Workers convert a single document and never launch other `mdpreview` workers.
The coordinator reserves canonical source paths before scheduling them, so self-links,
cycles, repeated references, and symlink aliases render each source only once per invocation.
All linked pages inherit the selected theme and never open additional browser windows.

Each invocation renders all pages in a staging directory inside its cache entry.
If conversion fails, the previous HTML remains available. Temporary staging files are removed.
Successful conversions replace each destination atomically, then remove stale pages recorded by the previous manifest.
Other files in an explicit output directory remain untouched.
A lock serializes concurrent invocations for the same cache entry.

The script requires Python 3.10 or later and Pandoc. Directory previews also require ripgrep.
The Nix package provides these dependencies and the default theme.
The script first looks for Pandoc and ripgrep on `PATH`. If either is missing, it
uses that command's mise shim, so GUI launches such as Kitty hints do not need an
interactive shell's environment. The fallback honors `MISE_SHIMS_DIR`, then
`MISE_DATA_DIR/shims`, then `${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims`.
The shim uses the version selected by mise for the launch directory. Install and
select a default with `mise use -g pandoc@3.11` (and `mise use -g ripgrep` for
directory previews). `mdpreview` does not add the shim directory to `PATH`.

## Future watch mode

`--watch` is not implemented. There is no event loop, background process, server, or automatic browser refresh.
For now, rerun the same command after edits, then refresh the browser.

A future `mdpreview --watch [PATH]` can reuse these functions:

1. Resolve PATH, with PWD as the default, and acquire the existing preview lock.
2. Use `discover()` for the initial list and for changes to the set of files.
3. Use the manifest to map source paths to stable output paths.
4. Use `convert_subprocess()` and `finish_render()` for changed files and rebuild the index after additions, deletions, or renames.
5. Apply the same atomic replacement and stale-page cleanup as `build_preview()`.

The watcher must handle recursive writes, editor save-by-rename events, and newly created subdirectories.
It must exclude the cache and output directories from events to prevent rebuild loops.
Changes to ignore files can change discovery results. Theme changes can affect every page.
Event coalescing and incremental rebuilds belong in that future implementation.

Manual browser refresh already has a stable URL to reload.
Automatic refresh can use a local HTTP server with an event channel in a later change.
That server will also need routes for local assets currently referenced through `file:` URLs.

Behavior references: [Glow](https://github.com/charmbracelet/glow#the-tui),
[Apple cache directories](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html),
and the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/).
