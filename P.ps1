$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
catch {
}

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
}
catch {
}

$RepoOwner = "Wxyuz"
$RepoName = "god"
$TagName = "v1.0.0"
$ExeName = "loader.exe"

$ReleasePage = "https://github.com/$RepoOwner/$RepoName/releases/tag/$TagName"
$DownloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$TagName/$ExeName"

$OutDir = Join-Path $env:USERPROFILE "Downloads"
$OutFile = Join-Path $OutDir $ExeName

function Write-Info {
    param(
        [string]$Text
    )
    Write-Host "[+] $Text" -ForegroundColor Cyan
}

function Write-Good {
    param(
        [string]$Text
    )
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-Bad {
    param(
        [string]$Text
    )
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function Test-WindowsExe {
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

Clear-Host

Write-Host "====================================================" -ForegroundColor Yellow
Write-Host "                  LOADER DOWNLOADER                 " -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
Write-Host ""

Write-Info "Repository : https://github.com/$RepoOwner/$RepoName"
Write-Info "Release    : $ReleasePage"
Write-Info "File       : $ExeName"
Write-Info "URL        : $DownloadUrl"
Write-Host ""

if (!(Test-Path -LiteralPath $OutDir)) {
    Write-Info "Creating Downloads folder..."
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

if (Test-Path -LiteralPath $OutFile) {
    Write-Info "Old loader.exe found. Removing old file..."
    Remove-Item -LiteralPath $OutFile -Force
}

Write-Info "Downloading loader.exe..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutFile -UseBasicParsing

Write-Host ""

if (!(Test-Path -LiteralPath $OutFile)) {
    Write-Bad "Download failed. File not found."
    Write-Host ""
    pause
    exit
}

Write-Good "Download complete"
Write-Info "Saved to: $OutFile"
Write-Host ""

Write-Info "Checking file type..."
if (!(Test-WindowsExe -Path $OutFile)) {
    Write-Bad "Downloaded file is not a valid Windows EXE."
    Write-Host ""
    pause
    exit
}

Write-Good "Valid Windows EXE file"
Write-Host ""

Write-Info "SHA256:"
Get-FileHash -LiteralPath $OutFile -Algorithm SHA256
Write-Host ""

Write-Info "Opening file location..."
explorer.exe /select,"$OutFile"

Write-Host ""
Write-Good "Done"
Write-Host "Check the file, then open loader.exe manually."
Write-Host ""

pause
