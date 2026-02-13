# DATABASE SCHEMA SYNC - MISSING COLUMNS FIX INSTRUCTIONS

## 🎯 OBJECTIVE

Fix the critical issue where backend code is querying database columns that don't exist. The solution involves:
1. **Analyze** all backend code to identify every column being queried/used
2. **Compare** with actual database schema to find missing columns
3. **Generate** SQL migration script that safely adds only missing columns
4. **Execute** migration and verify system works

---

## ⚠️ CRITICAL INSTRUCTIONS FOR ANTIGRAVITY

**YOU MUST:**
1. ✅ Analyze ALL backend code files (models, repositories, services, handlers)
2. ✅ Extract every column name referenced in code
3. ✅ Query actual database to get current schema
4. ✅ Identify gaps (columns in code but not in database)
5. ✅ Generate idempotent SQL migration (safe to run multiple times)
6. ✅ Test migration on database copy first
7. ✅ Document every change

**YOU MUST NOT:**
1. ❌ Assume column names without reading actual code
2. ❌ Drop any existing columns
3. ❌ Change existing column types without careful analysis
4. ❌ Run migrations on production without testing
5. ❌ Skip the analysis phase

**PRINCIPLE:** Migration must be **idempotent** - safe to run multiple times, adds only what's missing, skips what exists.

---

## 📋 PHASE 1: COMPREHENSIVE BACKEND CODE ANALYSIS

### Step 1.1: Locate All Backend Code Files

**Action:** Find every file that interacts with the database.

**What to find:**

1. **Model/Struct Definitions:**
   - Files defining database table structures
   - Look for: struct tags, ORM annotations (GORM tags in Go)
   - Typical locations: `/models`, `/domain`, `/entities`
   - File patterns: `*_model.go`, `models.go`, `entity.go`

2. **Repository/Database Layer:**
   - Files containing database queries
   - Look for: SQL queries, ORM query builders
   - Typical locations: `/repository`, `/data`, `/persistence`
   - File patterns: `*_repository.go`, `*_repo.go`, `repository.go`

3. **Service/Business Logic Layer:**
   - Files that might construct queries or use models
   - Typical locations: `/service`, `/business`, `/usecase`
   - File patterns: `*_service.go`, `service.go`

4. **Migration Files (if exist):**
   - Previous migration scripts
   - Typical locations: `/migrations`, `/db/migrations`
   - File patterns: `*.sql`, `*_migration.go`

**Document:** Create inventory of all files that touch database

---

### Step 1.2: Extract All Column References from Models

**Action:** Identify every database column defined in model structs.

**How to analyze:**

**For each model/struct file:**

1. **Find table structures:**
   - Look for struct definitions representing database tables
   - Example: `type Message struct`, `type Conversation struct`
   - Identify which structs map to which tables

2. **Extract column names from struct tags:**
   - GORM tags format: `gorm:"column:column_name"` or `json:"column_name"`
   - Some ORMs use field name as column name if not specified
   - Check for embedded structs (timestamps, soft delete fields)

3. **List all fields per model:**
   - Field name
   - Column name (from tag or derived from field name)
   - Data type
   - Nullable or NOT NULL
   - Default values
   - Foreign keys
   - Indexes

**Example extraction pattern:**

```
For Message struct:
- If field: Status string `gorm:"column:status;type:varchar(20)"`
  → Column: status, Type: varchar(20)
  
- If field: DeliveredAt *time.Time `gorm:"column:delivered_at"`
  → Column: delivered_at, Type: timestamptz, Nullable: true
  
- If field: Content string `json:"content"`
  → Column: content (if no gorm tag, use snake_case of field name)
```

**Document in:** `BACKEND_COLUMNS_ANALYSIS.md`

**Format:**
```markdown
## Messages Table (from code)

| Field Name | Column Name | Type | Nullable | Default | Notes |
|------------|-------------|------|----------|---------|-------|
| ID | id | uuid | NO | gen_random_uuid() | Primary key |
| ConversationID | conversation_id | uuid | NO | - | Foreign key |
| SenderID | sender_id | uuid | NO | - | - |
| Content | content | text | NO | - | - |
| Status | status | varchar(20) | NO | 'sent' | NEW FIELD |
| DeliveredAt | delivered_at | timestamptz | YES | NULL | NEW FIELD |
| SeenAt | seen_at | timestamptz | YES | NULL | NEW FIELD |
| CreatedAt | created_at | timestamptz | NO | now() | - |
| ... | ... | ... | ... | ... | ... |

## Conversations Table (from code)

| Field Name | Column Name | Type | Nullable | Default | Notes |
|------------|-------------|------|----------|---------|-------|
| ... | ... | ... | ... | ... | ... |

[Continue for all tables]
```

