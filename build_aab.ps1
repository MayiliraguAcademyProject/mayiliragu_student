<#
.SYNOPSIS
    Builds the Android App Bundle (.aab) for Mayiliragu Student App with auto version increment.

.DESCRIPTION
    1. Sets UTF-8 output encoding for clean console formatting.
    2. Pulls latest code from target git branch (default: prod).
    3. Reads and increments version code (+1) in pubspec.yaml.
    4. Runs 'flutter pub get' (and optionally 'flutter clean').
    5. Compiles release AAB ('flutter build appbundle --release').
    6. Saves output AAB to 'build_output/aab/' with versioned filename and opens File Explorer.

.PARAMETER Version
    Custom version string (e.g., "1.0.0+20"). If omitted, increments build number by 1.

.PARAMETER BumpType
    Specify version bump: 'build' (default, +1 build code), 'patch' (1.0.0 -> 1.0.1), 'minor', or 'major'.

.PARAMETER Branch
    Git branch to pull from before building (default: 'prod').

.PARAMETER SkipPull
    If specified, skips 'git pull'.

.PARAMETER Clean
    If specified, runs 'flutter clean' before building.

.PARAMETER NoExplorer
    If specified, suppresses opening File Explorer upon build completion.
#>

param (
    [string]$Version = '',
    [ValidateSet('build', 'patch', 'minor', 'major')]
    [string]$BumpType = 'build',
    [string]$Branch = 'prod',
    [switch]$SkipPull = $false,
    [switch]$Clean = $false,
    [switch]$NoExplorer = $false
)

$ErrorActionPreference = 'Stop'

# Set UTF-8 encoding for PowerShell output formatting
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Mayiliragu Student App - AAB Build" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

$pubspecPath = Join-Path -Path $PSScriptRoot -ChildPath 'pubspec.yaml'
if (-not (Test-Path $pubspecPath)) {
    Write-Host '[ERROR] pubspec.yaml not found' -ForegroundColor Red
    exit 1
}

# 1. Git pull from target branch
if (-not $SkipPull) {
    Write-Host ("`n[1/5] Pulling latest code from origin/{0}..." -f $Branch) -ForegroundColor Yellow
    # Reset local pubspec changes if any to prevent git merge conflicts
    git checkout -- pubspec.yaml 2>$null
    git pull origin $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host ("`n[ERROR] Git pull from origin/{0} failed. Please check your network or branch status." -f $Branch) -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[1/5] Skipping git pull as requested (-SkipPull)." -ForegroundColor Gray
}

# 2. Parse current version from pubspec.yaml
$pubspecLines = Get-Content -Path $pubspecPath
$versionPattern = '^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)'
$versionLine = $pubspecLines | Where-Object { $_ -match $versionPattern }

if (-not $versionLine) {
    Write-Host '[ERROR] Could not parse version pattern in pubspec.yaml' -ForegroundColor Red
    exit 1
}

$versionMatch = [regex]::Match($versionLine, $versionPattern)
$major = [int]$versionMatch.Groups[1].Value
$minor = [int]$versionMatch.Groups[2].Value
$patch = [int]$versionMatch.Groups[3].Value
$buildNum = [int]$versionMatch.Groups[4].Value

$oldVersionString = ("{0}.{1}.{2}+{3}" -f $major, $minor, $patch, $buildNum)
$newMajor = $major
$newMinor = $minor
$newPatch = $patch
$newBuildNum = $buildNum + 1

if ($Version -ne '') {
    if ($Version -match '^(\d+)\.(\d+)\.(\d+)\+(\d+)$') {
        $newMajor = [int]$Matches[1]
        $newMinor = [int]$Matches[2]
        $newPatch = [int]$Matches[3]
        $newBuildNum = [int]$Matches[4]
    } else {
        Write-Host ("`n[ERROR] Invalid version format: {0}. Expected format: X.Y.Z+BuildCode" -f $Version) -ForegroundColor Red
        exit 1
    }
} else {
    switch ($BumpType) {
        'patch' { $newPatch = $patch + 1; $newBuildNum = 1 }
        'minor' { $newMinor = $minor + 1; $newPatch = 0; $newBuildNum = 1 }
        'major' { $newMajor = $major + 1; $newMinor = 0; $newPatch = 0; $newBuildNum = 1 }
    }
}

