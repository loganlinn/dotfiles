---
date: 2026-03-29
git_revision: 6a928fa7
model: claude-opus-4-6
claude_version: 2.1.86
status: completed
---

# Plan: Complete kernel-configuration.nix Updates

## Document history

- 2026-03-29: Removed .old.nix file cleanup from plan scope. User will handle manual cleanup of `configuration.old.nix`, `hardware-configuration.old.nix`, and `kernel-configuration.old.nix` separately. Simplified plan to focus on kernel config updates only.

## Current state

- `kernel-configuration.nix` still has `linuxPackages_latest` and is missing `acpi_osi=Linux`.

## Steps

### 1. Update kernel-configuration.nix — kernel packages

Change `boot.kernelPackages = pkgs.linuxPackages_latest` → `pkgs.linuxPackages` (LTS) for A4000 ACPI stability on Z790-I.

### 2. Update kernel-configuration.nix — add ACPI kernel parameter

Add `"acpi_osi=Linux"` to `boot.kernelParams`:

```nix
boot.kernelParams = [
  "i915.enable_psr=1"
  "i915.force_probe=a780"
  "acpi_osi=Linux"
  "mem_sleep_default=deep"
];
```

Resolves Z790-I ACPI `_DSM` timeout on `\_SB.PC00.PEG1.PEGP`.

### 3. Commit

```
nijusan: complete kernel config for 25.11
```

### 4 (conditional). Update i915 force_probe ID

After manual verification, if iGPU device ID is not `a780`, update accordingly.

## Manual verification

1. **Verify iGPU PCI device ID**: `lspci | grep VGA` on nijusan. Expected: `a780` (UHD 770, Raptor Lake-S GT1).
2. **Rebuild**: `sudo nixos-rebuild switch --flake .#nijusan`
3. **Verify ACPI fix**: `dmesg | grep -i acpi` — `_DSM` timeout should be gone or cosmetic.
4. **Verify kernel**: `uname -r` should show LTS (6.12.x or similar).
5. **Verify GPU**: `nvidia-smi` shows A4000, display works through A4000 outputs.
6. **Verify boot**: systemd-boot menu with 3s timeout, generation cap at 10.

## Risks

1. **LTS kernel regression** — if LTS is older than what the fresh install used, 13th-gen Intel or Z790 support could regress. Mitigation: systemd-boot keeps previous generation bootable.
2. **i915 force_probe mismatch** — wrong ID means iGPU not force-probed (no crash, just no iGPU). Low impact since A4000 is primary.
3. **acpi_osi=Linux side effects** — changes BIOS ACPI behavior. Recommended fix for Z790-I but monitor thermals/fans after.

## Notes

- `*.old.nix` files left for manual cleanup
