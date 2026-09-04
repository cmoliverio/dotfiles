[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = "Stop"
$Source = Join-Path $PSScriptRoot "windows-terminal\settings.json"
$TerminalDirectory = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$Destination = Join-Path $TerminalDirectory "settings.json"

if (-not (Test-Path $Source)) {
    throw "Tracked Windows Terminal settings were not found: $Source"
}
if (-not (Test-Path $TerminalDirectory)) {
    throw "Install and open Windows Terminal once before running this script."
}

if (Test-Path $Destination) {
    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $Backup = "$Destination.before-dotfiles-$Stamp"
    Copy-Item -LiteralPath $Destination -Destination $Backup
    Write-Host "Backed up current settings to $Backup"
}

Copy-Item -LiteralPath $Source -Destination $Destination -Force
Write-Host "Restored Windows Terminal settings. Restart Windows Terminal."
