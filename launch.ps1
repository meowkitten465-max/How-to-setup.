# file: launch.ps1
# Uses "python -m pip" so deps always install to the exact Python running the script

$deps = @("websockets", "mss", "opencv-python-headless", "numpy")

Write-Host "[setup] installing deps to active Python..." -ForegroundColor Cyan
foreach ($pkg in $deps) {
    $check = python -m pip show $pkg 2>$null
    if (-not $check) {
        Write-Host "  installing $pkg..." -ForegroundColor Yellow
        python -m pip install $pkg --quiet
    } else {
        Write-Host "  $pkg ok" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "[launch] starting screen_server.py..." -ForegroundColor Cyan
Write-Host "[launch] ws://localhost:8080 — waiting for Lua client" -ForegroundColor Green
Write-Host ""

Set-Location $PSScriptRoot
python screen_server.py