---

### Step 1.3: Extract Column References from Queries

**Action:** Find all columns referenced in SQL queries and ORM queries.

**How to analyze:**

**1. Search for raw SQL queries:**

Look for:
- `db.Raw(...)` or `db.Exec(...)`
- String literals containing SQL
- Query builders

**Extract:**
- All column names in SELECT clauses
- All column names in WHERE clauses
- All column names in ORDER BY, GROUP BY
- All column names in INSERT, UPDATE statements
- All column names in JOIN conditions

**Example:**
```sql
SELECT id, sender_id, content, status, delivered_at, seen_at
FROM messages
WHERE conversation_id = ? AND status = 'sent'

Columns referenced:
- id
- sender_id
- content
- status ← Check if exists
- delivered_at ← Check if exists
- seen_at ← Check if exists
- conversation_id
```

**2. Search for ORM query methods:**

Look for:
- `.Select("column1, column2, ...")`
- `.Where("column = ?", value)`
- `.Order("column DESC")`
- `.Preload("relation")`
- `.Joins("JOIN table ON condition")`

**Extract all column references from these queries.**

**3. Search for dynamic column references:**

Look for:
- Map access: `data["column_name"]`
- String formatting with column names
- Query builders constructing column lists

**Document:** Add to `BACKEND_COLUMNS_ANALYSIS.md`

```markdown
## Columns Referenced in Queries (messages table)

| Column Name | Query Location | Query Type |
|-------------|----------------|------------|
| status | repository.go:123 | SELECT |
| status | repository.go:145 | WHERE |
| delivered_at | repository.go:123 | SELECT |
| seen_at | repository.go:123 | SELECT |
| ... | ... | ... |
```

---

### Step 1.4: Analyze All Tables Used

**Action:** Create complete inventory of all tables and columns the backend expects.

**Process:**

For each model struct found:
1. Identify the table name (from struct or gorm tag)
2. List all columns expected by that model
3. List all columns referenced in queries for that table
4. Combine into master list

**Create master inventory:**

```markdown
## Complete Expected Schema (from backend code)

### Table: messages
- id (uuid, PRIMARY KEY)
- conversation_id (uuid, NOT NULL, FOREIGN KEY)
- sender_id (uuid, NOT NULL)
- content (text, NOT NULL)
- message_type (varchar, NOT NULL, DEFAULT 'text')
- status (varchar(20), NOT NULL, DEFAULT 'sent') ← VERIFY IN DB
- delivered_at (timestamptz, NULL) ← VERIFY IN DB
- seen_at (timestamptz, NULL) ← VERIFY IN DB
- created_at (timestamptz, NOT NULL, DEFAULT now())
- updated_at (timestamptz, NULL)
- deleted_at (timestamptz, NULL)
- attachment_url (text, NULL)
- attachment_type (varchar(50), NULL)
- reply_to_message_id (uuid, NULL)

### Table: conversations
- id (uuid, PRIMARY KEY)
- car_id (uuid, NOT NULL) ← VERIFY IN DB
- car_title (varchar(255), NOT NULL) ← VERIFY IN DB
- car_seller_id (uuid, NOT NULL) ← VERIFY IN DB
- status (varchar(20), NOT NULL, DEFAULT 'active')
- created_at (timestamptz, NOT NULL)
- updated_at (timestamptz, NOT NULL)
- last_message_at (timestamptz, NULL) ← VERIFY IN DB
- metadata (jsonb, DEFAULT '{}')

### Table: conversation_participants
- id (uuid, PRIMARY KEY)
- conversation_id (uuid, NOT NULL, FOREIGN KEY)
- user_id (uuid, NOT NULL)
- last_read_message_id (uuid, NULL)
- unread_count (integer, NOT NULL, DEFAULT 0) ← VERIFY IN DB
- role (varchar(20), NOT NULL)
- joined_at (timestamptz, NOT NULL)

[Continue for all tables]
```

**Mark columns that need verification** - these are candidates for missing columns.

---

## 📋 PHASE 2: ACTUAL DATABASE SCHEMA INSPECTION

### Step 2.1: Connect to Database and Extract Schema

**Action:** Get the actual current schema from the database.

**How to extract schema:**

**Method 1: Using database client/admin tool**
```
For PostgreSQL:
1. Connect to database using psql, pgAdmin, or DBeaver
2. For each table, run:
   \d+ table_name
   
   Or:
   SELECT column_name, data_type, is_nullable, column_default
   FROM information_schema.columns
   WHERE table_name = 'messages';

3. Export results
```

