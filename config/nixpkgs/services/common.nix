{ config
, pkgs
, self
, ...
}:

{

  services.gpg-agent = {
    enable = true;
  };

  services.home-manager = {
    autoUpgrade = {
      enable = false;
      frequency = "weekly";
    };
  };

  services.syncthing = {
    enable = true;
  };

  # services.git-sync = {
  #   enable = true;
  #   repositories = {
  #     name = {
  #       path = "";
  #       uri = "";
  #       interval = 86400;
  #     }
  #   };
  # };

}
