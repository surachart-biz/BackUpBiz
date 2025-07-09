# BizConnect Database Setup Script for Windows
# This script sets up PostgreSQL database for BizConnect application

param(
    [string]$PostgreSQLPath = "C:\Program Files\PostgreSQL\15\bin",
    [string]$DatabaseHost = "localhost",
    [string]$Port = "5432",
    [string]$AdminUser = "postgres"
)

Write-Host "Setting up BizConnect PostgreSQL Database..." -ForegroundColor Green

# Check if PostgreSQL is installed
$psqlPath = Join-Path $PostgreSQLPath "psql.exe"
if (-not (Test-Path $psqlPath)) {
    Write-Host "ERROR: PostgreSQL not found at $PostgreSQLPath" -ForegroundColor Red
    Write-Host "Please install PostgreSQL or update the PostgreSQLPath parameter" -ForegroundColor Yellow
    Write-Host "Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Cyan
    exit 1
}

Write-Host "SUCCESS: PostgreSQL found at $psqlPath" -ForegroundColor Green

# Check if setup files exist
if (-not (Test-Path "setup-database.sql")) {
    Write-Host "ERROR: setup-database.sql not found in current directory" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "database_schema.sql")) {
    Write-Host "ERROR: database_schema.sql not found in current directory" -ForegroundColor Red
    exit 1
}

Write-Host "SUCCESS: Database setup files found" -ForegroundColor Green

# Prompt for admin password
$adminPassword = Read-Host "Enter PostgreSQL admin password for user '$AdminUser'" -AsSecureString
$adminPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword))

Write-Host "Creating database and user..." -ForegroundColor Yellow

# Set environment variable for password
$env:PGPASSWORD = $adminPasswordText

try {
    # Run the setup script
    & $psqlPath -h $DatabaseHost -p $Port -U $AdminUser -d postgres -f "setup-database.sql"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Database setup completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Database Connection Details:" -ForegroundColor Cyan
        Write-Host "  Host: $DatabaseHost" -ForegroundColor White
        Write-Host "  Port: $Port" -ForegroundColor White
        Write-Host "  Database: bizconnect" -ForegroundColor White
        Write-Host "  Username: bizconnect_user" -ForegroundColor White
        Write-Host "  Password: BizConnect2025!" -ForegroundColor White
        Write-Host ""
        Write-Host "Default Login Credentials:" -ForegroundColor Cyan
        Write-Host "  Username: admin" -ForegroundColor White
        Write-Host "  Password: Admin123!" -ForegroundColor White
        Write-Host ""
        Write-Host "  Username: testuser" -ForegroundColor White
        Write-Host "  Password: Admin123!" -ForegroundColor White
        Write-Host ""
        Write-Host "Next: Update appsettings.Development.json with the connection string" -ForegroundColor Yellow
    } else {
        Write-Host "ERROR: Database setup failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Error running database setup: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Clear the password from environment
    $env:PGPASSWORD = $null
}

Write-Host "SUCCESS: Database setup complete! You can now configure the connection string." -ForegroundColor Green