**Method 2: Using SQL query**
```sql
-- Get all columns for all tables in public schema
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

**Method 3: Using backend code to introspect**
```
If backend has database migration tool:
- Check migration status
- Look at applied migrations
- Some tools can dump current schema
```

**Document in:** `ACTUAL_DATABASE_SCHEMA.md`

```markdown
## Actual Database Schema (from database)

### Table: messages
- id (uuid, PRIMARY KEY)
- conversation_id (uuid, NOT NULL)
- sender_id (uuid, NOT NULL)
- content (text, NOT NULL)
- message_type (character varying, NOT NULL)
- created_at (timestamp with time zone, NOT NULL)
- updated_at (timestamp with time zone)
- deleted_at (timestamp with time zone)
- attachment_url (text)
- attachment_type (character varying)
- reply_to_message_id (uuid)

MISSING:
- status ← NOT IN DATABASE
- delivered_at ← NOT IN DATABASE
- seen_at ← NOT IN DATABASE

### Table: conversations
- id (uuid, PRIMARY KEY)
- created_at (timestamp with time zone, NOT NULL)
- updated_at (timestamp with time zone, NOT NULL)
- metadata (jsonb)

MISSING:
- car_id ← NOT IN DATABASE
- car_title ← NOT IN DATABASE
- car_seller_id ← NOT IN DATABASE
- status ← NOT IN DATABASE
- last_message_at ← NOT IN DATABASE

[Continue for all tables]
```

---

### Step 2.2: Compare Expected vs Actual Schema

**Action:** Identify every missing column.

**Comparison process:**

For each table:
1. List columns expected by backend (from Phase 1)
2. List columns that exist in database (from Phase 2.1)
3. Find the difference (expected but not existing)
4. Document data type, nullable, default for missing columns

**Create:** `MISSING_COLUMNS_REPORT.md`

```markdown
# Missing Columns Report

## Summary
- Total tables analyzed: X
- Total columns expected: Y
- Total columns missing: Z
- Tables needing updates: W

## Detailed Missing Columns

### Table: messages

| Column Name | Type | Nullable | Default | Source in Code |
|-------------|------|----------|---------|----------------|
| status | varchar(20) | NO | 'sent' | models/message.go:15 |
| delivered_at | timestamptz | YES | NULL | models/message.go:16 |
| seen_at | timestamptz | YES | NULL | models/message.go:17 |

**Impact:** Backend queries fail when trying to SELECT or UPDATE these columns.

**Found in queries:**
- repository/chat_repository.go:123 - SELECT status, delivered_at, seen_at
- repository/chat_repository.go:145 - WHERE status = ?
- repository/chat_repository.go:167 - UPDATE status = ?, delivered_at = ?

---

### Table: conversations

| Column Name | Type | Nullable | Default | Source in Code |
|-------------|------|----------|---------|----------------|
| car_id | uuid | NO | - | models/conversation.go:12 |
| car_title | varchar(255) | NO | - | models/conversation.go:13 |
| car_seller_id | uuid | NO | - | models/conversation.go:14 |
| status | varchar(20) | NO | 'active' | models/conversation.go:15 |
| last_message_at | timestamptz | YES | NULL | models/conversation.go:16 |

**Impact:** Critical - conversation queries fail, chat list cannot load.

**Found in queries:**
- repository/chat_repository.go:234 - SELECT car_title, car_id
- repository/chat_repository.go:256 - ORDER BY last_message_at DESC
- service/chat_service.go:89 - WHERE car_id = ? AND car_seller_id = ?

---

### Table: conversation_participants

| Column Name | Type | Nullable | Default | Source in Code |
|-------------|------|----------|---------|----------------|
| unread_count | integer | NO | 0 | models/participant.go:10 |

**Impact:** Unread count feature fails.

**Found in queries:**
- repository/chat_repository.go:345 - SELECT unread_count
- repository/chat_repository.go:367 - UPDATE unread_count = unread_count + 1

---

[Continue for all tables and missing columns]

## Priority Ranking

**Critical (system broken without these):**
1. conversations.car_id
2. conversations.car_title
3. conversations.car_seller_id
4. messages.status

**High (features broken):**
1. conversation_participants.unread_count
2. conversations.last_message_at
3. messages.delivered_at
4. messages.seen_at

