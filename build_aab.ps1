param (
    [string]$Version = '',
    [string]$BumpType = 'build',
    [switch]$Clean = $false,
    [switch]$NoExplorer = $false
)

$ErrorActionPreference = 'Stop'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Mayiliragu Student App - AAB Build" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

$pubspecPath = Join-Path -Path $PSScriptRoot -ChildPath 'pubspec.yaml'
if (-not (Test-Path $pubspecPath)) {
    Write-Host '[ERROR] pubspec.yaml not found' -ForegroundColor Red
    exit 1
}

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
        Write-Host ('[ERROR] Invalid version format: {0}' -f $Version) -ForegroundColor Red
        exit 1
    }
} else {
    switch ($BumpType) {
        'patch' { $newPatch = $patch + 1 }
        'minor' { $newMinor = $minor + 1; $newPatch = 0 }
        'major' { $newMajor = $major + 1; $newMinor = 0; $newPatch = 0 }
    }
}

$newVersionString = ("{0}.{1}.{2}+{3}" -f $newMajor, $newMinor, $newPatch, $newBuildNum)

Write-Host ('Current Version : {0}' -f $oldVersionString) -ForegroundColor Yellow
Write-Host ('New Version     : {0} (Version Code: {1})' -f $newVersionString, $newBuildNum) -ForegroundColor Green

$updatedLines = @()
foreach ($l in $pubspecLines) {
    if ($l -match '^version:\s*') {
        $updatedLines += ('version: ' + $newVersionString)
    } else {
        $updatedLines += $l
    }
}
Set-Content -Path $pubspecPath -Value $updatedLines
Write-Host ('[✓] Updated pubspec.yaml with version: {0}' -f $newVersionString) -ForegroundColor Green

try {
    if ($Clean) {
        Write-Host '[1/3] Cleaning build cache (flutter clean)...' -ForegroundColor Yellow
        flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw ('Flutter clean failed with exit code {0}' -f $LASTEXITCODE)
        }
    }

    Write-Host '[2/3] Fetching dependencies (flutter pub get)...' -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw ('Flutter pub get failed with exit code {0}' -f $LASTEXITCODE)
    }

    Write-Host '[3/3] Building Android App Bundle (flutter build appbundle --release)...' -ForegroundColor Yellow
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) {
        throw ('Flutter AAB build failed with exit code {0}' -f $LASTEXITCODE)
    }

    $sourceAab = (Join-Path -Path $PSScriptRoot -ChildPath 'build/app/outputs/bundle/release/app-release.aab').Replace('\', '/')
    if (-not (Test-Path $sourceAab)) {
        throw 'Build finished but output AAB file was not found'
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

    Write-Host '==========================================' -ForegroundColor Green
    Write-Host ' BUILD SUCCESSFUL!' -ForegroundColor Green
    Write-Host '==========================================' -ForegroundColor Green
    Write-Host ('Version       : {0}' -f $newVersionString) -ForegroundColor Cyan
    Write-Host ('Version Code  : {0}' -f $newBuildNum) -ForegroundColor Cyan
    Write-Host ('File Size     : {0} MB' -f $fileSizeMB) -ForegroundColor Cyan
    Write-Host ('AAB Saved To  : {0}' -f $targetAab) -ForegroundColor Green
    Write-Host '==========================================' -ForegroundColor Green

    if (-not $NoExplorer) {
        Invoke-Item $outputDir
    }
}
catch {
    Write-Host '[ERROR] Build failed' -ForegroundColor Red
    Write-Host 'Restoring previous version in pubspec.yaml...' -ForegroundColor Yellow
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
