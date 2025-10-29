import express from 'express';
import dotenv from 'dotenv';
import pkg from 'pg';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

dotenv.config();
const { Pool } = pkg;

const { DATABASE_URL, SYNC_ADMIN_TOKEN, PORT = 8000, JWT_SECRET = 'change-me' } = process.env;
if (!DATABASE_URL) { throw new Error('DATABASE_URL not set'); }
const pool = new Pool({ connectionString: DATABASE_URL, ssl: DATABASE_URL.includes('sslmode=require') ? { rejectUnauthorized: false } : undefined });

const app = express();
app.use(express.json());

// JWT helpers
const signTokens = (user) => {
  const payload = { sub: String(user.id), email: user.email, role: user.role || 'user' };
  const access = jwt.sign(payload, JWT_SECRET, { expiresIn: '15m', audience: 'exampro-mobile', issuer: 'exampro-auth' });
  const refresh = jwt.sign({ sub: payload.sub }, JWT_SECRET, { expiresIn: '30d', audience: 'exampro-mobile', issuer: 'exampro-auth' });
  return { access, refresh };
};
const auth = async (req, res, next) => {
  const hdr = req.get('Authorization') || '';
  if (!hdr.startsWith('Bearer ')) return res.status(401).json({ error: 'unauthorized' });
  try {
    const token = hdr.slice(7);
    const decoded = jwt.verify(token, JWT_SECRET, { audience: 'exampro-mobile', issuer: 'exampro-auth' });
    req.user = decoded;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'unauthorized' });
  }
};

// Auth endpoints
app.post('/auth/register', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password || password.length < 6) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    // Ensure table exists
    await client.query("CREATE TABLE IF NOT EXISTS users (id BIGSERIAL PRIMARY KEY, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'user')");
    const hash = await bcrypt.hash(password, 10);
    const role = 'user';
    const r = await client.query('INSERT INTO users(email, password_hash, role) VALUES($1,$2,$3) ON CONFLICT (email) DO NOTHING RETURNING id', [email, hash, role]);
    if (r.rowCount === 0) return res.status(409).json({ error: 'email_exists' });
    const id = r.rows[0].id;
    const tokens = signTokens({ id, email, role });
    return res.json(tokens);
  } finally { client.release(); }
});

app.post('/auth/sign-in', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    const r = await client.query('SELECT id, password_hash, role FROM users WHERE email = $1', [email]);
    if (r.rowCount === 0) return res.status(401).json({ error: 'invalid_credentials' });
    const { id, password_hash: hash, role } = r.rows[0];
    const ok = await bcrypt.compare(password, hash);
    if (!ok) return res.status(401).json({ error: 'invalid_credentials' });
    const tokens = signTokens({ id, email, role });
    return res.json(tokens);
  } finally { client.release(); }
});

app.post('/auth/refresh', async (req, res) => {
  const { refresh } = req.body || {};
  if (!refresh) return res.status(400).json({ error: 'invalid_input' });
  try {
    const { sub } = jwt.verify(refresh, JWT_SECRET, { audience: 'exampro-mobile', issuer: 'exampro-auth' });
    const client = await pool.connect();
    try {
      const r = await client.query('SELECT email, role FROM users WHERE id = $1', [sub]);
      if (r.rowCount === 0) return res.status(401).json({ error: 'invalid_token' });
      const user = { id: sub, email: r.rows[0].email, role: r.rows[0].role };
      const tokens = signTokens(user);
      return res.json(tokens);
    } finally { client.release(); }
  } catch (e) {
    return res.status(401).json({ error: 'invalid_token' });
  }
});

app.get('/auth/me', auth, async (req, res) => {
  const client = await pool.connect();
  try {
    const r = await client.query('SELECT id, email, role FROM users WHERE id = $1', [req.user.sub]);
    if (r.rowCount === 0) return res.status(404).json({ error: 'not_found' });
    return res.json(r.rows[0]);
  } finally { client.release(); }
});

// Content version
app.get('/sync/version', async (req, res) => {
  const client = await pool.connect();
  try {
    const r = await client.query('SELECT version FROM content_meta WHERE id = 1');
    if (r.rowCount === 0) {
      await client.query('INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING');
    }
    const r2 = await client.query('SELECT version FROM content_meta WHERE id = 1');
    return res.json({ version: r2.rows[0].version });
  } finally { client.release(); }
});

const TABLES = ['categories','subcategories','exams','questions','choices','exam_questions','exam_grade_bands'];

