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
    # self.homeModules.opnix
    ../nix/home/aws
    ../nix/home/dev
    ../nix/home/dev/kubernetes.nix
    ../nix/home/dev/lua.nix
    ../nix/home/dev/javascript.nix
    ../nix/home/docker.nix
    ../nix/home/doom
    ../nix/home/ghostty.nix
    ../nix/home/just
    ../nix/home/neovide.nix
    ../nix/home/nixvim
    ../nix/home/pretty.nix
    ../nix/home/television.nix
    ../nix/home/terraform.nix
    ../nix/home/tmux.nix
    ../nix/home/wezterm
    ../nix/home/yazi
    ../nix/home/yt-dlp.nix
  ];

  # mandb takes too long build every generation switch...
  # programs.fish.enable = true causes this to be set true by default
  programs.man.generateCaches = false;

  home.packages = with pkgs; [
    # step-cli
    (writeShellScriptBin "copilot-language-server" ''npx @github/copilot-language-server "$@"'')
    act
    actionlint
    checkov
    dive
    dry
    flyctl
    go-task
    google-cloud-sdk
    hl-log-viewer
    ipcalc
    jc
    jjui
    jnv
    jujutsu
    kcat
    mcat
    mkcert
    self'.packages.chrome-cli
    self'.packages.everything-fzf
    typescript-language-server
  ];

  home.username = "logan";
  home.homeDirectory = "/Users/logan";
  home.stateVersion = "22.11";

  programs.age-op.enable = true;
  programs.atuin = {
    enable = true;
    daemon = {
      enable = true;
    };
    flags = [
      "--disable-up-arrow"
    ];
    enableZshIntegration = true;
  };
  programs.asciinema.enable = true;
  programs.fish.enable = false; # not used currently and slows builds down a bit.
  programs.ghostty.enable = true;
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    plugins.lsp.servers.nixd.settings.options = {
      darwin.expr = ''(builtins.getFlake "${self}").darwinConfigurations.logamma.options'';
    };
  };
  programs.passage.enable = true;
  programs.raycast = {
    enable = true;
    scriptCommandDirectory = "${config.home.homeDirectory}/Library/CloudStorage/Dropbox/raycast";
  };
  programs.wezterm.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    shellAliases = {
      ecr-login = "aws ecr get-login-password --region us-east-2 | pee 'docker login --username AWS --password-stdin 591791561455.dkr.ecr.us-east-2.amazonaws.com' 'finch login --username AWS --password-stdin 591791561455.dkr.ecr.us-east-2.amazonaws.com'";
      ddb-local = "env -u AWS_ENDPOINT_DYNAMODB_URL aws dynamodb --endpoint-url http://localhost:8000";
    };
    dirHashes = {
      wt = "$HOME/src/github.com/gamma-app/gamma/.worktrees";
      gamma = "$HOME/src/github.com/gamma-app/gamma";
      gdrive1 = "$HOME/Library/CloudStorage/GoogleDrive-logan.linn@gmail.com/My Drive";
      gdrive2 = "$HOME/Library/CloudStorage/GoogleDrive-logan@gamma.app/My Drive";
      dropbox = "$HOME/Library/CloudStorage/Dropbox";
      logseq = "$HOME/Library/CloudStorage/GoogleDrive-logan.linn@gmail.com/My Drive/apps/logseq";
      books = "$HOME/Library/CloudStorage/Dropbox/books";
    };
  };
  xdg.enable = true;
}
