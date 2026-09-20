# mdpreview

`mdpreview` renders Markdown with Pandoc and opens the result in a browser.
A directory produces a filterable index with links to its documents.

```sh
mdpreview                               # Browse PWD and its subdirectories
mdpreview ./docs                        # Browse a specific directory
mdpreview README.md                     # Preview one file
cat README.md | mdpreview                # Preview standard input
mdpreview --no-open README.md            # Print the HTML path without a browser
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
Progress appears immediately, including when stderr is redirected to a log.
The stdout stream contains only the HTML path.

Without a path, piped or redirected input takes precedence over PWD.
A terminal or `/dev/null` selects PWD. An explicit `-` always reads stdin and rejects empty input.
An explicit file or directory takes precedence over stdin.

Directory discovery uses ripgrep ignore rules, including `.gitignore` in Git repositories and `.ignore` files.
It includes `.md`, `.markdown`, `.mdown`, `.mkd`, `.mkdn`, and extensionless `README` files, without regard to case.
`--all` includes hidden and ignored files. Discovery always skips `.git`, symlinks, the cache, and the generated output directory.
The selected directory is the search root. The command does not expand the search to the Git repository root.

Links between discovered Markdown files point to their HTML previews.
When a directory has a discovered README, links to that directory open its preview.
Links to the search root open the index.
Local images and other local links use absolute `file:` URLs to their original files.
These previews require access to the source files. They are not portable website exports.

Themes retain the existing behavior:

- `--theme PATH` selects a CSS file.
- `--theme NAME` resolves `${XDG_CONFIG_HOME:-$HOME/.config}/mdpreview/themes/NAME[.css]`.
- `MDPREVIEW_THEME` supplies the default selection.
- With no theme, each HTML page includes the built-in dark CSS.

Custom CSS remains an external file, so relative resources in that CSS retain their original base directory.

## Cache and rebuilds

The cache uses the native application cache directory:

- macOS: `~/Library/Caches/mdpreview`
- Linux and other Unix systems: `${XDG_CACHE_HOME:-$HOME/.cache}/mdpreview`

When `XDG_CACHE_HOME` is set on macOS, previews still use the native cache location.
On other Unix systems, a relative `XDG_CACHE_HOME` is ignored, as required by the XDG specification.
Cache entries contain generated HTML, conversion logs, a lock, and a versioned manifest.
All these files can be recreated. The command does not use `TMPDIR` for preview storage.

An entry key contains the canonical source path, input kind, and explicit output path.
It excludes content, timestamps, and theme selection. A rebuild therefore retains the same browser URL.
Stdin uses one entry per working directory and output selection.
This keeps repeated invocations from accumulating abandoned preview directories.
Even with matching filenames, previews of different source paths remain separate.

Directory pages use `pages/<relative-source-path>.html`. The original extension remains part of the path to prevent collisions.
For example, `notes.md` and `notes.markdown` produce distinct pages.
The site entrypoint is `index.html`.

Each invocation renders all pages in a staging directory inside its cache entry.
If conversion fails, the previous HTML remains available. Temporary staging files are removed.
Successful conversions replace each destination atomically, then remove stale pages recorded by the previous manifest.
Other files in an explicit output directory remain untouched.
A lock serializes concurrent invocations for the same cache entry.

The script requires Python 3.10 or later and Pandoc. Directory previews also require ripgrep.
The Nix package provides these dependencies and the default theme.

## Future watch mode

`--watch` is not implemented. There is no event loop, background process, server, or automatic browser refresh.
For now, rerun the same command after edits, then refresh the browser.

A future `mdpreview --watch [PATH]` can reuse these functions:

1. Resolve PATH, with PWD as the default, and acquire the existing preview lock.
2. Use `discover()` for the initial list and for changes to the set of files.
3. Use the manifest to map source paths to stable output paths.
4. Use `render_file()` for changed files and rebuild the index after additions, deletions, or renames.
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
