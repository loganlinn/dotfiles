---
description: Coding conventions for Nix files, adopted from NixOS/nixpkgs
globs: ["*.nix"]
---

# Nix Coding Conventions

Adopted from [NixOS/nixpkgs CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#code-conventions).

## File naming and organisation

Names of files and directories should be lowercase kebab-case (e.g. `all-packages.nix`, not `allPackages.nix`).

## Formatting

Use the [official Nix formatter](https://github.com/NixOS/nixfmt) (`nix fmt` / `treefmt`).

## Syntax

- Use `lowerCamelCase` for variable names (not `UpperCamelCase`). This does not apply to package attribute names.

- Functions should list their expected arguments precisely. Prefer:

  ```nix
  {
    stdenv,
    fetchurl,
    perl,
  }:
  ```

  Not `args: with args;` or `{ stdenv, fetchurl, perl, ... }:` with unused ellipsis.

- For truly generic functions with some required arguments, use `@`-pattern:

  ```nix
  {
    stdenv,
    doCoverageAnalysis ? false,
    ...
  }@args:
  ```

- Avoid unnecessary string conversions. Write `{ tag = version; }` not `{ tag = "${version}"; }`.

- Build lists conditionally with `lib.optional(s)`:

  ```nix
  { buildInputs = lib.optional stdenv.hostPlatform.isDarwin iconv; }
  ```

  Not `if cond then [ ... ] else null` or `if cond then [ ... ] else [ ]`.
