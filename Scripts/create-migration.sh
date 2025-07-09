#!/bin/bash

# Create Migration Script
# Usage: ./Scripts/create-migration.sh "migration_name" "Description of migration"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MIGRATIONS_DIR="./Migrations"
TEMPLATE_FILE="$MIGRATIONS_DIR/TEMPLATE_migration.sql"
ROLLBACK_TEMPLATE="$MIGRATIONS_DIR/TEMPLATE_rollback.sql"

# Check if migration name is provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Migration name is required${NC}"
    echo -e "${YELLOW}Usage: $0 \"migration_name\" \"Description of migration\"${NC}"
    echo -e "${YELLOW}Example: $0 \"add_user_roles\" \"Add user roles and permissions system\"${NC}"
    exit 1
fi

# Check if description is provided
if [ -z "$2" ]; then
    echo -e "${RED}❌ Error: Migration description is required${NC}"
    echo -e "${YELLOW}Usage: $0 \"migration_name\" \"Description of migration\"${NC}"
    exit 1
fi

MIGRATION_NAME="$1"
MIGRATION_DESCRIPTION="$2"
CURRENT_DATE=$(date +%Y-%m-%d)
AUTHOR="${USER:-System}"

# Check if Migrations directory exists
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo -e "${RED}❌ Migrations directory not found: $MIGRATIONS_DIR${NC}"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}❌ Template file not found: $TEMPLATE_FILE${NC}"
    exit 1
fi

# Get next migration number
LAST_MIGRATION=$(find "$MIGRATIONS_DIR" -name "[0-9][0-9][0-9]_*.sql" | sort | tail -1)
if [ -z "$LAST_MIGRATION" ]; then
    NEXT_NUMBER="001"
else
    LAST_NUMBER=$(basename "$LAST_MIGRATION" | cut -d'_' -f1)
    NEXT_NUMBER=$(printf "%03d" $((10#$LAST_NUMBER + 1)))
fi

# Create migration filename
MIGRATION_FILE="$MIGRATIONS_DIR/${NEXT_NUMBER}_${MIGRATION_NAME}.sql"
ROLLBACK_FILE="$MIGRATIONS_DIR/${NEXT_NUMBER}_${MIGRATION_NAME}_rollback.sql"

# Check if migration already exists
if [ -f "$MIGRATION_FILE" ]; then
    echo -e "${RED}❌ Migration file already exists: $MIGRATION_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Creating new migration...${NC}"
echo -e "${YELLOW}Migration Number: $NEXT_NUMBER${NC}"
echo -e "${YELLOW}Migration Name: $MIGRATION_NAME${NC}"
echo -e "${YELLOW}Description: $MIGRATION_DESCRIPTION${NC}"
echo -e "${YELLOW}Author: $AUTHOR${NC}"
echo -e "${YELLOW}Date: $CURRENT_DATE${NC}"
echo ""

# Create migration file from template
cp "$TEMPLATE_FILE" "$MIGRATION_FILE"

# Replace placeholders in migration file
sed -i "s/XXX_migration_name/${NEXT_NUMBER}_${MIGRATION_NAME}/g" "$MIGRATION_FILE"
sed -i "s/Brief description of what this migration does/$MIGRATION_DESCRIPTION/g" "$MIGRATION_FILE"
sed -i "s/YYYY-MM-DD/$CURRENT_DATE/g" "$MIGRATION_FILE"
sed -i "s/Your Name/$AUTHOR/g" "$MIGRATION_FILE"

# Create rollback file if template exists
if [ -f "$ROLLBACK_TEMPLATE" ]; then
    cp "$ROLLBACK_TEMPLATE" "$ROLLBACK_FILE"
    sed -i "s/XXX_migration_name/${NEXT_NUMBER}_${MIGRATION_NAME}/g" "$ROLLBACK_FILE"
    sed -i "s/YYYY-MM-DD/$CURRENT_DATE/g" "$ROLLBACK_FILE"
    sed -i "s/Your Name/$AUTHOR/g" "$ROLLBACK_FILE"
fi

echo -e "${GREEN}✅ Migration files created successfully!${NC}"
echo -e "${GREEN}📄 Migration: $MIGRATION_FILE${NC}"
if [ -f "$ROLLBACK_FILE" ]; then
    echo -e "${GREEN}📄 Rollback: $ROLLBACK_FILE${NC}"
fi
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "${YELLOW}1. Edit the migration file: $MIGRATION_FILE${NC}"
echo -e "${YELLOW}2. Add your SQL code between the marked sections${NC}"
echo -e "${YELLOW}3. Test the migration locally${NC}"
echo -e "${YELLOW}4. Commit and push to trigger CI/CD${NC}"
echo ""
echo -e "${BLUE}💡 To test locally:${NC}"
echo -e "${BLUE}psql -h localhost -U bizconnect_user -d bizconnect -f \"$MIGRATION_FILE\"${NC}"
