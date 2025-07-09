#!/bin/bash

# BizConnect Deployment Script
# Usage: ./deploy.sh [environment] [action]
# Environment: production, uat
# Action: install, update, rollback

set -e

ENVIRONMENT=${1:-production}
ACTION=${2:-install}
PROJECT_NAME="bizconnect"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
}

# Validate environment
validate_environment() {
    if [[ "$ENVIRONMENT" != "production" && "$ENVIRONMENT" != "uat" ]]; then
        error "Invalid environment: $ENVIRONMENT. Use 'production' or 'uat'"
        exit 1
    fi
}

# Set environment-specific variables
set_environment_vars() {
    if [[ "$ENVIRONMENT" == "uat" ]]; then
        APP_DIR="/var/www/${PROJECT_NAME}-uat"
        SERVICE_NAME="${PROJECT_NAME}-uat"
        PORT="5001"
    else
        APP_DIR="/var/www/${PROJECT_NAME}"
        SERVICE_NAME="${PROJECT_NAME}"
        PORT="5000"
    fi
}

# Install prerequisites
install_prerequisites() {
    log "Installing prerequisites..."
    
    # Update package list
    sudo apt update
    
    # Install .NET 8 runtime
    if ! command -v dotnet &> /dev/null; then
        log "Installing .NET 8 runtime..."
        wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb
        sudo apt update
        sudo apt install -y aspnetcore-runtime-8.0
    fi
    
    # Install Nginx
    if ! command -v nginx &> /dev/null; then
        log "Installing Nginx..."
        sudo apt install -y nginx
    fi
    
    # Install PostgreSQL client
    if ! command -v psql &> /dev/null; then
        log "Installing PostgreSQL client..."
        sudo apt install -y postgresql-client
    fi
    
    success "Prerequisites installed successfully"
}

# Create application directory
create_app_directory() {
    log "Creating application directory: $APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo chown -R www-data:www-data "$APP_DIR"
    sudo chmod 755 "$APP_DIR"
}

# Install systemd service
install_service() {
    log "Installing systemd service..."
    
    if [[ "$ENVIRONMENT" == "uat" ]]; then
        sudo cp "$SCRIPT_DIR/${PROJECT_NAME}-uat.service" "/etc/systemd/system/"
    else
        sudo cp "$SCRIPT_DIR/${PROJECT_NAME}.service" "/etc/systemd/system/"
    fi
    
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    success "Service installed successfully"
}

# Configure Nginx
configure_nginx() {
    log "Configuring Nginx..."
    
    # Copy Nginx configuration
    sudo cp "$SCRIPT_DIR/nginx-${PROJECT_NAME}.conf" "/etc/nginx/sites-available/${PROJECT_NAME}"
    
    # Enable site
    sudo ln -sf "/etc/nginx/sites-available/${PROJECT_NAME}" "/etc/nginx/sites-enabled/"
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Reload Nginx
    sudo systemctl reload nginx
    
    success "Nginx configured successfully"
}

# Deploy application
deploy_application() {
    log "Deploying application..."
    
    # Stop service if running
    sudo systemctl stop "$SERVICE_NAME" || true
    
    # Create backup if directory exists
    if [[ -d "$APP_DIR" && "$(ls -A $APP_DIR)" ]]; then
        BACKUP_DIR="${APP_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
        log "Creating backup: $BACKUP_DIR"
        sudo cp -r "$APP_DIR" "$BACKUP_DIR"
    fi
    
    # Deploy files (this would be done by GitLab CI/CD in practice)
    log "Application files should be deployed by GitLab CI/CD pipeline"
    
    # Set permissions
    sudo chown -R www-data:www-data "$APP_DIR"
    sudo chmod +x "$APP_DIR/$PROJECT_NAME" || true
    
    # Start service
    sudo systemctl start "$SERVICE_NAME"
    
    # Check service status
    sleep 5
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        success "Application deployed and started successfully"
    else
        error "Application failed to start"
        sudo systemctl status "$SERVICE_NAME"
        exit 1
    fi
}

# Rollback to previous version
rollback() {
    log "Rolling back to previous version..."
    
    # Find latest backup
    LATEST_BACKUP=$(ls -td ${APP_DIR}-backup-* 2>/dev/null | head -1)
    
    if [[ -z "$LATEST_BACKUP" ]]; then
        error "No backup found for rollback"
        exit 1
    fi
    
    log "Rolling back to: $LATEST_BACKUP"
    
    # Stop service
    sudo systemctl stop "$SERVICE_NAME"
    
    # Replace current with backup
    sudo rm -rf "$APP_DIR"
    sudo mv "$LATEST_BACKUP" "$APP_DIR"
    
    # Start service
    sudo systemctl start "$SERVICE_NAME"
    
    success "Rollback completed successfully"
}

# Main execution
main() {
    log "Starting deployment script for $ENVIRONMENT environment"
    
    check_root
    validate_environment
    set_environment_vars
    
    case "$ACTION" in
        install)
            install_prerequisites
            create_app_directory
            install_service
            configure_nginx
            deploy_application
            ;;
        update)
            deploy_application
            ;;
        rollback)
            rollback
            ;;
        *)
            error "Invalid action: $ACTION. Use 'install', 'update', or 'rollback'"
            exit 1
            ;;
    esac
    
    success "Deployment script completed successfully"
}

# Run main function
main "$@"
