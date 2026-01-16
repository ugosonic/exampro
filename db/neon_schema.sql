-- Postgres schema matching the app's SQLite schema

-- Content meta for versioning
CREATE TABLE IF NOT EXISTS content_meta (
  id INT PRIMARY KEY DEFAULT 1,
  version TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  "order" INT NOT NULL DEFAULT 0,
  pass_percent INT NOT NULL DEFAULT 60,
  image_url TEXT NOT NULL DEFAULT '',
  locked BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS subcategories (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  "order" INT NOT NULL DEFAULT 0,
  image_url TEXT NOT NULL DEFAULT '',
  locked BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS exams (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  subcategory_id INT REFERENCES subcategories(id) ON DELETE SET NULL,
  question_count INT NOT NULL DEFAULT 0,
  published BOOLEAN NOT NULL DEFAULT FALSE,
  time_limit_minutes INT NOT NULL DEFAULT 0,
  shuffle_options BOOLEAN NOT NULL DEFAULT TRUE,
  negative_marking BOOLEAN NOT NULL DEFAULT FALSE,
  pass_percent INT NOT NULL DEFAULT 60,
  theme_key INT NOT NULL DEFAULT 0,
  -- Optional URL to a reference PDF for the exam (used by server import/export)
  pdf_url TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS questions (
  id SERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  explanation TEXT NOT NULL DEFAULT '',
  multiple BOOLEAN NOT NULL DEFAULT FALSE,
  locked BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS choices (
  id SERIAL PRIMARY KEY,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  "order" INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS exam_questions (
  id SERIAL PRIMARY KEY,
  exam_id INT NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  "order" INT NOT NULL DEFAULT 0,
  points INT NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS exam_grade_bands (
  id SERIAL PRIMARY KEY,
  exam_id INT NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  min_percent INT NOT NULL,
  label TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#4CAF50'
);

-- Optional: question-category links
CREATE TABLE IF NOT EXISTS question_categories (
  id SERIAL PRIMARY KEY,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS question_subcategories (
  id SERIAL PRIMARY KEY,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  subcategory_id INT NOT NULL REFERENCES subcategories(id) ON DELETE CASCADE
);

-- Suggested indices
CREATE INDEX IF NOT EXISTS idx_choices_q ON choices(question_id);
CREATE INDEX IF NOT EXISTS idx_eq_exam ON exam_questions(exam_id);
CREATE INDEX IF NOT EXISTS idx_eq_question ON exam_questions(question_id);

-- Optional: Users / Payments (for online auth and billing)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  is_pro BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS payments (
  id SERIAL PRIMARY KEY,
  user_email TEXT NOT NULL,
  amount_minor INT NOT NULL,
  currency TEXT NOT NULL,
  stripe_payment_intent_id TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'paid',
  refunded BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Triggers to bump content version automatically on changes
CREATE OR REPLACE FUNCTION bump_content_version() RETURNS TRIGGER AS $$
BEGIN
  UPDATE content_meta SET version = now() WHERE id = 1;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_categories') THEN
    CREATE TRIGGER trg_bump_categories AFTER INSERT OR UPDATE OR DELETE ON categories
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_subcategories') THEN
    CREATE TRIGGER trg_bump_subcategories AFTER INSERT OR UPDATE OR DELETE ON subcategories
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_exams') THEN
    CREATE TRIGGER trg_bump_exams AFTER INSERT OR UPDATE OR DELETE ON exams
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_questions') THEN
    CREATE TRIGGER trg_bump_questions AFTER INSERT OR UPDATE OR DELETE ON questions
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_choices') THEN
    CREATE TRIGGER trg_bump_choices AFTER INSERT OR UPDATE OR DELETE ON choices
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_exam_questions') THEN
    CREATE TRIGGER trg_bump_exam_questions AFTER INSERT OR UPDATE OR DELETE ON exam_questions
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bump_exam_bands') THEN
    CREATE TRIGGER trg_bump_exam_bands AFTER INSERT OR UPDATE OR DELETE ON exam_grade_bands
    FOR EACH STATEMENT EXECUTE FUNCTION bump_content_version();
  END IF;
END $$;
