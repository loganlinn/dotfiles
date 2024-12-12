{ config, ... }:
{
  config = {
    assertions = [
      {
        asesrtion = builtins.elem "$HOME/.local/bin" config.home.sessionPath;
        message = "$HOME/.local/bin is not in sessionPath";
      }
    ];

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--type-add"
        "clj:include:clojure,edn"
        "--smart-case"
        "--hyperlink-format=kitty" # note: also supported by wezterm
        "--follow"
      ];
    };

    home.files.".local/bin/rgz".source = ../../bin/rgz;

  };
}
