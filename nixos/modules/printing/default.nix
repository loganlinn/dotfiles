{ config, lib, ... }:

with lib;

{
  imports = [
    ./brother.nix
  ];
  config = mkIf config.services.printing.enable {
    services.printing.startWhenNeeded = mkDefault true;
    services.printing.webInterface = false; # i.e. http://localhost:631/printers
  };
}
