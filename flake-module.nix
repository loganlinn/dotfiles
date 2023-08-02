top@{ self, inputs, config, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib) mkPerSystemOption;

  mkLib = import ./lib/extended.nix;
  mkHmLib = let compose = g: f: x: g (f x); in
    compose (import "${inputs.home-manager}/modules/lib/stdlib-extended.nix") mkLib;
in
{
  imports = [
    ./home-manager/flake-module.nix
    ./nixos/flake-module.nix
  ];

  options.perSystem = mkPerSystemOption (ctx@{ pkgs, ... }:
    with (mkHmLib top.lib);
    let
      cfg = ctx.config.my;
    in
    {
      options.my = mkOption {
        default = { };
        type = types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              default = "Logan";
            };

            user = mkOption {
              default = {
                name = "logan";
                shell = pkgs.zsh;
              };
              type = types.submodule {
                options = {
                  name = mkOption {
                    type = types.str;
                  };
                  shell = mkOption {
                    # type = with types; nullOr (either shellPackage (passwdEntry path));
                    type = with types; nullOr package;
                  };
                  authorizedKeys = {
                    keys = mkOption {
                      type = types.listOf types.singleLineStr;
                      default = [
                        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa"
                        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwurIVpZjNpRjFva/8loWMCZobZQ3FSATVLC8LX2TDB"
                      ];
                    };
                    keyFiles = mkOption {
                      type = types.listOf types.path;
                      default = [ ];
                    };
                  };
                };
              };
            };

            email = mkOption {
              type = types.str;
              default = "logan@loganlinn.com";
            };

            website = mkOption {
              type = types.str;
              default = "https://loganlinn.com";
            };

            # publicKeys = mkOption {
            #   type = types.listOf myTypes.publicKeySubmodule;
            #   example = literalExpression ''
            #     [ { source = ./pubkeys.txt; } ]
            #   '';
            #   default = [ ];
            #   description = ''
            #     A list of public keys to be imported into GnuPG. Note, these key files
            #     will be copied into the world-readable Nix store.
            #   '';
            # };

            homeDir = mkOption {
              type = types.str;
              default =
                if pkgs.stdenv.targetPlatform.isDarwin
                then "/Users/${cfg.user.name}"
                else "/home/${cfg.user.name}";
            };

            dotfilesDir = mkOption {
              type = types.str;
              default = "${cfg.homeDir}/.dotfiles";
            };

            srcDir = mkOption {
              type = types.str;
              default = "${cfg.homeDir}/src";
            };

            github.user = mkOption {
              type = types.str;
              default = "loganlinn";
            };

            flakeRoot = mkOption {
              type = types.path;
              default = "${cfg.dotfilesDir}";
            };

            fonts.serif = mkOption {
              type = hm.types.fontType;
              default = {
                package = pkgs.noto-fonts;
                name = "DejaVu Serif";
                size = if pkgs.stdenv.isDarwin then 12 else 10;
              };
            };

            fonts.sans = mkOption {
              type = hm.types.fontType;
              default = {
                package = pkgs.noto-fonts;
                name = "DejaVu Sans";
                size = if pkgs.stdenv.isDarwin then 12 else 10;
              };
            };

            fonts.mono = mkOption {
              type = hm.types.fontType;
              default = {
                package = cfg.fonts.nerdfonts.package;
                name = "DejaVu Sans Mono";
                size = if pkgs.stdenv.isDarwin then 12 else 10;
              };
            };

            fonts.terminal = mkOption {
              type = hm.types.fontType;
              default = {
                package = cfg.fonts.nerdfonts.package;
                name = "FiraCode Nerd Font Light";
                size = 11;
              };
            };

            fonts.nerdfonts = mkOption {
              readOnly = true;
              type = hm.types.fontType;
              default = {
                package = pkgs.nerdfonts.override {
                  fonts = [
                    # "3720"
                    "AnonymousPro"
                    "DejaVuSansMono"
                    "FiraCode"
                    "FiraMono"
                    "Go-Mono"
                    "Hack"
                    "Hasklig"
                    "FantasqueSansMono"
                    "IBMPlexMono"
                    "Inconsolata"
                    "Iosevka"
                    "JetBrainsMono"
                    "LiberationMono"
                    "Lilex"
                    "Meslo"
                    "NerdFontsSymbolsOnly"
                    "Noto"
                    "OpenDyslexic"
                    "ProFont"
                    "RobotoMono"
                    "SourceCodePro"
                    "SpaceMono"
                    "Terminus"
                    "Ubuntu"
                    "UbuntuMono"
                    "VictorMono"
                  ];
                };
              };
            };

            fonts.packages = mkOption {
              type = with types; listOf package;
              default = with pkgs; [
                open-sans
                ankacoder
                cascadia-code
                dejavu_fonts
                fira # sans
                fira-code
                fira-code-symbols
                font-awesome
                font-awesome_5
                hack-font
                iosevka
                jetbrains-mono
                liberation_ttf
                material-design-icons # https://materialdesignicons.com/
                material-icons
                noto-fonts
                noto-fonts-cjk
                noto-fonts-emoji
                recursive
                ubuntu_font_family
                victor-mono
              ];
            };
          };

          # config = {
          #   packages = lib.filterAttrs (_: v: v != null) {
          #     activate =
          #       if hasNonEmptyAttr [ "darwinConfigurations" ] self || hasNonEmptyAttr [ "nixosConfigurations" ] self
          #       then
          #         pkgs.writeShellApplication
          #           {
          #             name = "activate";
          #             text =
          #               # TODO: Replace with deploy-rs or (new) nixinate
          #               if system == "aarch64-darwin" || system == "x86_64-darwin" then
          #                 let
          #                   # This is used just to pull out the `darwin-rebuild` script.
          #                   # See also: https://github.com/LnL7/nix-darwin/issues/613
          #                   emptyConfiguration = self.nixos-flake.lib.mkMacosSystem system { };
          #                 in
          #                 ''
          #                   HOSTNAME=$(hostname -s)
          #                   set -x
          #                   ${emptyConfiguration.system}/sw/bin/darwin-rebuild \
          #                     switch \
          #                     --flake .#"''${HOSTNAME}" \
          #                     "$@"
          #                 ''
          #               else
          #                 ''
          #                   HOSTNAME=$(hostname -s)
          #                   set -x
          #                   ${lib.getExe pkgs.nixos-rebuild} \
          #                     switch \
          #                     --flake .#"''${HOSTNAME}" \
          #                     --use-remote-sudo \
          #                     "$@"
          #                 '';
          #           }
          #       else null;

          #     activate-home =
          #       if hasNonEmptyAttr [ "homeConfigurations" ] self || hasNonEmptyAttr [ "legacyPackages" system "homeConfigurations" ] self
          #       then
          #         pkgs.writeShellApplication
          #           {
          #             name = "activate-home";
          #             text =
          #               ''
          #                 set -x
          #                 nix run \
          #                   .#homeConfigurations."\"''${USER}\"".activationPackage \
          #                   "$@"
          #               '';
          #           }
          #       else null;
          #   };
          # };
        };
      };

      # nixosModules.my = { options, config, ... }:
      #   let cfg = config.my; in {
      #     options = {
      #       inherit (ctx.options) my;
      #     };
      #     config = {
      #       inherit (ctx.config) my;
      #       environment.shells = optional (cfg.user.shell != null) cfg.user.shell;
      #     };
      #   };

      # homeManagerModules.my = {
      #   options.my = ctx.options.my;
      #   config.my = ctx.config.my;
      # };
    });

  config = {
    perSystem = { pkgs, config, ... }:
      with top.lib;
      let
        appDerivations = pipe ./nix/apps [
          filesystem.listFilesRecursive
          (remove (hasPrefix "_"))
          (filter (hasSuffix ".nix"))
          (map (removeSuffix "default.nix"))
          (map (file: pkgs.callPackage file { }))
        ];
      in
      {
        apps = pipe appDerivations [
          (map (drv: { "${drv.name}" = { type = "app"; program = getExe drv; }; }))
          (fold recursiveUpdate { })
        ];
        checks = pipe appDerivations [
          (map (drv: { "app-${drv.name}" = drv; }))
          (fold recursiveUpdate { })
        ];
        # TODO checks.repl.default = mkNixReplCheck ./repl.nix
      };

    flake = {
      lib = (mkLib top.lib).my // {
        inherit mkLib mkHmLib;
      };
    };
  };
}
