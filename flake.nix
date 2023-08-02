{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    ## packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    ## builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland.url = "github:vaxerski/Hyprland/v0.21.0beta";
    # hyprland.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-shell.url = "github:Mic92/nixos-shell";
    # nixinate.url = "github:matthewcroughan/nixinate";

    ## overlays
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    # nixgl.url = "github:guibou/nixGL";

    ## libs + data
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixos-flake.url = "github:srid/nixos-flake"; # demands nix-darwin
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control"; # demands flake-root (and agenix?)
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:Mic92/sops-nix";
    agenix.url = "github:ryantm/agenix";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # haumea.url = "github:nix-community/haumea/v0.2.2";
    # haumea.inputs.nixpkgs.follows = "nixpkgs";
    # yants.url = "github:divnix/yants";
    # yants.inputs.nixpkgs.follows = "nixpkgs";
    # rime.url = "github:aakropotkin/rime";
    # rime.inputs.nixpkgs.follows = "nixpkgs";
    # process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    ## shells
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    # devshellurl = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs";

    ## apps
    # emanote.url = "github:srid/emanote";
    # hci.url = "github:hercules-ci/hercules-ci-agent";
    # nixos-vscode-server.flake = false;
    # nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    # nixpkgs-match.url = "github:srid/nixpkgs-match";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" ];

    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
      inputs.nixos-flake.flakeModule
      inputs.flake-root.flakeModule
      inputs.mission-control.flakeModule
      ./flake-module.nix
    ];

    perSystem = { config, system, inputs', pkgs, lib, ... }: {

      packages = {
        jdk = lib.mkDefault pkgs.jdk; # needed?
        kubefwd = pkgs.callPackage ./nix/pkgs/kubefwd.nix {};
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        i3-auto-layout = pkgs.callPackage ./nix/pkgs/os-specific/linux/i3-auto-layout.nix {};
        graphite-cli = pkgs.callPackage ./nix/pkgs/os-specific/linux/graphite-cli.nix {};
      };

      overlayAttrs = {
        inherit (config.packages) jdk kubefwd i3-auto-layout;
        inherit (inputs'.home-manager.packages) home-manager;
        inherit (inputs'.devenv.packages) devenv;
        inherit (inputs'.emacs.packages) emacs-unstable;
      };

      formatter = pkgs.nixpkgs-fmt;

      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.flake-root.devShell # sets FLAKE_ROOT
          config.mission-control.devShell
        ];
        buildInputs = [
          config.formatter
          inputs'.agenix.packages.agenix
        ];
        env.NIX_USER_CONF_FILES = toString ./nix.conf;
      };

      mission-control = {
        wrapperName = ",,"; # play nice with nix-community/comma
        scripts =
          let
            inherit (lib) getExe;
            withArgs = cmd: ''${cmd} "$@"'';
            withCows = cmd: ''${pkgs.neo-cowsay}/bin/cowsay --random -- ${lib.escapeShellArg cmd}; ${cmd}'';
            wrap = cmd: lib.pipe cmd [ withArgs withCows ];
            pkgExec = p: withArgs (getExe p);
            replExec = f: wrap ''nix repl --file "${f}"'';
          in
          {
            z = { description = "Start flake REPL"; exec = replExec "repl.nix"; };
            b = { description = "Build configuration"; exec = ''homie build "$@"''; };
            s = { description = "Build + activate configuration"; exec = withArgs "homie switch"; };
            f = { description = "Run nix fmt"; exec = withArgs "nix fmt"; };
            hm = { description = "Run home-manager"; exec = pkgExec inputs'.home-manager.packages.home-manager; };
            zh = { description = "Start home-manger REPL"; exec = replExec "home-manager/repl.nix"; };
            zo = { description = "Start nixos REPL"; exec = replExec "nixos/repl.nix"; };
            up = { description = "Update flake.lock"; exec = wrap "nix flake update --commit-lock-file"; };
            show = { description = "Show flake outputs"; exec = wrap "nix flake show"; };
            meta = { description = "Show flake"; exec = wrap "nix flake metadata"; };
          };
      };
    };

    debug = true; # https://flake.parts/debug.html, https://flake.parts/options/flake-parts.html#opt-debug
  };
}
