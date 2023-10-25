{ lib, ... }:

with lib;

{
  imports = [ ./brother.nix ];

  config = {
    services.printing.enable = mkDefault true;
    services.printing.cups-pdf.enable = mkDefault true;
    services.printing.startWhenNeeded = mkDefault true;
    services.printing.webInterface = mkDefault false;
  };
}
