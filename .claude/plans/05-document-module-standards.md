---
date: 2026-03-29
git_revision: 6a928fa7
model: claude-opus-4-6
claude_version: 2.1.86
status: todo
---

# Plan: Document Module Composition Standards and Standardize Options Namespace

## Current state

Two competing custom option namespaces with no documented convention:

### `config.my.*` (defined in `options.nix`, ~15 modules extend it)

Central cross-cutting concerns: user identity, fonts, nix settings, shell scripts, SSH keys, user dirs.

Additional modules also declare under `my.*`: tailscale, davfs2, sudo, vivaldi, gaming, zsh, java, python, awesomewm, eww, deadd, desktop.wayland.

### `config.modules.*` (ad-hoc, no central definition, ~11 modules)

- `nix/modules/themes/default.nix` → `modules.theme`
- `nix/modules/spellcheck.nix` → `modules.spellcheck`
- `nix/modules/desktop/browsers/` → `modules.desktop.browsers`
- `nix/modules/desktop/gnome/` → `modules.desktop.gnome`
- `nix/modules/desktop/plasma5/` → `modules.desktop.kde`
- `nixos/modules/btrfs.nix` → `modules.btrfs`
- `nixos/modules/minecraft-server.nix` → `modules.minecraft-server`
- `nixos/modules/wayland.nix` → `modules.wayland`
- `darwin/modules/kitty/` → `modules.kitty`
- `darwin/modules/raycast/` → `modules.raycast`
- `nix/home/polybar/` → `modules.polybar`

### Hardcoded values bypassing both namespaces

- `nixos/nijusan/configuration.nix` hardcodes `trusted-users = ["root" "logan"]`
- `home-manager/wijusan.nix` hardcodes `home.username = "logan"`
- `darwin/modules/system/default.nix` uses `config.my.user.name or "logan"` fallback

### `lib.my` (undocumented)

`lib/extended.nix` uses `lib.extend` to inject `lib.my` (from `lib/default.nix`): types, files, strings, float, hex, color, nerdfonts, font-awesome, currentHostname, getEnvOr, flakeRoot, toExe. Only ~5 call sites. No doc comments.

### Missing descriptions

Most options in `options.nix` use `mkOpt` shorthand which omits `description`. Only 3 of ~30 options have descriptions.

## Proposed standards

1. **`config.my.*`** — identity, preferences, and cross-cutting concerns consumed by multiple modules.
2. **`config.my.<program>.*`** — per-program options that extend `my` identity (e.g., `my.tailscale.ssh`).
3. **Retire `config.modules.*`** — migrate to `config.my.*` or standard NixOS/HM option patterns.
4. **No hardcoded values** when `config.my.*` exists for that value.
5. **Every `mkOption` must have a `description`**.
6. **`lib.my.*`** — pure utility functions only. Document via comments.

## Deliverables

1. `docs/module-standards.md` — prose guide with rules, examples, decision flowchart
2. Updated `options.nix` — descriptions on all options
3. Documented `lib/default.nix` and `lib/extended.nix` — comment blocks on exports
4. Migration of `config.modules.*` → `config.my.*` (11 files declaring, ~17 files referencing)
5. Removal of hardcoded values in 3 files
6. Comment in `lib/extended.nix` explaining the `lib.extend` mechanism

## Steps

### 1. Write `docs/module-standards.md` (no code changes, no risk)

Rules, examples, decision flowchart. Can be merged independently.

### 2. Add descriptions to `options.nix`

Expand `mkOpt type default` → `mkOption { type; default; description; }`. Purely additive.

### 3. Document `lib/default.nix` and `lib/extended.nix`

Inline comments. No functional changes.

### 4. Migrate `modules.*` → `my.*` (batch 1 — simple enable-flag modules)

- `nixos/modules/btrfs.nix`: `modules.btrfs` → `my.btrfs`
- `nixos/modules/minecraft-server.nix`: `modules.minecraft-server` → `my.minecraft-server`
- `nix/modules/spellcheck.nix`: `modules.spellcheck` → `my.spellcheck`
- `darwin/modules/kitty/default.nix`: `modules.kitty` → `my.kitty`
- `darwin/modules/raycast/default.nix`: `modules.raycast` → `my.raycast`

### 5. Migrate `modules.*` → `my.*` (batch 2 — modules with sub-options)

- `nix/modules/themes/default.nix`: `modules.theme` → `my.theme`
- `nix/modules/desktop/browsers/`: `modules.desktop.browsers` → `my.desktop.browsers`
- `nix/modules/desktop/gnome/`: `modules.desktop.gnome` → `my.desktop.gnome`
- `nix/modules/desktop/plasma5/`: `modules.desktop.kde` → `my.desktop.kde`
- `nixos/modules/wayland.nix`: `modules.wayland` → `my.wayland`
- `nix/home/polybar/`: `modules.polybar` → `my.polybar`

### 6. Fix hardcoded values

- `nixos/nijusan/configuration.nix` — remove inline `nix.settings` (plan #02 overlap)
- `home-manager/wijusan.nix` — `home.username = config.my.user.name`
- `darwin/modules/system/default.nix` — remove `or "logan"` fallback

### 7. Validate

`nix flake check` + build each active configuration.

## Risks

1. **Build breakage from renames (Steps 4-5)** — missed reference → eval error. Mitigation: small batches, `nix eval` after each change, thorough grep.

2. **Merge option collisions** — moving into `my.*` could collide with existing options. Audit all proposed names against `options.my` before migrating.

3. **Home-manager option forwarding** — `flake-module/default.nix` forwards `config.my` from system into HM. Newly added `my.*` from individual modules won't appear in HM unless those modules are also imported there. Verify each target's usage scope.

4. **Stale NixOS configurations** — removing hardcoded values requires confirming common module is imported and defaults are appropriate.

5. **Documentation drift** — `docs/module-standards.md` only useful if maintained. Consider grep-based CI check for new `options.modules.*` declarations.
