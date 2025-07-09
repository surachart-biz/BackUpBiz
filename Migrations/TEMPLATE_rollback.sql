-- Rollback: XXX_migration_name_rollback.sql
-- Description: Rollback for XXX_migration_name.sql
-- Date: YYYY-MM-DD
-- Author: Your Name
-- WARNING: This will undo changes made by XXX_migration_name.sql

DO $$
BEGIN
    -- Check if original migration was applied
    IF EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = 'XXX_migration_name'
    ) THEN
        
        RAISE NOTICE 'Rolling back migration: XXX_migration_name';
        
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
        DELETE FROM migration_history WHERE migration_name = 'XXX_migration_name';
        
        RAISE NOTICE 'Migration XXX_migration_name rolled back successfully';
        
    ELSE
        RAISE NOTICE 'Migration XXX_migration_name was not applied, nothing to rollback';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Rollback of XXX_migration_name failed: %', SQLERRM;
END $$;

-- Verification queries
-- SELECT COUNT(*) as "Remaining_Records" FROM "YourTableName";
-- SELECT 'Rollback XXX_migration_name verification completed' as "Status";
