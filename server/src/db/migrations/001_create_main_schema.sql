-- ============================================================
-- CREATE SCHEMA
-- ============================================================
CREATE SCHEMA IF NOT EXISTS main AUTHORIZATION postgres;

-- ============================================================
-- ADD EXTENSION
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE - USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.users (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name            TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    age             TEXT,
    address         TEXT,
    avatar_url      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ
);

-- ============================================================
-- TABLE - ACCOUNTS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.accounts (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    username        TEXT UNIQUE NOT NULL,
    password        TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ,
    user_id         UUID REFERENCES main.users(id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE - DEVICES
-- ============================================================
CREATE TABLE IF NOT EXISTS main.devices (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_code     TEXT,
    device_name     TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ
);

-- ============================================================
-- TABLE - ACCOUNT_DEVICES (N:N)
-- ============================================================
CREATE TABLE IF NOT EXISTS main.account_devices (
    account_id      UUID REFERENCES main.accounts(id) ON DELETE CASCADE,
    device_id       UUID REFERENCES main.devices(id) ON DELETE CASCADE,
    session_token   TEXT,
    PRIMARY KEY (account_id, device_id)
);

-- ============================================================
-- TABLE - SESSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.sessions (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    access_token    TEXT UNIQUE NOT NULL,
    refresh_token   TEXT UNIQUE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    last_login      TIMESTAMPTZ DEFAULT NOW(),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    expired_at      TIMESTAMPTZ,
    account_id      UUID REFERENCES main.accounts(id),
    device_id       UUID REFERENCES main.devices(id),
    user_id         UUID REFERENCES main.users(id)
);

-- ============================================================
-- TYPE - ENUM conversation_type
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_type') THEN
        CREATE TYPE conversation_type AS ENUM ('direct', 'room');
    END IF;
END
$$;

-- ============================================================
-- TABLE - CONVERSATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.conversations (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    type            conversation_type NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ
);

-- ============================================================
-- TABLE - DIRECT_CHATS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.direct_chats (
    id              UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    user1_id        UUID NOT NULL REFERENCES main.users(id),
    user2_id        UUID NOT NULL REFERENCES main.users(id),
    PRIMARY KEY (id)
);

-- ============================================================
-- TYPE - ENUM chat_role_type
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_role_type') THEN
        CREATE TYPE chat_role_type AS ENUM ('admin', 'member');
    END IF;
END
$$;

-- ============================================================
-- TABLE - ROOM_CHATS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.room_chats (
    id              UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    name            TEXT,
    creator         UUID NOT NULL REFERENCES main.users(id),
    PRIMARY KEY (id)
);

-- ============================================================
-- TABLE - ROOM_PARTICIPANTS
-- ============================================================
CREATE TABLE IF NOT EXISTS main.room_participants (
    room_id         UUID NOT NULL REFERENCES main.room_chats(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES main.users(id) ON DELETE CASCADE,
    role            chat_role_type NOT NULL DEFAULT 'member',
    PRIMARY KEY (room_id, user_id)
);

-- ============================================================
-- TABLE - MESSAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS main.messages (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    sender_id       UUID REFERENCES main.users(id),
    type            TEXT,
    data            JSONB,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ
);
