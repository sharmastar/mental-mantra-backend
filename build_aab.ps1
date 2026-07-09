# Build MentalMantra release App Bundle (AAB) with obfuscation and code shrinking
# Requires: flutter, Android SDK
#
# Usage:
#   .\build_aab.ps1                              # uses .env.client file
#   $env:GOOGLE_CLIENT_ID="xxx"; .\build_aab.ps1  # overrides OAuth client ID

$ErrorActionPreference = "Stop"

$outputDir = "build/app/outputs/bundle/release"
$debugInfoDir = "build/debug-info"

Write-Host "=== Building MentalMantra Release App Bundle (Obfuscated) ===" -ForegroundColor Cyan

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

# ── Step 4: Build release AAB ─────────────────────────────────
Write-Host "`n[4/5] Building release App Bundle (obfuscated)..." -ForegroundColor Yellow

$extraDefines = @()
if ($env:GOOGLE_CLIENT_ID) {
    $extraDefines += "--dart-define=GOOGLE_CLIENT_ID=$($env:GOOGLE_CLIENT_ID)"
    Write-Host "  Using GOOGLE_CLIENT_ID from environment" -ForegroundColor Cyan
}

$buildArgs = @(
    "build", "appbundle", "--release",
    "--obfuscate",
    "--split-debug-info", $debugInfoDir,
    "--dart-define-from-file=.env.client"
) + $extraDefines

flutter $buildArgs; if (!$?) { exit 1 }

# ── Step 5: Export ─────────────────────────────────────────────
Write-Host "`n[5/5] Build complete!" -ForegroundColor Green

$generatedAab = "$outputDir/app-release.aab"
if (Test-Path $generatedAab) {
    Write-Host "`nExporting AAB..." -ForegroundColor Cyan

    $rootAab = "mental-mantra-release.aab"
    Copy-Item -Path $generatedAab -Destination $rootAab -Force
    Write-Host "  Copied to project root: $rootAab" -ForegroundColor Green

    $downloadsDir = "$env:USERPROFILE\Downloads"
    if (Test-Path $downloadsDir) {
        $downloadsAab = "$downloadsDir\mental-mantra.aab"
        Copy-Item -Path $generatedAab -Destination $downloadsAab -Force
        Write-Host "  Copied to Downloads: $downloadsAab" -ForegroundColor Green
    }
} else {
    Write-Host "`n[ERROR] AAB not found at $generatedAab!" -ForegroundColor Red
    exit 1
}

Write-Host "`nDebug symbols: $debugInfoDir" -ForegroundColor Cyan
Write-Host "`n=== Done ===" -ForegroundColor Green
