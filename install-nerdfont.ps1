$ErrorActionPreference = 'Stop'

$FontName = 'JetBrainsMono'
$FontFamily = 'JetBrainsMono NF'
$FontVersion = 'v3.4.0'
$Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/$FontVersion/$FontName.zip"
$TempZip = Join-Path $env:TEMP "$FontName-NerdFont.zip"
$ExtractDir = Join-Path $env:TEMP "$FontName-NerdFont"
$FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$FontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

New-Item -ItemType Directory -Force -Path $ExtractDir, $FontDir | Out-Null
Invoke-WebRequest -Uri $Url -OutFile $TempZip
Expand-Archive -Path $TempZip -DestinationPath $ExtractDir -Force

Add-Type -AssemblyName System.Drawing
$FontFiles = Get-ChildItem $ExtractDir -File -Recurse |
    Where-Object { $_.Extension -in '.ttf', '.otf' }

foreach ($FontFile in $FontFiles) {
    $Destination = Join-Path $FontDir $FontFile.Name
    Copy-Item $FontFile.FullName $Destination -Force

    $PrivateFonts = New-Object System.Drawing.Text.PrivateFontCollection
    $PrivateFonts.AddFontFile($Destination)
    $InstalledFamily = $PrivateFonts.Families[0].Name
    $PrivateFonts.Dispose()

    $FontType = if ($FontFile.Extension -eq '.ttf') {
        'TrueType'
    } else {
        'OpenType'
    }
    $Style = $FontFile.BaseName -replace '^JetBrainsMono', ''
    New-ItemProperty -Path $FontRegistry `
        -Name "$InstalledFamily $Style ($FontType)" `
        -Value $Destination -PropertyType String -Force | Out-Null
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class FontChange {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg,
        IntPtr wParam, IntPtr lParam);
}
"@
[void][FontChange]::SendMessage([IntPtr]0xffff, 0x001D, [IntPtr]::Zero,
    [IntPtr]::Zero)

Remove-Item $TempZip -Force
Remove-Item $ExtractDir -Recurse -Force
Write-Host "Installed $FontFamily ($FontVersion) for the current Windows user."
