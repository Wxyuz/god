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

Write-Host "[+] กำลังโหลด loader.exe..."
Write-Host "[+] URL: $Url"
Write-Host ""

Invoke-WebRequest -Uri $Url -OutFile $OutFile

if (!(Test-Path $OutFile)) {
    Write-Host "[ERROR] โหลดไฟล์ไม่สำเร็จ"
    pause
    exit
}

Write-Host ""
Write-Host "[+] โหลดเสร็จแล้ว"
Write-Host "[+] บันทึกไว้ที่: $OutFile"
Write-Host ""

Write-Host "[+] SHA256:"
Get-FileHash $OutFile -Algorithm SHA256

Write-Host ""
Write-Host "[+] เปิดตำแหน่งไฟล์..."
explorer.exe /select,"$OutFile"

Write-Host ""
Write-Host "เสร็จแล้ว ให้ตรวจสอบไฟล์ก่อน แล้วค่อยเปิด loader.exe เอง"
Write-Host ""

pause
