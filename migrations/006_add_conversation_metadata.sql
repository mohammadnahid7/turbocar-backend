-- Migration: Add metadata to conversations
-- UP Migration

ALTER TABLE conversations ADD COLUMN IF NOT EXISTS metadata JSONB;

-- DOWN Migration
-- ALTER TABLE conversations DROP COLUMN IF EXISTS metadata;
