{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.yt-dlp.enable = lib.mkDefault true;

  home.packages = with pkgs; [
    ffmpeg
  ];

  my.shellScripts.music-dlp = {
    runtimeInputs = [
      config.programs.yt-dlp.package
      pkgs.ffmpeg
    ];
    text = ''
      set -x

      exec yt-dlp \
      --extract-audio \
      --format 'bestaudio' \
      --format-sort 'ext' \
      --check-formats \
      --embed-thumbnail \
      --embed-metadata \
      --restrict-filenames \
      --download-archive "''${XDG_STATE_DIR:-$HOME/.local/state}/yt-dlp/music.archive" \
      --output "''${XDG_MUSIC_DIR:-$HOME/Music}/%(artist)s/%(title)s-%(id)s.%(ext)s" \
      "$@"
    '';
  };
}
