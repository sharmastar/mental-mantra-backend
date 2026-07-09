# Mental Mantra - Firebase & Google Sign-In Setup Script
# Run this from the project root.
# Requirements: PowerShell 5.1+, Java (for keytool), Flutter SDK
# This script validates configuration and prevents building a broken APK.

$ErrorActionPreference = "Stop"

$expectedPackage = "com.mentalmantra.mental_mantra"
$exitCode = 0

Write-Host "=== Mental Mantra - Firebase Setup ===" -ForegroundColor Cyan
Write-Host "This script validates your Google Sign-In configuration and prevents building a broken APK.`n" -ForegroundColor Cyan

# ================================================================
# Step 0: Validate google-services.json
# ================================================================
Write-Host "[0/6] Validating google-services.json..." -ForegroundColor Yellow

$googleServicesPath = "android\app\google-services.json"
if (-not (Test-Path $googleServicesPath)) {
    Write-Host "  [FAIL] File not found: $googleServicesPath" -ForegroundColor Red
    Write-Host "    Download it from Firebase Console -> Project Settings -> Your apps -> Android" -ForegroundColor Gray
    $exitCode = 1
} else {
    $gsContent = Get-Content $googleServicesPath -Raw

    # --- Check structural validity ------------------------------------
    try {
        $gsJson = $gsContent | ConvertFrom-Json
    } catch {
        Write-Host "  [FAIL] google-services.json is not valid JSON." -ForegroundColor Red
        Write-Host "    Download a fresh copy from Firebase Console." -ForegroundColor Gray
        $exitCode = 1
        return
    }

    # Validate required top-level sections exist
    $missingSections = @()
    if (-not $gsJson.project_info) { $missingSections += "project_info" }
    if (-not $gsJson.client) { $missingSections += "client" }
    if ($missingSections.Count -gt 0) {
        Write-Host "  [FAIL] Missing required sections: $($missingSections -join ', ')" -ForegroundColor Red
        Write-Host "    This file is not a valid Firebase configuration." -ForegroundColor Gray
        $exitCode = 1
    }

    # --- Validate project ID format -----------------------------------
    $projectId = $gsJson.project_info.project_id
    if ($projectId -and $projectId -notmatch '^[a-z0-9-]+$') {
        Write-Host "  [FAIL] Invalid Firebase Project ID format: $projectId" -ForegroundColor Red
        Write-Host "    Project IDs should only contain lowercase letters, numbers, and hyphens." -ForegroundColor Gray
        $exitCode = 1
    } else {
        Write-Host "  [OK] Project ID: $projectId" -ForegroundColor Green
    }

    # --- Find the Android client by package name (not assuming client[0]) --
    if ($gsJson.client -and $gsJson.client.Count -gt 0) {
        $androidClient = $gsJson.client | Where-Object {
            $_.client_info.android_client_info.package_name -eq $expectedPackage
        }

        if (-not $androidClient) {
            $foundPackages = $gsJson.client | ForEach-Object { $_.client_info.android_client_info.package_name }
            Write-Host "  [FAIL] No Android client found for package '$expectedPackage'" -ForegroundColor Red
            Write-Host "    Found clients for: $($foundPackages -join ', ')" -ForegroundColor Gray
            $exitCode = 1
        } else {
            Write-Host "  [OK] Package name: $expectedPackage" -ForegroundColor Green
        }
    }

    # --- Validate Android client details -----------------------------
    if ($androidClient) {
        if (-not $androidClient.oauth_client) {
            Write-Host "  [FAIL] Missing oauth_client in google-services.json" -ForegroundColor Red
            Write-Host "    Ensure the Firebase project has Google Sign-In enabled." -ForegroundColor Gray
            $exitCode = 1
        }
        if (-not $androidClient.api_key) {
            Write-Host "  [FAIL] Missing api_key in google-services.json" -ForegroundColor Red
            $exitCode = 1
        }
    }

    # --- Check for placeholder values ---------------------------------
    $placeholderPatterns = @(
        "123456789012",
        "Placeholder",
        "placeholder",
        "your_google_client_id_here",
        "AIzaSyPlaceholder",
        "androidplaceholderclientid",
        "webplaceholderclientid",
        "YOUR_API_KEY"
    )

    $hasPlaceholder = $false
    foreach ($pattern in $placeholderPatterns) {
        if ($gsContent -match [regex]::Escape($pattern)) {
            $hasPlaceholder = $true
            break
        }
    }

    if ($hasPlaceholder) {
        Write-Host "  [FAIL] google-services.json contains placeholder values." -ForegroundColor Red
        Write-Host "    Project ID: $($gsJson.project_info.project_id)" -ForegroundColor Gray
        Write-Host "    Download the real file from Firebase Console -> Project Settings." -ForegroundColor Gray
        $exitCode = 1
    } else {
        Write-Host "  [OK] Contains real Firebase values" -ForegroundColor Green
    }

    # --- Check for Web Client ID (client_type 3) ----------------------
    if ($androidClient -and $androidClient.oauth_client) {
        $webClient = $androidClient.oauth_client | Where-Object { $_.client_type -eq 3 }
        if ($webClient) {
            $webClientId = $webClient.client_id
            $formatOk = $webClientId -match "\.apps\.googleusercontent\.com$"
            $isPlaceholderClient = ($webClientId -match "placeholder") -or ($webClientId -match "^123456789012-") -or ($webClientId -match "webplaceholderclientid")

            if (-not $formatOk) {
                Write-Host "  [FAIL] Web Client ID format looks invalid: $webClientId" -ForegroundColor Red
                Write-Host "    Expected format: xxxxx.apps.googleusercontent.com" -ForegroundColor Gray
                $exitCode = 1
            } elseif ($isPlaceholderClient) {
                Write-Host "  [FAIL] Web Client ID is still a placeholder: $webClientId" -ForegroundColor Red
                Write-Host "    Download the real google-services.json from Firebase Console." -ForegroundColor Gray
                $exitCode = 1
            } else {
                Write-Host "  [OK] Web Client ID found: $webClientId" -ForegroundColor Green
            }
        } else {
            Write-Host "  [WARN] No Web OAuth client found (client_type 3). Google Sign-In may not work." -ForegroundColor Yellow
            Write-Host "    Add a Web app in Firebase Console to generate the Web Client ID." -ForegroundColor Gray
        }
    }

    # --- Check for Android OAuth client (client_type 1) ---------------
    if ($androidClient -and $androidClient.oauth_client) {
        $androidOAuthClient = $androidClient.oauth_client | Where-Object { $_.client_type -eq 1 }
        if (-not $androidOAuthClient) {
            Write-Host "  [WARN] No Android OAuth client found (client_type 1)." -ForegroundColor Yellow
        }
    }
}

