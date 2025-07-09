-- Migration: 003_add_audit_logs.sql
-- Description: Add audit logging system for tracking user actions
-- Date: 2025-07-09
-- Author: System
-- Dependencies: List any migrations this depends on (optional)

DO $$
BEGIN
    -- Check if migration already applied
    IF NOT EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = '003_add_audit_logs'
    ) THEN
        
        RAISE NOTICE 'Applying migration: 003_add_audit_logs';
        
        -- ========================================
        -- YOUR MIGRATION CODE STARTS HERE
        -- ========================================
        
        -- Example: Create a new table
        CREATE TABLE IF NOT EXISTS "YourTableName" (
            "Id" SERIAL PRIMARY KEY,
            "Name" VARCHAR(100) NOT NULL,
            "Description" TEXT,
            "IsActive" BOOLEAN NOT NULL DEFAULT true,
            "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "UpdatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Example: Add indexes
        CREATE INDEX IF NOT EXISTS "IX_YourTableName_Name" ON "YourTableName"("Name");
        CREATE INDEX IF NOT EXISTS "IX_YourTableName_IsActive" ON "YourTableName"("IsActive");
        
        -- Example: Insert default data
        INSERT INTO "YourTableName" ("Name", "Description") VALUES
            ('Default Item 1', 'Description for item 1'),
            ('Default Item 2', 'Description for item 2')
        ON CONFLICT ("Name") DO NOTHING;
        
        -- Example: Add foreign key constraint
        -- ALTER TABLE "ChildTable" 
        -- ADD CONSTRAINT "FK_ChildTable_YourTableName" 
        -- FOREIGN KEY ("YourTableId") REFERENCES "YourTableName"("Id") ON DELETE CASCADE;
        
        -- Example: Update existing data
        -- UPDATE "Users" SET "SomeField" = 'new_value' WHERE "SomeCondition" = true;
        
        -- ========================================
        -- YOUR MIGRATION CODE ENDS HERE
        -- ========================================
        
        -- Record migration as applied
        INSERT INTO migration_history (migration_name, applied_at, description)
        VALUES (
            '003_add_audit_logs', 
            CURRENT_TIMESTAMP, 
            'Add audit logging system for tracking user actions'
        );
        
        RAISE NOTICE 'Migration 003_add_audit_logs applied successfully';
        
    ELSE
        RAISE NOTICE 'Migration 003_add_audit_logs already applied, skipping';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Migration 003_add_audit_logs failed: %', SQLERRM;
END $$;

-- Optional: Verification queries (these will run every time, even if migration is skipped)
-- SELECT COUNT(*) as "YourTableName_Count" FROM "YourTableName";
-- SELECT 'Migration 003_add_audit_logs verification completed' as "Status";
