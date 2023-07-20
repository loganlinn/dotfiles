{ lib, ... }:

with lib;

# merge with lib.types so `with lib.my` works as expected with stdlib types.
types // {

  pathStr = with types; coercedTo path toString str;

  exeType = with types; coercedTo package getExe str;

  # home-manager/modules/programs/gpg.nix
  publicKeySubmodule = with types; submodule ({ config, ... }: {
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
        apply = v:
          if isString v then
            {
              unknown = 1;
              never = 2;
              marginal = 3;
              full = 4;
              ultimate = 5;
            }.${v}
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
  });
}
