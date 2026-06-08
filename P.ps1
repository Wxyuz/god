# ============================================================
# Wxyuz CISCO Loader Script
# Usage:
# irm "https://raw.githubusercontent.com/Wxyuz/CISCO/main/P.ps?t=101" | iex
# ============================================================

$ErrorActionPreference = "Stop"

# -----------------------------
# CONFIG
# -----------------------------

$AppName = "WxyuzCISCO"

# แก้ไขลิงก์เป็น GitHub Release ของ Wxyuz/god
# หากมีการระบุเวอร์ชัน (Tag) สามารถเปลี่ยน /latest/ เป็น /download/v1.0.0/ (หรือชื่อ tag ที่ตั้งไว้) ได้
$LoaderUrl = "https://github.com/Wxyuz/god/releases/latest/download/loader.exe"

# SHA256 ของไฟล์ loader.exe ที่คุณอัปโหลดมา (ถ้าไฟล์ใน Release เป็นไฟล์ใหม่ อย่าลืมอัปเดตค่านี้)
$ExpectedSha256 = "b60811ffc2196ba3de82f2dcd92245ceab1335f0abf011ff3a2816ec6596ad6c"

# โฟลเดอร์ที่จะเก็บไฟล์หลังโหลด
$InstallDir = Join-Path $env:LOCALAPPDATA $AppName
$ExePath = Join-Path $InstallDir "loader.exe"

# -----------------------------
# FUNCTIONS
# -----------------------------

function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Internet {
    try {
        $request = [System.Net.WebRequest]::Create("https://github.com")
        $request.Method = "HEAD"
        $request.Timeout = 8000

        $response = $request.GetResponse()
        $response.Close()

        return $true
    }
    catch {
        return $false
    }
}

function Get-FileSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
}

function Download-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $tempFile = "$Destination.download"

    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }

    Write-Info "กำลังดาวน์โหลดไฟล์..."
    Write-Info "URL: $Url"

    try {
        Invoke-WebRequest `
            -Uri $Url `
            -OutFile $tempFile `
            -UseBasicParsing
    }
    catch {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }

        throw "ดาวน์โหลดไม่สำเร็จ: $($_.Exception.Message)"
    }

    if (-not (Test-Path $tempFile)) {
        throw "ดาวน์โหลดไม่สำเร็จ ไม่พบไฟล์ที่โหลดมา"
    }

    Move-Item -Path $tempFile -Destination $Destination -Force
}

function Verify-FileHash {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedHash
    )

    if ([string]::IsNullOrWhiteSpace($ExpectedHash)) {
        Write-Warn "ไม่ได้ตั้งค่า ExpectedSha256 ข้ามการตรวจสอบ SHA256"
        return $true
    }

    $actualHash = Get-FileSha256 -FilePath $FilePath

    if ($null -eq $actualHash) {
        Write-Fail "ไม่พบไฟล์สำหรับตรวจสอบ SHA256"
        return $false
    }

    Write-Info "SHA256 ที่ได้: $actualHash"

    if ($actualHash -ne $ExpectedHash.ToLower()) {
        Write-Fail "SHA256 ไม่ตรง ไฟล์อาจไม่ใช่ไฟล์เดียวกับที่ตั้งไว้"
        Write-Fail "Expected: $ExpectedHash"
        Write-Fail "Actual:   $actualHash"
        return $false
    }

    Write-Ok "ตรวจสอบ SHA256 ผ่าน"
    return $true
}

function Start-Loader {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        throw "ไม่พบ loader.exe"
    }

    Write-Info "กำลังเปิดโปรแกรม loader.exe..."

    Start-Process `
        -FilePath $FilePath `
        -WorkingDirectory (Split-Path $FilePath -Parent)

    Write-Ok "เปิดโปรแกรมเรียบร้อย"
}

# -----------------------------
# MAIN
# -----------------------------

try {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host "          Wxyuz CISCO Loader Installer         " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ""

    Write-Info "เตรียมระบบ..."

    try {
        [Net.ServicePointManager]::SecurityProtocol = `
            [Net.SecurityProtocolType]::Tls12 `
            -bor [Net.SecurityProtocolType]::Tls13
    }
    catch {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    if (-not (Test-Internet)) {
        throw "ไม่สามารถเชื่อมต่อ GitHub ได้ กรุณาตรวจสอบอินเทอร์เน็ต"
    }

    if (-not (Test-Path $InstallDir)) {
        Write-Info "สร้างโฟลเดอร์: $InstallDir"
        New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
    }

    $needDownload = $true

    if (Test-Path $ExePath) {
        Write-Info "พบ loader.exe เดิมแล้ว กำลังตรวจสอบไฟล์..."

        $currentHash = Get-FileSha256 -FilePath $ExePath

        if ($currentHash -eq $ExpectedSha256.ToLower()) {
            Write-Ok "ไฟล์เดิมถูกต้อง ไม่ต้องดาวน์โหลดใหม่"
            $needDownload = $false
        }
        else {
            Write-Warn "ไฟล์เดิมไม่ตรงกับ SHA256 จะดาวน์โหลดใหม่"
            Remove-Item $ExePath -Force
        }
    }

    if ($needDownload) {
        Download-File -Url $LoaderUrl -Destination $ExePath
    }

    $verified = Verify-FileHash -FilePath $ExePath -ExpectedHash $ExpectedSha256

    if (-not $verified) {
        if (Test-Path $ExePath) {
            Remove-Item $ExePath -Force
        }

        throw "ยกเลิกการเปิดโปรแกรม เพราะตรวจสอบไฟล์ไม่ผ่าน"
    }

    Start-Loader -FilePath $ExePath

    Write-Host ""
    Write-Ok "เสร็จสมบูรณ์"
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Fail $_
    Write-Host ""
    Write-Host "กด Enter เพื่อปิดหน้าต่างนี้..." -ForegroundColor Gray
    Read-Host | Out-Null
}
