$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch {
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================================
# GOD LOADER DOWNLOADER
# GitHub Repo: https://github.com/Wxyuz/god
# Safe Mode: Download + Verify + Open File Location
# ==========================================================

$AppTitle = "GOD LOADER DOWNLOADER"
$AppName = "LOADER"

$RepoOwner = "Wxyuz"
$RepoName = "god"
$ExeName = "loader.exe"

# ใช้ Release ล่าสุดของ repo
$LatestReleaseApi = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"

# ถ้าต้องการล็อก URL ตรง ให้ใส่ตรงนี้
# ถ้าเว้นว่าง จะดึง loader.exe จาก Release ล่าสุดให้อัตโนมัติ
$DirectExeUrl = ""

$InstallDir = Join-Path $env:USERPROFILE "Downloads"
$OutFile = Join-Path $InstallDir $ExeName

function Write-Line {
    param(
        [string]$Text = "",
        [System.ConsoleColor]$Color = [System.ConsoleColor]::Gray
    )

    Write-Host $Text -ForegroundColor $Color
}

function Show-Header {
    Clear-Host
    Write-Line "=============================================" Cyan
    Write-Line "              GOD LOADER DOWNLOADER          " Cyan
    Write-Line "=============================================" Cyan
    Write-Line ""
    Write-Line "[+] Repo : https://github.com/$RepoOwner/$RepoName" Yellow
    Write-Line "[+] File : $ExeName" Yellow
    Write-Line ""
}

function Test-PortableExecutable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (!(Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $stream = [System.IO.File]::Open(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::ReadWrite
        )

        try {
            if ($stream.Length -lt 2) {
                return $false
            }

            $buffer = New-Object byte[] 2
            [void]$stream.Read($buffer, 0, 2)

            # Windows EXE ต้องขึ้นต้นด้วย MZ
            return ($buffer[0] -eq 0x4D -and $buffer[1] -eq 0x5A)
        }
        finally {
            $stream.Close()
        }
    }
    catch {
        return $false
    }
}

function Get-LatestReleaseExeUrl {
    Write-Line "[+] Connecting to GitHub latest release..." Yellow

    $headers = @{
        "User-Agent" = "GOD-LOADER-DOWNLOADER"
        "Accept"     = "application/vnd.github+json"
    }

    $release = Invoke-RestMethod -Uri $LatestReleaseApi -Headers $headers -Method Get

    if ($null -eq $release.assets -or $release.assets.Count -eq 0) {
        throw "No release assets found. Please upload loader.exe to GitHub Releases."
    }

    $asset = $release.assets | Where-Object {
        $_.name -ieq $ExeName -and ![string]::IsNullOrWhiteSpace($_.browser_download_url)
    } | Select-Object -First 1

    if ($null -eq $asset) {
        $assetNames = ($release.assets | ForEach-Object { $_.name }) -join ", "
        throw "loader.exe not found in latest release. Assets found: $assetNames"
    }

    return $asset.browser_download_url
}

function Download-Loader {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    if (!(Test-Path -LiteralPath $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    Write-Line "[+] Downloading loader.exe..." Yellow
    Write-Line "[+] URL: $Url" DarkGray
    Write-Line ""

    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing

    if (!(Test-Path -LiteralPath $OutFile)) {
        throw "Download failed. Output file not found."
    }

    if (!(Test-PortableExecutable -Path $OutFile)) {
        throw "Downloaded file is not a valid Windows EXE."
    }

    Write-Line ""
    Write-Line "[+] Download complete" Green
    Write-Line "[+] Saved to: $OutFile" Green
    Write-Line ""

    Write-Line "[+] SHA256:" Yellow
    Get-FileHash -LiteralPath $OutFile -Algorithm SHA256 | Format-List

    Write-Line "[+] Opening file location..." Yellow
    explorer.exe /select,"$OutFile"

    Write-Line ""
    Write-Line "Done. Check the file, then open loader.exe manually." Green
    Write-Line ""
}

try {
    $Host.UI.RawUI.WindowTitle = $AppTitle
    Show-Header

    if ([string]::IsNullOrWhiteSpace($DirectExeUrl)) {
        $ExeUrl = Get-LatestReleaseExeUrl
    }
    else {
        $ExeUrl = $DirectExeUrl
    }

    Download-Loader -Url $ExeUrl

    Write-Line "Press Enter to close..." DarkGray
    [void][System.Console]::ReadLine()
}
catch {
    Write-Line ""
    Write-Line "[ERROR]" Red
    Write-Line $_.Exception.Message Red
    Write-Line ""
    Write-Line "Checklist:" Yellow
    Write-Line "1. Repo ต้องเป็น Public: https://github.com/Wxyuz/god" Yellow
    Write-Line "2. ต้องมี Release อย่างน้อย 1 ตัว" Yellow
    Write-Line "3. ใน Release Assets ต้องมีไฟล์ชื่อ loader.exe" Yellow
    Write-Line "4. ไฟล์ P.ps1 ต้องอยู่ใน branch main" Yellow
    Write-Line ""
    Write-Line "Press Enter to close..." DarkGray
    [void][System.Console]::ReadLine()
}
