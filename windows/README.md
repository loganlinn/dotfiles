# how2windows

Notes from my journey using Windows (11) again after over a decade with macOS and Linux.

- Installation process:
    - Windows can be installed prior to acquiring a license.
    - Download ISO disk image: https://www.microsoft.com/software-download/
    - Use a tool to prepare/write to a USB drive: https://github.com/WoeUSB/WoeUSB-ng
        - Simply copying the ISO to drive resulted in Windows installer that "could not locate drivers".
        - Try above tool before attempting to customize the ISO.
    - BIOS and booting
        - See [Dual Booting NixOS and Windows](https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows)
        - Ideally GRUB is configured to boot Linux + Windows with Secure Boot enabled[1], but this turns out to be non-trivial/impossible.
        - Use case for Secure Boot was Riot's Vanguard (anti-cheat) software, needed to play their games.

- Post-install tips:
    - Run https://github.com/Raphire/Win11Debloat or similar.
    - [Use the winget tool to install and manage applications | Microsoft Learn](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
    - See contained config files
    - Turn off all the creepy Microsoft analytics and instrumentation.
        - Microsoft Edge, in particular, has numerous settings that should be reviewed.
    - Enable long paths
      ```
      Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
      ```

- Essential software:
    - `winget install --id Microsoft.Powershell --source winget`
    - `wsl --install` 
    - `winget install Microsoft.Sysinternals.ProcessExplorer Microsoft.Sysinternals.ProcessMonitor Microsoft.Sysinternals.TCPView Microsoft.Sysinternals.Ctrl2Cap`

- Additional software:
    - [Flow Launcher](https://www.flowlauncher.com/)
    - https://github.com/LGUG2Z/komorebi (tiling window manager)
      ```
      winget install LGUG2Z.whkd
      winget install LGUG2Z.komorebi
      iwr https://raw.githubusercontent.com/LGUG2Z/komorebi/master/komorebi.example.json -OutFile "$Env:USERPROFILE\komorebi.json"

      ```

## Keyboard shortcuts


| Operation | Key bind |
| --- | --- |
| Run dialog box | <kbd>Win</kbd> + <kbd>r</kbd> |
| File Explorer | <kbd>Win</kbd> + <kbd>e</kbd> |
| System settings | <kbd>Win</kbd> + <kbd>i</kbd> |
| System information | <kbd>Win</kbd> + <kbd>Pause</kbd> |
| Clipboard history | <kbd>Win</kbd> + <kbd>v</kbd> |
| Emoji picker | <kbd>Win</kbd> + <kbd>;</kbd> |
| Snipping Tool | <kbd>Win</kbd> + <kbd>Shift</kbd> + <kbd>s</kbd> |
| Window snapping menu | <kbd>Win</kbd> + <kbd>z</kbd> |
| Notification panel | <kbd>Win</kbd> + <kbd>n</kbd> |
| Focus notification | <kbd>Win</kbd> + <kbd>Shift</kbd> + <kbd>v</kbd> |
| Quick settings panel | <kbd>Win</kbd> + <kbd>a</kbd> |
| Sound outputs panel | <kbd>Win</kbd> + <kbd>Ctrl</kbd> + <kbd>v</kbd> |
| Quick Link menu | <kbd>Win</kbd> + <kbd>x</kbd> |
| Next desktop | <kbd>Win</kbd> + <kbd>Ctrl</kbd> + <kbd>→</kbd> |
| Prev desktop | <kbd>Win</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd> |
| New desktop | <kbd>Win</kbd> + <kbd>Ctrl</kbd> + <kbd>d</kbd> |
| Close desktop | <kbd>Win</kbd> + <kbd>Ctrl</kbd> + <kbd>F4</kbd> |