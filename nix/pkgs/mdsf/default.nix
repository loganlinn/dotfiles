{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  zstd,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "mdsf";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "hougesen";
    repo = "mdsf";
    rev = "v${version}";
    hash = "sha256-5DFuOYy5C8y+pYDCTwcI9uGxh2kahFLwWMUIZ15+fkA=";
  };

  cargoHash = "sha256-xbztwzCZDJNl6FQRW/r+25b2aHQ7qBhfOq4xyKS6Zlg=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "Format markdown code blocks using your favorite tools";
    homepage = "https://github.com/hougesen/mdsf";
    changelog = "https://github.com/hougesen/mdsf/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mdsf";
  };
}
