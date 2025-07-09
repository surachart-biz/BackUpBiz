# 🚀 BizConnect Setup Guide

This guide will walk you through setting up the BizConnect application on your local development environment.

## Prerequisites

Before starting, ensure you have the following installed:

- ✅ **.NET 8.0 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- ✅ **PostgreSQL 13+** - [Download here](https://www.postgresql.org/download/)
- ✅ **Git** (if cloning from repository)

## Step 1: 🗄️ Set up PostgreSQL Database

### Option A: Automated Setup (Windows)

1. Open PowerShell as Administrator
2. Navigate to the project directory
3. Run the setup script:

```powershell
.\setup-database.ps1
```

The script will:
- Create the `bizconnect` database
- Create the `bizconnect_user` with proper permissions
- Run the database schema
- Insert default users

### Option B: Manual Setup

1. Open PostgreSQL command line (psql) as superuser:

```bash
psql -U postgres
```

2. Run the setup script:

```sql
\i setup-database.sql
```

### Verify Database Setup

Connect to verify the setup:

```bash
psql -h localhost -U bizconnect_user -d bizconnect
```

Check tables:
```sql
\dt
SELECT * FROM "Users";
```

## Step 2: 🔧 Configure Connection Strings

The connection strings are already configured for local development:

**appsettings.Development.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=bizconnect;Username=bizconnect_user;Password=BizConnect2025!"
  }
}
```

### Custom Configuration

If you need different settings, update the connection string in `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=YOUR_HOST;Database=YOUR_DB;Username=YOUR_USER;Password=YOUR_PASSWORD"
  }
}
```

## Step 3: 🏃‍♂️ Test Application Locally

### Build and Run

1. Open terminal in the project directory
2. Restore packages:

```bash
dotnet restore
```

3. Build the application:

```bash
dotnet build
```

4. Run the application:

```bash
dotnet run
```

### Access the Application

- **HTTPS**: https://localhost:5001
- **HTTP**: http://localhost:5000

The application will automatically redirect to the login page.

### Default Login Credentials

Use these credentials to test the application:

**Administrator Account:**
- Username: `admin`
- Password: `Admin123!`

**Test User Account:**
- Username: `testuser`
- Password: `Admin123!`

## Step 4: 🧪 Verify Functionality

### Test Login Process

1. Navigate to the login page
2. Enter credentials (admin/Admin123!)
3. Verify successful login and redirect to home page
4. Check user profile page
5. Test logout functionality

### Check Database Connection

1. Login successfully
2. Check PostgreSQL logs for connection activity
3. Verify user session is created

## Step 5: 🔍 Troubleshooting

### Common Issues

#### Database Connection Failed

**Error**: `Npgsql.NpgsqlException: Connection refused`

**Solutions**:
1. Verify PostgreSQL is running:
   ```bash
   # Windows
   net start postgresql-x64-16
   
   # Linux/Mac
   sudo systemctl start postgresql
   ```

2. Check connection string in appsettings.Development.json
3. Verify user permissions in PostgreSQL

#### Login Failed

**Error**: Invalid username or password

**Solutions**:
1. Verify users exist in database:
   ```sql
   SELECT "Username", "IsActive" FROM "Users";
   ```

2. Check password hashing (passwords should be BCrypt hashed)
3. Verify user is active (`IsActive = true`)

#### Build Errors

**Error**: Package restore failed

**Solutions**:
1. Clear NuGet cache:
   ```bash
   dotnet nuget locals all --clear
   ```

2. Restore packages:
   ```bash
   dotnet restore --force
   ```

### Useful Commands

```bash
# Check .NET version
dotnet --version

# Check PostgreSQL version
psql --version

# View application logs
dotnet run --verbosity detailed

# Reset database (if needed)
psql -U postgres -c "DROP DATABASE IF EXISTS bizconnect;"
.\setup-database.ps1
```

## Next Steps

Once the application is running locally:

1. ✅ **Explore the application** - Test all features
2. ✅ **Review the code** - Understand the architecture
3. ✅ **Set up GitLab CI/CD** - For deployment automation
4. ✅ **Configure production environment** - Using Deployment guides

## 📞 Support

If you encounter issues:

1. Check this troubleshooting guide
2. Review application logs
3. Check PostgreSQL logs
4. Create an issue in the repository

## 🎉 Success!

If you can login and navigate the application, you've successfully set up BizConnect! 

The application is now ready for development and testing.
