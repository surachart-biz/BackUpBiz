-- Migration: 002_add_user_roles.sql
-- Description: Add user roles and permissions system
-- Date: 2025-01-09
-- Author: System

DO $$
BEGIN
    -- Check if migration already applied
    IF NOT EXISTS (
        SELECT 1 FROM migration_history 
        WHERE migration_name = '002_add_user_roles'
    ) THEN
        
        RAISE NOTICE 'Applying migration: 002_add_user_roles';
        
        -- Create Roles table
        CREATE TABLE IF NOT EXISTS "Roles" (
            "RoleId" SERIAL PRIMARY KEY,
            "RoleName" VARCHAR(50) NOT NULL UNIQUE,
            "Description" TEXT,
            "IsActive" BOOLEAN NOT NULL DEFAULT true,
            "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Create UserRoles junction table
        CREATE TABLE IF NOT EXISTS "UserRoles" (
            "UserRoleId" SERIAL PRIMARY KEY,
            "UserId" INTEGER NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
            "RoleId" INTEGER NOT NULL REFERENCES "Roles"("RoleId") ON DELETE CASCADE,
            "AssignedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            "AssignedBy" INTEGER REFERENCES "Users"("UserId"),
            UNIQUE("UserId", "RoleId")
        );
        
        -- Create indexes
        CREATE INDEX IF NOT EXISTS "IX_UserRoles_UserId" ON "UserRoles"("UserId");
        CREATE INDEX IF NOT EXISTS "IX_UserRoles_RoleId" ON "UserRoles"("RoleId");
        
        -- Insert default roles
        INSERT INTO "Roles" ("RoleName", "Description") VALUES
            ('Admin', 'System Administrator with full access'),
            ('User', 'Regular user with limited access'),
            ('Manager', 'Manager with elevated permissions')
        ON CONFLICT ("RoleName") DO NOTHING;
        
        -- Assign admin role to admin user
        INSERT INTO "UserRoles" ("UserId", "RoleId")
        SELECT u."UserId", r."RoleId"
        FROM "Users" u, "Roles" r
        WHERE u."Username" = 'admin' AND r."RoleName" = 'Admin'
        ON CONFLICT ("UserId", "RoleId") DO NOTHING;
        
        -- Record migration as applied
        INSERT INTO migration_history (migration_name, applied_at, description)
        VALUES (
            '002_add_user_roles', 
            CURRENT_TIMESTAMP, 
            'Add user roles and permissions system with default roles'
        );
        
        RAISE NOTICE 'Migration 002_add_user_roles applied successfully';
        
    ELSE
        RAISE NOTICE 'Migration 002_add_user_roles already applied, skipping';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Migration 002_add_user_roles failed: %', SQLERRM;
END $$;
