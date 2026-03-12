# Kitty Skill Usage Examples

This document shows examples of how Claude uses the kitty skill to help with terminal configuration and scripting.

## Example 1: Font Configuration

**User**: How do I set up JetBrains Mono as my font in kitty with ligatures?

**Claude's approach**:
1. Read `docs/conf.md` (font configuration section)
2. Provide accurate syntax and examples

**Answer**:
```conf
# In kitty.conf
font_family      JetBrains Mono
font_size        12.0

# Ligatures are enabled by default
# To disable them when cursor is over them (easier editing):
disable_ligatures cursor

# To completely disable ligatures:
# disable_ligatures always
```

## Example 2: Creating Custom Keybindings

**User**: I want to create a keybinding that opens a new tab with a specific directory

**Claude's approach**:
1. Read `docs/actions.md` (mappable actions)
2. Read `docs/conf.md` (keyboard mapping syntax)
3. Provide working configuration

**Answer**:
```conf
# In kitty.conf
# Open new tab in ~/projects directory
map ctrl+shift+t new_tab_with_cwd
map ctrl+alt+p launch --type=tab --cwd=~/projects

# You can also pass environment variables
map f1 launch --type=tab --env VAR=value --cwd=~/code
```

## Example 3: Setting Up a Theme

**User**: How do I change my kitty theme to use a dark color scheme?

**Claude's approach**:
1. Read `docs/kittens/themes.md` (themes kitten)
2. Read `docs/conf.md` (color configuration)
3. Provide multiple approaches

**Answer**:

**Option 1: Use the themes kitten (easiest)**
```bash
# Browse and preview available themes
kitten themes
```

**Option 2: Manual configuration in kitty.conf**
```conf
# Dark theme example
foreground #cccccc
background #1a1a1a

# Black
color0  #1a1a1a
color8  #666666

# Red
color1  #ff5555
color9  #ff6e67

# Green
color2  #50fa7b
color10 #5af78e

# ... continue for all 16 colors
```

**Option 3: Include a theme file**
```conf
# In kitty.conf
include ./themes/dracula.conf
```

## Example 4: Remote Control Scripting

**User**: Write a script that creates multiple kitty tabs for my development workflow

**Claude's approach**:
1. Read `docs/remote-control.md` (remote control protocol)
2. Read `docs/generated/rc.md` (remote control commands)
3. Create working shell script

**Answer**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Create development workspace
# Opens tabs for: editor, server, logs, and terminal

# Tab 1: Editor
kitty @ launch --type=tab --tab-title "Editor" --cwd ~/projects/myapp
kitty @ send-text --match "title:Editor" "nvim .\n"

# Tab 2: Dev Server
kitty @ launch --type=tab --tab-title "Server" --cwd ~/projects/myapp
kitty @ send-text --match "title:Server" "npm run dev\n"

# Tab 3: Logs
kitty @ launch --type=tab --tab-title "Logs" --cwd ~/projects/myapp
kitty @ send-text --match "title:Logs" "tail -f logs/development.log\n"

# Tab 4: Terminal
kitty @ launch --type=tab --tab-title "Terminal" --cwd ~/projects/myapp

# Switch to first tab
kitty @ focus-tab --match "title:Editor"
```

## Example 5: Creating a Python Kitten

**User**: Help me create a kitten that displays system information

**Claude's approach**:
1. Read `docs/kittens/custom.md` (custom kitten development)
2. Read `docs/kittens_intro.md` (kittens introduction)
3. Create working Python kitten

**Answer**:

Create `~/.config/kitty/kittens/sysinfo.py`:
```python
#!/usr/bin/env python3
"""Display system information in kitty."""

import platform
import psutil
from kitty.boss import Boss
from kittens.tui.handler import result_handler


def main(args):
    # Get system info
    info = {
        "OS": platform.system(),
        "OS Version": platform.version(),
        "Python": platform.python_version(),
        "CPU Cores": psutil.cpu_count(),
        "RAM": f"{psutil.virtual_memory().total / (1024**3):.1f} GB",
        "Disk": f"{psutil.disk_usage('/').total / (1024**3):.1f} GB",
    }

    # Format output
    print("\\n=== System Information ===\\n")
    for key, value in info.items():
        print(f"{key:.<20} {value}")
    print()


@result_handler(type_of_input=None)
def handle_result(args, result, target_window_id, boss):
    # Called when kitten completes
    pass


# Entry point for command-line usage
if __name__ == "__main__":
    main([])
```

Add to `kitty.conf`:
```conf
# Map F2 to run the sysinfo kitten
map f2 kitten sysinfo.py
```

## Example 6: Session Management

**User**: How do I save and restore my kitty session with multiple tabs and layouts?

**Claude's approach**:
1. Read `docs/sessions.md` (session management)
2. Read `docs/layouts.md` (window layouts)
3. Provide comprehensive guide

**Answer**:

**Save current session:**
```bash
# Save current session to file
kitty @ ls > ~/.config/kitty/sessions/my-session.json
```

**Or create session file manually:**
```conf
# ~/.config/kitty/sessions/dev.conf
new_tab Editor
cd ~/projects
launch nvim

new_tab Server
cd ~/projects
launch npm run dev

new_tab Shell
cd ~/projects

# Set layout
layout stack
```

**Load session:**
```bash
# Start kitty with session
kitty --session ~/.config/kitty/sessions/dev.conf

# Or load in running kitty
kitty @ load-session ~/.config/kitty/sessions/dev.conf
```

**Add keybinding:**
```conf
# In kitty.conf
map f12 load_config_file ~/.config/kitty/sessions/dev.conf
```

---

These examples demonstrate how the kitty skill provides accurate, well-documented assistance by referencing the official kitty documentation that's been converted to an LLM-friendly format.
