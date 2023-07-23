{ nodePackages
, pixman
, cairo
, pango
, installShellFiles
, pkg-config
}:

# https://github.com/NixOS/nixpkgs/pull/244153
nodePackages.graphite-cli.override (prev: {
  nativeBuildInputs = [ installShellFiles pkg-config ];
  buildInputs = [pixman pango cairo];
})
