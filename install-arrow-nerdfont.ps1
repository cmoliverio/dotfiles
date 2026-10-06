param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory
)

$ErrorActionPreference = 'Stop'

$FontFamily = 'JetBrainsMono Arrow NF'
$FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$FontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

New-Item -ItemType Directory -Force -Path $FontDir | Out-Null
Add-Type -AssemblyName System.Drawing

$FontFiles = Get-ChildItem $SourceDirectory -File -Filter '*.ttf'
if (-not $FontFiles) {
    throw "No TTF files found in $SourceDirectory"
}

foreach ($FontFile in $FontFiles) {
    $Destination = Join-Path $FontDir $FontFile.Name
    Copy-Item $FontFile.FullName $Destination -Force

    $PrivateFonts = New-Object System.Drawing.Text.PrivateFontCollection
    $PrivateFonts.AddFontFile($Destination)
    $InstalledFamily = $PrivateFonts.Families[0].Name
    $PrivateFonts.Dispose()

    $Style = $FontFile.BaseName -replace '^JetBrainsMonoArrowNerdFont-', ''
    New-ItemProperty -Path $FontRegistry `
        -Name "$InstalledFamily $Style (TrueType)" `
        -Value $Destination -PropertyType String -Force | Out-Null
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class ArrowFontChange {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg,
        IntPtr wParam, IntPtr lParam);
}
"@
[void][ArrowFontChange]::SendMessage([IntPtr]0xffff, 0x001D, [IntPtr]::Zero,
    [IntPtr]::Zero)

Write-Host "Installed $FontFamily for the current Windows user."
