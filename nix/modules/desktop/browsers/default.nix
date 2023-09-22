{ options, config, lib, ... }:
with lib;
let cfg = config.modules.desktop.browsers;
in {
  imports = [
    ../../../home/firefox.nix # common settings
  ];

  options.modules.desktop.browsers = {
    default = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    alternate = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = {
    home.sessionVariables =
      let hasUnescapedQuote = s: (strings.match ''.*[^\]".*'' s) != null;
      in assert assertMsg (!hasUnescapedQuote cfg.default)
        "must escape quotes for session variable";
      assert assertMsg (!hasUnescapedQuote cfg.alternate)
        "must escape quotes for session variable";
      optionalAttrs (cfg.default != null) { BROWSER = cfg.default; }
      // optionalAttrs (cfg.alternate != null) { BROWSER_ALT = cfg.alternate; };
  };
}