# ================================================================
# Check: Google Services Gradle Plugin
# ================================================================
Write-Host "`n[1/6] Checking Gradle plugin..." -ForegroundColor Yellow

$gradleFile = "android\app\build.gradle.kts"
if (Test-Path $gradleFile) {
    $gradleContent = Get-Content $gradleFile -Raw
    if ($gradleContent -match 'com\.google\.gms\.google-services') {
        Write-Host "  [OK] Google Services plugin is present in $gradleFile" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Missing: id('com.google.gms.google-services') in $gradleFile" -ForegroundColor Red
        Write-Host "    Add this line to the plugins block." -ForegroundColor Gray
        $exitCode = 1
    }
} else {
    Write-Host "  [WARN] $gradleFile not found - cannot verify plugin." -ForegroundColor Yellow
}

# ================================================================
# Check: Environment Variable Files
# ================================================================
Write-Host "`n[2/6] Validating environment variables..." -ForegroundColor Yellow

$envFiles = @(
    @{ Path = ".env"; Label = ".env (frontend)" },
    @{ Path = "backend\.env"; Label = "backend\.env (backend)" }
)

$placeholderPatternsEnv = @("your_google_client_id_here", "YOUR_GOOGLE_CLIENT_ID")

foreach ($ef in $envFiles) {
    if (Test-Path $ef.Path) {
        $envContent = Get-Content $ef.Path -Raw

        # Check for placeholder
        $isPlaceholder = $false
        foreach ($p in $placeholderPatternsEnv) {
            if ($envContent -match [regex]::Escape($p)) {
                $isPlaceholder = $true
                break
            }
        }

        if ($isPlaceholder) {
            Write-Host "  [FAIL] $($ef.Label): GOOGLE_CLIENT_ID is still a placeholder value" -ForegroundColor Red
            $exitCode = 1
        } else {
            # Extract and validate format
            if ($envContent -match '(?m)^GOOGLE_CLIENT_ID=(.+)') {
                $clientId = $Matches[1].Trim()
                if ($clientId -notmatch "\.apps\.googleusercontent\.com$") {
                    Write-Host "  [FAIL] $($ef.Label): GOOGLE_CLIENT_ID format is invalid: $clientId" -ForegroundColor Red
                    Write-Host "    Expected format: xxxxxxxxxxxx-xxxxxxxxxxxx.apps.googleusercontent.com" -ForegroundColor Gray
                    $exitCode = 1
                } else {
                    Write-Host "  [OK] $($ef.Label): GOOGLE_CLIENT_ID = $clientId" -ForegroundColor Green
                }
            } else {
                Write-Host "  [FAIL] $($ef.Label): GOOGLE_CLIENT_ID not found in file" -ForegroundColor Red
                $exitCode = 1
            }
        }
    } else {
        Write-Host "  [FAIL] $($ef.Label): File not found at $($ef.Path)" -ForegroundColor Red
        $exitCode = 1
    }
}

