{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  programs.newsboat = {
    enable = true;
    urls = [
      {
        title = "r/NixOS";
        tags = ["nixos" "nix" "reddit"];
        url = "https://www.reddit.com/r/NixOS.rss";
      }
      {
        title = "NixOS weekly";
        tags = ["nixos" "nix"];
        url = "https://weekly.nixos.org/feeds/all.rss.xml";
      }
      {
        title = "Planet Clojure";
        tags = ["clojure"];
        url = "https://planet.clojure.in/atom.xml";
      }
      {
        url = "https://www.jeffgeerling.com/blog.xml";
        tags = ["people"];
      }
    ];
  };
}