**Medium (nice to have):**
[List others]
```

---

## 📋 PHASE 3: GENERATE IDEMPOTENT MIGRATION SCRIPT

### Step 3.1: Design Safe Migration Strategy

**Action:** Create SQL script that safely adds missing columns.

**Idempotent Migration Principles:**

1. **Check before adding:** Only add if column doesn't exist
2. **Use IF NOT EXISTS:** PostgreSQL syntax for safe operations
3. **Handle defaults carefully:** Don't break existing data
4. **Add indexes separately:** Can be created concurrently
5. **Make reversible:** Include down migration

**PostgreSQL Idempotent Patterns:**

**Pattern 1: Add column if not exists**
```sql
-- Check if column exists before adding
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'messages' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE messages ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'sent';
    END IF;
END $$;
```

**Pattern 2: Add multiple columns**
```sql
DO $$ 
BEGIN
    -- Add status column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'messages' AND column_name = 'status'
    ) THEN
        ALTER TABLE messages ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'sent';
    END IF;
    
    -- Add delivered_at column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'messages' AND column_name = 'delivered_at'
    ) THEN
        ALTER TABLE messages ADD COLUMN delivered_at TIMESTAMPTZ;
    END IF;
END $$;
```

**Pattern 3: Add index if not exists**
```sql
-- Create index only if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_messages_status 
ON messages(status);
```

---

### Step 3.2: Generate Complete Migration Script

**Action:** Create the full migration SQL file.

**Create:** `add_missing_columns_migration.sql`

**Script Structure:**

```sql
-- ============================================
-- Migration: Add Missing Columns
-- Date: [Current Date]
-- Description: Adds all columns that backend expects but are missing in database
-- Idempotent: Safe to run multiple times
-- ============================================

BEGIN;

-- ============================================
-- 1. MESSAGES TABLE
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
        ALTER TABLE messages ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'sent';
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
-- 2. CONVERSATIONS TABLE
-- ============================================

-- Add car_id column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'car_id'
    ) THEN
        -- Add as nullable first
        ALTER TABLE conversations ADD COLUMN car_id UUID;
        RAISE NOTICE 'Added conversations.car_id column (nullable for now)';
        
        -- TODO: Backfill car_id from metadata or related table
        -- After backfill, make NOT NULL:
        -- ALTER TABLE conversations ALTER COLUMN car_id SET NOT NULL;
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
        RAISE NOTICE 'Added conversations.car_title column (nullable for now)';
        
        -- TODO: Backfill from cars table
        -- After backfill, make NOT NULL:
        -- ALTER TABLE conversations ALTER COLUMN car_title SET NOT NULL;
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
        RAISE NOTICE 'Added conversations.car_seller_id column (nullable for now)';
        
        -- TODO: Backfill from cars table or participants
    ELSE
        RAISE NOTICE 'Column conversations.car_seller_id already exists, skipping';
    END IF;
END $$;

-- Add status column
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'conversations' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE conversations ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'active';
        RAISE NOTICE 'Added conversations.status column';
    ELSE
        RAISE NOTICE 'Column conversations.status already exists, skipping';
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
        ALTER TABLE conversations ADD COLUMN last_message_at TIMESTAMPTZ;
        RAISE NOTICE 'Added conversations.last_message_at column';
        
        -- TODO: Backfill from messages table (get max created_at per conversation)
    ELSE
        RAISE NOTICE 'Column conversations.last_message_at already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 3. CONVERSATION_PARTICIPANTS TABLE
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
        ALTER TABLE conversation_participants ADD COLUMN unread_count INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added conversation_participants.unread_count column';
    ELSE
        RAISE NOTICE 'Column conversation_participants.unread_count already exists, skipping';
    END IF;
END $$;

-- ============================================
-- 4. INDEXES
-- ============================================

-- Index on messages.status
CREATE INDEX IF NOT EXISTS idx_messages_status 
ON messages(status);

-- Index on messages.conversation_id and status
CREATE INDEX IF NOT EXISTS idx_messages_conv_status 
ON messages(conversation_id, status);

-- Index on conversations.car_id
CREATE INDEX IF NOT EXISTS idx_conversations_car_id 
ON conversations(car_id);

-- Index on conversations.car_seller_id
CREATE INDEX IF NOT EXISTS idx_conversations_seller 
ON conversations(car_seller_id);

-- Index on conversations.last_message_at
CREATE INDEX IF NOT EXISTS idx_conversations_last_msg 
ON conversations(last_message_at DESC NULLS LAST);

-- Index on conversation_participants.unread_count
CREATE INDEX IF NOT EXISTS idx_participants_unread 
ON conversation_participants(user_id, unread_count) 
WHERE unread_count > 0;

-- ============================================
-- 5. CONSTRAINTS (Optional - add if needed)
-- ============================================

