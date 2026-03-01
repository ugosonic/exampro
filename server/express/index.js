import express from 'express';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import pkg from 'pg';
import jwt from 'jsonwebtoken';
import Stripe from 'stripe';
import nodemailer from 'nodemailer';
import bcrypt from 'bcryptjs';
import multer from 'multer';
import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';

// Load .env next to this file regardless of PM2/working directory
try {
  // Resolve .env relative to this file so PM2/working directory doesn't matter
  const __dirname = (await import('path')).default.dirname(fileURLToPath(import.meta.url));
  const join = (await import('path')).default.join;
  dotenv.config({ path: join(__dirname, '.env') });
} catch (_) {
  dotenv.config();
}
const { Pool } = pkg;

const {
  DATABASE_URL,
  SYNC_ADMIN_TOKEN,
  PORT = 8000,
  JWT_SECRET = 'change-me',
  ADMIN_EMAILS = '',
  STRIPE_SECRET_KEY = '',
  STRIPE_SUCCESS_URL = 'https://example.com/success',
  STRIPE_CANCEL_URL = 'https://example.com/cancel',
  SMTP_HOST = '',
  SMTP_PORT = '',
  SMTP_USER = '',
  SMTP_PASS = '',
  FROM_EMAIL = '',
  FCM_SERVICE_ACCOUNT_JSON = '',
  FCM_SERVICE_ACCOUNT_FILE = '',
  REMINDER_SCHEDULER_ENABLED = '1',
  REMINDER_SCHEDULER_POLL_MS = '60000',
} = process.env;
const ADMIN_SET = new Set(String(ADMIN_EMAILS).split(',').map(s => s.trim().toLowerCase()).filter(Boolean));
if (!DATABASE_URL) { throw new Error('DATABASE_URL not set'); }
const pool = new Pool({ connectionString: DATABASE_URL, ssl: DATABASE_URL.includes('sslmode=require') ? { rejectUnauthorized: false } : undefined });
const stripe = STRIPE_SECRET_KEY ? new Stripe(STRIPE_SECRET_KEY, { apiVersion: '2024-06-20' }) : null;
let mailer = null;
if (SMTP_HOST && SMTP_USER && SMTP_PASS) {
  try {
    mailer = nodemailer.createTransport({
      host: SMTP_HOST,
      port: Number(SMTP_PORT || 465),
      secure: (SMTP_PORT || '465') === '465',
      auth: { user: SMTP_USER, pass: SMTP_PASS },
    });
  } catch (_) { mailer = null; }
}

const app = express();
const defaultCorsOrigins = [
  'https://citizentest.zenovtech.com',
  'https://www.citizentest.zenovtech.com',
];
const configuredCorsOrigins = String(process.env.CORS_ALLOW_ORIGINS || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const explicitCorsOrigins = new Set([...defaultCorsOrigins, ...configuredCorsOrigins]);
const isAllowedCorsOrigin = (origin) => {
  if (!origin) return false;
  if (explicitCorsOrigins.has(origin)) return true;
  try {
    const url = new URL(origin);
    if (url.hostname === 'localhost' || url.hostname === '127.0.0.1') {
      return url.protocol === 'http:' || url.protocol === 'https:';
    }
  } catch (_) {}
  return false;
};
app.use((req, res, next) => {
  const origin = req.get('Origin');
  if (isAllowedCorsOrigin(origin)) {
    res.set('Access-Control-Allow-Origin', origin);
    res.set('Vary', 'Origin');
    res.set(
      'Access-Control-Allow-Headers',
      'Authorization, Content-Type, X-Requested-With',
    );
    res.set(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    );
  }
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }
  return next();
});
app.use(express.json({ limit: '25mb' }));

const isDbConnectivityError = (e) =>
  ['ECONNREFUSED', 'ETIMEDOUT', 'ECONNRESET', 'ENETUNREACH', 'EHOSTUNREACH'].includes(
    String(e?.code || ''),
  );

const sendApiError = (res, e, context = 'request') => {
  console.error(`${context} failed:`, e?.message || e);
  if (res.headersSent) return;
  if (isDbConnectivityError(e)) {
    return res.status(503).json({ error: 'db_unavailable' });
  }
  return res.status(500).json({ error: 'failed' });
};

let fcmMessaging = null;
try {
  let credential = null;
  if (FCM_SERVICE_ACCOUNT_JSON) {
    credential = admin.credential.cert(JSON.parse(FCM_SERVICE_ACCOUNT_JSON));
  } else if (FCM_SERVICE_ACCOUNT_FILE) {
    const serviceAccountRaw = fs.readFileSync(FCM_SERVICE_ACCOUNT_FILE, 'utf8');
    credential = admin.credential.cert(JSON.parse(serviceAccountRaw));
  }
  if (credential) {
    const firebaseApp =
      admin.apps.length > 0
        ? admin.app()
        : admin.initializeApp({ credential });
    fcmMessaging = firebaseApp.messaging();
    console.log('[fcm] initialized');
  } else {
    console.log('[fcm] disabled (no service account configured)');
  }
} catch (e) {
  console.error('[fcm] init failed:', e?.message || e);
}

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
  const roleClaim = ADMIN_SET.has(String(user.email || '').toLowerCase()) ? 'admin' : (user.role || 'user');
  const payload = { sub: String(user.id), email: user.email, role: roleClaim };
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

