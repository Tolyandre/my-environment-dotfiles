# autorun folder C:\Users\%user%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
$Startup = [environment]::getfolderpath('Startup');

# C:\Users\%users%\AppData\Roaming
$ApplicationData = [environment]::getFolderPath("ApplicationData");

$HardLinks = @{
    ".\Settings\AlwaysOnTop.ahk" = "$Startup\AlwaysOnTop.ahk";
    ".\Settings\ConEmu.xml" = "$ApplicationData\ConEmu.xml";
    ".\Settings\profile.ps1" = $PROFILE.CurrentUserAllHosts;
}

$HardLinks.GetEnumerator() | % {
    
    if (Test-Path $_.Value -PathType Leaf){
        # preserve system config file over repository one, as latter can be restored from git
        Remove-Item $_.Name;
    } else {
        Move-Item $_.Name $_.Value
    }

    New-Item -ItemType HardLink -Path $_.Name -Value $_.Value
}