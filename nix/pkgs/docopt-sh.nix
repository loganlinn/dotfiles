pkgs@{ lib, python3Packages, poetry, fetchFromGitHub, ... }:

python3Packages.buildPythonPackage rec {
  pname = "docopt-sh";
  version = "4c9971cfb32825309b65f25e61410390b920a3a2";
  format = "pyproject";
  nativeBuildInputs = with python3Packages; [ flit ];
  src = fetchFromGitHub {
    owner = "andsens";
    repo = "docopt.sh";
    rev = version;
    hash = "sha256-Qys80h1IbU461mwZ3phWXm6bqeHW/GECNOyG9rcbR7U=";
  };
  doCheck = false;
  meta = {
    description = "Command-line argument parser for bash 3.2, 4+, and 5+.";
    homepage = "https://github.com/andsens/docopt.sh";
    license = lib.licenses.mit;
  };
}
