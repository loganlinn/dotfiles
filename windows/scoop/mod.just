set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

[windows]
export:
  scoop export --config > scoopfile.json

[windows]
import:
  scoop import scoopfile.json
