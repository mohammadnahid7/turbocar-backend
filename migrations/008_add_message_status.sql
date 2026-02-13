-- Migration: Add message status tracking and unread count optimization
-- UP Migration

-- Add status column to messages (sent, delivered, seen)
ALTER TABLE messages ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'sent';

-- Add delivery and seen timestamps
ALTER TABLE messages ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMPTZ;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS seen_at TIMESTAMPTZ;

-- Add unread_count to conversation_participants for efficient tracking
ALTER TABLE conversation_participants ADD COLUMN IF NOT EXISTS unread_count INTEGER DEFAULT 0;

-- Backfill existing messages: set status based on is_read
UPDATE messages SET status = 'seen' WHERE is_read = true AND status = 'sent';

-- Initialize unread_count for existing participants
UPDATE conversation_participants cp
SET unread_count = (
    SELECT COUNT(*) 
    FROM messages m 
    WHERE m.conversation_id = cp.conversation_id 
      AND m.sender_id != cp.user_id 
      AND m.is_read = false
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_messages_status ON messages(status);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_status ON messages(conversation_id, status);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_unread ON conversation_participants(user_id, unread_count);

-- DOWN Migration (for rollback)
-- DROP INDEX IF EXISTS idx_conversation_participants_unread;
-- DROP INDEX IF EXISTS idx_messages_conversation_status;
-- DROP INDEX IF EXISTS idx_messages_status;
-- ALTER TABLE conversation_participants DROP COLUMN IF EXISTS unread_count;
-- ALTER TABLE messages DROP COLUMN IF EXISTS seen_at;
-- ALTER TABLE messages DROP COLUMN IF EXISTS delivered_at;
-- ALTER TABLE messages DROP COLUMN IF EXISTS status;