# ================================================================
# Check: Backend health
# ================================================================
Write-Host "`n[3/6] Checking backend connectivity..." -ForegroundColor Yellow

$authApiUrl = $null
if (Test-Path ".env") {
    $authApiLine = Get-Content ".env" | Select-String -Pattern "^AUTH_API_URL=(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    if ($authApiLine) {
        $authApiUrl = $authApiLine.Trim()
    }
}

if ($authApiUrl) {
    $healthUrl = "$authApiUrl/api/health".Replace("//api", "/api")
    try {
        $response = Invoke-RestMethod -Uri $healthUrl -Method GET -TimeoutSec 5
        if ($response.status -eq "ok") {
            Write-Host "  [OK] Backend is healthy at $authApiUrl (status: ok)" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] Backend responded but is unhealthy at $authApiUrl" -ForegroundColor Red
            Write-Host "    Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
            $exitCode = 1
        }
    } catch {
        Write-Host "  [WARN] Backend at $authApiUrl is not reachable." -ForegroundColor Yellow
        Write-Host "    Start the backend: cd backend; npm start" -ForegroundColor Gray
        Write-Host "    (This is not a hard failure - you can start the backend later.)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [WARN] AUTH_API_URL not found in .env - skipping backend check." -ForegroundColor Yellow
}

# ================================================================
# Check: SHA certificate fingerprints
# ================================================================
Write-Host "`n[4/6] Generating SHA certificate fingerprints..." -ForegroundColor Yellow

$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"
$projectKeystore = "android\app\upload-keystore.jks"
$detectedFingerprints = @()

function Get-SHAFingerprints {
    param([string]$KeystorePath, [string]$Alias, [string]$StorePass, [string]$KeyPass, [string]$Label)

    if (-not (Test-Path -LiteralPath $KeystorePath)) {
        Write-Host "  ${Label}: Keystore not found at $KeystorePath" -ForegroundColor Red
        return $null
    }

    try {
        Write-Host "  Reading: $KeystorePath (alias: $Alias)" -ForegroundColor Gray
        $keytool = "keytool"
        if (-not (Get-Command "keytool" -ErrorAction SilentlyContinue)) {
            $commonPaths = @(
                "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
                "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe",
                "C:\Program Files\Java\jdk*\bin\keytool.exe"
            )
            foreach ($p in $commonPaths) {
                $resolved = Get-ChildItem -Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($resolved) {
                    $keytool = $resolved.FullName
                    break
                }
            }
        }
        $output = & $keytool -list -v -keystore $KeystorePath -alias $Alias -storepass $StorePass -keypass $KeyPass 2>&1
        $sha1 = $output | Select-String -Pattern "SHA1: " | ForEach-Object { $_ -replace '.*SHA1: ', '' }
        $sha256 = $output | Select-String -Pattern "SHA256: " | ForEach-Object { $_ -replace '.*SHA256: ', '' }

        Write-Host "  ${Label}:" -ForegroundColor White
        if ($sha1) {
            Write-Host "    SHA-1:   $sha1" -ForegroundColor Green
        } else {
            Write-Host "    SHA-1:   (not found)" -ForegroundColor Red
        }
        if ($sha256) {
            Write-Host "    SHA-256: $sha256" -ForegroundColor Green
        } else {
            Write-Host "    SHA-256: (not found)" -ForegroundColor Red
        }

        return @{ SHA1 = $sha1; SHA256 = $sha256 }
    } catch {
        Write-Host "  ${Label}: Error reading keystore: $_" -ForegroundColor Red
        return $null
    }
}

