-- ============================================
-- COMPLETE DATABASE SCHEMA SYNC MIGRATION
-- Date: 2026-02-08
-- Description: Idempotent migration to add ALL missing columns
--              Safe to run multiple times
-- ============================================

BEGIN;

-- ============================================
-- 1. USERS TABLE - Missing columns
-- ============================================

-- Add gender column (from models/user.go)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'users' 
        AND column_name = 'gender'
    ) THEN
        ALTER TABLE users ADD COLUMN gender VARCHAR(20);
        RAISE NOTICE 'Added users.gender column';
    ELSE
        RAISE NOTICE 'Column users.gender already exists, skipping';
    END IF;
END $$;

-- Add dob (date of birth) column (from models/user.go)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'users' 
        AND column_name = 'dob'
    ) THEN
        ALTER TABLE users ADD COLUMN dob DATE;
        RAISE NOTICE 'Added users.dob column';
    ELSE
        RAISE NOTICE 'Column users.dob already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 2. CARS TABLE - Missing columns
-- ============================================

-- Add chat_only column (from listing/models.go)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'cars' 
        AND column_name = 'chat_only'
    ) THEN
        ALTER TABLE cars ADD COLUMN chat_only BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Added cars.chat_only column';
    ELSE
        RAISE NOTICE 'Column cars.chat_only already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 3. CONVERSATIONS TABLE - Missing columns
-- ============================================

-- Add metadata column (JSONB for flexible data)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'metadata'
    ) THEN
        ALTER TABLE conversations ADD COLUMN metadata JSONB DEFAULT '{}';
        RAISE NOTICE 'Added conversations.metadata column';
    ELSE
        RAISE NOTICE 'Column conversations.metadata already exists, skipping';
    END IF;
END $$;

-- Add car_id column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'car_id'
    ) THEN
        ALTER TABLE conversations ADD COLUMN car_id UUID;
        RAISE NOTICE 'Added conversations.car_id column';
    ELSE
        RAISE NOTICE 'Column conversations.car_id already exists, skipping';
    END IF;
END $$;

-- Add car_title column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'car_title'
    ) THEN
        ALTER TABLE conversations ADD COLUMN car_title VARCHAR(255);
        RAISE NOTICE 'Added conversations.car_title column';
    ELSE
        RAISE NOTICE 'Column conversations.car_title already exists, skipping';
    END IF;
END $$;

-- Add car_seller_id column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'car_seller_id'
    ) THEN
        ALTER TABLE conversations ADD COLUMN car_seller_id UUID;
        RAISE NOTICE 'Added conversations.car_seller_id column';
    ELSE
        RAISE NOTICE 'Column conversations.car_seller_id already exists, skipping';
    END IF;
END $$;

-- Add last_message_at column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'last_message_at'
    ) THEN
        ALTER TABLE conversations ADD COLUMN last_message_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Added conversations.last_message_at column';
    ELSE
        RAISE NOTICE 'Column conversations.last_message_at already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 4. MESSAGES TABLE - Missing columns
-- ============================================

-- Add status column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'messages' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE messages ADD COLUMN status VARCHAR(20) DEFAULT 'sent';
        RAISE NOTICE 'Added messages.status column';
    ELSE
        RAISE NOTICE 'Column messages.status already exists, skipping';
    END IF;
END $$;

-- Add delivered_at column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'messages' 
        AND column_name = 'delivered_at'
    ) THEN
        ALTER TABLE messages ADD COLUMN delivered_at TIMESTAMPTZ;
        RAISE NOTICE 'Added messages.delivered_at column';
    ELSE
        RAISE NOTICE 'Column messages.delivered_at already exists, skipping';
    END IF;
END $$;

-- Add seen_at column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'messages' 
        AND column_name = 'seen_at'
    ) THEN
        ALTER TABLE messages ADD COLUMN seen_at TIMESTAMPTZ;
        RAISE NOTICE 'Added messages.seen_at column';
    ELSE
        RAISE NOTICE 'Column messages.seen_at already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 5. CONVERSATION_PARTICIPANTS TABLE - Missing columns
-- ============================================

-- Add unread_count column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversation_participants' 
        AND column_name = 'unread_count'
    ) THEN
        ALTER TABLE conversation_participants ADD COLUMN unread_count INTEGER DEFAULT 0;
        RAISE NOTICE 'Added conversation_participants.unread_count column';
    ELSE
        RAISE NOTICE 'Column conversation_participants.unread_count already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 6. INDEXES (for performance)
-- ============================================

-- Conversations indexes
CREATE INDEX IF NOT EXISTS idx_conversations_car_id ON conversations(car_id);
CREATE INDEX IF NOT EXISTS idx_conversations_car_seller_id ON conversations(car_seller_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at DESC);

-- Messages indexes
CREATE INDEX IF NOT EXISTS idx_messages_status ON messages(status);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_status ON messages(conversation_id, status);

-- Conversation participants indexes
CREATE INDEX IF NOT EXISTS idx_conversation_participants_unread ON conversation_participants(user_id, unread_count);

-- ============================================
-- 7. DATA BACKFILL (for existing data)
-- ============================================

-- Backfill messages.status for existing messages
UPDATE messages SET status = 'seen' WHERE status IS NULL AND is_read = true;
UPDATE messages SET status = 'sent' WHERE status IS NULL;

-- Backfill conversation_participants.unread_count
UPDATE conversation_participants SET unread_count = 0 WHERE unread_count IS NULL;

-- Backfill conversations.last_message_at from messages
UPDATE conversations c
SET last_message_at = (
    SELECT MAX(m.created_at)
    FROM messages m
    WHERE m.conversation_id = c.id
)
WHERE last_message_at IS NULL;

COMMIT;

-- ============================================
-- VERIFICATION QUERIES (run manually to verify)
-- ============================================
/*
-- Check users table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check cars table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'cars' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check conversations table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'conversations' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check messages table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'messages' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check conversation_participants table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'conversation_participants' AND table_schema = 'public'
ORDER BY ordinal_position;
*/
