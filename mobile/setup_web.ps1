# setup_web.ps1

Write-Host "Step 1: Creating Web Directory..." -ForegroundColor Cyan
flutter create . --platforms web

Write-Host "Step 2: Downloading sqlite3.wasm (v2.9.4)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm" -OutFile "web/sqlite3.wasm"

Write-Host "Step 3: Patching Title to 'Wadeea'..." -ForegroundColor Cyan
$indexFile = "web/index.html"
if (Test-Path $indexFile) {
    $content = Get-Content $indexFile -Raw
    # Fix Title
    $content = $content.Replace("<title>mobile</title>", "<title>Wadeea</title>")
    # Fix Apple Meta Title
    $content = $content.Replace('content="mobile"', 'content="Wadeea"')
    Set-Content $indexFile -Value $content
}

Write-Host "Step 4: Patching Manifest Name..." -ForegroundColor Cyan
$manifestFile = "web/manifest.json"
if (Test-Path $manifestFile) {
    $content = Get-Content $manifestFile -Raw
    $content = $content.Replace('"mobile"', '"Wadeea"')
    Set-Content $manifestFile -Value $content
}

Write-Host "Step 5: Generating Web Icons..." -ForegroundColor Cyan
# Ensuring flutter_launcher_icons is run to generate web assets
dart run flutter_launcher_icons

Write-Host "SUCCESS: Web environment is ready!" -ForegroundColor Green
Write-Host "You can now run: flutter build web" -ForegroundColor Green
