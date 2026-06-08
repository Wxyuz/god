$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch {
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$RepoOwner = "Wxyuz"
$RepoName = "god"
$TagName = "v1.0.0"
$ExeName = "loader.exe"

$ReleaseUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$TagName/$ExeName"
$OutDir = Join-Path $env:USERPROFILE "Downloads"
$OutFile = Join-Path $OutDir $ExeName

Clear-Host

Write-Host "============================================="
Write-Host "              LOADER DOWNLOADER"
Write-Host "============================================="
Write-Host ""
Write-Host "[+] Repo : https://github.com/$RepoOwner/$RepoName"
Write-Host "[+] File : $ExeName"
Write-Host "[+] URL  : $ReleaseUrl"
Write-Host ""

if (!(Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

Write-Host "[+] Downloading loader.exe..."
Invoke-WebRequest -Uri $ReleaseUrl -OutFile $OutFile -UseBasicParsing

if (!(Test-Path -LiteralPath $OutFile)) {
    Write-Host ""
    Write-Host "[ERROR] Download failed."
    Write-Host ""
    pause
    exit
}

Write-Host ""
Write-Host "[+] Download complete"
Write-Host "[+] Saved to: $OutFile"
Write-Host ""

Write-Host "[+] Checking file type..."

$bytes = [System.IO.File]::ReadAllBytes($OutFile)
if ($bytes.Length -lt 2 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    Write-Host ""
    Write-Host "[ERROR] Downloaded file is not a valid Windows EXE."
    Write-Host ""
    pause
    exit
}

Write-Host "[+] Valid EXE file"
Write-Host ""

Write-Host "[+] SHA256:"
Get-FileHash -LiteralPath $OutFile -Algorithm SHA256

Write-Host ""
Write-Host "[+] Opening file location..."
explorer.exe /select,"$OutFile"

Write-Host ""
Write-Host "Done. Check the file, then open loader.exe manually."
Write-Host ""

pause
