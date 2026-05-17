# bin/ script portability

`./bin/` is intended for scripts that work on both macOS and Linux. Platform-specific scripts
belong in `darwin/bin/` or `linux/bin/`.

When adding or editing scripts in `./bin/`, think about portability and surface any caveats:

- If a script uses a platform-specific command (`pbcopy`, `open`, `osascript`, `defaults`,
  `launchctl`, `xdg-open`, `/sys/`, `systemctl`, etc.), mention it and whether a cross-platform
  fallback is straightforward or would require real tradeoffs.
- If the script's *functionality* is inherently platform-specific (macOS Keychain, Apple
  defaults system, Linux kernel interfaces, etc.), suggest `darwin/bin/` or `linux/bin/` as
  the right home — but don't block, just flag it.
- If portability is easily achievable (e.g. `pbcopy` → detect + fallback to `xclip`/`wl-copy`),
  offer to add it rather than waiting to be asked.
