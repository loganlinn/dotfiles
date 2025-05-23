let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock.prev);
in
  import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz")
