{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.awesomewm;

  awesome = cfg.package;

  luafun = pkgs.fetchFromGitHub {
    owner = "luafun";
    repo = "luafun";
    rev = "cb6a7e25d4b55d9578fd371d1474b00e47bd29f3";
    hash = "sha256-lqWTPn1HPQxhfkUFvEUCbS05IkkroaykgYehJqQ0+lw=";
  };

  getLuaPath = lib: dir: "${lib}/${dir}/lua/${awesome.lua.luaversion}";

  makeSearchPath = concatMapStrings (path:
    " --search ${getLuaPath path "share"}"
    + " --search ${getLuaPath path "lib"}");

  awesome-init = ''${getExe awesome} ${makeSearchPath cfg.luaModules}'';
in
{
  options.my.awesomewm = {
    enable = mkEnableOption "awesome window manager";

    package = mkOption {
      type = types.package;
      default = pkgs.awesome;
      defaultText = literalExpression "pkgs.awesome";
      description = "Package to use for running the Awesome WM.";
    };

    luaModules = mkOption {
      type = types.listOf types.package;
      description = ''
        List of lua packages available for being
        used in the Awesome configuration.
      '';
      default = with pkgs.luaPackages; [
        fennel
        # luafun
        # lua-curl
        # lua-toml
        # lua-messagepack
        # lualogging
        # luafilesystem
        # luaevent
        # luadbi
        # luadbi-sqlite3
      ];
    };

    noArgb = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Disable client transparency support, which can be greatly
        detrimental to performance in some setups
      '';
    };
  };

  config = mkIf cfg.enable {
    services.picom.enable = true;
    home.packages = with pkgs; [
      awesome
      # lua
      # luarocks-nix
      # luajit
      # luaPackages.luarepl
      fennel
      xst
      (pkgs.writeShellScriptBin "awesome-check" ''
        #set -o xtrace
        set -o errexit -o nounset -o pipefail -o errtrace
        IFS=$'\n\t'

        eval $(${pkgs.luarocks}/bin/luarocks path --bin)

        disp_num=1
        disp=:$disp_num
        Xephyr -screen 1024x768 $disp -ac -br -sw-cursor &
        pid=$!
        while [ ! -e /tmp/.X11-unix/X''${disp_num} ] ; do
            sleep 0.1
        done

        export DISPLAY=$disp
        ${awesome-init}
        ${awesome}/bin/awesome-client

        kill $pid
        exit 0
      '')
    ];
    xdg.configFile = {
      # "awesome".source  =  "${config.my.dotfilesDir}/config/awesome";# { source = "${config.my.dotfilesDir}/config/awesome"; recursive = true; };
      "awesome/init.fnl".source = "${../..}/config/awesome/init.fnl"; # { source = "${config.my.dotfilesDir}/config/awesome"; recursive = true; };
      "awesome/rc.lua".text = ''
        package.path = package.path .. ";${pkgs.fennel}/?.lua"
        local fennel = require("fennel").install()
        fennel.path = fennel.path .. ";.config/awesome/?.fnl"
        -- for `import-macro` to work, also enhance `fennel['macro-path']`

        -- debug.traceback = fennel.traceback

        -- fennel.path = fennel.path .. ";.config/awesome/?.fnl"

        --- table.insert(package.loaders or package.searchers, fennel.makeSearcher({
        ---     correlate    = true,
        ---     useMetadata  = true
        --- }))

        require("init")
      '';
    };

    home.file.".xsession-awesome" = {
      text = awesome-init;
      executable = true;
    };
  };
}
