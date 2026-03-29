# dotfiles — Claude Code Context

## Machine: nijusan

ASUS ROG Strix Z790-I ITX, Intel Core i9-13900K, NVIDIA RTX A4000 (16GB), 2x Samsung NVMe.

### Fresh NixOS 25.11 install — March 2026

Just reinstalled from scratch. The config in `nixos/nijusan/` needs to be updated to reflect the new setup.

---

## Disk layout (new)

| Partition | Device | Size | FS | Mount |
|-----------|--------|------|----|-------|
| boot | nvme0n1p1 | 1GB | FAT32 | `/boot` |
| root | nvme0n1p2 | 100GB | ext4 | `/` |
| nix store | nvme0n1p3 | ~1.7TB | ext4 | `/nix` |
| home | nvme1n1p1 | 1TB | ext4 | `/home` |
| (unallocated) | nvme1n1 | ~1TB | — | reserved for future Windows |

Previous setup used tmpfs root + btrfs subvolumes. That's gone. All plain ext4 now.

---

## hardware-configuration.nix

The file at `nixos/nijusan/hardware-configuration.nix` is **stale** — it has old btrfs UUIDs and the tmpfs root layout from the previous install.

The freshly generated file is at `/etc/nixos/hardware-configuration.nix` on nijusan. Copy it into the repo and replace the old one. Key things the new file should have (verify against live system):

- `fileSystems."/"` — ext4, correct UUID
- `fileSystems."/nix"` — ext4, correct UUID
- `fileSystems."/home"` — ext4, correct UUID
- `fileSystems."/boot"` — vfat, correct UUID
- No swap (none configured)
- Keep `nixos-hardware` imports: `common-cpu-intel`, `common-gpu-nvidia-nonprime`, `common-pc-ssd`

---

## kernel-configuration.nix

Needs these changes:

1. **Kernel**: change `linuxPackages_latest` → `linuxPackages` (LTS) — the A4000 ACPI issues are more stable on LTS

2. **Add ACPI fix** to `boot.kernelParams`:
   ```nix
   "acpi_osi=Linux"
   ```
   This resolves the Z790-I ACPI `_DSM` timeout on the PCIe slot (`\_SB.PC00.PEG1.PEGP`) that causes boot hangs and IRQ errors.

3. **Verify iGPU probe ID**: `i915.force_probe=a780` may need updating — run `lspci | grep VGA` on nijusan to confirm the correct device ID.

4. **Add generation limit** (if not elsewhere in config):
   ```nix
   boot.loader.systemd-boot.configurationLimit = 10;
   ```
   Previous installs ran out of space for generations. `/nix` now has ~1.7TB so this is less critical, but still good hygiene.

---

## nix settings

Add to `configuration.nix` or a shared module:

```nix
nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dde0946WDTTkh8+bZQITgBR7ZMEH2eyJw="
  ];
  trusted-users = [ "root" "logan" ];
};
```

---

## Known issues / boot quirks

- **ACPI Error on boot**: `Aborting method \_SB.PC00.PEG1.PEGP._DSM (AE_AML_LOOP_TIMEOUT)` — cosmetic after adding `acpi_osi=Linux`, but present without it
- **iGPU output**: BIOS was set to PEG Slot (discrete GPU) by default. Had to enable iGPU output in BIOS Graphics Configuration to get display during install. After Nvidia drivers are properly configured via `nixosModules.nvidia`, the A4000 will be primary again.
- **Audio IRQ**: `snd_hda_intel: No response from codec` / IRQ #17 disabled — harmless, audio still works via pipewire

---

## First rebuild checklist

- [ ] Copy fresh `hardware-configuration.nix` from `/etc/nixos/` on nijusan into repo
- [ ] Update `kernel-configuration.nix` (see above)
- [ ] Add `nix.settings` block
- [ ] Run `sudo nixos-rebuild switch --flake .#nijusan`
- [ ] Verify display output switches to A4000 after rebuild
- [ ] Verify GNOME / xsession launches correctly
