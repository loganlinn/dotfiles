# AWS CLI Help with Terminal Hyperlinks

This adds clickable hyperlinks to AWS CLI help output, allowing you to navigate between help pages directly in your terminal.

## File Structure

```
nix/home/aws/help-linkify/
├── README.md                      # This file
├── aws-help-linkify.plugin.zsh   # Zsh plugin entry point
└── bin/
    ├── aws-help-linkify           # Core transformation script
    └── aws-help-pager             # Pager wrapper
```

## Components

### 1. `aws-help-linkify.plugin.zsh`
Zsh plugin that:
- Adds `bin/` directory to PATH automatically
- Wraps the `aws` command to intercept help requests
- Configures AWS_PAGER to pipe through `aws-help-linkify`
- Preserves pager behavior (less/bat)
- Passes non-help commands through unchanged

### 2. `bin/aws-help-linkify`
Bash/awk script that transforms AWS help output by adding OSC 8 terminal hyperlinks:
- **Services list**: In `aws help`, each service name links to `aws <service> help`
- **Commands list**: In `aws <service> help`, each command name links to `aws <service> <command> help`
- **HTTP URLs**: Existing `<https://...>` URLs become clickable

### 3. `bin/aws-help-pager`
Pager wrapper script that:
- Reads service/command context from environment variables
- Calls `aws-help-linkify` with proper arguments
- Pipes to user's `$PAGER` (with special handling for `bat`)

### 4. Kitty Configuration
Located in `config/kitty/`:
- `kitty.common.conf`: Adds `exec` to `url_prefixes`
- `open-actions.conf`: Handles `exec://` URLs by launching commands in a kitty overlay

## Installation

This plugin is loaded via Nix home-manager's `programs.zsh.plugins` option:

```nix
programs.zsh = {
  plugins = [
    {
      name = "aws-help-linkify";
      src = ./help-linkify;
    }
  ];
};
```

The plugin automatically adds its `bin/` directory to PATH, so the helper scripts are available.

## Usage

After activation (via Nix home-manager rebuild), simply use AWS help as normal:

```bash
aws help              # Service names are clickable
aws s3 help           # Command names are clickable
aws s3 cp help        # URLs in docs are clickable
```

Click any hyperlink to:
- Navigate to related help pages (opens in kitty overlay)
- Open AWS documentation URLs in browser

## Implementation Details

### Hyperlink Format
Uses OSC 8 escape sequences: `\e]8;;URL\e\\TEXT\e]8;;\e\\`

### URL Scheme
Links use `exec://` protocol with URL-encoded commands:
- Example: `exec://aws%20s3%20help` → runs `aws s3 help`
- The kitty handler decodes the URL and executes the command in an overlay

### Pager Integration
The wrapper uses `AWS_PAGER` environment variable to inject the linkifier:
- AWS CLI → linkifier → less (pager)
- Preserves interactive paging behavior
- User can navigate help with less keybindings

### Pattern Matching
- Services/commands: `^\s+o\s+([a-z0-9-]+)$`
- HTTP URLs: `<(https?://[^>]+)>`
- Section detection: `^AVAILABLE SERVICES`, `^AVAILABLE COMMANDS`

### Performance
- Uses awk for fast single-pass processing
- No subshell spawning or external command calls in main loop
- ~0.01s overhead for processing large help output

## Known Limitations

1. **Multi-line URLs**: AWS help wraps long URLs across multiple lines. The script processes line-by-line, so wrapped URLs won't be linkified. Most URLs in AWS help are short enough to fit on one line.

2. **Context parsing**: The script relies on simple argument parsing. Complex command lines with many options might not be parsed correctly, but basic usage (common case) works well.

3. **Kitty-specific**: The `exec://` protocol handler is configured in kitty. Other terminals would need their own configuration.

## Testing

Test the components individually:

```bash
# Test linkification script
aws s3 help | aws-help-linkify s3 | head -50

# Test with the wrapper (after sourcing aws-help.zsh)
aws s3 help

# Verify escape sequences
echo "See <https://example.com>" | aws-help-linkify | od -An -tx1
```
