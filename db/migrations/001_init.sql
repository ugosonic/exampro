-- Initial schema for single login (users + roles)
-- Safe to run multiple times using IF NOT EXISTS

CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user', -- 'user' | 'admin'
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Optional: basic index to speed up email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