// Allow either: (1) JWT with role=admin, or (2) SYNC_ADMIN_TOKEN bearer
const adminGuard = async (req, res, next) => {
  const hdr = req.get('Authorization') || '';
  if (hdr.startsWith('Bearer ')) {
    const token = hdr.slice(7);
    if (SYNC_ADMIN_TOKEN && token === SYNC_ADMIN_TOKEN) {
      req.user = { role: 'admin' };
      return next();
    }
    try {
      const decoded = jwt.verify(token, JWT_SECRET, { audience: 'exampro-mobile', issuer: 'exampro-auth' });
      if ((decoded.role || 'user') !== 'admin') return res.status(403).json({ error: 'forbidden' });
      req.user = decoded;
      return next();
    } catch (_) {
      return res.status(401).json({ error: 'unauthorized' });
    }
  }
  return res.status(401).json({ error: 'unauthorized' });
};

const ensureUsersTable = async (client) => {
  await client.query(
    "CREATE TABLE IF NOT EXISTS users (id BIGSERIAL PRIMARY KEY, email TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'user', is_pro BOOLEAN NOT NULL DEFAULT FALSE)",
  );
  await client.query(
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_pro BOOLEAN NOT NULL DEFAULT FALSE",
  );
};

// Auth endpoints
app.post('/auth/register', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password || password.length < 6) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    // Ensure table exists
    await ensureUsersTable(client);
    const hash = await bcrypt.hash(password, 10);
    const role = ADMIN_SET.has(String(email).toLowerCase()) ? 'admin' : 'user';
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
    const roleClaim = ADMIN_SET.has(String(email).toLowerCase()) ? 'admin' : role;
    const tokens = signTokens({ id, email, role: roleClaim });
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

const ensurePushTokenTable = async (client) => {
  await client.query(
    "CREATE TABLE IF NOT EXISTS user_push_tokens (" +
      "token TEXT PRIMARY KEY, " +
      "user_id TEXT NOT NULL, " +
      "platform TEXT NOT NULL DEFAULT '', " +
      "app_version TEXT NOT NULL DEFAULT '', " +
      "updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()" +
    ")"
  );
  await client.query(
    "ALTER TABLE user_push_tokens " +
      "ADD COLUMN IF NOT EXISTS user_id TEXT NOT NULL DEFAULT '', " +
      "ADD COLUMN IF NOT EXISTS platform TEXT NOT NULL DEFAULT '', " +
      "ADD COLUMN IF NOT EXISTS app_version TEXT NOT NULL DEFAULT '', " +
      "ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()"
  );
  // Support both numeric and UUID user IDs by normalizing to TEXT.
  await client.query(
    "DO $$ " +
      "DECLARE c RECORD; " +
      "BEGIN " +
        "FOR c IN " +
          "SELECT conname FROM pg_constraint " +
          "WHERE conrelid = 'user_push_tokens'::regclass AND contype = 'f' " +
        "LOOP " +
          "EXECUTE format('ALTER TABLE user_push_tokens DROP CONSTRAINT %I', c.conname); " +
        "END LOOP; " +
        "IF EXISTS (" +
          "SELECT 1 FROM information_schema.columns " +
          "WHERE table_schema='public' AND table_name='user_push_tokens' AND column_name='user_id' AND data_type <> 'text'" +
        ") THEN " +
          "ALTER TABLE user_push_tokens ALTER COLUMN user_id TYPE TEXT USING user_id::text; " +
        "END IF; " +
      "EXCEPTION WHEN others THEN " +
        "NULL; " +
      "END $$;"
  );
  await client.query(
    'CREATE INDEX IF NOT EXISTS idx_user_push_tokens_user_id ON user_push_tokens(user_id)'
  );
};

const ensureReminderPreferencesTable = async (client) => {
  await client.query(
    "CREATE TABLE IF NOT EXISTS user_notification_preferences (" +
      "user_id TEXT PRIMARY KEY, " +
      "user_email TEXT NOT NULL DEFAULT '', " +
      "enabled BOOLEAN NOT NULL DEFAULT TRUE, " +
      "reminder_hour INT NOT NULL DEFAULT 19, " +
      "reminder_minute INT NOT NULL DEFAULT 0, " +
      "timezone TEXT NOT NULL DEFAULT 'UTC', " +
      "last_sent_local_date TEXT NOT NULL DEFAULT '', " +
      "updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()" +
    ")"
  );
  await client.query(
    "ALTER TABLE user_notification_preferences " +
      "ADD COLUMN IF NOT EXISTS user_email TEXT NOT NULL DEFAULT '', " +
      "ADD COLUMN IF NOT EXISTS enabled BOOLEAN NOT NULL DEFAULT TRUE, " +
      "ADD COLUMN IF NOT EXISTS reminder_hour INT NOT NULL DEFAULT 19, " +
      "ADD COLUMN IF NOT EXISTS reminder_minute INT NOT NULL DEFAULT 0, " +
      "ADD COLUMN IF NOT EXISTS timezone TEXT NOT NULL DEFAULT 'UTC', " +
      "ADD COLUMN IF NOT EXISTS last_sent_local_date TEXT NOT NULL DEFAULT '', " +
      "ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()"
  );
  await client.query(
    'CREATE INDEX IF NOT EXISTS idx_user_notification_preferences_enabled ON user_notification_preferences(enabled)'
  );
};

