-- Migration: Create chat and notification tables
-- UP Migration

-- Conversations table (chat rooms)
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversation participants (many-to-many between users and conversations)
CREATE TABLE IF NOT EXISTS conversation_participants (
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    last_read_message_id UUID,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, file
    media_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User devices table (FCM token storage)
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    fcm_token VARCHAR(512) NOT NULL,
    device_type VARCHAR(20) DEFAULT 'android', -- android, ios, web
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, fcm_token)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user_id ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON user_devices(user_id);

-- Trigger to update updated_at on conversations
DROP TRIGGER IF EXISTS update_conversations_updated_at ON conversations;
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update updated_at on user_devices
DROP TRIGGER IF EXISTS update_user_devices_updated_at ON user_devices;
CREATE TRIGGER update_user_devices_updated_at BEFORE UPDATE ON user_devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- DOWN Migration (for rollback)
-- DROP TRIGGER IF EXISTS update_user_devices_updated_at ON user_devices;
-- DROP TRIGGER IF EXISTS update_conversations_updated_at ON conversations;
-- DROP INDEX IF EXISTS idx_user_devices_user_id;
-- DROP INDEX IF EXISTS idx_conversation_participants_user_id;
-- DROP INDEX IF EXISTS idx_messages_sender_id;
-- DROP INDEX IF EXISTS idx_messages_created_at;
-- DROP INDEX IF EXISTS idx_messages_conversation_id;
-- DROP TABLE IF EXISTS user_devices;
-- DROP TABLE IF EXISTS messages;
-- DROP TABLE IF EXISTS conversation_participants;
-- DROP TABLE IF EXISTS conversations;
