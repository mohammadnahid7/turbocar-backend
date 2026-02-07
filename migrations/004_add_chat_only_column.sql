-- Add chat_only column to cars table
ALTER TABLE cars ADD COLUMN IF NOT EXISTS chat_only BOOLEAN DEFAULT FALSE;
