{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  config = mkIf pkgs.stdenv.isDarwin {

    my.shellScripts.bundle-ids.text = ''
      fd -d1 \
         -eapp \
         -L \
         . /System/Applications /Applications ~/Applications \
         -x bash -c 'echo -ne "{},"; mdls -name kMDItemCFBundleIdentifier -r "{}"; echo' \
      | sort
    '';

  };
}
