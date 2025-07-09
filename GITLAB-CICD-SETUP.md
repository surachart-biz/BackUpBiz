# 🚀 GitLab CI/CD Setup Guide for BizConnect

This guide provides step-by-step instructions for setting up GitLab CI/CD variables and configuring automated deployment for the BizConnect application.

## 📋 Required GitLab CI/CD Variables

Configure these variables in your GitLab project: **Settings > CI/CD > Variables**

### 🔧 UAT Environment Variables

| Variable Name | Type | Protected | Masked | Description | Example Value |
|---------------|------|-----------|--------|-------------|---------------|
| `UAT_SERVER_HOST` | Variable | ✅ | ❌ | UAT server hostname/IP | `uat-server.yourdomain.com` |
| `UAT_SERVER_USER` | Variable | ✅ | ❌ | SSH username for UAT server | `deploy` |
| `UAT_SSH_PRIVATE_KEY` | Variable | ✅ | ✅ | SSH private key for UAT access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `UAT_DB_HOST` | Variable | ✅ | ❌ | PostgreSQL server for UAT | `uat-db.yourdomain.com` |
| `UAT_DB_NAME` | Variable | ✅ | ❌ | Database name for UAT | `bizconnect_uat` |
| `UAT_DB_USER` | Variable | ✅ | ❌ | Database username for UAT | `bizconnect_uat_user` |
| `UAT_DB_PASSWORD` | Variable | ✅ | ✅ | Database password for UAT | `SecureUATPassword123!` |

### 🏭 Production Environment Variables

| Variable Name | Type | Protected | Masked | Description | Example Value |
|---------------|------|-----------|--------|-------------|---------------|
| `PROD_SERVER_HOST` | Variable | ✅ | ❌ | Production server hostname/IP | `prod-server.yourdomain.com` |
| `PROD_SERVER_USER` | Variable | ✅ | ❌ | SSH username for production | `deploy` |
| `PROD_SSH_PRIVATE_KEY` | Variable | ✅ | ✅ | SSH private key for production | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `PROD_DB_HOST` | Variable | ✅ | ❌ | PostgreSQL server for production | `prod-db.yourdomain.com` |
| `PROD_DB_NAME` | Variable | ✅ | ❌ | Database name for production | `bizconnect` |
| `PROD_DB_USER` | Variable | ✅ | ❌ | Database username for production | `bizconnect_user` |
| `PROD_DB_PASSWORD` | Variable | ✅ | ✅ | Database password for production | `SecureProdPassword123!` |

## 🔐 SSH Key Setup

### 1. Generate SSH Key Pair

On your local machine or CI/CD server:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "gitlab-ci@bizconnect" -f ~/.ssh/bizconnect_deploy

# This creates:
# ~/.ssh/bizconnect_deploy (private key)
# ~/.ssh/bizconnect_deploy.pub (public key)
```

### 2. Configure Server Access

On each target server (UAT and Production):

```bash
# Create deploy user
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG sudo deploy

# Set up SSH access
sudo mkdir -p /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh

# Copy public key to server
sudo nano /home/deploy/.ssh/authorized_keys
# Paste the content of bizconnect_deploy.pub

# Set permissions
sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh

# Configure sudo without password for deploy user
sudo visudo
# Add: deploy ALL=(ALL) NOPASSWD:ALL
```

### 3. Add Private Key to GitLab

1. Copy the private key content:
   ```bash
   cat ~/.ssh/bizconnect_deploy
   ```

2. In GitLab: **Settings > CI/CD > Variables**
3. Add variable:
   - **Key**: `UAT_SSH_PRIVATE_KEY` or `PROD_SSH_PRIVATE_KEY`
   - **Value**: Paste the entire private key content
   - **Type**: Variable
   - **Protected**: ✅ Yes
   - **Masked**: ✅ Yes

## 🗄️ Database Setup

### UAT Database

```sql
-- Connect as PostgreSQL superuser
CREATE DATABASE bizconnect_uat;
CREATE USER bizconnect_uat_user WITH PASSWORD 'SecureUATPassword123!';
GRANT ALL PRIVILEGES ON DATABASE bizconnect_uat TO bizconnect_uat_user;