-- Add check constraint on messages.status if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'messages_status_check'
    ) THEN
        ALTER TABLE messages 
        ADD CONSTRAINT messages_status_check 
        CHECK (status IN ('sent', 'delivered', 'seen'));
        RAISE NOTICE 'Added check constraint on messages.status';
    END IF;
END $$;

-- Add check constraint on conversations.status if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'conversations_status_check'
    ) THEN
        ALTER TABLE conversations 
        ADD CONSTRAINT conversations_status_check 
        CHECK (status IN ('active', 'archived', 'blocked'));
        RAISE NOTICE 'Added check constraint on conversations.status';
    END IF;
END $$;

COMMIT;

-- ============================================
-- NOTES FOR MANUAL FOLLOW-UP:
-- ============================================
-- 
-- 1. BACKFILL conversations.car_id, car_title, car_seller_id:
--    These columns were added as nullable. You need to populate them.
--    
--    Example backfill query (adjust to your schema):
--    UPDATE conversations c
--    SET car_id = (c.metadata->>'car_id')::uuid,
--        car_title = c.metadata->>'car_title',
--        car_seller_id = (SELECT seller_id FROM cars WHERE id = (c.metadata->>'car_id')::uuid)
--    WHERE car_id IS NULL;
--    
--    After backfill, make NOT NULL:
--    ALTER TABLE conversations ALTER COLUMN car_id SET NOT NULL;
--    ALTER TABLE conversations ALTER COLUMN car_title SET NOT NULL;
--    ALTER TABLE conversations ALTER COLUMN car_seller_id SET NOT NULL;
--
-- 2. BACKFILL conversations.last_message_at:
--    UPDATE conversations c
--    SET last_message_at = (
--        SELECT MAX(created_at) 
--        FROM messages m 
--        WHERE m.conversation_id = c.id
--    )
--    WHERE last_message_at IS NULL;
--
-- 3. VERIFY all migrations worked:
--    Run schema inspection queries again to confirm columns exist.
--
-- ============================================
```

---

### Step 3.3: Create Rollback Script (Down Migration)

**Action:** Create script to undo changes if needed.

**Create:** `rollback_missing_columns_migration.sql`

```sql
-- ============================================
-- Rollback Migration: Remove Added Columns
-- DANGER: This removes columns added by the migration
-- Only use if migration caused issues
-- ============================================

BEGIN;

-- Remove indexes first
DROP INDEX IF EXISTS idx_messages_status;
DROP INDEX IF EXISTS idx_messages_conv_status;
DROP INDEX IF EXISTS idx_conversations_car_id;
DROP INDEX IF EXISTS idx_conversations_seller;
DROP INDEX IF EXISTS idx_conversations_last_msg;
DROP INDEX IF EXISTS idx_participants_unread;

-- Remove constraints
ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_status_check;
ALTER TABLE conversations DROP CONSTRAINT IF EXISTS conversations_status_check;

-- Remove columns from messages table
ALTER TABLE messages DROP COLUMN IF EXISTS status;
ALTER TABLE messages DROP COLUMN IF EXISTS delivered_at;
ALTER TABLE messages DROP COLUMN IF EXISTS seen_at;

-- Remove columns from conversations table
ALTER TABLE conversations DROP COLUMN IF EXISTS car_id;
ALTER TABLE conversations DROP COLUMN IF EXISTS car_title;
ALTER TABLE conversations DROP COLUMN IF EXISTS car_seller_id;
ALTER TABLE conversations DROP COLUMN IF EXISTS status;
ALTER TABLE conversations DROP COLUMN IF EXISTS last_message_at;

-- Remove columns from conversation_participants table
ALTER TABLE conversation_participants DROP COLUMN IF EXISTS unread_count;

COMMIT;
```

---

## 📋 PHASE 4: DATA BACKFILL STRATEGY

### Step 4.1: Identify Columns Needing Backfill

**Action:** Determine which new columns need data populated for existing rows.

**Columns requiring backfill:**

**1. conversations.car_id, car_title, car_seller_id**
- These are critical for existing conversations
- Data might be in metadata JSONB or need JOIN with other tables
- **Source options:**
  - From metadata column if car info stored there
  - From messages table if messages have car context
  - From separate mapping table

**2. conversations.last_message_at**
- Can calculate from messages table
- Get MAX(created_at) for each conversation

**3. conversation_participants.unread_count**
- Can calculate from messages table
- Count unread messages per participant

**4. messages.status**
- Default 'sent' is fine for existing messages
- Or mark old messages as 'seen' since they're already read

---

### Step 4.2: Create Backfill Queries

**Action:** Write SQL to populate missing data.

**Create:** `backfill_data.sql`

```sql
-- ============================================
-- Data Backfill for Missing Columns
-- Run AFTER add_missing_columns_migration.sql
-- ============================================

