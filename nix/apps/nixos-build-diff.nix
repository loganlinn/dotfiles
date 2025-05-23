{
  writeShellApplication,
  nvd,
  ...
}:
writeShellApplication {
  name = "nixos-build-diff";
  runtimeInputs = [nvd];
  text = ''
    nixos-rebuild build "$@" && nvd diff /run/current-system result
  '';
}
