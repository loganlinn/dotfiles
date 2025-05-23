{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "fztea";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jon4hz";
    repo = "fztea";
    rev = "v${version}";
    hash = "sha256-m2pUWXjJELJho9sbueOH3xox/kJrd0Cyk2TIWHdODR4=";
  };

  vendorHash = "sha256-tQNPiReMQMDDMKaBHXn7d4v4XtTyKQvmzhIdXp/I3xM=";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Remote control your flipper from the local terminal or remotely over SSH";
    homepage = "https://github.com/jon4hz/fztea";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "fztea";
  };
}
