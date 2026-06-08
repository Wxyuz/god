$ErrorActionPreference = "Stop"

$Url = "https://raw.githubusercontent.com/Wxyuz/god/main/loader.exe"
$OutDir = Join-Path $env:USERPROFILE "Downloads"
$OutFile = Join-Path $OutDir "loader.exe"

Write-Host ""
Write-Host "============================================="
Write-Host "             LOADER DOWNLOADER"
Write-Host "============================================="
Write-Host ""

if (!(Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

Write-Host "[+] Downloading loader.exe..."
Write-Host "[+] URL: $Url"
Write-Host ""

Invoke-WebRequest -Uri $Url -OutFile $OutFile

if (!(Test-Path $OutFile)) {
    Write-Host "[ERROR] Download failed"
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
Write-Host "เสร็จแล้ว: ไฟล์อยู่ใน Downloads"
Write-Host "ให้ตรวจสอบไฟล์ก่อน แล้วค่อยเปิดใช้งานเอง"
Write-Host ""

pause
