$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Url = "https://github.com/Wxyuz/god/releases/download/v1.0.0/loader.exe"
$OutDir = Join-Path $env:USERPROFILE "Downloads"
$OutFile = Join-Path $OutDir "loader.exe"

Clear-Host

Write-Host "====================================="
Write-Host "          LOADER DOWNLOADER"
Write-Host "====================================="
Write-Host ""

if (!(Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

Write-Host "[+] Downloading loader.exe..."
Write-Host "[+] URL: $Url"
Write-Host ""

Invoke-WebRequest -Uri $Url -OutFile $OutFile

if (!(Test-Path $OutFile)) {
    Write-Host ""
    Write-Host "[ERROR] Download failed."
    pause
    exit
}

Write-Host ""
Write-Host "[+] Download complete"
Write-Host "[+] Saved to: $OutFile"
Write-Host ""

Write-Host "[+] SHA256:"
Get-FileHash $OutFile -Algorithm SHA256

Write-Host ""
Write-Host "[+] Opening file location..."
explorer.exe /select,"$OutFile"

Write-Host ""
Write-Host "Done. Check the file, then open loader.exe manually."
Write-Host ""

pause
