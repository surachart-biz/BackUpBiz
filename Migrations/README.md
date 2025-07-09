# Database Migrations for BizConnect

## Database First Approach - SQL Migration Scripts

Since we use Database First approach, we manage schema changes using SQL scripts instead of EF Migrations.

## Migration Script Naming Convention

```
Migrations/
- ├── 001_initial_schema.sql          # Initial database schema
- ├── 002_update_password_hashes.sql  # Fix password hashes
- ├── 003_add_user_roles.sql          # Future: Add roles table
- ├── 004_add_audit_logs.sql          # Future: Add audit logging
- ├── migration_tracker.sql           # Track applied migrations
```

## Migration Script Template

Each migration script should follow this format:

```sql
-- Migration: 002_update_password_hashes.sql
-- Description: Update password hashes to use correct BCrypt format
-- Date: 2025-01-09
-- Author: System

-- Check if migration already applied
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = '002_update_password_hashes'
    ) THEN
        
        -- Your migration code here
        UPDATE "Users" SET "PasswordHash" = '$2a$12$3dAYRdgSipBqJpI33vpxZe8kjTifZneFToMkEC3ubDAqmYMhbrBKu' 
        WHERE "Username" = 'admin';
        
        UPDATE "Users" SET "PasswordHash" = '$2a$12$56qo/3I9QSPBOePO8etqn.jWHBTayTVz50wTk6J8qmhPRQr0jd2uq' 
        WHERE "Username" = 'testuser';
        
        -- Record migration as applied
        INSERT INTO migration_history (migration_name, applied_at, description)
        VALUES ('002_update_password_hashes', CURRENT_TIMESTAMP, 'Update password hashes to use correct BCrypt format');
        
        RAISE NOTICE 'Migration 002_update_password_hashes applied successfully';
    ELSE
        RAISE NOTICE 'Migration 002_update_password_hashes already applied, skipping';
    END IF;
END $$;
```

## Usage in CI/CD

In your GitLab CI/CD pipeline:

```yaml
migrate_database:
  stage: deploy
  script:
    - cd migrations
    - for file in *.sql; do
        echo "Applying migration: $file"
        psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$file"
      done
```

## Creating New Migrations

### Using the Script (Recommended)

**Linux/Mac:**
```bash
chmod +x Scripts/create-migration.sh
./Scripts/create-migration.sh "add_user_roles" "Add user roles and permissions system"
```

**Windows PowerShell:**
```powershell
.\Scripts\create-migration.ps1 -MigrationName "add_user_roles" -Description "Add user roles and permissions system"
```

### Manual Creation

1. Copy `TEMPLATE_migration.sql` to `XXX_your_migration_name.sql`
2. Replace all placeholders (XXX_migration_name, descriptions, etc.)
3. Add your SQL code between the marked sections

## Testing Migrations

### Test Single Migration
```bash
psql -h localhost -U bizconnect_user -d bizconnect -f Migrations/003_your_migration.sql
```

### Test All Migrations
```bash
# Linux/Mac
./Scripts/run-migrations.sh

# Windows
set PGPASSWORD=your_password
for %f in (migrations\*.sql) do psql -h localhost -U bizconnect_user -d bizconnect -f "%f"
```

## Manual Migration

To apply migrations manually:

```bash
cd migrations
psql -h localhost -U bizconnect_user -d bizconnect -f 002_update_password_hashes.sql
```
