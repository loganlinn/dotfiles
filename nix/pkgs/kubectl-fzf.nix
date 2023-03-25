{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "kubectl-fzf";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "bonnefoa";
    repo = "kubectl-fzf";
    rev = "v${version}";
    hash = "sha256-d8EV9+37Q3z/Mnfo4diKxuN7ON6KxlTLOHnBgLGBHuY=";
  };

  vendorHash = "sha256-dOEYHMHHaksy7K1PgfFrSzRcucOgnHjZFpl+/2A1Zzs=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X 'main.version=${version}'"
    "-X 'main.buildDate=19700101-00:00:00'"
  ];

  subPackages = [
    "cmd/kubectl-fzf-server"
    "cmd/kubectl-fzf-completion"
  ];

  postInstall = ''
    substituteInPlace shell/* \
      --replace kubectl-fzf-completion $out/bin/kubectl-fzf-completion

    installShellCompletion --bash shell/kubectl_fzf.bash
    installShellCompletion --zsh --name _kubectl_fzf shell/kubectl_fzf.plugin.zsh
  '';

  meta = with lib; {
    description = "A fast kubectl autocompletion with fzf";
    homepage = "https://github.com/bonnefoa/kubectl-fzf";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
