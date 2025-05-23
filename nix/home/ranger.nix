{
  config,
  pkgs,
  ...
}: let
in {
  home.packages = with pkgs; [
    ranger
    # ranger-archive
    zip
    unzip
    gzip
    gnutar
    p7zip
    # pbzip2 # parallel zip
    pigz # parallel gzip
    pixz # parallel xz
  ];

  # TODO check out https://github.com/maximtrp/ranger-archives

  xdg.configFile."ranger/rc.conf".text = ''
    set vcs_aware false
    map zg set vcs_aware true
    setlocal path=${config.xdg.userDirs.download} sort mtime

    # extract
    map ex extract
    map ec compress
  '';

  xdg.configFile."ranger/plugins/ranger-archives".source = pkgs.fetchFromGitHub {
    owner = "maximtrp";
    repo = "ranger-archives";
    rev = "62783ddb84c8fd25eba1be1607d3a47e8efe8b31";
    hash = "sha256-hSwTsWrbX+unvm9f7dkCRljc6EM9bhGOHRaLNo7ehio=";
  };
}
