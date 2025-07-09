-- Migration: 001_fix_password_hashes.sql
-- Description: Update password hashes to use correct BCrypt format
-- Date: 2025-01-09
-- Author: System

DO $$
BEGIN
    -- Check if migration already applied
    IF NOT EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = '001_fix_password_hashes'
    ) THEN
        
        RAISE NOTICE 'Applying migration: 001_fix_password_hashes';
        
        -- Update admin user password hash (password: Admin123!)
        UPDATE "Users" 
        SET "PasswordHash" = '$2a$12$3dAYRdgSipBqJpI33vpxZe8kjTifZneFToMkEC3ubDAqmYMhbrBKu' 
        WHERE "Username" = 'admin';
        
        -- Update testuser password hash (password: Test123!)
        UPDATE "Users" 
        SET "PasswordHash" = '$2a$12$56qo/3I9QSPBOePO8etqn.jWHBTayTVz50wTk6J8qmhPRQr0jd2uq' 
        WHERE "Username" = 'testuser';
        
        -- Record migration as applied
        INSERT INTO migration_history (migration_name, applied_at, description)
        VALUES (
            '001_fix_password_hashes', 
            CURRENT_TIMESTAMP, 
            'Update password hashes to use correct BCrypt format for admin and testuser'
        );
        
        RAISE NOTICE 'Migration 001_fix_password_hashes applied successfully';
        RAISE NOTICE 'Updated % user(s)', (SELECT COUNT(*) FROM "Users" WHERE "Username" IN ('admin', 'testuser'));
        
    ELSE
        RAISE NOTICE 'Migration 001_fix_password_hashes already applied, skipping';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Migration 001_fix_password_hashes failed: %', SQLERRM;
END $$;
