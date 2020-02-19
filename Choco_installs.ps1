#Requires -RunAsAdministrator

# install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation

# hotkey to dock a window always on top
choco install autohotkey

# git
## TODO: consider option /WindowsTerminal
choco install git.install --params "/GitAndUnixToolsOnPath /NoShellIntegration /SChannel"