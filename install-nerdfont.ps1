$ErrorActionPreference = 'Stop'

$FontName = 'JetBrainsMono'
$FontVersion = 'v3.4.0'
$Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/$FontVersion/$FontName.zip"
$TempZip = Join-Path $env:TEMP "$FontName-NerdFont.zip"
$ExtractDir = Join-Path $env:TEMP "$FontName-NerdFont"
$FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

New-Item -ItemType Directory -Force -Path $ExtractDir, $FontDir | Out-Null
Invoke-WebRequest -Uri $Url -OutFile $TempZip
Expand-Archive -Path $TempZip -DestinationPath $ExtractDir -Force

$Shell = New-Object -ComObject Shell.Application
$Fonts = $Shell.Namespace(0x14)
Get-ChildItem $ExtractDir -File -Include *.ttf, *.otf | ForEach-Object {
    Copy-Item $_.FullName $FontDir -Force
    $Fonts.CopyHere($_.FullName, 0x10)
}

Remove-Item $TempZip -Force
Remove-Item $ExtractDir -Recurse -Force
Write-Host "Installed $FontName Nerd Font ($FontVersion) for the current Windows user."