const getUserLocalClock = (timeZone) => {
  const safeTimeZone = String(timeZone || 'UTC').trim() || 'UTC';
  try {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: safeTimeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    }).formatToParts(new Date());
    const values = Object.fromEntries(parts.map((p) => [p.type, p.value]));
    return {
      timeZone: safeTimeZone,
      date: `${values.year}-${values.month}-${values.day}`,
      hour: Number(values.hour),
      minute: Number(values.minute),
    };
  } catch (_) {
    if (safeTimeZone !== 'UTC') {
      return getUserLocalClock('UTC');
    }
    const now = new Date();
    return {
      timeZone: 'UTC',
      date: now.toISOString().slice(0, 10),
      hour: now.getUTCHours(),
      minute: now.getUTCMinutes(),
    };
  }
};

const getPendingAttemptReminder = async (client, userEmail) => {
  const tableCheck = await client.query(
    "SELECT to_regclass('public.user_attempts') AS table_name"
  );
  if (!tableCheck.rows[0]?.table_name) return null;
  const attempt = await client.query(
    'SELECT local_id, exam_id, mode FROM user_attempts WHERE user_email = $1 AND ended_at IS NULL ORDER BY started_at DESC LIMIT 1',
    [userEmail],
  );
  if (attempt.rowCount === 0) return null;
  const row = attempt.rows[0];
  return {
    title: 'Pending test reminder',
    body: 'Continue your unfinished test',
    data: {
      type: 'pending_test',
      attemptId: row.local_id,
      examId: row.exam_id,
      mode: row.mode || 'exam',
    },
  };
};

const toStringMap = (obj) => {
  const out = {};
  for (const [k, v] of Object.entries(obj || {})) {
    if (v === null || v === undefined) continue;
    out[String(k)] = String(v);
  }
  return out;
};

const sendPushToUser = async ({ userId, title, body, data }) => {
  if (!fcmMessaging) {
    console.warn(`[fcm] send skipped user=${userId} reason=fcm_not_configured`);
    return { ok: false, error: 'fcm_not_configured', tokens: 0, successCount: 0, failureCount: 0 };
  }
  const client = await pool.connect();
  try {
    await ensurePushTokenTable(client);
    const rows = await client.query('SELECT token FROM user_push_tokens WHERE user_id = $1', [userId]);
    const tokens = rows.rows.map((r) => r.token).filter(Boolean);
    if (!tokens.length) {
      console.warn(`[fcm] send skipped user=${userId} reason=no_tokens`);
      return { ok: false, error: 'no_tokens', tokens: 0, successCount: 0, failureCount: 0 };
    }
    const resp = await fcmMessaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: toStringMap(data),
      android: {
        priority: 'high',
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    });
    const stale = [];
    const failureCodes = {};
    for (let i = 0; i < resp.responses.length; i++) {
      const rr = resp.responses[i];
      if (rr.success) continue;
      const code = rr.error?.code || '';
      if (code) {
        failureCodes[code] = (failureCodes[code] || 0) + 1;
      }
      if (code === 'messaging/invalid-registration-token' || code === 'messaging/registration-token-not-registered') {
        stale.push(tokens[i]);
      }
    }
    if (stale.length) {
      await client.query('DELETE FROM user_push_tokens WHERE token = ANY($1::text[])', [stale]);
    }
    console.log(
      `[fcm] send user=${userId} tokens=${tokens.length} success=${resp.successCount} failure=${resp.failureCount} stale=${stale.length} codes=${JSON.stringify(failureCodes)}`,
    );
    return {
      ok: resp.successCount > 0,
      tokens: tokens.length,
      successCount: resp.successCount,
      failureCount: resp.failureCount,
      staleCount: stale.length,
      failureCodes,
    };
  } finally { client.release(); }
};

app.post('/notifications/register-token', auth, async (req, res) => {
  const token = String(req.body?.token || '').trim();
  const platform = String(req.body?.platform || '').trim();
  const appVersion = String(req.body?.app_version || req.body?.appVersion || '').trim();
  if (!token || token.length < 16) return res.status(400).json({ error: 'invalid_token' });
  const userId = String(req.user?.sub || '').trim();
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const client = await pool.connect();
  try {
    await ensurePushTokenTable(client);
    await client.query(
      "INSERT INTO user_push_tokens(token, user_id, platform, app_version, updated_at) VALUES ($1,$2,$3,$4,NOW()) " +
      "ON CONFLICT(token) DO UPDATE SET user_id = EXCLUDED.user_id, platform = EXCLUDED.platform, app_version = EXCLUDED.app_version, updated_at = NOW()",
      [token, userId, platform, appVersion],
    );
    const tokenPrefix = token.slice(0, Math.min(16, token.length));
    console.log(
      `[fcm] register-token user=${userId} platform=${platform || 'unknown'} version=${appVersion || 'unknown'} token_prefix=${tokenPrefix}...`,
    );
    return res.json({ ok: true });
  } finally { client.release(); }
});

