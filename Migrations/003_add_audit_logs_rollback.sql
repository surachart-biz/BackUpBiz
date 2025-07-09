-- Rollback: 003_add_audit_logs_rollback.sql
-- Description: Rollback for 003_add_audit_logs.sql
-- Date: 2025-07-09
-- Author: System
-- WARNING: This will undo changes made by 003_add_audit_logs.sql

DO $$
BEGIN
    -- Check if original migration was applied
    IF EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = '003_add_audit_logs'
    ) THEN
        
        RAISE NOTICE 'Rolling back migration: 003_add_audit_logs';
        
        -- ========================================
        -- YOUR ROLLBACK CODE STARTS HERE
        -- ========================================
        -- NOTE: Write rollback operations in REVERSE order of the original migration
        
        -- Example: Remove foreign key constraints first
        -- ALTER TABLE "ChildTable" DROP CONSTRAINT IF EXISTS "FK_ChildTable_YourTableName";
        
        -- Example: Drop indexes
        DROP INDEX IF EXISTS "IX_YourTableName_Name";
        DROP INDEX IF EXISTS "IX_YourTableName_IsActive";
        
        -- Example: Remove data (BE CAREFUL!)
        -- DELETE FROM "YourTableName" WHERE "Name" IN ('Default Item 1', 'Default Item 2');
        
        -- Example: Drop table (BE VERY CAREFUL!)
        -- DROP TABLE IF EXISTS "YourTableName";
        
        -- Example: Revert data changes
        -- UPDATE "Users" SET "SomeField" = 'old_value' WHERE "SomeField" = 'new_value';
        
        -- ========================================
        -- YOUR ROLLBACK CODE ENDS HERE
        -- ========================================
        
        -- Remove migration record
        DELETE FROM migration_history WHERE migration_name = '003_add_audit_logs';
        
        RAISE NOTICE 'Migration 003_add_audit_logs rolled back successfully';
        
    ELSE
        RAISE NOTICE 'Migration 003_add_audit_logs was not applied, nothing to rollback';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Rollback of 003_add_audit_logs failed: %', SQLERRM;
END $$;

-- Verification queries
-- SELECT COUNT(*) as "Remaining_Records" FROM "YourTableName";
-- SELECT 'Rollback 003_add_audit_logs verification completed' as "Status";
