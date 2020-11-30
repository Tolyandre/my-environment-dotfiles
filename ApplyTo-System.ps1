# autorun folder C:\Users\%user%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
$Startup = [environment]::getfolderpath('Startup');

# C:\Users\%users%\AppData\Roaming
$ApplicationData = [environment]::getFolderPath("ApplicationData");

$LinksToSystemFiles = @{
    ".\Settings\Hotkeys.ahk" = "$Startup\Hotkeys.ahk";
    ".\Settings\ConEmu.xml"  = "$ApplicationData\ConEmu.xml";
    ".\Settings\profile.ps1" = $PROFILE.CurrentUserAllHosts;
}

$confirm = Read-Host "This will override your config files. Sure? (y to continue)"
if ($confirm -ne "y") {
    exit;
}

$LinksToSystemFiles.GetEnumerator() | % {

    if (-Not (Test-Path $_.Value -PathType Leaf)) {
        # Create the folder structure and empty destination file, similar to
        # the Unix 'touch' command
        New-Item -ItemType File -Path $_.Value -Force       
    }

    Remove-Item $_.Value;
    New-Item -ItemType HardLink -Path $_.Value -Value $(Resolve-Path $_.Name).Path | Select FullName
}