BEGIN;

-- ============================================
-- 1. Backfill conversations.car_id, car_title, car_seller_id
-- ============================================

-- Option A: If data is in metadata JSONB
UPDATE conversations
SET 
    car_id = (metadata->>'car_id')::uuid,
    car_title = metadata->>'car_title',
    car_seller_id = (metadata->>'car_seller_id')::uuid
WHERE car_id IS NULL 
  AND metadata IS NOT NULL
  AND metadata->>'car_id' IS NOT NULL;

-- Option B: If need to join with cars table
-- (Adjust based on your schema and relationships)
UPDATE conversations c
SET 
    car_id = /* derive from somewhere */,
    car_title = /* derive from somewhere */,
    car_seller_id = /* derive from somewhere */
WHERE car_id IS NULL;

-- After backfill, make NOT NULL (if all rows populated)
-- Uncomment after verifying all rows have data:
-- ALTER TABLE conversations ALTER COLUMN car_id SET NOT NULL;
-- ALTER TABLE conversations ALTER COLUMN car_title SET NOT NULL;
-- ALTER TABLE conversations ALTER COLUMN car_seller_id SET NOT NULL;

-- ============================================
-- 2. Backfill conversations.last_message_at
-- ============================================

UPDATE conversations c
SET last_message_at = (
    SELECT MAX(m.created_at)
    FROM messages m
    WHERE m.conversation_id = c.id
)
WHERE last_message_at IS NULL;

-- ============================================
-- 3. Backfill conversation_participants.unread_count
-- ============================================

-- Calculate unread messages per participant
-- This is complex - you need to determine what's "unread"
-- For simplicity, can set all to 0 (assume old messages are read)

UPDATE conversation_participants
SET unread_count = 0
WHERE unread_count IS NULL;

-- Or calculate from messages if you track read status:
-- UPDATE conversation_participants cp
-- SET unread_count = (
--     SELECT COUNT(*)
--     FROM messages m
--     WHERE m.conversation_id = cp.conversation_id
--       AND m.sender_id != cp.user_id
--       AND m.status != 'seen'
-- );

-- ============================================
-- 4. Set messages.status for existing messages
-- ============================================

