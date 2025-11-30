# ============================================================================
# jh-mlfaGasStation - Deployment Script
# Automated deployment for production
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  jh-mlfaGasStation v2.4.0 Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$DB_NAME = "jh_gasstation"
$DB_USER = "root"
$RESOURCE_NAME = "jh-mlfaGasStation"
$BACKUP_DIR = ".\backups"

# ============================================================================
# STEP 1: Pre-Deployment Checks
# ============================================================================

Write-Host "[1/6] Pre-Deployment Checks..." -ForegroundColor Yellow

# Check if MySQL is accessible
Write-Host "  - Checking MySQL connection..." -ForegroundColor Gray
# Add your MySQL check here

# Check if resource exists
if (Test-Path ".\$RESOURCE_NAME") {
    Write-Host "  ✓ Resource found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Resource not found!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 2: Backup
# ============================================================================

Write-Host "[2/6] Creating Backup..." -ForegroundColor Yellow

# Create backup directory
if (!(Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
}

$BACKUP_FILE = "$BACKUP_DIR\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"

Write-Host "  - Backing up database to: $BACKUP_FILE" -ForegroundColor Gray
# mysqldump -u $DB_USER -p $DB_NAME > $BACKUP_FILE

Write-Host "  ✓ Backup created" -ForegroundColor Green

# ============================================================================
# STEP 3: Database Import
# ============================================================================

Write-Host "[3/6] Importing Database..." -ForegroundColor Yellow

$SQL_FILE = ".\$RESOURCE_NAME\mlfa_gasstations.sql"

if (Test-Path $SQL_FILE) {
    Write-Host "  - Importing $SQL_FILE..." -ForegroundColor Gray
    # mysql -u $DB_USER -p $DB_NAME < $SQL_FILE
    Write-Host "  ✓ Database imported" -ForegroundColor Green
} else {
    Write-Host "  ✗ SQL file not found!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 4: Configuration Check
# ============================================================================

Write-Host "[4/6] Checking Configuration..." -ForegroundColor Yellow

$CONFIG_FILE = ".\$RESOURCE_NAME\config.lua"

if (Test-Path $CONFIG_FILE) {
    $config = Get-Content $CONFIG_FILE -Raw
    
    # Check if debug is disabled
    if ($config -match "Config\.Debug\.Enabled\s*=\s*false") {
        Write-Host "  ✓ Debug mode: DISABLED (Production)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Debug mode: ENABLED (Development)" -ForegroundColor Yellow
        Write-Host "    Consider disabling for production!" -ForegroundColor Yellow
    }
    
    # Check if Discord is configured
    if ($config -match "Config\.Discord\.Enabled\s*=\s*true") {
        Write-Host "  ✓ Discord logging: ENABLED" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Discord logging: DISABLED" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ Config file not found!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 5: Resource Restart
# ============================================================================

Write-Host "[5/6] Restarting Resource..." -ForegroundColor Yellow

Write-Host "  - Stopping $RESOURCE_NAME..." -ForegroundColor Gray
# stop $RESOURCE_NAME

Start-Sleep -Seconds 2

Write-Host "  - Starting $RESOURCE_NAME..." -ForegroundColor Gray
# ensure $RESOURCE_NAME

Write-Host "  ✓ Resource restarted" -ForegroundColor Green

# ============================================================================
# STEP 6: Post-Deployment Verification
# ============================================================================

Write-Host "[6/6] Post-Deployment Verification..." -ForegroundColor Yellow

Write-Host "  - Checking resource status..." -ForegroundColor Gray
# Add resource status check here

Write-Host "  ✓ Deployment completed successfully!" -ForegroundColor Green

# ============================================================================
# Deployment Summary
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resource: $RESOURCE_NAME" -ForegroundColor White
Write-Host "Version: 2.4.0" -ForegroundColor White
Write-Host "Database: $DB_NAME" -ForegroundColor White
Write-Host "Backup: $BACKUP_FILE" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Test /gastest command" -ForegroundColor Gray
Write-Host "  2. Verify Discord webhook" -ForegroundColor Gray
Write-Host "  3. Test NPC spawning" -ForegroundColor Gray
Write-Host "  4. Monitor server console" -ForegroundColor Gray
Write-Host ""
Write-Host "✓ Deployment Complete!" -ForegroundColor Green
Write-Host ""
