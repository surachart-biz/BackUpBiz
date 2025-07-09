# Create Migration Script for Windows PowerShell
# Usage: .\scripts\create-migration.ps1 -MigrationName "migration_name" -Description "Description of migration"

param(
    [Parameter(Mandatory=$true)]
    [string]$MigrationName,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$Author = $env:USERNAME
)

# Configuration
$MigrationsDir = ".\Migrations"
$TemplateFile = "$MigrationsDir\TEMPLATE_migration.sql"
$RollbackTemplate = "$MigrationsDir\TEMPLATE_rollback.sql"
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# Check if Migrations directory exists
if (-not (Test-Path $MigrationsDir)) {
    Write-Host "❌ Migrations directory not found: $MigrationsDir" -ForegroundColor Red
    exit 1
}

# Check if template exists
if (-not (Test-Path $TemplateFile)) {
    Write-Host "❌ Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}

# Get next migration number
$LastMigration = Get-ChildItem "$MigrationsDir\[0-9][0-9][0-9]_*.sql" | Sort-Object Name | Select-Object -Last 1
if ($null -eq $LastMigration) {
    $NextNumber = "001"
} else {
    $LastNumber = [int]($LastMigration.BaseName.Split('_')[0])
    $NextNumber = "{0:D3}" -f ($LastNumber + 1)
}

# Create migration filename
$MigrationFile = "$MigrationsDir\${NextNumber}_${MigrationName}.sql"
$RollbackFile = "$MigrationsDir\${NextNumber}_${MigrationName}_rollback.sql"

# Check if migration already exists
if (Test-Path $MigrationFile) {
    Write-Host "❌ Migration file already exists: $MigrationFile" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Creating new migration..." -ForegroundColor Blue
Write-Host "Migration Number: $NextNumber" -ForegroundColor Yellow
Write-Host "Migration Name: $MigrationName" -ForegroundColor Yellow
Write-Host "Description: $Description" -ForegroundColor Yellow
Write-Host "Author: $Author" -ForegroundColor Yellow
Write-Host "Date: $CurrentDate" -ForegroundColor Yellow
Write-Host ""

# Create migration file from template
Copy-Item $TemplateFile $MigrationFile

# Replace placeholders in migration file
$content = Get-Content $MigrationFile -Raw
$content = $content -replace "XXX_migration_name", "${NextNumber}_${MigrationName}"
$content = $content -replace "Brief description of what this migration does", $Description
$content = $content -replace "YYYY-MM-DD", $CurrentDate
$content = $content -replace "Your Name", $Author
Set-Content $MigrationFile $content

# Create rollback file if template exists
if (Test-Path $RollbackTemplate) {
    Copy-Item $RollbackTemplate $RollbackFile
    $rollbackContent = Get-Content $RollbackFile -Raw
    $rollbackContent = $rollbackContent -replace "XXX_migration_name", "${NextNumber}_${MigrationName}"
    $rollbackContent = $rollbackContent -replace "YYYY-MM-DD", $CurrentDate
    $rollbackContent = $rollbackContent -replace "Your Name", $Author
    Set-Content $RollbackFile $rollbackContent
}

Write-Host "✅ Migration files created successfully!" -ForegroundColor Green
Write-Host "📄 Migration: $MigrationFile" -ForegroundColor Green
if (Test-Path $RollbackFile) {
    Write-Host "📄 Rollback: $RollbackFile" -ForegroundColor Green
}
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit the migration file: $MigrationFile" -ForegroundColor Yellow
Write-Host "2. Add your SQL code between the marked sections" -ForegroundColor Yellow
Write-Host "3. Test the migration locally" -ForegroundColor Yellow
Write-Host "4. Commit and push to trigger CI/CD" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 To test locally:" -ForegroundColor Blue
Write-Host "psql -h localhost -U bizconnect_user -d bizconnect -f `"$MigrationFile`"" -ForegroundColor Blue
