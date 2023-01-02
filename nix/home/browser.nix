{ config, lib, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      "kcabmhnajflfolhelachlflngdbfhboe" # Spoof Timezone
      "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
      "cfohepagpmnodfdmjliccbbigdkfcgia" # Location Guard
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma integration
    ];
  };

  programs.google-chrome.enable = true;

  programs.firefox.enable = true;
}
