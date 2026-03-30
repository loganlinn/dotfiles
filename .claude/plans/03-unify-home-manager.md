---
date: 2026-03-29
git_revision: 6a928fa7
model: claude-opus-4-6
claude_version: 2.1.86
status: done
---

# Plan: Unify Home-Manager Configurations Across Hosts

## Current state

Home-manager config uses three different patterns:

| Host | Pattern | Location |
|------|---------|----------|
| nijusan | Standalone `homeConfigurations` | `home-manager/nijusan.nix` |
| wijusan | Standalone `homeConfigurations` | `home-manager/wijusan.nix` |
| framework | Inline in NixOS via `home-manager.users.logan = import ./home.nix` | `nixos/framework/home.nix` |
| logamma | Inline in darwin config (~90 lines) | `darwin/logamma/default.nix` L158-246 |
| patchbook | Inline in darwin config (~12 lines) | `darwin/patchbook.nix` L10-22 |

Darwin modules (aerospace, hammerspoon, kitty, borders, sketchybar, sunbeam) also inject HM config via `home-manager.users.${...}` — this pattern is valid and should be preserved.

Note: `nixos/framework/configuration.nix` has `# TODO unify with nijusan`.

## Target architecture

Every host gets a standalone home-manager file at `home-manager/<hostname>.nix`. NixOS/darwin configs reference them via import.

```
home-manager/
  framework.nix    # NEW — from nixos/framework/home.nix
  logamma.nix      # NEW — from darwin/logamma inline block
  nijusan.nix      # EXISTS
  patchbook.nix    # NEW — from darwin/patchbook inline block
  wijusan.nix      # EXISTS
```

System configs import the standalone file:
```nix
home-manager.users.logan = import ../../home-manager/framework.nix;
```

Darwin module injection (`home-manager.users.${...}` from aerospace, kitty, etc.) composes cleanly via NixOS module system merging.

## Steps

### 1. Create `home-manager/framework.nix`

- Copy contents of `nixos/framework/home.nix`
- Add `home.username = "logan";` and `home.homeDirectory = "/home/logan";`
- Update `nixos/framework/configuration.nix`: change import path to `../../home-manager/framework.nix`
- **Validate**: `sudo nixos-rebuild build --flake .#framework`

### 2. Create `home-manager/logamma.nix`

- Extract inline block from `darwin/logamma/default.nix` (L159-246)
- Add `home.username`, `home.homeDirectory = "/Users/logan";`
- Replace inline block with `import ../../home-manager/logamma.nix;`
- **Validate**: `darwin-rebuild build --flake .#logamma`

### 3. Create `home-manager/patchbook.nix`

- Extract inline block from `darwin/patchbook.nix` (L10-22)
- Add `home.username`, `home.homeDirectory = "/Users/logan";`, `home.stateVersion`
- Replace inline block with `import ../home-manager/patchbook.nix;`
- **Validate**: `darwin-rebuild build --flake .#patchbook`

### 4. Register new standalone `homeConfigurations` in flake.nix (optional)

Enables `home-manager switch` without full system rebuild:
```nix
homeConfigurations."logan@framework" = mkHomeConfiguration { system = "x86_64-linux"; modules = [ ./home-manager/framework.nix ]; };
homeConfigurations."logan@logamma" = mkHomeConfiguration { system = "aarch64-darwin"; modules = [ ./home-manager/logamma.nix ]; };
homeConfigurations."logan@patchbook" = mkHomeConfiguration { system = "aarch64-darwin"; modules = [ ./home-manager/patchbook.nix ]; };
```

### 5. Delete `nixos/framework/home.nix`

After confirming framework build works with new path.

### 6. Audit and deduplicate shared imports (follow-up)

- Common imports across configs → consider `homeModules.base` bundle
- `nix.*` and `home.stateVersion` repeated → set in `homeModules.common` with `mkDefault`
- `colorScheme` overrides → remove from configs that want the default

## Migration strategy

- Each step is independent, testable in isolation, and a single commit
- Steps 1-3 can be done in any order
- Old files not deleted until Step 5
- Rollback: revert commit, point import back to original path
- Verify existing standalone configs still build: `nix build .#homeConfigurations.logan@nijusan.activationPackage`

## Risks

1. **`specialArgs` mismatch** — standalone vs module contexts receive `extraSpecialArgs` from different sources. Both use `mkSpecialArgs` from `flake-module/default.nix`, so should be identical. But standalone context lacks NixOS/darwin-level `config`. Audit home files for NixOS-level config references.

2. **`my.*` option propagation asymmetry** — NixOS propagates `config.my` into HM; darwin only imports `options.nix` (gets defaults, not darwin-level values). Existing issue, not introduced by migration.

3. **Darwin module injection ordering** — Darwin modules injecting via `home-manager.users.${...}` compose with the imported file via module system merging. No risk unless there are conflicting option definitions.

4. **`nix.*` settings in standalone darwin** — standalone HM on darwin needs its own `nix.*` settings. Only register darwin hosts as `homeConfigurations` if actually needed.

5. **Relative path changes** — moving files changes import paths (e.g., `../../nix/home/dev` → `../nix/home/dev`). Mechanical, caught immediately by `nix build`.
