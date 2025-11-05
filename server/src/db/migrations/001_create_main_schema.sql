CREATE SCHEMA IF NOT EXISTS main AUTHORIZATION postgres;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- CREATE TYPE 
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_type') THEN
        CREATE TYPE conversation_type AS ENUM ('myself', 'direct', 'group');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_role_type') THEN
        CREATE TYPE chat_role_type AS ENUM ('admin', 'member');
    END IF;
END
$$;

-- ============================================================
-- TABLE 
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

CREATE TABLE IF NOT EXISTS main.devices (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_code     TEXT,
    device_name     TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ,
    user_id         UUID REFERENCES main.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS main.account_devices (
    account_id      UUID REFERENCES main.accounts(id) ON DELETE CASCADE,
    device_id       UUID REFERENCES main.devices(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, device_id)
);

CREATE TABLE IF NOT EXISTS main.sessions (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    access_token    TEXT UNIQUE NOT NULL,
    refresh_token   TEXT UNIQUE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    last_login      TIMESTAMPTZ DEFAULT NOW(),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    expired_at      TIMESTAMPTZ,
    account_id      UUID REFERENCES main.accounts(id) ON DELETE CASCADE,
    device_id       UUID REFERENCES main.devices(id) ON DELETE CASCADE,
    user_id         UUID REFERENCES main.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS main.conversations (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    type            conversation_type NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ,
    user_id         UUID REFERENCES main.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS main.myself_chats (
    id              UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    user_id         UUID REFERENCES main.users(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS main.direct_chats (
    id              UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    user1_id        UUID NOT NULL REFERENCES main.users(id),
    user2_id        UUID NOT NULL REFERENCES main.users(id),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS main.group_chats (
    id              UUID REFERENCES main.conversations(id) ON DELETE CASCADE,
    name            TEXT,
    creator         UUID NOT NULL REFERENCES main.users(id),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS main.group_participants (
    room_id         UUID NOT NULL REFERENCES main.group_chats(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES main.users(id) ON DELETE CASCADE,
    role            chat_role_type NOT NULL DEFAULT 'member',
    PRIMARY KEY (room_id, user_id)
);

CREATE TABLE IF NOT EXISTS main.messages (
    id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    type            TEXT,
    data            JSONB,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    is_deleted      BOOLEAN DEFAULT FALSE,
    deleted_at      TIMESTAMPTZ,
    sender_id       UUID REFERENCES main.users(id),
    conversation_id UUID REFERENCES main.conversations(id) ON DELETE CASCADE
);
