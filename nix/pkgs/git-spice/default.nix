{
  lib,
  stdenv,
  buildGo124Module,
  fetchFromGitHub,
  git,
  nix-update-script,
  installShellFiles,
}:
buildGo124Module rec {
  pname = "git-spice";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "abhinav";
    repo = "git-spice";
    rev = "4fec4747d879716a0a1db354d53685648dbee21b";
    hash = "sha256-ew0ehaYXJgc1ePdQCxxfahBdTs5zsiHDfB4SdS2WZ8A=";
  };

  vendorHash = "sha256-jlCNcjACtms9kI4Lo8AtUfxqODyv4U2nJITGpBNxk9I=";

  subPackages = ["."];

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  nativeCheckInputs = [git];

  buildInputs = [git];

  ldflags = [
    "-s"
    "-w"
    "-X=main._version=${version}"
  ];

  __darwinAllowLocalNetworking = true;

  doCheck = false;

  preCheck = lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ''
    # timeout
    rm testdata/script/branch_submit_remote_prompt.txt
    rm testdata/script/branch_submit_multiple_pr_templates.txt
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gs \
      --bash <($out/bin/gs shell completion bash) \
      --zsh <($out/bin/gs shell completion zsh) \
      --fish <($out/bin/gs shell completion fish)
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Manage stacked Git branches";
    homepage = "https://abhinav.github.io/git-spice/";
    changelog = "https://github.com/abhinav/git-spice/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [lib.maintainers.vinnymeller];
    mainProgram = "gs";
  };
}
