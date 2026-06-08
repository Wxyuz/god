$Url = "https://raw.githubusercontent.com/Wxyuz/god/main/loader.exe"
$OutFile = "$env:USERPROFILE\Downloads\loader.exe"

Write-Host "[+] Downloading loader.exe..."
Invoke-WebRequest -Uri $Url -OutFile $OutFile

Write-Host "[+] Download complete"
Write-Host "[+] Saved to: $OutFile"

Write-Host "[+] SHA256:"
Get-FileHash $OutFile -Algorithm SHA256
