---
date: 2026-03-29
git_revision: 6a928fa7
model: claude-opus-4-6
claude_version: 2.1.86
status: todo
---

# Plan: Extract Reusable Module Patterns with Proper Options

## Current patterns

### Pattern 1: Import-only (most common, ~30 modules)

Plain attribute sets, no options. Features toggled by adding/removing imports in host configs:
```nix
# nix/home/dev/rust.nix
{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ openssl pkg-config rustup ];
  home.sessionVariables = { RUSTUP_HOME = "${config.xdg.dataHome}/rustup"; };
}
```

### Pattern 2: Piggybacking upstream `enable` options

Wraps upstream HM program options, guards with `mkIf cfg.enable` but no custom enable:
```nix
# nix/home/kitty/default.nix
programs = mkIf cfg.enable { kitty = { ... }; };
# where cfg = config.programs.kitty
```

### Pattern 3: Proper module pattern (rare, ~8 modules)

Declares custom options: `nix/modules/spellcheck.nix`, `nix/home/claude/default.nix`, `nix/home/aider.nix`, `nix/home/dev/javascript.nix`, `darwin/modules/kitty/default.nix`.

## Target pattern

```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.<name>;
in {
  options.modules.<name> = {
    enable = lib.mkEnableOption "<human description>";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ... ];
  };
}
```

Conventions:
- `modules.<name>` for custom modules; `programs.<name>` only when extending upstream
- Always wrap `config` in `mkIf cfg.enable`
- `enable` defaults to `false`; hosts opt in explicitly
- Import all, enable selectively

## Priority modules

### 1. `nix/home/dev/` (and sub-modules)

Marked `# TODO module` in framework's home.nix. 12 sub-modules. Target:
```nix
modules.dev.enable = true;
modules.dev.rust.enable = true;   # defaults to cfg.enable
modules.dev.kubernetes.enable = true;  # not in default set
```

### 2. `nix/home/emacs/default.nix`

Substantial module (emacs, service, vterm, helpers). Target: `modules.emacs.enable`.

### 3. `nix/home/docker.nix`

Simple package-list module. Target: `modules.docker.enable`.

### 4. `nix/home/terraform.nix`

Pure package-list, simplest conversion candidate. Target: `modules.terraform.enable`.

### 5. `nix/home/aws/default.nix`

Packages + shell functions, only needed on work machines. Target: `modules.aws.enable`.

### 6. `nix/home/tmux.nix`

Medium complexity, programs.tmux config + zsh integration. Target: `modules.tmux.enable`.

### 7. `nix/home/doom/`

Tightly coupled to emacs. Target: `modules.doom.enable` (implies `modules.emacs.enable`).

## Steps

### Phase 1: Infrastructure

1. **Convert `nix/home/terraform.nix`** as proof-of-concept (simplest module).
2. **Convert `nix/home/docker.nix`** — validates the pattern.

### Phase 2: Dev toolchain

3. **Convert `nix/home/dev/` sub-modules** — each gets `modules.dev.<lang>.enable`.
4. **Convert `nix/home/dev/default.nix`** — top-level `modules.dev.enable`, sub-modules default to `cfg.enable`.
5. **Update host configs** — replace dev imports with `modules.dev.enable = true;` declarations.

### Phase 3: Application modules

6. **Convert `nix/home/emacs/default.nix`**
7. **Convert `nix/home/doom/`** — add assertion that `modules.emacs.enable` must be true.
8. **Convert `nix/home/aws/default.nix`**
9. **Convert `nix/home/tmux.nix`**

### Phase 4: Integration

10. **Create module index** in `nix/home/modules.nix` or extend `common/default.nix` — imports all converted modules, none enabled by default.
11. **Update host configs** — remove individual imports, add `modules.X.enable` declarations.
12. **Document the pattern** in a comment at top of the module index.

### Future candidates (out of scope)

`ghostty.nix`, `kitty/`, `nixvim/`, `pretty.nix`, `wezterm/`, `yazi/`, `yubikey.nix`, `television.nix`.

## Risks

1. **Evaluation cost** — importing all modules means evaluating all option declarations. Negligible at ~30 modules. Ensure expensive expressions are inside `mkIf` blocks.

2. **Namespace conflicts** — `modules.<name>` shared with `nix/modules/` (spellcheck, desktop, polybar). Grep before adding new options.

3. **Silent feature loss** — converting from "active when imported" to "active when enabled" could silently disable features if host forgets `enable = true`. Mitigation: convert module + update hosts in same commit. Run `home-manager switch --dry-run`.

4. **Dev sub-module defaults** — if sub-modules default to `true` when `modules.dev.enable` is `true`, matches current behavior. Hosts disable selectively with `modules.dev.ruby.enable = false;`.

5. **Module index naming** — `nix/home/modules.nix` vs existing `nix/modules/modules.nix`. Consider `nix/home/all-modules.nix` or integrating into `common/default.nix`.