// Full snapshot
app.get('/sync/snapshot', async (req, res) => {
  const client = await pool.connect();
  try {
    const ver = await client.query('SELECT version FROM content_meta WHERE id = 1');
    const data = { version: ver.rows[0]?.version };
    for (const t of TABLES) {
      const rows = await client.query(`SELECT * FROM ${t}`);
      data[t] = rows.rows;
    }
    return res.json(data);
  } finally { client.release(); }
});

// Progress endpoints
app.post('/sync/user-progress', async (req, res) => {
  const { email, data } = req.body || {};
  if (!email || !data) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query("CREATE TABLE IF NOT EXISTS user_attempts (user_email TEXT NOT NULL, local_id INT NOT NULL, exam_id INT NOT NULL, mode TEXT NOT NULL, started_at TIMESTAMPTZ NOT NULL, ended_at TIMESTAMPTZ NULL, score INT NULL, score_percent INT NOT NULL DEFAULT 0, grade_label TEXT NOT NULL DEFAULT '' , PRIMARY KEY(user_email, local_id))");
    await client.query("CREATE TABLE IF NOT EXISTS user_attempt_answers (user_email TEXT NOT NULL, local_attempt_id INT NOT NULL, question_id INT NOT NULL, selected TEXT NOT NULL, time_ms INT NOT NULL DEFAULT 0, is_correct BOOLEAN NOT NULL DEFAULT FALSE, points INT NOT NULL DEFAULT 0, PRIMARY KEY(user_email, local_attempt_id, question_id))");
    await client.query("CREATE TABLE IF NOT EXISTS user_saved_questions (user_email TEXT NOT NULL, question_id INT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), PRIMARY KEY(user_email, question_id))");
    for (const m of (data.attempts || [])) {
      await client.query('INSERT INTO user_attempts(user_email, local_id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) ON CONFLICT(user_email, local_id) DO UPDATE SET exam_id=EXCLUDED.exam_id, mode=EXCLUDED.mode, started_at=EXCLUDED.started_at, ended_at=EXCLUDED.ended_at, score=EXCLUDED.score, score_percent=EXCLUDED.score_percent, grade_label=EXCLUDED.grade_label', [email, m.id, m.exam_id, m.mode, m.started_at, m.ended_at, m.score, m.score_percent, m.grade_label]);
    }
    for (const m of (data.answers || [])) {
      await client.query('INSERT INTO user_attempt_answers(user_email, local_attempt_id, question_id, selected, time_ms, is_correct, points) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT(user_email, local_attempt_id, question_id) DO UPDATE SET selected=EXCLUDED.selected, time_ms=EXCLUDED.time_ms, is_correct=EXCLUDED.is_correct, points=EXCLUDED.points', [email, m.attempt_id, m.question_id, m.selected, m.time_ms, m.is_correct, m.points]);
    }
    for (const m of (data.saved || [])) {
      await client.query('INSERT INTO user_saved_questions(user_email, question_id, created_at) VALUES ($1,$2,$3) ON CONFLICT(user_email, question_id) DO UPDATE SET created_at=EXCLUDED.created_at', [email, m.question_id, m.created_at]);
    }
    await client.query('COMMIT');
    return res.json({ ok: true });
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch {}
    return res.status(500).json({ error: 'failed' });
  } finally { client.release(); }
});

app.get('/sync/user-progress', async (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    const attempts = (await client.query('SELECT local_id AS id, exam_id, mode, started_at, ended_at, score, score_percent, grade_label FROM user_attempts WHERE user_email = $1 ORDER BY started_at', [email])).rows;
    const answers = (await client.query('SELECT local_attempt_id AS attempt_id, question_id, selected, time_ms, is_correct, points FROM user_attempt_answers WHERE user_email = $1 ORDER BY local_attempt_id, question_id', [email])).rows;
    const saved = (await client.query('SELECT question_id, created_at FROM user_saved_questions WHERE user_email = $1', [email])).rows;
    return res.json({ attempts, answers, saved });
  } finally { client.release(); }
});

// Admin: bump content version
app.post('/admin/bump-version', async (req, res) => {
  if (!SYNC_ADMIN_TOKEN) return res.status(403).json({ error: 'Not configured' });
  const authz = req.get('Authorization') || '';
  if (!authz.startsWith('Bearer ')) return res.status(401).json({ error: 'Missing token' });
  const token = authz.slice(7);
  if (token !== SYNC_ADMIN_TOKEN) return res.status(403).json({ error: 'Invalid token' });
  const client = await pool.connect();
  try {
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    return res.json({ ok: true });
  } finally { client.release(); }
});

app.listen(PORT, () => console.log(`API listening on ${PORT}`));
