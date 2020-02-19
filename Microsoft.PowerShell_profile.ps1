# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$Env:LC_ALL='C.UTF-8' # for git log
# $Env:LANG='en_US.UTF-8' # 
$Env:TERM='xterm-256color' # for unix tools like tig

# Install-Module posh-git
Import-Module posh-git

# based on https://stackoverflow.com/a/44411205/843449
function Write-BranchName () {
    try {
        $branch = git rev-parse --abbrev-ref HEAD

        if ($branch -eq "HEAD") {
            # we're probably in detached HEAD state, so print the SHA
            $branch = git rev-parse --short HEAD
            Write-Host " ($branch)" -ForegroundColor "red"
        }
        else {
            # we're on an actual branch, so print it
            Write-Host " ($branch)" -ForegroundColor "blue"
        }
    } catch {
        # we'll end up here if we're in a newly initiated git repo
        Write-Host " (no branches yet)" -ForegroundColor "yellow"
    }
}

function prompt
{
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #                                                                              Rikard Ronnkvist / snowland.se
    # Multicolored prompt with marker for windows started as Admin and marker for providers outside filesystem
    # Examples
    #    C:\Windows\System32>
    #    [Admin] C:\Windows\System32>
    #    [Registry] HKLM:\SOFTWARE\Microsoft\Windows>
    #    [Admin] [Registry] HKLM:\SOFTWARE\Microsoft\Windows>
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
    # New nice WindowTitle
    $Host.UI.RawUI.WindowTitle = "PowerShell v" + (get-host).Version.Major + "." + (get-host).Version.Minor + " (" + $pwd.Provider.Name + ") " + $pwd.Path
 
    # Admin ?
    if( (
        New-Object Security.Principal.WindowsPrincipal (
            [Security.Principal.WindowsIdentity]::GetCurrent())
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Admin-mark in WindowTitle
        $Host.UI.RawUI.WindowTitle = "[Admin] " + $Host.UI.RawUI.WindowTitle
 
        # Admin-mark on prompt
        Write-Host "[" -nonewline -foregroundcolor DarkGray
        Write-Host "Admin" -nonewline -foregroundcolor Red
        Write-Host "] " -nonewline -foregroundcolor DarkGray
    }
	
	Write-Host "PS " -nonewline -foregroundcolor DarkGray
 
    # Show providername if you are outside FileSystem
    if ($pwd.Provider.Name -ne "FileSystem") {
        Write-Host "[" -nonewline -foregroundcolor DarkGray
        Write-Host $pwd.Provider.Name -nonewline -foregroundcolor Gray
        Write-Host "] " -nonewline -foregroundcolor DarkGray
    }
 
    # Split path and write \ in a gray
    $pwd.Path.Split("\") | foreach {
        Write-Host $_ -nonewline -foregroundcolor Green
        Write-Host "\" -nonewline -foregroundcolor Green
    }
 
    # Backspace last \
	Write-Host "`b " -nonewline
	
	#if (Test-Path .git) {        
        #Write-BranchName
    #}
	Write-VcsStatus
	
    Write-Host "`n>" -nonewline -foregroundcolor Gray
 
    return " "
}