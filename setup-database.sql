-- BizConnect Database Setup Script
-- This script creates the database, user, and initial schema
-- Run this as a PostgreSQL superuser (e.g., postgres)

-- Create database
DROP DATABASE IF EXISTS bizconnect;
CREATE DATABASE bizconnect;

-- Create user for the application
DROP USER IF EXISTS bizconnect_user;
CREATE USER bizconnect_user WITH PASSWORD 'BizConnect2025!';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE bizconnect TO bizconnect_user;

-- Connect to the bizconnect database
\c bizconnect;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO bizconnect_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bizconnect_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bizconnect_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bizconnect_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO bizconnect_user;

-- Now run the main schema script
\i database_schema.sql

-- Verify the setup
SELECT 'Database setup completed successfully!' as status;
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
SELECT COUNT(*) as user_count FROM "Users";
