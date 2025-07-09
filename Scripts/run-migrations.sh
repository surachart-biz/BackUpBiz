#!/bin/bash

# Auto Migration Script for BizConnect
# This script automatically applies all pending migrations

set -e  # Exit on any error

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-bizconnect}"
DB_USER="${DB_USER:-bizconnect_user}"
MIGRATIONS_DIR="./Migrations"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting BizConnect Database Migrations${NC}"
echo "Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "User: $DB_USER"
echo ""

# Check if Migrations directory exists
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo -e "${RED}❌ Migrations directory not found: $MIGRATIONS_DIR${NC}"
    exit 1
fi

# Check database connection
echo -e "${YELLOW}🔍 Testing database connection...${NC}"
if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to database${NC}"
    echo "Please check your database connection settings and ensure PGPASSWORD is set"
    exit 1
fi
echo -e "${GREEN}✅ Database connection successful${NC}"

# Create migration tracker table if it doesn't exist
echo -e "${YELLOW}📋 Setting up migration tracker...${NC}"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$MIGRATIONS_DIR/000_migration_tracker.sql" > /dev/null

# Get list of migration files (excluding tracker)
migration_files=$(find "$MIGRATIONS_DIR" -name "*.sql" -not -name "000_migration_tracker.sql" | sort)

if [ -z "$migration_files" ]; then
    echo -e "${YELLOW}ℹ️  No migration files found${NC}"
    exit 0
fi

echo -e "${YELLOW}📁 Found migration files:${NC}"
for file in $migration_files; do
    echo "  - $(basename "$file")"
done
echo ""

# Apply migrations
migration_count=0
for migration_file in $migration_files; do
    migration_name=$(basename "$migration_file" .sql)
    echo -e "${YELLOW}🔄 Processing: $migration_name${NC}"
    
    # Run the migration
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$migration_file"; then
        echo -e "${GREEN}✅ $migration_name completed${NC}"
        ((migration_count++))
    else
        echo -e "${RED}❌ $migration_name failed${NC}"
        exit 1
    fi
    echo ""
done

echo -e "${GREEN}🎉 All migrations completed successfully!${NC}"
echo -e "${GREEN}📊 Applied $migration_count migration(s)${NC}"

# Show migration history
echo -e "${YELLOW}📜 Migration History:${NC}"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
SELECT 
    migration_name,
    applied_at,
    description
FROM migration_history 
ORDER BY applied_at DESC 
LIMIT 10;
"
