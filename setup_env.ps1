Param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $RootDir "toyota-vehicle-finder\backend"
$FrontendDir = Join-Path $RootDir "toyota-vehicle-finder\frontend"

Write-Host "🚗 Setting up Toyota Vehicle Finder environment..."

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is required but was not found on the PATH."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm is required but was not found on the PATH."
}

$venvPath = Join-Path $BackendDir ".venv"
$useVenv = $true
if (-not (Test-Path $venvPath)) {
    Write-Host "Creating Python virtual environment in $venvPath"
    try {
        python -m venv $venvPath
    } catch {
        Write-Warning "Could not create a virtual environment. Falling back to system Python."
        $useVenv = $false
    }
}

Write-Host "Installing backend dependencies..."
if ($useVenv -and (Test-Path (Join-Path $venvPath "Scripts\activate"))) {
    & "$venvPath\Scripts\python.exe" -m pip install --upgrade pip
    & "$venvPath\Scripts\pip.exe" install -r (Join-Path $BackendDir "requirements.txt")
} else {
    python -m pip install --upgrade pip
    python -m pip install -r (Join-Path $BackendDir "requirements.txt")
}

Write-Host "Installing frontend dependencies..."
Push-Location $FrontendDir
try {
    npm install
}
finally {
    Pop-Location
}

Write-Host "Writing backend environment file..."
@"
GEMINI_API_KEY=your_api_key_here
"@ | Set-Content -Encoding UTF8 (Join-Path $BackendDir ".env")

Write-Host "Writing frontend environment file..."
@"
NEXT_PUBLIC_API_URL=http://localhost:8000
"@ | Set-Content -Encoding UTF8 (Join-Path $FrontendDir ".env.local")

Write-Host "✅ Environment setup complete."
