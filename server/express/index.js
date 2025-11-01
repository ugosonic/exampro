import express from 'express';
import dotenv from 'dotenv';
import pkg from 'pg';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import multer from 'multer';
import fs from 'fs';
import path from 'path';

dotenv.config();
const { Pool } = pkg;

const { DATABASE_URL, SYNC_ADMIN_TOKEN, PORT = 8000, JWT_SECRET = 'change-me' } = process.env;
if (!DATABASE_URL) { throw new Error('DATABASE_URL not set'); }
const pool = new Pool({ connectionString: DATABASE_URL, ssl: DATABASE_URL.includes('sslmode=require') ? { rejectUnauthorized: false } : undefined });

const app = express();
app.use(express.json({ limit: '25mb' }));

// File uploads (PDFs)
const UPLOAD_DIR = process.env.UPLOAD_DIR || '/data/uploads';
try { fs.mkdirSync(UPLOAD_DIR, { recursive: true }); } catch {}
const storage = multer.diskStorage({
  destination: function (req, file, cb) { cb(null, UPLOAD_DIR); },
  filename: function (req, file, cb) {
    const safe = `${Date.now()}_${(file.originalname || 'file').replace(/[^\w.\-]+/g, '_')}`;
    cb(null, safe);
  }
});
const upload = multer({ storage });
app.use('/files', express.static(UPLOAD_DIR));

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

