-- Migration Tracker Table
-- This table tracks which migrations have been applied
-- Run this first before any other migrations

CREATE TABLE IF NOT EXISTS migration_history (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    checksum VARCHAR(64) -- Optional: for integrity checking
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_migration_history_name ON migration_history(migration_name);

-- Insert initial migration record
INSERT INTO migration_history (migration_name, description)
VALUES ('000_migration_tracker', 'Create migration tracking table')
ON CONFLICT (migration_name) DO NOTHING;

SELECT 'Migration tracker table created successfully!' as status;
