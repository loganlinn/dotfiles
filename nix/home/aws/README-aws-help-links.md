# AWS CLI Help with Terminal Hyperlinks

This adds clickable hyperlinks to AWS CLI help output, allowing you to navigate between help pages directly in your terminal.

## Components

### 1. `bin/aws-help-linkify`
Bash script that transforms AWS help output by adding OSC 8 terminal hyperlinks:
- **Services list**: In `aws help`, each service name links to `aws <service> help`
- **Commands list**: In `aws <service> help`, each command name links to `aws <service> <command> help`
- **HTTP URLs**: Existing `<https://...>` URLs become clickable

### 2. `aws-help.zsh`
Zsh wrapper function that:
- Intercepts `aws ... help` commands
- Pipes output through `aws-help-linkify` with proper context
- Passes non-help commands through unchanged

### 3. Kitty Configuration
- `kitty.common.conf`: Adds `exec` to `url_prefixes`
- `open-actions.conf`: Handles `exec://` URLs by launching commands in a kitty overlay

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

### Pattern Matching
- Services/commands: `^\s+o\s+([a-z0-9-]+)$`
- HTTP URLs: `<(https?://[^>]+)>`
- Section detection: `^AVAILABLE SERVICES`, `^AVAILABLE COMMANDS`

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