$newVersionString = ("{0}.{1}.{2}+{3}" -f $newMajor, $newMinor, $newPatch, $newBuildNum)

Write-Host ("`n[2/5] Updating version in pubspec.yaml...") -ForegroundColor Yellow
Write-Host ("      Current Version : {0}" -f $oldVersionString) -ForegroundColor Gray
Write-Host ("      New Version     : {0} (Version Code: {1})" -f $newVersionString, $newBuildNum) -ForegroundColor Green

$updatedLines = @()
foreach ($l in $pubspecLines) {
    if ($l -match '^version:\s*') {
        $updatedLines += ('version: ' + $newVersionString)
    } else {
        $updatedLines += $l
    }
}
Set-Content -Path $pubspecPath -Value $updatedLines
Write-Host ("      [OK] Saved new version ({0}) to pubspec.yaml" -f $newVersionString) -ForegroundColor Green

try {
    # 3. Optional Flutter Clean
    if ($Clean) {
        Write-Host "`n[3/5] Cleaning build cache (flutter clean)..." -ForegroundColor Yellow
        flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw ("Flutter clean failed with exit code {0}" -f $LASTEXITCODE)
        }
    } else {
        Write-Host "`n[3/5] Skipping flutter clean (use -Clean to perform full clean)." -ForegroundColor Gray
    }

    # 4. Flutter pub get
    Write-Host "`n[4/5] Fetching package dependencies (flutter pub get)..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw ("Flutter pub get failed with exit code {0}" -f $LASTEXITCODE)
    }

    # 5. Build AAB release
    Write-Host "`n[5/5] Building Release App Bundle (flutter build appbundle --release)..." -ForegroundColor Yellow
    flutter build appbundle --release --dart-define=BASE_URL=https://api-mayiliragu.sathishdev.in/api --dart-define=ENV=prod
    if ($LASTEXITCODE -ne 0) {
        throw ("Flutter AAB build failed with exit code {0}" -f $LASTEXITCODE)
    }

    $sourceAab = (Join-Path -Path $PSScriptRoot -ChildPath 'build/app/outputs/bundle/release/app-release.aab').Replace('\', '/')
    if (-not (Test-Path $sourceAab)) {
        throw 'Build finished, but generated output file app-release.aab was not found.'
    }

    $outputDir = (Join-Path -Path $PSScriptRoot -ChildPath 'build_output/aab').Replace('\', '/')
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    $fileName = ("Mayiliragu-v{0}.{1}.{2}-build{3}.aab" -f $newMajor, $newMinor, $newPatch, $newBuildNum)
    $targetAab = (Join-Path -Path $outputDir -ChildPath $fileName).Replace('\', '/')

    Copy-Item -Path $sourceAab -Destination $targetAab -Force

    $fileItem = Get-Item $targetAab
    $fileSizeMB = [math]::Round($fileItem.Length / 1MB, 2)

    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host " BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ("Version       : {0}" -f $newVersionString) -ForegroundColor Cyan
    Write-Host ("Version Code  : {0}" -f $newBuildNum) -ForegroundColor Cyan
    Write-Host ("File Size     : {0} MB" -f $fileSizeMB) -ForegroundColor Cyan
    Write-Host ("AAB Saved To  : {0}" -f $targetAab) -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green

    if (-not $NoExplorer) {
        Invoke-Item $outputDir
    }
}
catch {
    Write-Host "`n[ERROR] Build failed: $_" -ForegroundColor Red
    Write-Host ("Restoring previous version string ({0}) in pubspec.yaml..." -f $oldVersionString) -ForegroundColor Yellow
    $errLines = Get-Content -Path $pubspecPath
    $revertedLines = @()
    foreach ($line in $errLines) {
        if ($line -match '^version:\s*') {
            $revertedLines += ('version: ' + $oldVersionString)
        } else {
            $revertedLines += $line
        }
    }
    Set-Content -Path $pubspecPath -Value $revertedLines
    exit 1
}
