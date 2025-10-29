-- Minimal schema for content meta and user progress/auth

CREATE TABLE IF NOT EXISTS content_meta (
  id INT PRIMARY KEY,
  version TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS user_attempts (
  user_email TEXT NOT NULL,
  local_id INT NOT NULL,
  exam_id INT NOT NULL,
  mode TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ NULL,
  score INT NULL,
  score_percent INT NOT NULL DEFAULT 0,
  grade_label TEXT NOT NULL DEFAULT '',
  PRIMARY KEY(user_email, local_id)
);

CREATE TABLE IF NOT EXISTS user_attempt_answers (
  user_email TEXT NOT NULL,
  local_attempt_id INT NOT NULL,
  question_id INT NOT NULL,
  selected TEXT NOT NULL,
  time_ms INT NOT NULL DEFAULT 0,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  points INT NOT NULL DEFAULT 0,
  PRIMARY KEY(user_email, local_attempt_id, question_id)
);

CREATE TABLE IF NOT EXISTS user_saved_questions (
  user_email TEXT NOT NULL,
  question_id INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(user_email, question_id)
);

