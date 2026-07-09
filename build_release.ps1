# Build MentalMantra release APK with obfuscation and code shrinking
# Requires: flutter, Android SDK
#
# Usage:
#   .\build_release.ps1                              # uses .env.client file
#   $env:GOOGLE_CLIENT_ID="xxx"; .\build_release.ps1  # overrides OAuth client ID

$ErrorActionPreference = "Stop"

$outputDir = "build/app/outputs/flutter-apk"
$debugInfoDir = "build/debug-info"

Write-Host "=== Building MentalMantra Release APK (Obfuscated) ===" -ForegroundColor Cyan

# ── Step 1: Clean ──────────────────────────────────────────────
Write-Host "`n[1/5] Cleaning previous builds..." -ForegroundColor Yellow
flutter clean; if (!$?) { exit 1 }

# ── Step 2: Dependencies ───────────────────────────────────────
Write-Host "`n[2/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get; if (!$?) { exit 1 }

# ── Step 3: Validate secrets not hardcoded ────────────────────
Write-Host "`n[3/5] Validating no exposed secrets..." -ForegroundColor Yellow
$exposedKeys = Select-String -Path "lib/**/*.dart" -Pattern "AIzaSy[A-Za-z0-9_-]{30,}" -SimpleMatch:$false
if ($exposedKeys) {
    Write-Host "[ERROR] Exposed API key found in Dart code! Aborting." -ForegroundColor Red
    $exposedKeys | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber)" -ForegroundColor Red }
    exit 1
}
Write-Host "  No exposed secrets found." -ForegroundColor Green

# ── Step 4: Build release APK ─────────────────────────────────
Write-Host "`n[4/5] Building release APK (obfuscated)..." -ForegroundColor Yellow

$extraDefines = @()
if ($env:GOOGLE_CLIENT_ID) {
    $extraDefines += "--dart-define=GOOGLE_CLIENT_ID=$($env:GOOGLE_CLIENT_ID)"
    Write-Host "  Using GOOGLE_CLIENT_ID from environment" -ForegroundColor Cyan
}

$buildArgs = @(
    "build", "apk", "--release",
    "--obfuscate",
    "--split-debug-info", $debugInfoDir,
    "--dart-define-from-file=.env.client"
) + $extraDefines

flutter $buildArgs; if (!$?) { exit 1 }

# ── Step 5: Export ─────────────────────────────────────────────
Write-Host "`n[5/5] Build complete!" -ForegroundColor Green

$generatedApk = "$outputDir/app-release.apk"
if (Test-Path $generatedApk) {
    Write-Host "`nExporting APK..." -ForegroundColor Cyan

    $rootApk = "mental-mantra-release.apk"
    Copy-Item -Path $generatedApk -Destination $rootApk -Force
    Write-Host "  Copied to project root: $rootApk" -ForegroundColor Green

    $downloadsDir = "$env:USERPROFILE\Downloads"
    if (Test-Path $downloadsDir) {
        $downloadsApk = "$downloadsDir\mental-mantra.apk"
        Copy-Item -Path $generatedApk -Destination $downloadsApk -Force
        Write-Host "  Copied to Downloads: $downloadsApk" -ForegroundColor Green
    }
} else {
    Write-Host "`n[ERROR] APK not found at $generatedApk!" -ForegroundColor Red
    exit 1
}

Write-Host "`nDebug symbols: $debugInfoDir" -ForegroundColor Cyan
Write-Host "`n=== Done ===" -ForegroundColor Green