app.post('/notifications/settings', auth, async (req, res) => {
  const userId = String(req.user?.sub || '').trim();
  const userEmail = String(req.user?.email || '').trim().toLowerCase();
  if (!userId || !userEmail) return res.status(401).json({ error: 'unauthorized' });

  const enabled = Boolean(req.body?.enabled);
  const hour = Number(req.body?.hour);
  const minute = Number(req.body?.minute);
  const timeZoneRaw = String(req.body?.timezone || 'UTC').trim() || 'UTC';
  const localClock = getUserLocalClock(timeZoneRaw);

  if (!Number.isInteger(hour) || hour < 0 || hour > 23) {
    return res.status(400).json({ error: 'invalid_hour' });
  }
  if (!Number.isInteger(minute) || minute < 0 || minute > 59) {
    return res.status(400).json({ error: 'invalid_minute' });
  }

  const client = await pool.connect();
  try {
    await ensureReminderPreferencesTable(client);
    await client.query(
      "INSERT INTO user_notification_preferences(user_id, user_email, enabled, reminder_hour, reminder_minute, timezone, updated_at) " +
      "VALUES ($1,$2,$3,$4,$5,$6,NOW()) " +
      "ON CONFLICT(user_id) DO UPDATE SET user_email = EXCLUDED.user_email, enabled = EXCLUDED.enabled, reminder_hour = EXCLUDED.reminder_hour, reminder_minute = EXCLUDED.reminder_minute, timezone = EXCLUDED.timezone, updated_at = NOW()",
      [userId, userEmail, enabled, hour, minute, localClock.timeZone],
    );
    return res.json({
      ok: true,
      enabled,
      hour,
      minute,
      timezone: localClock.timeZone,
    });
  } finally { client.release(); }
});

app.post('/notifications/reminder-preview', auth, async (req, res) => {
  const userId = String(req.user?.sub || '').trim();
  if (!userId) return res.status(401).json({ error: 'unauthorized' });
  const title = String(req.body?.title || '').trim() || 'Pending test reminder';
  const body = String(req.body?.body || '').trim() || 'Continue your test';
  const data = toStringMap(req.body?.data || req.body?.payload || {});
  try {
    const sent = await sendPushToUser({ userId, title, body, data });
    if (!sent.ok) {
      const status = sent.error === 'fcm_not_configured' ? 503 : (sent.error === 'no_tokens' ? 404 : 502);
      return res.status(status).json({ error: sent.error, ...sent });
    }
    return res.json({ ok: true, ...sent });
  } catch (e) {
    console.error('reminder-preview failed:', e);
    return res.status(500).json({ error: 'failed' });
  }
});

let reminderSchedulerRunning = false;
const reminderSchedulerEnabled =
  String(REMINDER_SCHEDULER_ENABLED).trim() !== '0';
const reminderSchedulerPollMs = Math.max(
  15000,
  Number.parseInt(String(REMINDER_SCHEDULER_POLL_MS || '60000'), 10) || 60000,
);
const reminderSchedulerWindowMinutes = Math.max(
  1,
  Math.ceil(reminderSchedulerPollMs / 60000),
);

const isWithinReminderWindow = (scheduledHour, scheduledMinute, localClock) => {
  const scheduledTotal = (Number(scheduledHour) * 60) + Number(scheduledMinute);
  const currentTotal = (Number(localClock.hour) * 60) + Number(localClock.minute);
  return (
    currentTotal >= scheduledTotal &&
    currentTotal <= (scheduledTotal + reminderSchedulerWindowMinutes)
  );
};

const runReminderSchedulerTick = async () => {
  if (!reminderSchedulerEnabled || reminderSchedulerRunning) return;
  reminderSchedulerRunning = true;
  const client = await pool.connect();
  try {
    await ensureReminderPreferencesTable(client);
    await ensurePushTokenTable(client);
    const prefs = await client.query(
      'SELECT p.user_id, ' +
      "COALESCE(NULLIF(p.user_email, ''), u.email, '') AS user_email, " +
      'p.reminder_hour, p.reminder_minute, p.timezone, p.last_sent_local_date ' +
      'FROM user_notification_preferences p ' +
      'LEFT JOIN users u ON u.id::text = p.user_id ' +
      'WHERE p.enabled = TRUE'
    );
    for (const pref of prefs.rows) {
      const localClock = getUserLocalClock(pref.timezone);
      if (
        !isWithinReminderWindow(
          pref.reminder_hour,
          pref.reminder_minute,
          localClock,
        )
      ) {
        continue;
      }
      if (String(pref.last_sent_local_date || '') === localClock.date) {
        continue;
      }
      const reminder = await getPendingAttemptReminder(client, pref.user_email);
      if (!reminder) {
        continue;
      }
      const sent = await sendPushToUser({
        userId: pref.user_id,
        title: reminder.title,
        body: reminder.body,
        data: reminder.data,
      });
      if (sent.ok) {
        await client.query(
          'UPDATE user_notification_preferences SET last_sent_local_date = $2, updated_at = NOW() WHERE user_id = $1',
          [pref.user_id, localClock.date],
        );
        console.log(
          `[fcm] scheduled-reminder user=${pref.user_id} date=${localClock.date} tz=${localClock.timeZone}`,
        );
      }
    }
  } catch (e) {
    console.error('[fcm] scheduler tick failed:', e?.message || e);
  } finally {
    reminderSchedulerRunning = false;
    client.release();
  }
};

