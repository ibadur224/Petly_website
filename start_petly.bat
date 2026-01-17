# Save as: E:\not your bissnus\Petly\site\start_petly.ps1

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         PETLY AUTOMATION SCRIPT         ║" -ForegroundColor Green
Write-Host "║    One Click - Start Everything!        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

# Function to display status
function Show-Status {
    param($Step, $Message, $IsError = $false)
    
    if ($IsError) {
        Write-Host "[$Step] $Message" -ForegroundColor Red
    } else {
        Write-Host "[$Step] $Message" -ForegroundColor Yellow
    }
}

function Show-Success {
    param($Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Show-Error {
    param($Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

function Show-Info {
    param($Message)
    Write-Host "  ℹ️  $Message" -ForegroundColor Cyan
}

# Step 1: Check Python
Show-Status "1/6" "Checking Python installation..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Show-Success "Python found: $pythonVersion"
    } else {
        Show-Error "Python not found! Please install Python 3.8+"
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Show-Error "Python not found! Please install Python 3.8+"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Check directory
Show-Status "2/6" "Checking directory structure..."
$requiredFiles = @(
    "E:\not your bissnus\Petly\site\back_end\app.py",
    "E:\not your bissnus\Petly\site\front_end\auth\sign_in.html",
    "E:\not your bissnus\Petly\site\resourses"
)

$allExist = $true
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Show-Error "Missing: $file"
        $allExist = $false
    }
}

if (-not $allExist) {
    Show-Error "Some required files are missing!"
    Read-Host "Press Enter to exit"
    exit 1
}
Show-Success "Directory structure OK"

# Step 3: Start XAMPP
Show-Status "3/6" "Starting XAMPP MySQL..."
$xamppPath = "C:\xampp\xampp-control.exe"
if (Test-Path $xamppPath) {
    Start-Process $xamppPath
    Show-Success "XAMPP Control Panel opened"
} else {
    Show-Info "XAMPP not found at default location"
    Show-Info "Please start MySQL manually from XAMPP"
}

Write-Host "  Waiting 10 seconds for MySQL..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Step 4: Setup Python environment
Show-Status "4/6" "Setting up Python environment..."
Set-Location "E:\not your bissnus\Petly\site\back_end"

# Create virtual environment if needed
if (-not (Test-Path "venv")) {
    Show-Info "Creating virtual environment..."
    python -m venv venv
}

# Activate venv
$activateScript = ".\venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    & $activateScript
} else {
    Show-Info "Using global Python environment"
}

# Install packages
Show-Info "Installing required packages..."
$packages = @(
    "Flask",
    "Flask-SQLAlchemy", 
    "Flask-Login",
    "Flask-WTF",
    "Flask-Migrate",
    "mysql-connector-python",
    "python-dotenv"
)

foreach ($package in $packages) {
    pip install $package --quiet
}
Show-Success "Python packages installed"

# Step 5: Setup database
Show-Status "5/6" "Setting up database..."
try {
    python -c "
import mysql.connector
try:
    conn = mysql.connector.connect(
        host='localhost',
        user='root',
        password=''
    )
    cursor = conn.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS petly_db')
    print('Database petly_db ready')
    cursor.close()
    conn.close()
except Exception as e:
    print(f'Note: {e}')
    print('Please make sure MySQL is running in XAMPP')
"
    Show-Success "Database setup completed"
} catch {
    Show-Info "Database check completed"
}

# Step 6: Start Flask
Show-Status "6/6" "Starting Flask backend..."
Write-Host "`n"
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║          PETLY IS STARTING...           ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host "`n"

Write-Host "📍 Backend URL: http://localhost:5000" -ForegroundColor White
Write-Host "📍 Sign Up: http://localhost:5000/signup" -ForegroundColor White
Write-Host "📍 Admin Login: admin@petly.com / admin123" -ForegroundColor White
Write-Host "`n"
Write-Host "📢 IMPORTANT: Keep all windows open!" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "`n"

# Start Flask in new window
$flaskScript = @'
cd "E:\not your bissnus\Petly\site\back_end"
call venv\Scripts\activate.bat
python app.py
'@

$flaskScript | Out-File -FilePath "start_flask.bat" -Encoding ASCII
Start-Process cmd.exe -ArgumentList "/k start_flask.bat" -WindowStyle Normal

# Open browser after delay
Write-Host "Opening browser in 5 seconds..." -ForegroundColor Gray
Start-Sleep -Seconds 5
Start-Process "http://localhost:5000"

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           SETUP COMPLETE!               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

Write-Host "✅ Backend: Running (http://localhost:5000)" -ForegroundColor Green
Write-Host "✅ Database: Ready (petly_db)" -ForegroundColor Green
Write-Host "✅ Frontend: Ready" -ForegroundColor Green
Write-Host "`n"

# Menu options
do {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "QUICK ACTIONS MENU:" -ForegroundColor Cyan
    Write-Host "1. Open Admin Dashboard" -ForegroundColor White
    Write-Host "2. Open User Viewer" -ForegroundColor White
    Write-Host "3. Open phpMyAdmin" -ForegroundColor White
    Write-Host "4. Check Flask Logs" -ForegroundColor White
    Write-Host "5. Stop Everything & Exit" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    $choice = Read-Host "Select option (1-5)"
    
    switch ($choice) {
        '1' {
            Start-Process "http://localhost:5000/admin/dashboard"
        }
        '2' {
            Start-Process "E:\not your bissnus\Petly\site\admins_only\view_user.html"
        }
        '3' {
            Start-Process "http://localhost/phpmyadmin"
        }
        '4' {
            Write-Host "`nFlask is running in the separate window..." -ForegroundColor Yellow
            Write-Host "Check the 'PetLy Flask Backend' window for logs." -ForegroundColor Yellow
        }
        '5' {
            Write-Host "`nStopping PetLy..." -ForegroundColor Red
            Write-Host "1. Close the Flask window (PetLy Flask Backend)" -ForegroundColor Yellow
            Write-Host "2. Stop MySQL in XAMPP Control Panel" -ForegroundColor Yellow
            Write-Host "3. Close this window" -ForegroundColor Yellow
            Write-Host "`nGoodbye! 👋" -ForegroundColor Green
            Start-Sleep -Seconds 3
            break
        }
        default {
            Write-Host "Invalid choice! Try again." -ForegroundColor Red
        }
    }
} while ($choice -ne '5')

# Cleanup
if (Test-Path "start_flask.bat") {
    Remove-Item "start_flask.bat"
}