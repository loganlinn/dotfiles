{pkgs, lib, ...}: {
  programs.yt-dlp.enable = lib.mkDefault true;

  home.shellAliases.yt-dlp = "noglob yt-dlp";
  home.shellAliases.yt-dl = "noglob yt-dlp";

  home.packages =  with pkgs; [
    ffmpeg
  ];
}
