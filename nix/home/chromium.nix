{ config, lib, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "kcabmhnajflfolhelachlflngdbfhboe" # Spoof Timezone
      "fihnjjcciajhdojfnbdddfaoknhalnja" # I don't care about cookies
      "cfohepagpmnodfdmjliccbbigdkfcgia" # Location Guard
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
    ];
  };
}
