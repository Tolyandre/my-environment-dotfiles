# Windows development environment as code
This repo is settings of my development environment on Windows. Inspired by term Infrastructure-as-Code.

Goals:
- sync things like hotkeys over my home and work machines;
- git history to recall which tools I used and how configured them;
- quick environment and software restore, just in case.
However, that requires to script every change.

## Files
Choco_installs.ps1
Installs tools.

AlwaysOnTop.ahk
Hotkeys. Should go to autoruns.

Microsoft.PowerShell_profile.ps1
Powershell profile for suitable command prompt with git branch. Should go to all possible powershell profiles

## TODO
- add more configs:
    - Fiddler,
    - ConEmu;
- script to automatically sync files;
- test automated install on virtual machine.
