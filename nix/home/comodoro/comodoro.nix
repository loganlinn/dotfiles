{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  installShellFiles,
  installShellCompletions ? stdenv.hostPlatform == stdenv.buildPlatform,
  installManPages ? stdenv.hostPlatform == stdenv.buildPlatform,
  withTcp ? true,
}:
rustPlatform.buildRustPackage rec {
  pname = "comodoro";
  version = "5b7aa9c2cc2f6761f8c0c300c56601abe01f0848";

  src = fetchFromGitHub {
    owner = "pimalaya";
    repo = "comodoro";
    rev = "${version}";
    hash = "sha256-hPEuxB7OrYtjVQJfiFpDiosxj2cxAckOHobvBuk3tfQ=";
  };

  cargoHash = "sha256-q6ht+gcsBMkfckUG09LQeV+YVsOxwogxRKJ7b9vyHgI=";

  nativeBuildInputs = lib.optional (installManPages || installShellCompletions) installShellFiles;

  # buildNoDefaultFeatures = true;
  # buildFeatures = [ "client" "server" "hooks" ] ++ (lib.optional withTcp "tcp");

  postInstall =
    lib.optionalString installManPages ''
      mkdir -p $out/man
      $out/bin/comodoro man $out/man
      installManPage $out/man/*
    ''
    + lib.optionalString installShellCompletions ''
      installShellCompletion --cmd comodoro \
        --bash <($out/bin/comodoro completion bash) \
        --fish <($out/bin/comodoro completion fish) \
        --zsh <($out/bin/comodoro completion zsh)
    '';

  meta = with lib; {
    description = "CLI to manage your time.";
    homepage = "https://pimalaya.org/comodoro/";
    changelog = "https://github.com/soywod/comodoro/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [soywod];
    mainProgram = "comodoro";
  };
}
