# Trying vertical tabs

Requires Kitty 0.48 or newer. `kitty.common.conf` includes
`kitty.tabs.custom.conf`, preserving the existing custom bottom bar at startup.
`kitty.tabs.vertical.conf` is an overlay that selects the left edge and Kitty's
built-in `fade` renderer, keeping the existing colors, session filter, and
always-visible tab bar. The sidebar uses Kitty's default width.

After the two new config files are linked into your Kitty config directory:

1. Press **Ctrl+Shift+F5** to reload your config and install the new shortcut.
2. Press **Ctrl+Shift+F12** to switch to vertical tabs.
3. Press **Ctrl+Shift+F12** again to restore the custom bottom bar.

These are full config reloads and affect every OS window in the same Kitty
process. A normal reload keeps the selected appearance; a fresh process starts
with the custom bottom bar. Config reloads can also reset temporary settings,
such as an interactively changed font size. Startup `-o` overrides still take
precedence.

For a separate test process, run this yourself (omit `--single-instance`):

```sh
kitty --config "$HOME/.config/kitty/kitty.conf" \
      --config "$HOME/.config/kitty/kitty.tabs.vertical.conf"
```

You can also select either appearance explicitly from a shell inside Kitty:

```sh
# Vertical
kitten @ --to "$KITTY_LISTEN_ON" load-config kitty.conf kitty.tabs.vertical.conf
# Custom bottom bar
kitten @ --to "$KITTY_LISTEN_ON" load-config kitty.conf
```

The shortcut uses Kitty's built-in `remote_control` action, which resolves the
file names relative to the config directory. Both directions load the complete
`kitty.conf`, including the OS-specific and local config, before applying any
overlay. No custom toggle kitten or second copy of the main config is needed.
