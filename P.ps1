# ============================================================
# Wxyuz Auto-Run GUI Script
# ============================================================
$ErrorActionPreference = "Stop"

# ลิงก์ดาวน์โหลดไฟล์ .exe จาก GitHub (ต้องเป็นไฟล์โปรแกรม GUI ตัวจริง)
$ExeUrl = "https://github.com/Wxyuz/god/releases/download/v1.0.0/loader.exe"

# บันทึกไว้ในโฟลเดอร์ Temp (ไฟล์ชั่วคราว) จะได้ไม่ไปรกในเครื่อง
$ExePath = Join-Path $env:TEMP "WxyuzLoaderGUI.exe"

Clear-Host
Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host "          Starting Wxyuz Program...           " -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "[*] กำลังดาวน์โหลดและเตรียมเปิดโปรแกรม กรุณารอสักครู่..." -ForegroundColor Yellow

try {
    # บังคับใช้ TLS 1.2 เพื่อให้โหลดจาก GitHub ได้
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # ลบไฟล์เก่าใน Temp ทิ้งก่อน (ถ้ามี) เพื่อบังคับโหลดไฟล์ใหม่เสมอ
    if (Test-Path $ExePath) {
        Remove-Item $ExePath -Force
    }

    # ดาวน์โหลดไฟล์
    Invoke-WebRequest -Uri $ExeUrl -OutFile $ExePath -UseBasicParsing

    if (Test-Path $ExePath) {
        # สั่งเปิดโปรแกรมทันที
        Start-Process -FilePath $ExePath
        
        # ปิดหน้าต่าง PowerShell เพื่อให้เหลือแต่หน้า GUI ที่คุณต้องการ
        Stop-Process -Id $PID
    } else {
        Write-Host "[X] เกิดข้อผิดพลาด: ไม่พบไฟล์หลังจากการดาวน์โหลด" -ForegroundColor Red
        Start-Sleep -Seconds 5
    }
} catch {
    Write-Host "[X] เกิดข้อผิดพลาดในการโหลดโปรแกรม: $_" -ForegroundColor Red
    Start-Sleep -Seconds 5
}
