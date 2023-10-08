{
  perSystem = ctx@{ inputs', self', config, system, pkgs, lib, ... }: {
    mission-control = {
      wrapperName = ",,"; # play nice with nix-community/comma
      scripts = let
        withPrintNixEnv = cmd: "printenv | grep '^NIX'; ${cmd}";
        withCows = cmd:
          "${pkgs.neo-cowsay}/bin/cowsay --random -- ${
            lib.escapeShellArg cmd
          }; ${cmd}";
        replExec = f:
          withPrintNixEnv (withCows ''
            nix repl --verbose --trace-verbose --file "${f}" "$@"
          '');
      in {
        z = {
          description = "Start flake REPL";
          exec = replExec "repl.nix";
        };
        b = {
          description = "Build configuration";
          exec = ''home-manager build --flake "$@"'';
        };
        s = {
          description = "Build + activate configuration";
          exec = withCows "home-manager switch --flake ~/.";
        };
        f = {
          description = "Run nix fmt";
          exec = "nix fmt";
        };
        hm = {
          description = "Run home-manager";
          exec =
            "${inputs'.home-manager.packages.home-manager}/bin/home-manager";
        };
        zh = {
          description = "Start home-manger REPL";
          exec = replExec "home-manager/repl.nix";
        };
        zo = {
          description = "Start nixos REPL";
          exec = replExec "nixos/repl.nix";
        };
        up = {
          description = "Update flake.lock";
          exec = ''nix flake update --commit-lock-file "$@"'';
        };
        show = {
          description = "Show flake outputs";
          exec = ''nix flake show "$@"'';
        };
        meta = {
          description = "Show flake";
          exec = ''nix flake metadata "$@"'';
        };
      };
    };
  };
}
