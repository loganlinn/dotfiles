{
  self,
  self',
  config,
  pkgs,
  ...
}:
{
  imports = [
    self.homeModules.common
    self.homeModules.nix-colors
    ../nix/home/atuin.nix
    # ../nix/home/aws
    ../nix/home/claude
    ../nix/home/mise
    ../nix/home/dev
    # ../nix/home/dev/kubernetes.nix
    # ../nix/home/dev/lua.nix
    ../nix/home/dev/javascript.nix
    ../nix/home/docker.nix
    ../nix/home/doom
    # ../nix/home/ghostty.nix
    ../nix/home/just
    # ../nix/home/neovide.nix
    ../nix/home/nixvim
    ../nix/home/pretty.nix
    # ../nix/home/terraform
    ../nix/home/tmux.nix
    # ../nix/home/wezterm
    ../nix/home/yt-dlp.nix
  ];

  # mandb takes too long build every generation switch...
  # programs.fish.enable = true causes this to be set true by default
  programs.man.generateCaches = false;

  home.packages = with pkgs; [
    emacs-lsp-booster
    ipcalc
    jc
    jnv
    mkcert
    openssh
    self'.packages.everything-fzf
    typescript-language-server
  ];

  home.username = "logan";
  home.homeDirectory = "/Users/logan";
  home.stateVersion = "26.11";

  programs.age-op.enable = true;
  programs.claude.enable = true;
  programs.atuin.enable = true;
  programs.asciinema.enable = true;
  programs.mise.enable = true;
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    plugins.lsp.servers.nixd.settings.options = {
      darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logmini.options'';
    };
  };
  programs.passage.enable = true;
  programs.raycast = {
    enable = true;
    scriptCommandDirectory = "${config.home.homeDirectory}/Library/CloudStorage/Dropbox/raycast";
  };
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    shellAliases = { };
    dirHashes = { };
  };
  xdg.enable = true;
}
