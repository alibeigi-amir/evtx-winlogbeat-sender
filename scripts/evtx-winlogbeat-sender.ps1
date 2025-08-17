<#
.SYNOPSIS
    🚀 Batch-ship Windows EVTX logs to Elasticsearch via Winlogbeat with style ✨

.DESCRIPTION
    Reads one or more `.evtx` files (or an entire folder) and streams the events
    to your configured Winlogbeat output (Elasticsearch, Logstash, …).

.PARAMETER Source
    📁 Path to a single `.evtx` file **or** a folder that contains `.evtx` files.

.PARAMETER WinlogbeatExe
    🏃‍♂️ Full path to `winlogbeat.exe`.

.PARAMETER ConfigFile
    ⚙️ Full path to your `winlogbeat.yml` configuration file.

.PARAMETER Verbose
    🔍 Switch to print detailed progress in the console.

.EXAMPLE
    .\Process-EvtxWithWinlogbeat.ps1 `
        -Source "C:\Forensics\Logs" `
        -WinlogbeatExe "C:\Tools\winlogbeat\winlogbeat.exe" `
        -ConfigFile "C:\Tools\winlogbeat\winlogbeat.yml" `
        -Verbose
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$WinlogbeatExe,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ConfigFile,

    [switch]$Verbose
)

# ────────────────────────────────────────────────────────────────
# 🧰 0. Helper emojis & colors
# ────────────────────────────────────────────────────────────────
$E = @{
    OK   = "✅"
    WARN = "⚠️"
    ERR  = "❌"
    INFO = "ℹ️"
    ARR  = "➡️"
}

# ────────────────────────────────────────────────────────────────
# 🔍 1. Validate inputs
# ────────────────────────────────────────────────────────────────
if (-not (Test-Path $WinlogbeatExe)) {
    Write-Host "$($E.ERR) winlogbeat.exe not found at: $WinlogbeatExe" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ConfigFile)) {
    Write-Host "$($E.ERR) winlogbeat.yml not found at: $ConfigFile" -ForegroundColor Red
    exit 1
}

# ────────────────────────────────────────────────────────────────
# 📂 2. Collect EVTX files
# ────────────────────────────────────────────────────────────────
if ((Test-Path $Source) -and (Get-Item $Source).PSIsContainer) {
    $evtxFiles = Get-ChildItem -Path $Source -Filter *.evtx -Recurse
} elseif (Test-Path $Source) {
    $evtxFiles = @(Get-Item $Source)
} else {
    Write-Host "$($E.ERR) Source path does not exist: $Source" -ForegroundColor Red
    exit 1
}

if ($evtxFiles.Count -eq 0) {
    Write-Host "$($E.ERR) No EVTX files found at $Source" -ForegroundColor Red
    exit 1
}

Write-Host "$($E.OK) Found $($evtxFiles.Count) EVTX file(s) to process." -ForegroundColor Green

# ────────────────────────────────────────────────────────────────
# 🚀 3. Process each file
# ────────────────────────────────────────────────────────────────
foreach ($evtx in $evtxFiles) {
    Write-Host "$($E.ARR) Processing $($evtx.FullName) ..." -ForegroundColor Cyan

    # Unique data dir to avoid collisions
    $dataDir = Join-Path $env:TEMP "winlogbeat_data\$($evtx.BaseName)_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null

    $args = @(
        "-c", "`"$ConfigFile`""
        "-e"
        "--path.data", "`"$dataDir`""
        "-E", "EVTX_FILE=`"$($evtx.FullName)`""
    )

    if ($Verbose) {
        Write-Host "$($E.INFO) Executing: $WinlogbeatExe $($args -join ' ')"
    }

    if ($PSCmdlet.ShouldProcess($evtx.FullName, "Process with Winlogbeat")) {
        & $WinlogbeatExe @args
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            Write-Host "$($E.WARN) winlogbeat failed on $($evtx.FullName) (exit code $exitCode)" -ForegroundColor Yellow
        } else {
            Write-Host "$($E.OK) Finished $($evtx.Name)" -ForegroundColor Green
        }
    }

    # Optional cleanup – remove empty data folder
    if ((Get-ChildItem $dataDir -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item $dataDir -Recurse -Force
    }
}

Write-Host "$($E.OK) All EVTX files processed." -ForegroundColor Green
