# BizConnect - ASP.NET Core MVC Application

BizConnect is a secure ASP.NET Core MVC web application with PostgreSQL database integration, designed for business connectivity and user management.

## Features

- **Authentication System**: Secure login/logout functionality with cookie-based authentication
- **PostgreSQL Integration**: Database-first approach with Entity Framework Core
- **SQL Migration System**: Database schema versioning with SQL migration scripts
- **Multi-Environment Support**: Configured for Development, Local, UAT, and Production environments
- **Responsive UI**: Modern Bootstrap-based interface with Font Awesome icons
- **Security**: BCrypt password hashing, HTTPS enforcement, and secure session management
- **CI/CD Ready**: GitLab CI/CD pipeline configuration for automated deployment
- **Local Development**: Secure local configuration with `appsettings.Local.json`

## Technology Stack

- **Framework**: ASP.NET Core 8.0 MVC
- **Database**: PostgreSQL with Entity Framework Core
- **Authentication**: Cookie-based authentication with BCrypt password hashing
- **Frontend**: Bootstrap 5, Font Awesome icons
- **Testing**: xUnit testing framework
- **Deployment**: GitLab CI/CD, Nginx reverse proxy, systemd services

## Prerequisites

- .NET 8.0 SDK
- PostgreSQL 13+
- Visual Studio 2022 or VS Code (optional)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/surachart-biz/BizConnect.git
cd BizConnect
```

### 2. Database Setup

1. Install PostgreSQL and create a database:
```sql
CREATE DATABASE bizconnect;
```

2. Create `appsettings.Local.json` for your local database credentials:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=bizconnect;Username=your_username;Password=your_password"
  }
}
```

**Note**: This file is ignored by Git and will override settings from other configuration files.

3. Run the database schema script:
```bash
psql -h localhost -U your_username -d bizconnect -f database_schema.sql
```

### 3. Run the Application

```bash
dotnet restore
dotnet build
dotnet run
```

The application will be available at `https://localhost:7037` or `http://localhost:5065`.

### 4. Default Login Credentials

- **Username**: `admin`
- **Password**: `Admin123!`

Or:

- **Username**: `testuser`
- **Password**: `Test123!`

## Project Structure

```
BizConnect/
├── Controllers/           # MVC Controllers
│   ├── AccountController.cs
│   └── HomeController.cs
├── Data/                 # Database Context
│   └── BizConnectDbContext.cs
├── Deployment/           # Deployment Configuration
│   ├── deploy.sh
│   ├── nginx-bizconnect.conf
│   ├── bizconnect.service
│   └── README.md
├── Migrations/           # Database Migration Scripts
│   ├── 000_migration_tracker.sql
│   ├── 001_fix_password_hashes.sql
│   ├── TEMPLATE_migration.sql
│   ├── TEMPLATE_rollback.sql
│   └── README.md
├── Models/               # Data Models and ViewModels
│   ├── User.cs
│   ├── UserSession.cs
│   └── ViewModels/
├── Scripts/              # Utility Scripts
│   ├── create-migration.sh
│   ├── create-migration.ps1
│   └── run-migrations.sh
├── Services/             # Business Logic Services
│   ├── IAuthenticationService.cs
│   ├── AuthenticationService.cs
│   ├── IUserService.cs
│   └── UserService.cs
├── Views/                # Razor Views
│   ├── Account/
│   ├── Home/
│   └── Shared/
├── database_schema.sql   # Database Schema
├── .gitlab-ci.yml       # CI/CD Pipeline
└── appsettings*.json    # Configuration Files
```

## Configuration

### Environment-Specific Settings

- **Development**: `appsettings.Development.json`
- **Local**: `appsettings.Local.json` (for local development, not committed to Git)
- **UAT**: `appsettings.UAT.json`
- **Production**: `appsettings.Production.json`

**Note**: For local development, create `appsettings.Local.json` with your actual database credentials. This file is ignored by Git for security.

### Key Configuration Sections

#### Connection Strings
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=bizconnect;Username=user;Password=pass"
  }
}
```

#### Authentication Settings
```json
{
  "Authentication": {
    "CookieName": "BizConnect.Auth",
    "LoginPath": "/Account/Login",
    "ExpireTimeSpan": "01:00:00",
    "RequireHttps": true
  }
}
```

## Database Schema

The application uses a PostgreSQL database with Pascal case naming convention:

- **Users**: User accounts and authentication information
- **UserSessions**: Session management (optional, for enhanced security)
- **migration_history**: Tracks applied database migrations

### Database Management

We use **Database First approach** with SQL Migration Scripts:

- **Initial Setup**: Use `database_schema.sql` for first-time database creation
- **Schema Changes**: Use migration scripts in `Migrations/` folder
- **Migration Tracking**: Automatic tracking of applied migrations

See `Migrations/README.md` for detailed migration documentation.

## Security Features

- **Password Hashing**: BCrypt with salt for secure password storage
- **Session Management**: Secure cookie-based authentication
- **HTTPS Enforcement**: Configurable HTTPS requirements
- **SQL Injection Protection**: Entity Framework Core parameterized queries
- **XSS Protection**: Razor view engine automatic encoding

## Development

### Adding New Features

1. Create models in the `Models/` directory
2. Add services in the `Services/` directory
3. Implement controllers in the `Controllers/` directory
4. Create views in the `Views/` directory
5. Create database migration if schema changes are needed:
   ```bash
   ./Scripts/create-migration.sh "feature_name" "Description of changes"
   ```
6. Test the migration locally before committing

### Running Tests

```bash
dotnet test
```

### Database Migrations

We use **Database First approach** with SQL Migration Scripts instead of EF Migrations.

```bash
# Create new migration (Linux/Mac)
chmod +x Scripts/create-migration.sh
./Scripts/create-migration.sh "migration_name" "Description of migration"

# Create new migration (Windows PowerShell)
.\Scripts\create-migration.ps1 -MigrationName "migration_name" -Description "Description"

# Apply migrations manually
psql -h localhost -U bizconnect_user -d bizconnect -f Migrations/XXX_migration_name.sql

# Run all pending migrations
./Scripts/run-migrations.sh
```

For detailed migration documentation, see `Migrations/README.md`.

## Deployment

### Using GitLab CI/CD

1. Configure GitLab CI/CD variables (see `Deployment/README.md`)
2. Push to `develop` branch for UAT deployment
3. Push to `main` branch for Production deployment
4. Manually trigger deployments in GitLab

### Manual Deployment

See the detailed deployment guide in `Deployment/README.md`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the deployment documentation in `Deployment/README.md`
