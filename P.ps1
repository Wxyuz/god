# ============================================================
# Wxyuz Loader Script
# ============================================================

$ErrorActionPreference = "Stop"

# -----------------------------
# CONFIG
# -----------------------------
$AppName = "WxyuzCISCO"
# ลิงก์ดาวน์โหลดอ้างอิงจากรูปภาพของคุณ
$LoaderUrl = "https://github.com/Wxyuz/god/releases/download/v1.0.0/loader.exe"

# ใช้โฟลเดอร์ Temp (ไฟล์ชั่วคราว) เพื่อไม่ให้รกเครื่อง
$InstallDir = Join-Path $env:TEMP $AppName
$ExePath = Join-Path $InstallDir "loader.exe"

# -----------------------------
# MAIN
# -----------------------------
Clear-Host
Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host "          Wxyuz Loader Starting...            " -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host ""

try {
    # 1. เตรียมระบบเครือข่าย
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

    # สร้างโฟลเดอร์ Temp หากยังไม่มี
    if (-not (Test-Path $InstallDir)) {
        New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
    }

    # ลบไฟล์เก่าทิ้ง (ถ้ามี) เพื่อให้โหลดตัวใหม่เสมอ
    if (Test-Path $ExePath) {
        Remove-Item $ExePath -Force
    }

    # 2. เริ่มการดาวน์โหลด (จะมีหลอดความคืบหน้าแสดงขึ้นมา)
    Write-Host "[INFO] กำลังดาวน์โหลดข้อมูลเพื่อเปิดโปรแกรม กรุณารอสักครู่..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $LoaderUrl -OutFile $ExePath -UseBasicParsing

    # 3. เปิดโปรแกรม GUI ทันทีที่โหลดเสร็จ
    if (Test-Path $ExePath) {
        Write-Host "[OK] โหลดเสร็จสิ้น กำลังเปิด GUI..." -ForegroundColor Green
        Start-Process -FilePath $ExePath -WorkingDirectory $InstallDir
        
        # หน่วงเวลาเล็กน้อยให้โปรแกรมเปิดติด ก่อนปิดสคริปต์
        Start-Sleep -Seconds 2 
    } else {
        throw "ไม่พบไฟล์หลังจากการดาวน์โหลด"
    }

} catch {
    Write-Host ""
    Write-Host "[ERROR] เกิดข้อผิดพลาด: $_" -ForegroundColor Red
    Write-Host ""
    Start-Sleep -Seconds 5
}
