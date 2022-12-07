{pkgs, ...}: {
  nix.trustedUsers = ["logan"];

  users.extraUsers.logan = {
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
    isNormalUser = true;
    createHome = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa logan@llinn.dev"
    ];
  };

  programs.zsh.enable = true;
}
