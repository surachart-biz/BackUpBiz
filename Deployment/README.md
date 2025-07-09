# BizConnect Deployment Guide

This guide provides instructions for deploying the BizConnect ASP.NET Core MVC application to UAT and Production environments using GitLab CI/CD.

## Prerequisites

### Server Requirements
- Ubuntu 22.04 LTS or similar Linux distribution
- .NET 8.0 Runtime
- PostgreSQL 13+ database server
- Nginx web server
- SSL certificates for HTTPS

### GitLab CI/CD Variables

Configure the following variables in your GitLab project settings (Settings > CI/CD > Variables):

#### UAT Environment
- `UAT_SERVER_HOST`: UAT server hostname/IP
- `UAT_SERVER_USER`: SSH username for UAT server
- `UAT_SSH_PRIVATE_KEY`: SSH private key for UAT server access
- `UAT_DB_HOST`: PostgreSQL server hostname for UAT
- `UAT_DB_NAME`: Database name for UAT (e.g., bizconnect_uat)
- `UAT_DB_USER`: Database username for UAT
- `UAT_DB_PASSWORD`: Database password for UAT

#### Production Environment
- `PROD_SERVER_HOST`: Production server hostname/IP
- `PROD_SERVER_USER`: SSH username for production server
- `PROD_SSH_PRIVATE_KEY`: SSH private key for production server access
- `PROD_DB_HOST`: PostgreSQL server hostname for production
- `PROD_DB_NAME`: Database name for production (e.g., bizconnect)
- `PROD_DB_USER`: Database username for production
- `PROD_DB_PASSWORD`: Database password for production

## Initial Server Setup

### 1. Prepare the Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y wget curl gnupg2 software-properties-common

# Install .NET 8 Runtime
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y aspnetcore-runtime-8.0

# Install Nginx
sudo apt install -y nginx

# Install PostgreSQL client
sudo apt install -y postgresql-client
```

### 2. Create Application User and Directories

```bash
# Create application directories
sudo mkdir -p /var/www/bizconnect
sudo mkdir -p /var/www/bizconnect-uat

# Set ownership
sudo chown -R www-data:www-data /var/www/bizconnect
sudo chown -R www-data:www-data /var/www/bizconnect-uat
```

### 3. Configure Systemd Services

```bash
# Copy service files
sudo cp Deployment/bizconnect.service /etc/systemd/system/
sudo cp Deployment/bizconnect-uat.service /etc/systemd/system/

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl enable bizconnect
sudo systemctl enable bizconnect-uat
```

### 4. Configure Nginx

```bash
# Copy Nginx configuration
sudo cp Deployment/nginx-bizconnect.conf /etc/nginx/sites-available/bizconnect

# Enable the site
sudo ln -s /etc/nginx/sites-available/bizconnect /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Configure SSL Certificates

```bash
# Install Certbot for Let's Encrypt (recommended)
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificates
sudo certbot --nginx -d bizconnect.yourdomain.com
sudo certbot --nginx -d uat.bizconnect.yourdomain.com
```

### 6. Database Setup

```bash
# Connect to PostgreSQL and create databases
sudo -u postgres psql

-- Create databases
CREATE DATABASE bizconnect;
CREATE DATABASE bizconnect_uat;

-- Create users (replace with secure passwords)
CREATE USER bizconnect_user WITH PASSWORD 'secure_password_here';
CREATE USER bizconnect_uat_user WITH PASSWORD 'secure_uat_password_here';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE bizconnect TO bizconnect_user;
GRANT ALL PRIVILEGES ON DATABASE bizconnect_uat TO bizconnect_uat_user;

-- Exit PostgreSQL
\q
```

## Deployment Process

### Automatic Deployment via GitLab CI/CD

1. **UAT Deployment**: Push to `develop` branch and manually trigger UAT deployment
2. **Production Deployment**: Push to `main` branch and manually trigger production deployment

### Manual Deployment

Use the provided deployment script:

```bash
# Make script executable
chmod +x Deployment/deploy.sh

# Install (first time)
./Deployment/deploy.sh production install
./Deployment/deploy.sh uat install

# Update (subsequent deployments)
./Deployment/deploy.sh production update
./Deployment/deploy.sh uat update

# Rollback (if needed)
./Deployment/deploy.sh production rollback
./Deployment/deploy.sh uat rollback
```

## Database Migrations

Run Entity Framework migrations after deployment:

```bash
# Production
cd /var/www/bizconnect
sudo -u www-data dotnet ef database update --environment Production

# UAT
cd /var/www/bizconnect-uat
sudo -u www-data dotnet ef database update --environment UAT
```

## Monitoring and Maintenance

### Check Application Status

```bash
# Check service status
sudo systemctl status bizconnect
sudo systemctl status bizconnect-uat

# Check logs
sudo journalctl -u bizconnect -f
sudo journalctl -u bizconnect-uat -f

# Check Nginx logs
sudo tail -f /var/log/nginx/bizconnect_access.log
sudo tail -f /var/log/nginx/bizconnect_error.log
```

### Backup Strategy

```bash
# Database backup
pg_dump -h localhost -U bizconnect_user bizconnect > backup_$(date +%Y%m%d).sql

# Application backup (done automatically by deployment script)
sudo cp -r /var/www/bizconnect /var/www/bizconnect-backup-$(date +%Y%m%d-%H%M%S)
```

## Security Considerations

1. **Firewall Configuration**:
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Regular Updates**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **SSL Certificate Renewal**:
   ```bash
   sudo certbot renew --dry-run
   ```

## Troubleshooting

### Common Issues

1. **Application won't start**: Check service logs with `sudo journalctl -u bizconnect -f`
2. **Database connection issues**: Verify connection strings and database permissions
3. **Nginx errors**: Check Nginx configuration with `sudo nginx -t`
4. **SSL certificate issues**: Verify certificate paths and permissions

### Useful Commands

```bash
# Restart services
sudo systemctl restart bizconnect
sudo systemctl restart nginx

# Check port usage
sudo netstat -tlnp | grep :5000
sudo netstat -tlnp | grep :5001

# Test database connection
psql -h localhost -U bizconnect_user -d bizconnect
```

## Support

For deployment issues or questions, please contact the development team or create an issue in the GitLab repository.
