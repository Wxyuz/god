$ErrorActionPreference = "Stop"

$Url = "https://github.com/Wxyuz/god/releases/download/v1.0.0/loader.exe"
$OutFile = "$env:USERPROFILE\Downloads\loader.exe"

Write-Host "====================================="
Write-Host "        LOADER DOWNLOADER"
Write-Host "====================================="
Write-Host ""

Write-Host "[+] Downloading loader.exe..."
Write-Host "[+] URL: $Url"

Invoke-WebRequest -Uri $Url -OutFile $OutFile

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
Write-Host "โหลดเสร็จแล้ว ให้ตรวจสอบไฟล์ก่อน แล้วค่อยเปิด loader.exe เอง"
pause