$debugResult = Get-SHAFingerprints -KeystorePath $debugKeystore -Alias androiddebugkey -StorePass android -KeyPass android -Label "Debug Keystore (debug builds only)"
if ($debugResult) { $detectedFingerprints += $debugResult }

$releaseStorePass = ""
$releaseKeyPass = ""
$keyPropertiesPath = "android\key.properties"
if (Test-Path $keyPropertiesPath) {
    $kpContent = Get-Content $keyPropertiesPath
    foreach ($line in $kpContent) {
        if ($line -match "^storePassword=(.+)") { $releaseStorePass = $Matches[1].Trim() }
        if ($line -match "^keyPassword=(.+)") { $releaseKeyPass = $Matches[1].Trim() }
    }
}
$releaseResult = Get-SHAFingerprints -KeystorePath $projectKeystore -Alias upload -StorePass $releaseStorePass -KeyPass $releaseKeyPass -Label "Release Keystore (release builds)"
if ($releaseResult) { $detectedFingerprints += $releaseResult }

Write-Host ""
Write-Host "  IMPORTANT:" -ForegroundColor Yellow
Write-Host "  +----------------------------------------------------------+" -ForegroundColor White
Write-Host "  | Add BOTH SHA-1 and SHA-256 to Firebase Console           |" -ForegroundColor White
Write-Host "  |                                                          |" -ForegroundColor White
Write-Host "  | If testing with: flutter run       -> use DEBUG          |" -ForegroundColor White
Write-Host "  | If testing with: flutter build apk -> use RELEASE        |" -ForegroundColor White
Write-Host "  | If distributing on Play Store      -> use Play App Key   |" -ForegroundColor White
Write-Host "  +----------------------------------------------------------+" -ForegroundColor White

# ================================================================
# Exit on validation failure
# ================================================================
if ($exitCode -ne 0) {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "CONFIGURATION ERRORS DETECTED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "An APK built with the current configuration WILL fail with Google Sign-In error [28444]." -ForegroundColor Red
    Write-Host "Fix the issues above, then re-run this script." -ForegroundColor Red
    exit 1
}

Write-Host "`n  [OK] All configuration checks passed.`n" -ForegroundColor Green

# ================================================================
# Step 5: Firebase Console Instructions
# ================================================================
Write-Host "[5/6] Firebase Console - verify these are done:" -ForegroundColor Yellow
Write-Host "  +--------------------------------------------------------------------+" -ForegroundColor White
Write-Host "  | 1. Go to https://console.firebase.google.com                       |" -ForegroundColor White
Write-Host "  |                                                                    |" -ForegroundColor White
Write-Host "  | 2. Select your project                                             |" -ForegroundColor White
Write-Host "  |                                                                    |" -ForegroundColor White
Write-Host "  | 3. Authentication -> Sign-in method -> Google -> Enable (must be ON)|" -ForegroundColor White
Write-Host "  |                                                                    |" -ForegroundColor White
Write-Host "  | 4. Project Settings -> General -> Your apps -> Android             |" -ForegroundColor White
Write-Host "  |    -> Verify package name: $expectedPackage        |" -ForegroundColor White
Write-Host "  |    -> Verify SHA fingerprints are added                             |" -ForegroundColor White
Write-Host "  |                                                                    |" -ForegroundColor White
Write-Host "  | 5. Project Settings -> Service accounts -> check Firebase Admin SDK|" -ForegroundColor White
Write-Host "  +--------------------------------------------------------------------+" -ForegroundColor White
Write-Host ""
Write-Host "  REMINDER: Google Sign-In must be explicitly ENABLED (it's off by default)." -ForegroundColor Yellow
Write-Host "  If you get 'disabled' errors later, this is why.`n" -ForegroundColor Yellow

# ================================================================
# Step 6: Build instructions
# ================================================================
Write-Host "[6/6] Ready to build!" -ForegroundColor Yellow
Write-Host "  +---------------------------------------------+" -ForegroundColor White
Write-Host "  | flutter clean                                |" -ForegroundColor Gray
Write-Host "  | flutter pub get                              |" -ForegroundColor Gray
Write-Host "  | flutter build apk --release                  |" -ForegroundColor Gray
Write-Host "  +---------------------------------------------+" -ForegroundColor White
Write-Host ""
Write-Host "  Start the backend (if not already running):" -ForegroundColor Gray
Write-Host "    cd backend; npm start" -ForegroundColor Gray

Write-Host "`n=== Setup validation complete. Configuration is valid. ===" -ForegroundColor Green
