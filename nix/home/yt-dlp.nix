{pkgs, lib, ...}: {
  programs.yt-dlp.enable = lib.mkDefault true;

  home.packages =  with pkgs; [
    ffmpeg
  ];
}
