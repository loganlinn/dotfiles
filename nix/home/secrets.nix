{ config, pkgs, ... }:

let inherit (config.home) homeDirectory;
in {
  # https://github.com/FiloSottile/passage
  home.packages = with pkgs; [
    age
    age-plugin-yubikey
    passage
    (writeShellScriptBin "pz" ''
       set -eou pipefail
       PREFIX="''${PASSAGE_DIR:-$HOME/.passage/store}"
       FZF_DEFAULT_OPTS=""
       name="$(find "$PREFIX" -type f -name '*.age' | \
         sed -e "s|$PREFIX/||" -e 's|\.age$||' | \
         ${fzf}/bin/fzf --height 40% --reverse --no-multi)"

      exec ${passage}/bin/passage "''${@}" "$name"
    '')
  ];

  home.sessionVariables = {
    PASSAGE_DIR = "${homeDirectory}/.passage/store";
    PASSAGE_AGE = "${pkgs.age}/bin/age";
  };

  programs.password-store.enable = true;
}