-- Connect to bizconnect_uat database
\c bizconnect_uat;
GRANT ALL ON SCHEMA public TO bizconnect_uat_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bizconnect_uat_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO bizconnect_uat_user;
```

### Production Database

```sql
-- Connect as PostgreSQL superuser
CREATE DATABASE bizconnect;
CREATE USER bizconnect_user WITH PASSWORD 'SecureProdPassword123!';
GRANT ALL PRIVILEGES ON DATABASE bizconnect TO bizconnect_user;

-- Connect to bizconnect database
\c bizconnect;
GRANT ALL ON SCHEMA public TO bizconnect_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bizconnect_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO bizconnect_user;
```

## 🌐 Server Configuration

### Install Prerequisites

On both UAT and Production servers:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install .NET 8 Runtime
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y aspnetcore-runtime-8.0

# Install Nginx
sudo apt install -y nginx

# Install PostgreSQL client
sudo apt install -y postgresql-client

# Create application directories
sudo mkdir -p /var/www/bizconnect
sudo mkdir -p /var/www/bizconnect-uat
sudo chown -R www-data:www-data /var/www/bizconnect*
```

## 🔄 Deployment Process

### Branch Strategy

- **`develop` branch** → Triggers UAT deployment (manual)
- **`main` branch** → Triggers Production deployment (manual)

### Pipeline Stages

1. **Build**: Compiles and publishes the application
2. **Test**: Runs unit tests (if available)
3. **Deploy UAT**: Deploys to UAT environment (manual trigger)
4. **Deploy Production**: Deploys to Production environment (manual trigger)

### Manual Deployment Triggers

1. Push code to `develop` or `main` branch
2. Go to **CI/CD > Pipelines** in GitLab
3. Click the ▶️ play button next to the deployment job
4. Confirm the deployment

## 🔍 Verification Steps

### After Setting Up Variables

1. **Test SSH Connection**:
   ```bash
   ssh -i ~/.ssh/bizconnect_deploy deploy@your-server-host
   ```

2. **Test Database Connection**:
   ```bash
   psql -h your-db-host -U your-db-user -d your-db-name
   ```

3. **Verify GitLab Variables**:
   - Go to **Settings > CI/CD > Variables**
   - Ensure all variables are set and marked as protected/masked appropriately

### After First Deployment

1. **Check Application Status**:
   ```bash
   sudo systemctl status bizconnect
   sudo systemctl status bizconnect-uat
   ```

2. **Check Application Logs**:
   ```bash
   sudo journalctl -u bizconnect -f
   sudo journalctl -u bizconnect-uat -f
   ```

3. **Test Application Access**:
   - UAT: `https://uat.bizconnect.yourdomain.com`
   - Production: `https://bizconnect.yourdomain.com`

## 🚨 Security Best Practices

1. **Use strong passwords** for database users
2. **Rotate SSH keys** regularly
3. **Enable firewall** on servers:
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
4. **Use SSL certificates** (Let's Encrypt recommended)
5. **Regularly update** server packages
6. **Monitor logs** for suspicious activity

## 🆘 Troubleshooting

### Common Issues

1. **SSH Connection Failed**:
   - Verify SSH key is correctly formatted
   - Check server firewall settings
   - Ensure deploy user has proper permissions

2. **Database Connection Failed**:
   - Verify database credentials
   - Check PostgreSQL server accessibility
   - Ensure database user has proper permissions

3. **Deployment Failed**:
   - Check GitLab CI/CD logs
   - Verify all variables are set
   - Check server disk space and permissions

### Useful Commands

```bash
# Test GitLab CI/CD locally
gitlab-runner exec docker build

# Check server resources
df -h
free -m
systemctl status

# View deployment logs
tail -f /var/log/nginx/bizconnect_access.log
sudo journalctl -u bizconnect -f
```

## ✅ Checklist

Before first deployment, ensure:

- [ ] All GitLab CI/CD variables are configured
- [ ] SSH keys are generated and configured
- [ ] Servers are prepared with prerequisites
- [ ] Databases are created with proper users
- [ ] Nginx is configured (if using reverse proxy)
- [ ] SSL certificates are installed
- [ ] Firewall rules are configured
- [ ] DNS records point to servers

## 🎉 Ready for Deployment!

Once all variables are configured and servers are prepared, you can trigger deployments through GitLab CI/CD pipelines!
