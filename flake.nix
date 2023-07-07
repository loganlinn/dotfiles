{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    ## packages
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    ## builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland.url = "github:vaxerski/Hyprland/v0.21.0beta";
    # hyprland.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-shell.url = "github:Mic92/nixos-shell";
    # nixinate.url = "github:matthewcroughan/nixinate";

    ## overlays
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    ## libs + data
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    grub2-themes.inputs.nixpkgs.follows = "nixpkgs";
    grub2-themes.url = "github:AnotherGroupChat/grub2-themes-png";
    mission-control.url = "github:Platonic-Systems/mission-control";
    nix-colors.url = "github:misterio77/nix-colors";
    nixos-flake.url = "github:srid/nixos-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    agenix.url = "github:ryantm/agenix";
    # process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    ## shells
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    # devshellurl = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs";

    ## applications
    # emanote.url = "github:srid/emanote";
    # hci.url = "github:hercules-ci/hercules-ci-agent";
    # nixos-vscode-server.flake = false;
    # nixos-vscode-server.url = "github:msteen/nixos-vscode-server";
    # nixpkgs-match.url = "github:srid/nixpkgs-match";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];

    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
      inputs.flake-root.flakeModule
      inputs.mission-control.flakeModule
      # inputs.nixos-flake.flakeModule # FIXME: conflicts with flake.lib
      # inputs.emanote.flakeModule
      ./flake-modules/options.nix # TODO move
      ./home-manager/flake-module.nix
      ./nixos/flake-module.nix
      ./nix/flake-parts
    ];

    debug = true;

    flake.lib.my = (import ./lib/extended.nix inputs.nixpkgs.lib).my;

    perSystem = { config, system, inputs', pkgs, lib, ... }: {

      packages.jdk = lib.mkDefault pkgs.jdk;

      overlayAttrs = {
        inherit (inputs'.home-manager.packages) home-manager;
        inherit (inputs'.devenv.packages) devenv;
        inherit (inputs'.emacs.packages) emacs-unstable;
        inherit (config.packages) jdk;
      };

      formatter = pkgs.nixpkgs-fmt;

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.mission-control.devShell ];
        buildInputs = [
          config.formatter
          inputs'.agenix.packages.agenix
        ];
        env = {
          NIX_USER_CONF_FILES = toString ./nix.conf;
        };
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
  };
}
