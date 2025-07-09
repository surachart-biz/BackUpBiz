-- BizConnect Database Schema
-- PostgreSQL Database with Pascal Case Naming Convention
-- Database Name: bizconnect

-- Create database (run this separately if needed)
-- CREATE DATABASE bizconnect;

-- Use the bizconnect database
-- \c bizconnect;

-- Create Users table for authentication
CREATE TABLE "Users" (
    "UserId" SERIAL PRIMARY KEY,
    "Username" VARCHAR(50) NOT NULL UNIQUE,
    "PasswordHash" VARCHAR(255) NOT NULL,
    "Email" VARCHAR(100),
    "FirstName" VARCHAR(50),
    "LastName" VARCHAR(50),
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "LastLoginAt" TIMESTAMP WITH TIME ZONE
);

-- Create index on Username for faster lookups
CREATE INDEX "IX_Users_Username" ON "Users" ("Username");
CREATE INDEX "IX_Users_Email" ON "Users" ("Email");
CREATE INDEX "IX_Users_IsActive" ON "Users" ("IsActive");

-- Create a function to update the UpdatedAt timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW."UpdatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update UpdatedAt
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON "Users" 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (password: Admin123!) and test user (password: Test123!)
-- Note: In production, this should be done through the application with proper password hashing
INSERT INTO "Users" ("Username", "PasswordHash", "Email", "FirstName", "LastName", "IsActive")
VALUES
    ('admin', '$2a$12$3dAYRdgSipBqJpI33vpxZe8kjTifZneFToMkEC3ubDAqmYMhbrBKu', 'admin@bizconnect.com', 'System', 'Administrator', true),
    ('testuser', '$2a$12$56qo/3I9QSPBOePO8etqn.jWHBTayTVz50wTk6J8qmhPRQr0jd2uq', 'test@bizconnect.com', 'Test', 'User', true);

-- Create UserSessions table for session management (optional, for enhanced security)
CREATE TABLE "UserSessions" (
    "SessionId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "UserId" INTEGER NOT NULL REFERENCES "Users"("UserId") ON DELETE CASCADE,
    "SessionToken" VARCHAR(255) NOT NULL UNIQUE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ExpiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "IpAddress" INET,
    "UserAgent" TEXT
);

-- Create indexes for UserSessions
CREATE INDEX "IX_UserSessions_UserId" ON "UserSessions" ("UserId");
CREATE INDEX "IX_UserSessions_SessionToken" ON "UserSessions" ("SessionToken");
CREATE INDEX "IX_UserSessions_ExpiresAt" ON "UserSessions" ("ExpiresAt");
CREATE INDEX "IX_UserSessions_IsActive" ON "UserSessions" ("IsActive");

-- Create trigger for UserSessions UpdatedAt (if we add UpdatedAt column later)
-- This is prepared for future enhancements

-- Grant permissions (adjust as needed for your environment)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bizconnect_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bizconnect_user;
