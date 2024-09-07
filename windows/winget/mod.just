set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

[windows]
export:
  winget export -o packages.json

[windows]
import:
  winget import -i packages.json
