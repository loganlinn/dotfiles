# Kitty Terminal Skill

A Claude Code skill for expert assistance with configuring and scripting the kitty terminal emulator.

## Features

- Access to complete kitty documentation converted to LLM-optimized markdown
- Configuration assistance for kitty.conf
- Keybinding and action mapping help
- Theme and color scheme customization
- Session and layout management
- Kitten development guidance
- Remote control scripting

## Prerequisites

- **mise** - Development environment manager (for task running)
- **uv** - Python package manager (managed by mise)
- Python 3.10 or later

The script uses uv's inline script dependencies feature, which automatically manages:
- `beautifulsoup4` - HTML parsing
- `html2text` - HTML to Markdown conversion
- `lxml` - XML/HTML processing

## Quick Start

### Initial Setup

Convert all documentation upfront for optimal performance:

```bash
# Using mise (recommended)
mise run setup

# Or directly
uv run scripts/get_doc.py --convert-all
```

This converts all HTML documentation to markdown and caches it in `docs/`.

### Using Mise Tasks

The project includes mise tasks for common operations:

```bash
# List all available documentation
mise run list

# Fetch specific documentation
mise run doc conf
mise run doc kittens/themes

# Generate documentation index
mise run index

# Convert all documentation
mise run convert-all

# Test the conversion
mise run test

# Clean cache
mise run clean

# Clean and regenerate everything
mise run refresh
```

## Usage

### Automatic Skill Invocation

The skill is automatically invoked by Claude when you ask about kitty-related topics:

- "How do I configure kitty's font?"
- "Show me how to create a custom keybinding"
- "Help me write a Python kitten"
- "What are the available kitty @ commands?"

### Manual Documentation Access

You can also access documentation directly:

```bash
# Using mise tasks
mise run doc conf
mise run doc actions
mise run doc kittens/themes

# Or directly with uv
uv run scripts/get_doc.py --list
uv run scripts/get_doc.py conf
uv run scripts/get_doc.py --index

# Or as executable
./scripts/get_doc.py --list
./scripts/get_doc.py conf
```

## Documentation Cache

Converted documentation is cached in the `docs/` directory:

```
docs/
├── INDEX.md                    # Complete documentation index
├── conf.md                     # Main configuration reference
├── actions.md                  # Mappable actions
├── kittens/
│   ├── themes.md
│   ├── unicode_input.md
│   └── ...
└── generated/
    └── ...
```

The cache is automatically updated when source HTML files are modified.

## Directory Structure

```
.
├── SKILL.md                    # Skill definition and instructions
├── README.md                   # This file
├── EXAMPLES.md                 # Usage examples
├── mise.toml                   # Task runner configuration
├── .gitignore                  # Git ignore rules
├── scripts/
│   └── get_doc.py             # Documentation converter
└── docs/                      # Cached markdown documentation
    ├── INDEX.md
    └── ...
```

## Platform Support

### macOS
Documentation path: `/Applications/kitty.app/Contents/Resources/doc/kitty/html`

### Linux
Searches the following paths in order:
- `/usr/share/doc/kitty/html`
- `/usr/local/share/doc/kitty/html`
- `~/.local/share/doc/kitty/html`

## Development

### Adding New Documentation Sources

If kitty adds new documentation files, simply run:

```bash
mise run refresh
```

This will clean the cache and reconvert all documentation.

### Customizing Conversion

The `html_to_markdown()` function in `scripts/get_doc.py` can be customized to:
- Extract different HTML elements
- Apply custom cleaning rules
- Format output differently

### Testing Changes

```bash
# Test conversion of key documentation files
mise run test

# Test a specific file
mise run doc conf
```

### Debugging

To see raw HTML paths being searched:

```bash
uv run scripts/get_doc.py nonexistent.html
```

This will print the search locations and available documentation.

## Distribution and Packaging

### Creating a Distributable Package

Package the skill for distribution:

```bash
# Full package with pre-converted docs (~10MB)
mise run package

# Minimal package without docs (~50KB)
mise run package-minimal
```

Both commands create a `.tar.gz` archive in the `dist/` directory.

### Installing from Package

**Extract the package:**
```bash
# To personal skills directory
tar -xzf kitty-skill-*.tar.gz -C ~/.claude/skills/

# Or to project skills directory
tar -xzf kitty-skill-*.tar.gz -C .claude/skills/
```

**For minimal packages, run setup:**
```bash
cd ~/.claude/skills/kitty  # or .claude/skills/kitty
mise run setup
```

### Installing Directly (Development)

Install the current skill directly to your local Claude skills directory:

```bash
mise run install-local
```

This copies all files including the documentation cache to `~/.claude/skills/kitty`.

## Available Mise Tasks

| Task | Description |
|------|-------------|
| **Setup** ||
| `setup` | Initial setup: convert all documentation |
| `validate` | Validate skill structure and required files |
| **Documentation** ||
| `list` | List all available kitty documentation |
| `doc <name>` | Fetch and convert a specific documentation file |
| `index` | Generate documentation index |
| `convert-all` | Convert all kitty HTML documentation to markdown |
| `test` | Test the documentation conversion with key docs |
| `clean` | Remove all cached documentation |
| `refresh` | Clean and regenerate all documentation |
| **Distribution** ||
| `package` | Package skill with pre-converted documentation |
| `package-minimal` | Package skill without documentation cache (smaller) |
| `install-local` | Install skill to local Claude skills directory |

## Best Practices

1. **Pre-convert documentation** - Run `mise run setup` after installing/updating kitty
2. **Keep cache fresh** - The script automatically updates stale cache entries
3. **Reference by name** - Use simple names like "conf" instead of full paths with `.html`
4. **Explore the index** - Use `mise run index` to see all available documentation
5. **Use mise tasks** - Easier than remembering script paths and arguments

## Troubleshooting

### "Could not find kitty documentation path"

The kitty application may not be installed in the standard location. You can:

1. Find your kitty installation:
   ```bash
   which kitty
   ```

2. Locate the HTML docs (usually in `<kitty-prefix>/share/doc/kitty/html`)

3. Update the paths in `scripts/get_doc.py`'s `find_kitty_docs_path()` function

### "Required packages not found"

If you see this error, ensure you have `uv` installed:

```bash
# Check if uv is available
mise which uv

# Or install it
mise install
```

Then run the script using one of these methods:
```bash
mise run doc conf        # Preferred
uv run scripts/get_doc.py conf
./scripts/get_doc.py conf
```

### Cache Issues

If you're getting stale or incorrect documentation:

```bash
# Clean and regenerate
mise run refresh

# Or manually
mise run clean
mise run convert-all
```

## Performance

- **Cached access**: ~50ms per document
- **Conversion**: ~100-200ms per document (first time only)
- **Full conversion**: ~30-60 seconds for all ~70 documents

Cache makes subsequent access nearly instant.

## License

This skill uses documentation from the kitty terminal emulator, which is GPL v3 licensed.
See: https://github.com/kovidgoyal/kitty