-- Option A: Mark all existing as 'seen' (they're old)
UPDATE messages
SET status = 'seen'
WHERE status IS NULL OR status = 'sent';

-- Option B: Leave as 'sent' (default handles this)

COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check for NULL values that should not exist
SELECT 
    COUNT(*) FILTER (WHERE car_id IS NULL) as null_car_id,
    COUNT(*) FILTER (WHERE car_title IS NULL) as null_car_title,
    COUNT(*) FILTER (WHERE car_seller_id IS NULL) as null_car_seller_id,
    COUNT(*) FILTER (WHERE last_message_at IS NULL) as null_last_msg
FROM conversations;

SELECT 
    COUNT(*) FILTER (WHERE unread_count IS NULL) as null_unread
FROM conversation_participants;

SELECT 
    COUNT(*) FILTER (WHERE status IS NULL) as null_status
FROM messages;
```

---

## 📋 PHASE 5: TESTING & EXECUTION

### Step 5.1: Test on Database Copy

**Action:** Never run migrations on production first. Test thoroughly.

**Testing Process:**

1. **Create database backup/copy:**
   ```sql
   -- PostgreSQL backup
   pg_dump -U username -d database_name > backup.sql
   
   -- Or create test database from production copy
   CREATE DATABASE test_db WITH TEMPLATE production_db;
   ```

2. **Run migration on test database:**
   ```
   Connect to test database
   Run: add_missing_columns_migration.sql
   Check for errors
   Verify columns added
   ```

3. **Verify schema:**
   ```sql
   -- Check all expected columns exist
   SELECT table_name, column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_name IN ('messages', 'conversations', 'conversation_participants')
   ORDER BY table_name, ordinal_position;
   ```

4. **Run backfill on test:**
   ```
   Run: backfill_data.sql
   Check for errors
   Verify data populated
   ```

5. **Test backend against test database:**
   ```
   Point backend to test database
   Start backend server
   Test all endpoints
   Check logs for column errors
   Verify queries work
   ```

6. **Verify idempotency:**
   ```
   Run migration script AGAIN on test database
   Should complete without errors
   Should skip existing columns
   No duplicate columns created
   ```

---

### Step 5.2: Execute on Production

**Action:** Once tested, apply to production database.

**Execution Checklist:**

**Pre-execution:**
- [ ] Full database backup created
- [ ] Migration tested on copy of production data
- [ ] Backend tested against test database successfully
- [ ] Rollback script ready
- [ ] Maintenance window scheduled (if needed)
- [ ] Team notified

**Execution:**
```
1. Create production backup:
   pg_dump -U username -d production_db > production_backup_YYYYMMDD.sql

2. Connect to production database

3. Run migration:
   \i add_missing_columns_migration.sql
   
4. Check for errors in output
   - Look for "ERROR" messages
   - Verify "NOTICE" messages show columns added
   
5. Run backfill:
   \i backfill_data.sql
   
6. Verify completion:
   - Run verification queries
   - Check for NULL values where not expected
```

**Post-execution:**
- [ ] Verify schema matches expectations
- [ ] Restart backend application
- [ ] Monitor logs for errors
- [ ] Test critical functionality
- [ ] Monitor for 30+ minutes
- [ ] If issues: run rollback script and restore backup

---

### Step 5.3: Verify Backend Works

**Action:** Confirm backend queries succeed after migration.

**Verification Steps:**

1. **Restart backend server:**
   - Ensure it connects to updated database
   - Check startup logs for errors

2. **Test each feature:**
   - Send message → Verify status tracking works
   - View chat list → Verify car details, last message, unread count appear
   - Open chat room → Verify messages load, car banner shows
   - Mark messages as seen → Verify unread count updates

3. **Check backend logs:**
   - Look for SQL errors
   - Look for "column does not exist" errors
   - Verify queries execute successfully

4. **Monitor database:**
   - Check slow query log
   - Verify indexes are being used
   - Check for missing index warnings

**Success Criteria:**
- No database column errors in backend logs
- All features work as expected
- Query performance acceptable
- No data corruption

---

## 📋 PHASE 6: DOCUMENTATION

### Step 6.1: Document Migration

**Action:** Record what was done for future reference.

**Create:** `MIGRATION_HISTORY.md`

```markdown
# Migration History

## Migration: Add Missing Columns
**Date:** YYYY-MM-DD
**Author:** [Your Name]
**Database Version:** Before/After

### Problem
Backend code was querying columns that didn't exist in database:
- messages.status, delivered_at, seen_at
- conversations.car_id, car_title, car_seller_id, status, last_message_at
- conversation_participants.unread_count

### Solution
Created idempotent migration to add missing columns.

### Files
- `add_missing_columns_migration.sql` - Main migration
- `backfill_data.sql` - Data population
- `rollback_missing_columns_migration.sql` - Rollback script

### Execution
- Tested on: test_db (YYYY-MM-DD)
- Applied to production: production_db (YYYY-MM-DD)
- No issues encountered

### Verification
All missing columns now exist. Backend queries execute successfully.

### Schema Changes

#### messages table
- Added: status VARCHAR(20) NOT NULL DEFAULT 'sent'
- Added: delivered_at TIMESTAMPTZ NULL
- Added: seen_at TIMESTAMPTZ NULL
- Added: Index idx_messages_status

#### conversations table
- Added: car_id UUID NOT NULL
- Added: car_title VARCHAR(255) NOT NULL
- Added: car_seller_id UUID NOT NULL
- Added: status VARCHAR(20) NOT NULL DEFAULT 'active'
- Added: last_message_at TIMESTAMPTZ NULL
- Added: Multiple indexes

#### conversation_participants table
- Added: unread_count INTEGER NOT NULL DEFAULT 0
- Added: Index idx_participants_unread

### Backfill Notes
- conversations.car_id, car_title, car_seller_id populated from metadata
- conversations.last_message_at calculated from messages.created_at
- conversation_participants.unread_count set to 0 for existing rows
- messages.status set to 'seen' for existing messages

### Rollback Tested
Rollback script tested on test database. Can safely reverse migration if needed.
```

---

### Step 6.2: Update Schema Documentation

**Action:** Ensure schema docs reflect new columns.

**Update:** Project's database schema documentation

**Add:**
- New columns to schema diagrams
- Column descriptions and purposes
- Index documentation
- Constraints documentation

---

### Step 6.3: Create Troubleshooting Guide

**Action:** Document how to handle future schema sync issues.

**Create:** `SCHEMA_SYNC_TROUBLESHOOTING.md`

```markdown
# Schema Sync Troubleshooting Guide

## Preventing Schema Mismatches

1. **Always create migrations for schema changes**
   - Don't manually add columns to models without database migration
   - Don't manually add columns to database without updating models

2. **Migration workflow:**
   - Update backend model → Generate migration → Apply migration
   - Or: Write migration → Update backend model

3. **Code review checklist:**
   - Model changes include migration?
   - Migration tested on dev database?
   - Migration is idempotent?

## Detecting Schema Mismatches

**Symptoms:**
- Backend logs show "column does not exist" errors
- SQL queries fail
- Features not working

**Diagnosis:**
1. Check backend logs for specific column name in error
2. Query database to verify column exists:
   ```sql
   SELECT column_name 
   FROM information_schema.columns 
   WHERE table_name = 'table_name' 
   AND column_name = 'column_name';
   ```
3. Check backend model to see what's expected
4. Identify the mismatch

## Fixing Schema Mismatches

**Process:**
1. Follow analysis steps in PHASE 1
2. Generate idempotent migration in PHASE 3
3. Test on database copy in PHASE 5.1
4. Apply to production in PHASE 5.2

**Never:**
- Manually add columns without migration script
- Run untested migrations on production
- Skip the analysis phase

## Emergency Rollback

If migration causes issues:
1. Stop backend application
2. Run rollback script: `rollback_missing_columns_migration.sql`
3. Restore database backup if needed
4. Investigate issue
5. Fix migration script
6. Test again on copy
7. Re-apply when ready
```

---

## 🎯 SUCCESS CRITERIA

Migration is successful when:

### Database Schema
- [ ] All columns expected by backend exist in database
- [ ] All data types match between code and database
- [ ] All nullable/not-null constraints correct
- [ ] All default values set appropriately
- [ ] All indexes created for performance

### Backend Functionality
- [ ] No "column does not exist" errors in logs
- [ ] All SQL queries execute successfully
- [ ] All features work end-to-end
- [ ] Query performance acceptable

### Data Integrity
- [ ] No NULL values where NOT NULL required
- [ ] Existing data preserved
- [ ] New columns backfilled correctly
- [ ] No data corruption

### Migration Quality
- [ ] Migration is idempotent (can run multiple times safely)
- [ ] Migration tested on database copy
- [ ] Rollback script tested
- [ ] Migration documented

### Long-term Maintenance
- [ ] Schema documentation updated
- [ ] Migration history documented
- [ ] Troubleshooting guide created
- [ ] Process established to prevent future mismatches

---

## 🚨 CRITICAL REMINDERS

### Analysis Phase
1. ✅ Read EVERY backend file that touches database
2. ✅ Extract EVERY column reference (models, queries, handlers)
3. ✅ Query actual database schema (don't assume)
4. ✅ Create complete comparison (expected vs actual)
5. ✅ Document findings thoroughly

### Migration Creation
1. ✅ Use IF NOT EXISTS patterns (idempotent)
2. ✅ Add one column at a time with error handling
3. ✅ Include helpful RAISE NOTICE messages
4. ✅ Create corresponding rollback script
5. ✅ Add comments explaining each change

### Testing
1. ✅ NEVER test on production first
2. ✅ Create database backup before migration
3. ✅ Test on copy of production data
4. ✅ Verify idempotency (run twice)
5. ✅ Test backend against migrated database

### Execution
1. ✅ Full backup before running
2. ✅ Have rollback script ready
3. ✅ Monitor during and after migration
4. ✅ Verify no errors in output
5. ✅ Test critical functionality immediately

### Documentation
1. ✅ Document what changed
2. ✅ Document why it changed
3. ✅ Document how to rollback
4. ✅ Update schema documentation
5. ✅ Create prevention guide

---

## 📝 DELIVERABLES

After completing this process:

1. **BACKEND_COLUMNS_ANALYSIS.md** - Complete analysis of backend expectations
2. **ACTUAL_DATABASE_SCHEMA.md** - Current database schema
3. **MISSING_COLUMNS_REPORT.md** - Detailed gap analysis
4. **add_missing_columns_migration.sql** - Idempotent migration script
5. **backfill_data.sql** - Data population script
6. **rollback_missing_columns_migration.sql** - Rollback script
7. **MIGRATION_HISTORY.md** - Migration execution record
8. **SCHEMA_SYNC_TROUBLESHOOTING.md** - Future prevention guide
9. **Updated schema documentation** - Reflects new columns
10. **Test results** - Verification that everything works

---

**START WITH PHASE 1: COMPREHENSIVE BACKEND CODE ANALYSIS**

Do not skip the analysis phase. Understanding exactly what the backend expects and what the database has is critical to creating the correct migration script.

Good luck! 🔍📊🔧
