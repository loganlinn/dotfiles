{ lib, ... }:

with lib;

{
  font = types.submodule {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.dejavu_fonts";
      };

      name = mkOption {
        type = types.str;
        example = "DejaVu Sans";
      };

      size = mkOption {
        type = types.nullOr types.number;
        default = null;
        example = "8";
      };
    };
  };

  pathStr = with types; coercedTo path toString str;

  # home-manager/modules/programs/gpg.nix
  publicKeySubmodule =
    with types;
    submodule (
      { config, ... }:
      {
        options = {
          text = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Text of an OpenPGP public key.
            '';
          };

          source = mkOption {
            type = path;
            description = ''
              Path of an OpenPGP public key file.
            '';
          };

          trust = mkOption {
            type = nullOr (enum [
              "unknown"
              1
              "never"
              2
              "marginal"
              3
              "full"
              4
              "ultimate"
              5
            ]);
            default = null;
            apply =
              v:
              if isString v then
                {
                  unknown = 1;
                  never = 2;
                  marginal = 3;
                  full = 4;
                  ultimate = 5;
                }
                .${v}
              else
                v;
            description = ''
              The amount of trust you have in the key ownership and the care the
              owner puts into signing other keys. The available levels are
              <variablelist>
                <varlistentry>
                  <term><literal>unknown</literal> or <literal>1</literal></term>
                  <listitem><para>I don't know or won't say.</para></listitem>
                </varlistentry>
                <varlistentry>
                  <term><literal>never</literal> or <literal>2</literal></term>
                  <listitem><para>I do NOT trust.</para></listitem>
                </varlistentry>
                <varlistentry>
                  <term><literal>marginal</literal> or <literal>3</literal></term>
                  <listitem><para>I trust marginally.</para></listitem>
                </varlistentry>
                <varlistentry>
                  <term><literal>full</literal> or <literal>4</literal></term>
                  <listitem><para>I trust fully.</para></listitem>
                </varlistentry>
                <varlistentry>
                  <term><literal>ultimate</literal> or <literal>5</literal></term>
                  <listitem><para>I trust ultimately.</para></listitem>
                </varlistentry>
              </variablelist>
              </para><para>
              See <link xlink:href="https://www.gnupg.org/gph/en/manual/x334.html"/>
              for more.
            '';
          };
        };
        config = {
          source = mkIf (config.text != null) (pkgs.writeText "gpg-pubkey" config.text);
        };
      }
    );

  # https://github.com/NixOS/nixpkgs/blob/f67841950fe8e33ae6597cc2dac1bc179c3c2627/nixos/modules/config/nix-flakes.nix
  nix-registry = types.attrsOf (
    types.submodule (
      let
        referenceAttrs =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
            path
            package
          ]);
      in
      { config, name, ... }:
      {
        options = {
          from = mkOption {
            type = referenceAttrs;
            example = {
              type = "indirect";
              id = "nixpkgs";
            };
            description = "The flake reference to be rewritten.";
          };
          to = mkOption {
            type = referenceAttrs;
            example = {
              type = "github";
              owner = "my-org";
              repo = "my-nixpkgs";
            };
            description = "The flake reference {option}`from` is rewritten to.";
          };
          flake = mkOption {
            type = types.nullOr types.attrs;
            default = null;
            example = literalExpression "nixpkgs";
            description = ''
              The flake input {option}`from` is rewritten to.
            '';
          };
          exact = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether the {option}`from` reference needs to match exactly. If set,
              a {option}`from` reference like `nixpkgs` does not
              match with a reference like `nixpkgs/nixos-20.03`.
            '';
          };
        };
        config = {
          from = mkDefault {
            type = "indirect";
            id = name;
          };
          to = mkIf (config.flake != null) (
            mkDefault (
              {
                type = "path";
                path = config.flake.outPath;
              }
              // filterAttrs (
                n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash"
              ) config.flake
            )
          );
        };
      }
    )
  );
}