// Content version
app.get('/sync/version', async (req, res) => {
  let client;
  try {
    client = await pool.connect();
    const r = await client.query('SELECT version FROM content_meta WHERE id = 1');
    if (r.rowCount === 0) {
      await client.query('INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING');
    }
    const r2 = await client.query('SELECT version FROM content_meta WHERE id = 1');
    return res.json({ version: r2.rows[0].version });
  } catch (e) {
    return sendApiError(res, e, 'sync/version');
  } finally {
    try { client?.release(); } catch {}
  }
});

const TABLES = ['categories','subcategories','exams','questions','choices','exam_questions','exam_grade_bands'];

// Full snapshot
app.get('/sync/snapshot', async (req, res) => {
  let client;
  try {
    client = await pool.connect();
    const ver = await client.query('SELECT version FROM content_meta WHERE id = 1');
    const data = { version: ver.rows[0]?.version };
    for (const t of TABLES) {
      const rows = await client.query(`SELECT * FROM ${t}`);
      data[t] = rows.rows;
    }
    return res.json(data);
  } catch (e) {
    return sendApiError(res, e, 'sync/snapshot');
  } finally {
    try { client?.release(); } catch {}
  }
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

// Public catalog endpoints (read-only)
app.get('/catalog/categories', async (req, res) => {
  let client;
  try {
    client = await pool.connect();
    const r = await client.query('SELECT id, name, "order", pass_percent, image_url, locked FROM categories ORDER BY "order", name');
    return res.json(r.rows);
  } catch (e) {
    return sendApiError(res, e, 'catalog/categories');
  } finally {
    try { client?.release(); } catch {}
  }
});

app.get('/catalog/subcategories', async (req, res) => {
  const { category_id } = req.query;
  let client;
  try {
    client = await pool.connect();
    const sql = 'SELECT id, category_id, name, "order", image_url, locked FROM subcategories' + (category_id ? ' WHERE category_id = $1' : '') + ' ORDER BY "order", name';
    const params = category_id ? [category_id] : [];
    const r = await client.query(sql, params);
    return res.json(r.rows);
  } catch (e) {
    return sendApiError(res, e, 'catalog/subcategories');
  } finally {
    try { client?.release(); } catch {}
  }
});

app.get('/catalog/exams', async (req, res) => {
  const { category_id, subcategory_id } = req.query;
  let client;
  try {
    client = await pool.connect();
    const where = [];
    const params = [];
    if (category_id) { params.push(category_id); where.push(`category_id = $${params.length}`); }
    if (subcategory_id) { params.push(subcategory_id); where.push(`subcategory_id = $${params.length}`); }
    const sql = `SELECT id, title, description, category_id, subcategory_id, question_count, published, time_limit_minutes, shuffle_options, negative_marking, pass_percent, theme_key FROM exams ${where.length ? ('WHERE ' + where.join(' AND ')) : ''} ORDER BY id`;
    const r = await client.query(sql, params);
    return res.json(r.rows);
  } catch (e) {
    return sendApiError(res, e, 'catalog/exams');
  } finally {
    try { client?.release(); } catch {}
  }
});

app.get('/catalog/exam/:id/questions', async (req, res) => {
  const id = Number(req.params.id);
  if (!id) return res.status(400).json({ error: 'invalid_id' });
  let client;
  try {
    client = await pool.connect();
    const joins = await client.query('SELECT question_id, "order", points FROM exam_questions WHERE exam_id = $1 ORDER BY "order"', [id]);
    if (joins.rowCount === 0) return res.json({ order: [], questions: [], choices: [] });
    const qids = [...new Set(joins.rows.map(r => r.question_id))];
    const qs = await client.query('SELECT id, body, explanation, multiple, locked FROM questions WHERE id = ANY($1::int[])', [qids]);
    const cs = await client.query('SELECT id, question_id, label, is_correct, "order" FROM choices WHERE question_id = ANY($1::int[]) ORDER BY question_id, "order"', [qids]);
    return res.json({ order: joins.rows, questions: qs.rows, choices: cs.rows });
  } catch (e) {
    return sendApiError(res, e, 'catalog/exam/questions');
  } finally {
    try { client?.release(); } catch {}
  }
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
app.post('/admin/import-snapshot', adminGuard, async (req, res) => {
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
      // Ensure content_meta exists so we can bump version at the end
      await client.query("CREATE TABLE IF NOT EXISTS content_meta (id INT PRIMARY KEY, version TIMESTAMPTZ NOT NULL DEFAULT now())");
      await client.query("INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING");
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
      console.error('import-snapshot failed inner:', e);
      return res.status(500).json({ error: 'failed' });
    } finally { client.release(); }
  } catch (e) {
    console.error('import-snapshot failed outer:', e);
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

// Admin: upload generic image (JWT required, admin role)
app.post('/admin/upload/image', auth, (req, res) => {
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

// Public config (allows toggling upgrade prompts globally)
app.get('/config', async (req, res) => {
  const upgradeDisabled = (process.env.UPGRADE_DISABLED || '0') === '1';
  res.json({ upgrade_disabled: upgradeDisabled });
});

// Simple success/cancel landing pages for Stripe (used only for redirect detection in app)
app.get('/success', (req, res) => {
  res.set('Content-Type', 'text/html');
  res.send('<html><body><h2>Payment success</h2><p>You can close this page.</p></body></html>');
});
app.get('/cancel', (req, res) => {
  res.set('Content-Type', 'text/html');
  res.send('<html><body><h2>Payment canceled</h2><p>You can close this page.</p></body></html>');
});

// Store a payment record in Postgres (used by app after checkout success)
app.post('/payments/record', auth, async (req, res) => {
  const { amount_minor = 0, currency = 'GBP', session_id = '', payment_intent_id = '' } = req.body || {};
  const email = (req.user && req.user.email) || '';
  if (!email || !amount_minor || amount_minor <= 0) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    await client.query("CREATE TABLE IF NOT EXISTS payments (id BIGSERIAL PRIMARY KEY, user_email TEXT NOT NULL, amount_minor INT NOT NULL, currency TEXT NOT NULL, stripe_session_id TEXT DEFAULT '', status TEXT NOT NULL DEFAULT 'paid', refunded BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
    const stripeId = payment_intent_id || session_id || '';
    await client.query('INSERT INTO payments(user_email, amount_minor, currency, stripe_session_id, status) VALUES($1,$2,$3,$4,$5)', [email, amount_minor, String(currency).toUpperCase(), stripeId, 'paid']);
    return res.json({ ok: true });
  } catch (e) {
    console.error('payments/record error', e);
    return res.status(500).json({ error: 'failed' });
  } finally { client.release(); }
});

// Admin: list payments
app.get('/admin/payments', adminGuard, async (req, res) => {
  const limit = Math.max(1, Math.min(200, Number(req.query.limit) || 50));
  const offset = Math.max(0, Number(req.query.offset) || 0);
  const client = await pool.connect();
  try {
    await client.query("CREATE TABLE IF NOT EXISTS payments (id BIGSERIAL PRIMARY KEY, user_email TEXT NOT NULL, amount_minor INT NOT NULL, currency TEXT NOT NULL, stripe_session_id TEXT DEFAULT '', status TEXT NOT NULL DEFAULT 'paid', refunded BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
    const rows = await client.query('SELECT id, user_email, amount_minor, currency, stripe_session_id, status, refunded, created_at FROM payments ORDER BY created_at DESC LIMIT $1 OFFSET $2', [limit, offset]);
    return res.json(rows.rows);
  } finally { client.release(); }
});

// Admin: refund a payment via Stripe (full amount)
app.post('/admin/refund', adminGuard, async (req, res) => {
  if (!stripe) return res.status(503).json({ error: 'stripe_not_configured' });
  const { id } = req.body || {};
  if (!id) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    await client.query("CREATE TABLE IF NOT EXISTS payments (id BIGSERIAL PRIMARY KEY, user_email TEXT NOT NULL, amount_minor INT NOT NULL, currency TEXT NOT NULL, stripe_session_id TEXT DEFAULT '', status TEXT NOT NULL DEFAULT 'paid', refunded BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
    const r = await client.query('SELECT amount_minor, stripe_session_id, refunded FROM payments WHERE id = $1', [id]);
    if (r.rowCount === 0) return res.status(404).json({ error: 'not_found' });
    const row = r.rows[0];
    if (row.refunded) return res.json({ ok: true });
    const pi = row.stripe_session_id; // stores PaymentIntent id for PaymentSheet
    if (!pi) return res.status(400).json({ error: 'missing_payment_intent' });
    await stripe.refunds.create({ payment_intent: pi, amount: row.amount_minor });
    await client.query("UPDATE payments SET refunded = TRUE, status = 'refunded' WHERE id = $1", [id]);
    return res.json({ ok: true });
  } catch (e) {
    console.error('admin/refund error', e);
    return res.status(500).json({ error: 'failed' });
  } finally { client.release(); }
});

// Admin: send email via SMTP (Hostinger). Authorization: Bearer <SYNC_ADMIN_TOKEN> or admin JWT
app.post('/admin/send-email', adminGuard, async (req, res) => {
  if (!mailer || !FROM_EMAIL) return res.status(503).json({ error: 'smtp_not_configured' });
  const { to = [], subject = '', text = '', html = '' } = req.body || {};
  try {
    if (!Array.isArray(to) || to.length === 0 || !subject) return res.status(400).json({ error: 'invalid_input' });
    await mailer.sendMail({
      from: FROM_EMAIL,
      to: to.join(','),
      subject,
      text: text || undefined,
      html: html || undefined,
    });
    return res.json({ ok: true });
  } catch (e) {
    console.error('send-email error', e);
    return res.status(500).json({ error: 'failed' });
  }
});

// Payments: create Stripe Checkout Session with server-side secret
app.post('/payments/checkout', auth, async (req, res) => {
  if (!stripe) return res.status(503).json({ error: 'stripe_not_configured' });
  try {
    const { currency = 'GBP', amount_minor = 0, product_name = 'Pro Upgrade' } = req.body || {};
    const amount = Number(amount_minor) || 0;
    if (amount <= 0) return res.status(400).json({ error: 'invalid_amount' });
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [{
        price_data: {
          currency: String(currency).toLowerCase(),
          unit_amount: amount,
          product_data: { name: product_name },
        },
        quantity: 1,
      }],
      success_url: `${STRIPE_SUCCESS_URL}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${STRIPE_CANCEL_URL}`,
    });
    return res.json({ url: session.url, id: session.id });
  } catch (e) {
    console.error('stripe checkout error', e);
    return res.status(500).json({ error: 'failed' });
  }
});

// Payments: create PaymentIntent for PaymentSheet (native in-app)
app.post('/payments/intent', auth, async (req, res) => {
  if (!stripe) return res.status(503).json({ error: 'stripe_not_configured' });
  try {
    const { currency = 'GBP', amount_minor = 0 } = req.body || {};
    const amount = Number(amount_minor) || 0;
    if (amount <= 0) return res.status(400).json({ error: 'invalid_amount' });
    const intent = await stripe.paymentIntents.create({
      amount,
      currency: String(currency).toLowerCase(),
      automatic_payment_methods: { enabled: true },
    });
    return res.json({ client_secret: intent.client_secret });
  } catch (e) {
    console.error('stripe intent error', e);
    return res.status(500).json({ error: 'failed' });
  }
});

// Admin CRUD for content (create/update/delete)
app.post('/admin/categories', adminGuard, async (req, res) => {
  const { name, order = 0, pass_percent = 60, image_url = '' } = req.body || {};
  if (!name) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    const r = await client.query('INSERT INTO categories(name, "order", pass_percent, image_url) VALUES ($1,$2,$3,$4) RETURNING id', [name, order, pass_percent, image_url]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ id: r.rows[0].id });
  } finally { client.release(); }
});

app.put('/admin/categories/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  if (!id) return res.status(400).json({ error: 'invalid_id' });
  const fields = ['name','order','pass_percent','image_url','locked'];
  const sets = [];
  const vals = [];
  for (const f of fields) {
    if (Object.prototype.hasOwnProperty.call(req.body || {}, f)) {
      vals.push(req.body[f]);
      sets.push(`${f === 'order' ? '"order"' : f} = $${vals.length}`);
    }
  }
  const client = await pool.connect();
  try {
    if (sets.length) await client.query(`UPDATE categories SET ${sets.join(', ')} WHERE id = $${vals.length + 1}`, [...vals, id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.delete('/admin/categories/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const client = await pool.connect();
  try {
    await client.query('DELETE FROM categories WHERE id=$1', [id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.post('/admin/subcategories', adminGuard, async (req, res) => {
  const { category_id, name, order = 0, image_url = '' } = req.body || {};
  if (!category_id || !name) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    const r = await client.query('INSERT INTO subcategories(category_id, name, "order", image_url) VALUES ($1,$2,$3,$4) RETURNING id', [category_id, name, order, image_url]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ id: r.rows[0].id });
  } finally { client.release(); }
});

app.put('/admin/subcategories/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const fields = ['name','order','image_url','locked'];
  const sets = [];
  const vals = [];
  for (const f of fields) {
    if (Object.prototype.hasOwnProperty.call(req.body || {}, f)) {
      vals.push(req.body[f]);
      sets.push(`${f === 'order' ? '"order"' : f} = $${vals.length}`);
    }
  }
  const client = await pool.connect();
  try {
    if (sets.length) await client.query(`UPDATE subcategories SET ${sets.join(', ')} WHERE id = $${vals.length + 1}`, [...vals, id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.delete('/admin/subcategories/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const client = await pool.connect();
  try {
    await client.query('DELETE FROM subcategories WHERE id=$1', [id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.post('/admin/exams', adminGuard, async (req, res) => {
  const { title, description = '', category_id, subcategory_id = null, time_limit_minutes = 0, pass_percent = 60, shuffle_options = true, negative_marking = false, published = false, theme_key = 0, pdf_url = '' } = req.body || {};
  if (!title || !category_id) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    const r = await client.query('INSERT INTO exams(title, description, category_id, subcategory_id, time_limit_minutes, pass_percent, shuffle_options, negative_marking, published, theme_key, pdf_url) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING id', [title, description, category_id, subcategory_id, time_limit_minutes, pass_percent, shuffle_options, negative_marking, published, theme_key, pdf_url]);
    const id = r.rows[0].id;
    await client.query("INSERT INTO exam_grade_bands(exam_id, min_percent, label) VALUES ($1,90,'Distinction'), ($1,75,'Merit'), ($1,$2,'Pass')", [id, pass_percent]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ id });
  } finally { client.release(); }
});

app.put('/admin/exams/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const fields = ['title','description','category_id','subcategory_id','time_limit_minutes','pass_percent','shuffle_options','negative_marking','published','theme_key','pdf_url'];
  const sets = [];
  const vals = [];
  for (const f of fields) {
    if (Object.prototype.hasOwnProperty.call(req.body || {}, f)) { vals.push(req.body[f]); sets.push(`${f} = $${vals.length}`); }
  }
  const client = await pool.connect();
  try {
    if (sets.length) await client.query(`UPDATE exams SET ${sets.join(', ')} WHERE id = $${vals.length + 1}`, [...vals, id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.delete('/admin/exams/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const client = await pool.connect();
  try {
    await client.query('DELETE FROM exams WHERE id=$1', [id]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

app.post('/admin/exams/:id/questions', adminGuard, async (req, res) => {
  const examId = Number(req.params.id);
  const { text, explanation = '', options = [], points = 1, order = 0 } = req.body || {};
  const providedMultiple = Object.prototype.hasOwnProperty.call(req.body || {}, 'multiple')
    ? !!req.body.multiple
    : null;
  const inferredMultiple = options.filter((o) => !!o.correct).length > 1;
  const multiple = providedMultiple ?? inferredMultiple;
  if (!text || !Array.isArray(options) || options.length === 0) return res.status(400).json({ error: 'invalid_input' });
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const q = await client.query(
      'INSERT INTO questions(body, explanation, multiple) VALUES ($1,$2,$3) RETURNING id',
      [text, explanation, multiple],
    );
    const qid = q.rows[0].id;
    for (let i = 0; i < options.length; i++) {
      const o = options[i];
      await client.query('INSERT INTO choices(question_id, label, is_correct, "order") VALUES ($1,$2,$3,$4)', [qid, (o.text || ''), !!o.correct, i]);
    }
    await client.query('INSERT INTO exam_questions(exam_id, question_id, "order", points) VALUES ($1,$2,$3,$4)', [examId, qid, order, points]);
    await client.query('UPDATE exams SET question_count = (SELECT COUNT(*) FROM exam_questions WHERE exam_id = $1) WHERE id = $1', [examId]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    await client.query('COMMIT');
    res.json({ id: qid });
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch {}
    res.status(500).json({ error: 'failed' });
  } finally { client.release(); }
});

app.put('/admin/questions/:id', adminGuard, async (req, res) => {
  const id = Number(req.params.id);
  const { body, explanation = '', options = [] } = req.body || {};
  const providedMultiple = Object.prototype.hasOwnProperty.call(req.body || {}, 'multiple')
    ? !!req.body.multiple
    : null;
  const inferredMultiple = options.filter((o) => !!o.correct).length > 1;
  const multiple = providedMultiple ?? inferredMultiple;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    if (body != null) {
      await client.query(
        'UPDATE questions SET body=$1, explanation=$2, multiple=$3 WHERE id=$4',
        [body, explanation, multiple, id],
      );
    }
    await client.query('DELETE FROM choices WHERE question_id = $1', [id]);
    for (let i = 0; i < options.length; i++) {
      const o = options[i];
      await client.query('INSERT INTO choices(question_id, label, is_correct, "order") VALUES ($1,$2,$3,$4)', [id, (o.text || ''), !!o.correct, i]);
    }
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    await client.query('COMMIT');
    res.json({ ok: true });
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch {}
    res.status(500).json({ error: 'failed' });
  } finally { client.release(); }
});

app.delete('/admin/exams/:examId/questions/:questionId', adminGuard, async (req, res) => {
  const examId = Number(req.params.examId); const qid = Number(req.params.questionId);
  const client = await pool.connect();
  try {
    await client.query('DELETE FROM exam_questions WHERE exam_id=$1 AND question_id=$2', [examId, qid]);
    await client.query('UPDATE exams SET question_count = (SELECT COUNT(*) FROM exam_questions WHERE exam_id = $1) WHERE id = $1', [examId]);
    await client.query('UPDATE content_meta SET version = now() WHERE id = 1');
    res.json({ ok: true });
  } finally { client.release(); }
});

// Admin: list registered users (from online DB)
app.get('/admin/users', adminGuard, async (req, res) => {
  let client;
  try {
    client = await pool.connect();
    await ensureUsersTable(client);
    const rows = await client.query(
      'SELECT id, email, role, is_pro FROM users ORDER BY id DESC',
    );
    return res.json(rows.rows);
  } catch (e) {
    return sendApiError(res, e, 'admin/users');
  } finally {
    try { client?.release(); } catch {}
  }
});

// Admin: change user role (admin <-> user)
app.put('/admin/users/:id/role', adminGuard, async (req, res) => {
  const id = String(req.params.id || '').trim();
  const role = String(req.body?.role || '').trim().toLowerCase();
  if (!id || !['admin', 'user'].includes(role)) {
    return res.status(400).json({ error: 'invalid_input' });
  }
  if (req.user?.sub && String(req.user.sub) === id && role !== 'admin') {
    return res.status(400).json({ error: 'cannot_demote_self' });
  }
  const client = await pool.connect();
  try {
    await ensureUsersTable(client);
    const updated = await client.query(
      'UPDATE users SET role = $1 WHERE id::text = $2 RETURNING id, email, role, is_pro',
      [role, id],
    );
    if (updated.rowCount === 0) return res.status(404).json({ error: 'not_found' });
    return res.json(updated.rows[0]);
  } finally { client.release(); }
});

// Bind explicitly on IPv4 so clients that use IPv4 addresses can connect even if the OS reports '::'
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API listening on ${PORT}`);
  if (reminderSchedulerEnabled) {
    console.log(
      `[fcm] reminder scheduler enabled interval_ms=${reminderSchedulerPollMs}`,
    );
    void runReminderSchedulerTick();
    setInterval(() => {
      void runReminderSchedulerTick();
    }, reminderSchedulerPollMs);
  } else {
    console.log('[fcm] reminder scheduler disabled');
  }
});
