{ config, lib, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
      { id = "gcbommkclmclpchllfjekcdonpmejbdp"; } # HTTPS Everywhere
      { id = "kcabmhnajflfolhelachlflngdbfhboe"; } # Spoof Timezone
      { id = "cfohepagpmnodfdmjliccbbigdkfcgia"; } # Location Guard
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
      { id = "fjdmkanbdloodhegphphhklnjfngoffa"; } # YouTube Auto HD
    ];
  };
}
