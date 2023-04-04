{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "kubefwd";
  version = "1.22.4";

  src = fetchFromGitHub {
    owner = "txn2";
    repo = "kubefwd";
    rev = version;
    hash = "sha256-iC2oowLJCtpV0O+CpUCaBmSw668mFVoKbB+QEUDcG9Y=";
  };

  vendorHash = "sha256-oeRShx5lYwJ9xFPg5Ch0AzdQXwX/5OA3EyuumgH9gXU=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s" # Omit symbol table and debug information
    "-w" # Omit the DWARF symbol table.
    "-X 'main.Version=${version}'"
  ];

  postInstall = ''
    installShellCompletion --cmd kubefwd \
      --bash <($out/bin/kubefwd completion bash) \
      --zsh <($out/bin/kubefwd completion zsh) \
      --fish <($out/bin/kubefwd completion fish)
  '';

  meta = with lib; {
    description = "Bulk port forwarding Kubernetes services for local development";
    homepage = "https://github.com/txn2/kubefwd";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
