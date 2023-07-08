{ python3, python3Packages, poetry, lib, ... }:

python3Packages.buildPythonPackage rec {
  pname = "i3-balance-workspace"; # bin/i3_balance_workspace
  version = "1.8.6";
  format = "pyproject";
  nativeBuildInputs = [poetry python3Packages.poetry-core];
  propagatedBuildInputs = with python3.pkgs; [i3ipc];
  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-zJdn/Q6r60FQgfehtQfeDkmN0Rz3ZaqgNhiWvjyQFy0=";
  };
  doCheck = false;
  meta = {
    description = "Balance windows and workspaces in i3wm";
    homepage = "https://github.com/atreyasha/i3-balance-workspace";
    license = lib.licenses.mit;
    mainProgram = "i3_balance_workspace";
  };
}
