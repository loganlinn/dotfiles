{ lib , rustPlatform , fetchFromGitHub , ...}:

rustPlatform.buildRustPackage {
  pname = "i3-auto-layout";
  version = "unstable-2022-03-29";

  src = fetchFromGitHub {
    owner = "chmln";
    repo = "i3-auto-layout";
    rev = "9e41eb3891991c35b7d35c9558e788899519a983";
    hash = "sha256-gpVYVyh+2y4Tttvw1SuCf7mx/nxR330Ob2R4UmHZSJs=";
  };

  cargoHash = "sha256-uYlc/u6b/g/y2qwh67tnwuEN5bk1ngHCVNYB9qR1uCs=";
  useFetchCargoVendor = true;

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with lib; {
    description = "Automatic, optimal tiling for i3wm";
    homepage = "https://github.com/chmln/i3-auto-layout";
    license = licenses.mit;
    maintainers = with maintainers; [ mephistophiles ];
    platforms = platforms.linux;
    mainProgram = "i3-auto-layout";
  };
}