// Admin: import snapshot into Neon via server (uses DATABASE_URL of API)
app.post('/admin/import-snapshot', auth, async (req, res) => {
  try {
    if (!req.user || (req.user.role !== 'admin')) return res.status(403).json({ error: 'forbidden' });
    const snap = req.body || {};
    // Prepare media (category/subcategory images) from snapshot for hosting on VPS
    // Snapshot may contain: media_files: [{ entity: 'categories'|'subcategories', entity_id: <id>, filename, content_base64 }]
    const media = Array.isArray(snap.media_files) ? snap.media_files : [];
    const mediaMap = new Map(); // key: `${entity}:${id}` => '/files/<name>'
    try {
      for (const m of media) {
        const entity = m.entity;
        const id = m.entity_id;
        const b64 = m.content_base64 || '';
        if (!entity || !id || !b64) continue;
        const safeName = `${entity}_${id}_${(m.filename || 'file').replace(/[^\w.\-]+/g, '_')}`;
        const dest = path.join(UPLOAD_DIR, safeName);
        try { fs.mkdirSync(UPLOAD_DIR, { recursive: true }); } catch {}
        fs.writeFileSync(dest, Buffer.from(b64, 'base64'));
        mediaMap.set(`${entity}:${id}`, `/files/${safeName}`);
      }
    } catch (_) { /* non-fatal */ }
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      // Clear existing content tables in dependency order
      await client.query('DELETE FROM exam_grade_bands');
      await client.query('DELETE FROM exam_questions');
      await client.query('DELETE FROM choices');
      await client.query('DELETE FROM questions');
      await client.query('DELETE FROM exams');
      await client.query('DELETE FROM question_categories');
      await client.query('DELETE FROM question_subcategories');
      await client.query('DELETE FROM subcategories');
      await client.query('DELETE FROM categories');
      await client.query('CREATE TABLE IF NOT EXISTS translations (id BIGSERIAL PRIMARY KEY, entity TEXT NOT NULL, entity_id BIGINT NOT NULL, lang TEXT NOT NULL, k TEXT NOT NULL, v TEXT NOT NULL)');
      await client.query('DELETE FROM translations');

      const cats = snap.categories || [];
      for (const c of cats) {
        // Prefer uploaded media URL if provided; otherwise keep HTTP(S) URLs; ignore device-local paths
        const hosted = mediaMap.get(`categories:${c.id}`);
        const img = hosted || ((c.image_url && /^https?:/i.test(c.image_url)) ? c.image_url : '');
        await client.query('INSERT INTO categories(id, name, "order", pass_percent, image_url, locked) VALUES($1,$2,$3,$4,$5,$6) ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name, "order"=EXCLUDED."order", pass_percent=EXCLUDED.pass_percent, image_url=EXCLUDED.image_url, locked=EXCLUDED.locked', [c.id, c.name, c.order || 0, c.pass_percent || 60, img, c.locked || false]);
      }
      const subs = snap.subcategories || [];
      for (const s of subs) {
        const hosted = mediaMap.get(`subcategories:${s.id}`);
        const img = hosted || ((s.image_url && /^https?:/i.test(s.image_url)) ? s.image_url : '');
        await client.query('INSERT INTO subcategories(id, category_id, name, "order", image_url, locked) VALUES($1,$2,$3,$4,$5,$6) ON CONFLICT(id) DO UPDATE SET category_id=EXCLUDED.category_id, name=EXCLUDED.name, "order"=EXCLUDED."order", image_url=EXCLUDED.image_url, locked=EXCLUDED.locked', [s.id, s.category_id, s.name, s.order || 0, img, s.locked || false]);
      }
      const exams = snap.exams || [];
      for (const e of exams) {
        await client.query('INSERT INTO exams(id, title, description, category_id, subcategory_id, question_count, published, time_limit_minutes, shuffle_options, negative_marking, pass_percent, theme_key, pdf_url) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,COALESCE($13, \'\')) ON CONFLICT(id) DO UPDATE SET title=EXCLUDED.title, description=EXCLUDED.description, category_id=EXCLUDED.category_id, subcategory_id=EXCLUDED.subcategory_id, question_count=EXCLUDED.question_count, published=EXCLUDED.published, time_limit_minutes=EXCLUDED.time_limit_minutes, shuffle_options=EXCLUDED.shuffle_options, negative_marking=EXCLUDED.negative_marking, pass_percent=EXCLUDED.pass_percent, theme_key=EXCLUDED.theme_key, pdf_url=EXCLUDED.pdf_url', [e.id, e.title, e.description || '', e.category_id, e.subcategory_id, e.question_count || 0, e.published || false, e.time_limit_minutes || 0, e.shuffle_options ?? true, e.negative_marking || false, e.pass_percent || 60, e.theme_key || 0, e.pdf_url || '']);
      }
      const qs = snap.questions || [];
      for (const q of qs) {
        await client.query('INSERT INTO questions(id, body, explanation, multiple, locked) VALUES($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET body=EXCLUDED.body, explanation=EXCLUDED.explanation, multiple=EXCLUDED.multiple, locked=EXCLUDED.locked', [q.id, q.body, q.explanation || '', q.multiple || false, q.locked || false]);
      }
      const ch = snap.choices || [];
      for (const c of ch) {
        await client.query('INSERT INTO choices(id, question_id, label, is_correct, "order") VALUES($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET question_id=EXCLUDED.question_id, label=EXCLUDED.label, is_correct=EXCLUDED.is_correct, "order"=EXCLUDED."order"', [c.id, c.question_id, c.label, c.is_correct || false, c.order || 0]);
      }
      const eq = snap.exam_questions || [];
      for (const j of eq) {
        await client.query('INSERT INTO exam_questions(id, exam_id, question_id, "order", points) VALUES($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET exam_id=EXCLUDED.exam_id, question_id=EXCLUDED.question_id, "order"=EXCLUDED."order", points=EXCLUDED.points', [j.id, j.exam_id, j.question_id, j.order || 0, j.points || 1]);
      }
      const bands = snap.exam_grade_bands || [];
      for (const b of bands) {
        await client.query('INSERT INTO exam_grade_bands(id, exam_id, min_percent, label, color) VALUES($1,$2,$3,$4,$5) ON CONFLICT(id) DO UPDATE SET exam_id=EXCLUDED.exam_id, min_percent=EXCLUDED.min_percent, label=EXCLUDED.label, color=EXCLUDED.color', [b.id, b.exam_id, b.min_percent, b.label, b.color || '#4CAF50']);
      }
      const trans = snap.translations || [];
      for (const t of trans) {
        await client.query('INSERT INTO translations(entity, entity_id, lang, k, v) VALUES($1,$2,$3,$4,$5)', [t.entity, t.entity_id, t.lang, t.k, t.v]);
      }
      await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
      await client.query('COMMIT');
      return res.json({ ok: true });
    } catch (e) {
      try { await client.query('ROLLBACK'); } catch {}
      return res.status(500).json({ error: 'failed' });
    } finally { client.release(); }
  } catch (e) {
    return res.status(500).json({ error: 'failed' });
  }
});

// Admin: upload PDF (JWT required, admin role)
app.post('/admin/upload/pdf', auth, (req, res) => {
  try {
    if (!req.user || (req.user.role !== 'admin')) return res.status(403).json({ error: 'forbidden' });
    upload.single('file')(req, res, function (err) {
      if (err) return res.status(400).json({ error: 'upload_failed' });
      if (!req.file) return res.status(400).json({ error: 'no_file' });
      const url = `/files/${req.file.filename}`;
      return res.json({ url });
    });
  } catch (e) {
    return res.status(500).json({ error: 'failed' });
  }
});

app.listen(PORT, () => console.log(`API listening on ${PORT}`));
