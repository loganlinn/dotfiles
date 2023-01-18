{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

python3Packages.buildPythonPackage rec {
  pname = "i3-balance-workspace";
  version = "1.8.6";
  format = "pyproject";
  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = with python3.pkgs; [ i3ipc ];
  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-zJdn/Q6r60FQgfehtQfeDkmN0Rz3ZaqgNhiWvjyQFy0=";
  };
  doCheck = false;
  meta = with lib; {
    description = "Balance windows and workspaces in i3wm";
    homepage = "https://github.com/atreyasha/i3-balance-workspace";
    license = licenses.mit;
  };
}
