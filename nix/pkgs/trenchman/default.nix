{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "trenchman";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "athos";
    repo = "trenchman";
    rev = "v${version}";
    hash = "sha256-HhTANZlaXMH6dePyRzmbOQpxjWDdzY0dL0cwjH6f6s0=";
  };

  vendorHash = "sha256-1o1mkg8fagjqPzL6ivOVJ8+8Zj6N9bRBZr/LktWnPco=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A standalone nREPL/prepl client written in Go and heavily inspired by Grenchman";
    homepage = "https://github.com/athos/trenchman";
    changelog = "https://github.com/athos/trenchman/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
