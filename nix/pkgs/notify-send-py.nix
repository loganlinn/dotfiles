{
  lib,
  fetchFromGitHub,
  dbus,
  python3,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "notify-send-py";
  version = "unstable-2021-05-12";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "phuhl";
    repo = "notify-send.py";
    rev = "0575c79f10d10892c41559dd3695346d16a8b184";
    hash = "sha256-+6hh2c+TWMYaAI2SCRZrrwIh8FhKpJthFL0o6QMsoSY=";
  };

  nativeBuildInputs = [python3.pkgs.flit-core];

  propagatedBuildInputs = with python3.pkgs; [dbus-python pygobject3];

  pythonImportsCheck = ["notify_send_py"];

  meta = with lib; {
    description = "A python-script like libnotify but with improved functionality";
    homepage = "https://github.com/phuhl/notify-send.py";
    license = with licenses; [bsd2 mit];
    maintainers = with maintainers; [];
    mainProgram = "notify-send.py";
    platforms = dbus.meta.platforms;
  };
}
