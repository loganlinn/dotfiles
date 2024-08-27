set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

export DotfilesDir := absolute_path("..")

default: ssh_config wsl_config

[windows]
ssh_config: (symlink (DotfilesDir / "ssh" / "config") (home_dir() / ".ssh" / "config"))

[windows]
wsl_config: (symlink (DotfilesDir / "windows" / "wslconfig") (home_dir() / ".wslconfig")) \
            (symlink (DotfilesDir / "windows" / "wslgconfig") (home_dir() / ".wslgconfig"))

[windows]
[positional-arguments]
symlink target link:
  #!pwsh.exe
  $target = [System.Environment]::ExpandEnvironmentVariables("{{ clean(target) }}") | Resolve-Path
  $link = [System.Environment]::ExpandEnvironmentVariables("{{ clean(link) }}")
  if (Test-Path "$link") {
    if ((Get-ItemPropertyValue "$link" -Name LinkTarget) -ne "$target") {
      throw "Failed to create symbolic link '$target' to '$link': File exists"
    }
  } else {
    New-Item -ItemType SymbolicLink -Target "$target" -Path "$link"
  }
