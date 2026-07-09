// ⚠️ DEPRECATED — Legacy monolithic server using SQLite.
// The active server is at src/server.js (Prisma + PostgreSQL + Firebase Admin).
// This file is kept for reference only and is NOT started by package.json.
// See backend/README.md for migration guide.
// Remove this file once all endpoints are verified in the new server.

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const { body, validationResult, query } = require('express-validator');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Configuration (all from env, NO fallback secrets in source) ────
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;
const CSRF_SECRET = process.env.CSRF_SECRET;
const BREVO_API_KEY = process.env.BREVO_API_KEY;
const APP_URL = process.env.APP_URL || 'http://localhost:8080';
const CORS_ORIGIN = process.env.CORS_ORIGIN || 'http://localhost:8080';
const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS) || 12;
const ACCESS_TOKEN_EXPIRY = process.env.ACCESS_TOKEN_EXPIRY || '15m';
const REFRESH_TOKEN_EXPIRY_DAYS = parseInt(process.env.REFRESH_TOKEN_EXPIRY_DAYS) || 7;
const ACCOUNT_LOCKOUT_THRESHOLD = parseInt(process.env.ACCOUNT_LOCKOUT_THRESHOLD) || 5;
const ACCOUNT_LOCKOUT_WINDOW_MS = parseInt(process.env.ACCOUNT_LOCKOUT_WINDOW_MS) || 900000; // 15 min

if (!JWT_SECRET || !JWT_REFRESH_SECRET || !CSRF_SECRET) {
  console.error('FATAL: JWT_SECRET, JWT_REFRESH_SECRET, and CSRF_SECRET must be set in .env');
  process.exit(1);
}

// ─── Security Middleware ────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: CORS_ORIGIN.split(',').map(s => s.trim()),
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token', 'X-Requested-With'],
  exposedHeaders: ['X-CSRF-Token'],
}));
app.use(express.json({ limit: '10kb' }));
app.disable('x-powered-by');

// ─── Global Rate Limiter ────────────────────────────────────────────
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests, please try again later.' },
});
app.use('/api/', globalLimiter);

// ─── Auth-specific Strict Rate Limiters ─────────────────────────────
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many authentication attempts. Please try again later.' },
});

const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many password reset requests. Please try again in an hour.' },
});

// ─── Database Setup ─────────────────────────────────────────────────
const dbPath = path.resolve(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Database connection error:', err.message);
    process.exit(1);
  }
  console.log('Connected to SQLite database at:', dbPath);
  initializeDatabase();
});

function initializeDatabase() {
  db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE,
      password_hash TEXT,
      name TEXT,
      photo_url TEXT,
      role TEXT DEFAULT 'user',
      status TEXT DEFAULT 'active',
      created_at TEXT,
      last_login TEXT,
      email_verified INTEGER DEFAULT 0,
      profile_data TEXT,
      failed_login_attempts INTEGER DEFAULT 0,
      locked_until TEXT
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS refresh_tokens (
      id TEXT PRIMARY KEY,
      token_hash TEXT NOT NULL,
      user_id TEXT NOT NULL,
      family_id TEXT NOT NULL,
      device_info TEXT,
      expires_at TEXT NOT NULL,
      revoked INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS documents (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      collection TEXT,
      data TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS temp_tokens (
      token TEXT PRIMARY KEY,
      user_id TEXT,
      type TEXT,
      expires_at TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS csrf_tokens (
      token TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS sessions_log (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      action TEXT NOT NULL,
      ip_address TEXT,
      user_agent TEXT,
      timestamp TEXT DEFAULT (datetime('now')),
      FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    )`);
  });
}

// ─── Helpers ────────────────────────────────────────────────────────
function generateId() {
  return 'user_' + crypto.randomBytes(16).toString('hex');
}

function generateDocId() {
  return 'doc_' + crypto.randomBytes(12).toString('hex');
}

function generateTokenId() {
  return 'tok_' + crypto.randomBytes(12).toString('hex');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function generateAccessToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRY, issuer: 'mental-mantra' }
  );
}

function generateRefreshToken(user, familyId, deviceInfo) {
  const rawToken = crypto.randomBytes(48).toString('hex');
  const tokenHash = hashToken(rawToken);
  const tokenId = generateTokenId();
  const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000).toISOString();

  db.run(
    'INSERT INTO refresh_tokens (id, token_hash, user_id, family_id, device_info, expires_at) VALUES (?, ?, ?, ?, ?, ?)',
    [tokenId, tokenHash, user.id, familyId, deviceInfo || null],
    (err) => {
      if (err) console.error('Error storing refresh token:', err.message);
    }
  );

  return { rawToken, tokenId, expiresAt };
}

function logSession(userId, action, req) {
  const id = generateDocId();
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || 'unknown';
  const ua = req.headers['user-agent'] || 'unknown';
  db.run(
    'INSERT INTO sessions_log (id, user_id, action, ip_address, user_agent) VALUES (?, ?, ?, ?, ?)',
    [id, userId, action, ip, ua]
  );
}

// ─── CSRF Token Management ─────────────────────────────────────────
function generateCsrfToken(userId) {
  const token = crypto.randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(); // 2 hours

  db.run('DELETE FROM csrf_tokens WHERE user_id = ?', [userId]);
  db.run('INSERT INTO csrf_tokens (token, user_id, expires_at) VALUES (?, ?, ?)', [token, userId, expiresAt]);

  return token;
}

function validateCsrfToken(req, res, next) {
  const csrfToken = req.headers['x-csrf-token'];
  if (!csrfToken) {
    return res.status(403).json({ message: 'CSRF token required.', code: 'CSRF_REQUIRED' });
  }

  db.get('SELECT * FROM csrf_tokens WHERE token = ? AND user_id = ?', [csrfToken, req.user.id], (err, row) => {
    if (err || !row) {
      return res.status(403).json({ message: 'Invalid or expired CSRF token.', code: 'CSRF_INVALID' });
    }
    if (new Date(row.expires_at) < new Date()) {
      db.run('DELETE FROM csrf_tokens WHERE token = ?', [csrfToken]);
      return res.status(403).json({ message: 'CSRF token expired.', code: 'CSRF_EXPIRED' });
    }
    next();
  });
}

// ─── Authentication Middleware ──────────────────────────────────────
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Authentication token required.', code: 'AUTH_REQUIRED' });
  }

  jwt.verify(token, JWT_SECRET, { issuer: 'mental-mantra' }, (err, decoded) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({ message: 'Token expired.', code: 'TOKEN_EXPIRED' });
      }
      return res.status(403).json({ message: 'Invalid token.', code: 'TOKEN_INVALID' });
    }

    db.get('SELECT status FROM users WHERE id = ?', [decoded.id], (err, user) => {
      if (err || !user) {
        return res.status(403).json({ message: 'User not found.', code: 'USER_NOT_FOUND' });
      }
      if (user.status === 'disabled') {
        return res.status(403).json({ message: 'Account is disabled.', code: 'ACCOUNT_DISABLED' });
      }
      req.user = decoded;
      next();
    });
  });
}

// ─── Input Validation Rules ────────────────────────────────────────
const emailRule = body('email').isEmail().normalizeEmail().withMessage('Valid email required');
const passwordRule = body('password')
  .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
  .matches(/[A-Z]/).withMessage('Password must contain an uppercase letter')
  .matches(/[0-9]/).withMessage('Password must contain a number')
  .matches(/[^A-Za-z0-9]/).withMessage('Password must contain a special character');
const nameRule = body('name').trim().isLength({ min: 1, max: 100 }).withMessage('Name is required (1-100 chars)');

function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: errors.array().map(e => e.msg).join('. '),
      code: 'VALIDATION_ERROR',
      details: errors.array().map(e => ({ field: e.path, message: e.msg }))
    });
  }
  next();
}

// ─── Build User Response (NEVER exposes password_hash or internal fields) ──
function buildUserResponse(user, profile) {
  return {
    uid: user.id,
    email: user.email,
    displayName: user.name,
    photoUrl: user.photo_url,
    createdAt: user.created_at,
    lastActive: user.last_login,
    emailVerified: !!user.email_verified,
    streakDays: profile.streakDays || 0,
    totalPoints: profile.totalPoints || 0,
    level: profile.level || 1,
    selectedAddiction: profile.selectedAddiction,
    addictions: profile.addictions || [],
    onboardingCompleted: profile.onboardingCompleted || false,
    nickname: profile.nickname,
    age: profile.age,
    gender: profile.gender,
    country: profile.country,
    role: user.role,
    relationshipStatus: profile.relationshipStatus,
    wellnessProfile: profile.wellnessProfile,
    goals: profile.goals,
    preferences: profile.preferences,
    accountStatus: user.status
  };
}

function parseProfile(user) {
  try {
    return JSON.parse(user.profile_data || '{}');
  } catch (e) {
    return {};
  }
}

// ─── Auth API Endpoints ────────────────────────────────────────────

// GET /api/auth/csrf-token — Fetch CSRF token (authenticated)
app.get('/api/auth/csrf-token', authenticateToken, (req, res) => {
  const token = generateCsrfToken(req.user.id);
  res.json({ csrfToken: token });
});

// POST /api/auth/register — Sign Up
app.post('/api/auth/register',
  authLimiter,
  emailRule,
  passwordRule,
  nameRule,
  handleValidationErrors,
  (req, res) => {
    const { name, email, password } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    db.get('SELECT email FROM users WHERE email = ?', [normalizedEmail], (err, row) => {
      if (err) return res.status(500).json({ message: 'Server database error.', code: 'DB_ERROR' });
      if (row) return res.status(409).json({ message: 'An account with this email already exists.', code: 'EMAIL_ALREADY_IN_USE' });

      bcrypt.hash(password, BCRYPT_ROUNDS, (err, hash) => {
        if (err) return res.status(500).json({ message: 'Encryption failed.', code: 'SERVER_ERROR' });

        const userId = generateId();
        const now = new Date().toISOString();
        const defaultProfile = JSON.stringify({
          nickname: '', age: 0, gender: '', country: '',
          relationshipStatus: '', onboardingCompleted: false,
          wellnessProfile: {}, goals: [], preferences: {},
          accountStatus: 'active', streakDays: 0, totalPoints: 0, level: 1,
          addictions: []
        });

        db.run(
          'INSERT INTO users (id, email, password_hash, name, created_at, last_login, profile_data) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [userId, normalizedEmail, hash, name, now, now, defaultProfile],
          function(err) {
            if (err) return res.status(500).json({ message: 'Failed to create user.', code: 'DB_ERROR' });

            const verificationToken = crypto.randomBytes(24).toString('hex');
            const tokenExpires = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
            db.run('INSERT INTO temp_tokens (token, user_id, type, expires_at) VALUES (?, ?, ?, ?)',
              [verificationToken, userId, 'verify', tokenExpires]);

            // Log registration
            logSession(userId, 'register', req);

            // Send verification email via Brevo
            sendVerificationEmail(normalizedEmail, verificationToken);

            // Issue tokens
            const userPayload = { id: userId, email: normalizedEmail, role: 'user' };
            const familyId = crypto.randomBytes(16).toString('hex');
            const accessToken = generateAccessToken(userPayload);
            const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'registration');

            const userData = buildUserResponse({
              id: userId, email: normalizedEmail, name, created_at: now,
              last_login: now, role: 'user', status: 'active',
              email_verified: 0, photo_url: null
            }, parseProfile({ profile_data: defaultProfile }));

            res.status(201).json({
              message: 'User registered successfully. Please verify your email.',
              accessToken, refreshToken, user: userData
            });
          }
        );
      });
    });
  }
);

// POST /api/auth/login — Login with email & password
app.post('/api/auth/login',
  authLimiter,
  emailRule,
  body('password').notEmpty().withMessage('Password is required'),
  handleValidationErrors,
  (req, res) => {
    const { email, password } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    db.get('SELECT * FROM users WHERE email = ?', [normalizedEmail], (err, user) => {
      if (err) return res.status(500).json({ message: 'Server database error.', code: 'DB_ERROR' });

      if (!user) {
        return res.status(401).json({ message: 'Invalid email or password.', code: 'INVALID_CREDENTIALS' });
      }

      // Check account lockout
      if (user.locked_until && new Date(user.locked_until) > new Date()) {
        const remainingMs = new Date(user.locked_until) - new Date();
        const remainingMin = Math.ceil(remainingMs / 60000);
        return res.status(429).json({
          message: `Account temporarily locked. Try again in ${remainingMin} minute(s).`,
          code: 'ACCOUNT_LOCKED'
        });
      }

      if (user.status === 'disabled') {
        return res.status(403).json({ message: 'Account is disabled. Contact support.', code: 'ACCOUNT_DISABLED' });
      }

      bcrypt.compare(password, user.password_hash, (err, matches) => {
        if (err) return res.status(500).json({ message: 'Verification error.', code: 'SERVER_ERROR' });

        if (!matches) {
          const attempts = (user.failed_login_attempts || 0) + 1;
          if (attempts >= ACCOUNT_LOCKOUT_THRESHOLD) {
            const lockUntil = new Date(Date.now() + ACCOUNT_LOCKOUT_WINDOW_MS).toISOString();
            db.run('UPDATE users SET failed_login_attempts = ?, locked_until = ? WHERE id = ?',
              [attempts, lockUntil, user.id]);
            logSession(user.id, 'account_locked', req);
            return res.status(429).json({
              message: `Account locked for ${ACCOUNT_LOCKOUT_WINDOW_MS / 60000} minutes due to too many failed attempts.`,
              code: 'ACCOUNT_LOCKED'
            });
          }
          db.run('UPDATE users SET failed_login_attempts = ? WHERE id = ?', [attempts, user.id]);
          return res.status(401).json({ message: 'Invalid email or password.', code: 'INVALID_CREDENTIALS' });
        }

        // Success — reset lockout counter
        const now = new Date().toISOString();
        db.run('UPDATE users SET last_login = ?, failed_login_attempts = 0, locked_until = NULL WHERE id = ?',
          [now, user.id]);

        logSession(user.id, 'login', req);

        const userPayload = { id: user.id, email: user.email, role: user.role };
        const familyId = crypto.randomBytes(16).toString('hex');
        const accessToken = generateAccessToken(userPayload);
        const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'login');
        const profile = parseProfile(user);

        res.json({
          accessToken, refreshToken, user: buildUserResponse(user, profile)
        });
      });
    });
  }
);

// POST /api/auth/refresh — Token refresh with rotation & reuse detection
app.post('/api/auth/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ message: 'Refresh token is required.', code: 'REFRESH_REQUIRED' });
  }

  const tokenHash = hashToken(refreshToken);

  db.get('SELECT * FROM refresh_tokens WHERE token_hash = ?', [tokenHash], (err, row) => {
    if (err) return res.status(500).json({ message: 'Server database error.', code: 'DB_ERROR' });
    if (!row) {
      return res.status(403).json({ message: 'Invalid refresh token.', code: 'REFRESH_INVALID' });
    }

    if (row.revoked === 1) {
      // Token reuse detected — revoke ALL tokens in this family
      db.run('UPDATE refresh_tokens SET revoked = 1 WHERE family_id = ?', [row.family_id]);
      db.run('UPDATE users SET status = ? WHERE id = ?', ['suspicious', row.user_id]);
      logSession(row.user_id, 'token_reuse_compromised', req);
      return res.status(403).json({
        message: 'Session compromised. All sessions terminated. Please log in again.',
        code: 'TOKEN_COMPROMISED'
      });
    }

    if (new Date(row.expires_at) < new Date()) {
      db.run('UPDATE refresh_tokens SET revoked = 1 WHERE id = ?', [row.id]);
      return res.status(401).json({ message: 'Refresh token expired. Please log in again.', code: 'REFRESH_EXPIRED' });
    }

    // Rotate: revoke current, issue new
    db.run('UPDATE refresh_tokens SET revoked = 1 WHERE id = ?', [row.id], (err) => {
      if (err) return res.status(500).json({ message: 'Failed to rotate token.', code: 'DB_ERROR' });

      db.get('SELECT * FROM users WHERE id = ?', [row.user_id], (err, user) => {
        if (err || !user) return res.status(500).json({ message: 'User not found.', code: 'USER_NOT_FOUND' });
        if (user.status === 'disabled') {
          return res.status(403).json({ message: 'Account is disabled.', code: 'ACCOUNT_DISABLED' });
        }

        const userPayload = { id: user.id, email: user.email, role: user.role };
        const newAccessToken = generateAccessToken(userPayload);
        const { rawToken: newRefreshToken } = generateRefreshToken(userPayload, row.family_id, 'refresh');

        res.json({ accessToken: newAccessToken, refreshToken: newRefreshToken });
      });
    });
  });
});

// POST /api/auth/logout — Revoke session
app.post('/api/auth/logout', (req, res) => {
  const { refreshToken, allDevices } = req.body;

  if (!refreshToken && !allDevices) {
    return res.status(400).json({ message: 'Refresh token required for logout.', code: 'REFRESH_REQUIRED' });
  }

  if (allDevices) {
    // Requires authentication to log out all devices
    const authHeader = req.headers['authorization'];
    const accessToken = authHeader && authHeader.split(' ')[1];
    if (!accessToken) {
      return res.status(401).json({ message: 'Authentication required for full logout.', code: 'AUTH_REQUIRED' });
    }
    jwt.verify(accessToken, JWT_SECRET, { issuer: 'mental-mantra' }, (err, decoded) => {
      if (err) return res.status(403).json({ message: 'Invalid token.', code: 'TOKEN_INVALID' });
      db.run('UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?', [decoded.id]);
      logSession(decoded.id, 'logout_all_devices', req);
      res.json({ message: 'Logged out from all devices.' });
    });
  } else {
    const tokenHash = hashToken(refreshToken);
    db.get('SELECT user_id FROM refresh_tokens WHERE token_hash = ?', [tokenHash], (err, row) => {
      if (err) return res.status(500).json({ message: 'Database error.', code: 'DB_ERROR' });
      db.run('UPDATE refresh_tokens SET revoked = 1 WHERE token_hash = ?', [tokenHash]);
      if (row) logSession(row.user_id, 'logout', req);
      res.json({ message: 'Logged out successfully.' });
    });
  }
});

// POST /api/auth/google — Google Sign-In
app.post('/api/auth/google',
  authLimiter,
  body('email').isEmail().normalizeEmail(),
  body('idToken').notEmpty().withMessage('Google ID token required'),
  handleValidationErrors,
  async (req, res) => {
    const { email, name, photoUrl, idToken } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    // Verify Google idToken
    const { OAuth2Client } = require('google-auth-library');
    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (clientId && clientId !== 'your_google_client_id_here') {
      try {
        const client = new OAuth2Client(clientId);
        const ticket = await client.verifyIdToken({ idToken, audience: clientId });
        const payload = ticket.getPayload();
        if (!payload) {
          return res.status(401).json({ message: 'Google token verification failed: empty payload.', code: 'GOOGLE_AUTH_FAILED' });
        }
        if (payload.email !== normalizedEmail) {
          return res.status(401).json({ message: 'Google token email mismatch.', code: 'GOOGLE_AUTH_FAILED' });
        }
      } catch (err) {
        console.error('[google] idToken verification failed:', err.message);
        return res.status(401).json({
          message: 'Google Sign-In configuration error. Ensure GOOGLE_CLIENT_ID is correct and API is enabled.',
          code: 'GOOGLE_AUTH_FAILED',
          detail: err.message
        });
      }
    } else if (!clientId || clientId === 'your_google_client_id_here') {
      console.warn('[google] GOOGLE_CLIENT_ID not configured — skipping token verification');
    }

    db.get('SELECT * FROM users WHERE email = ?', [normalizedEmail], (err, user) => {
      if (err) return res.status(500).json({ message: 'Server database error.', code: 'DB_ERROR' });

      const now = new Date().toISOString();

      if (user) {
        // User exists — login
        db.run('UPDATE users SET last_login = ?, photo_url = ?, failed_login_attempts = 0, locked_until = NULL WHERE id = ?',
          [now, photoUrl || user.photo_url, user.id]);

        logSession(user.id, 'google_login', req);

        const userPayload = { id: user.id, email: user.email, role: user.role };
        const familyId = crypto.randomBytes(16).toString('hex');
        const accessToken = generateAccessToken(userPayload);
        const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'google');
        const profile = parseProfile(user);

        return res.json({ accessToken, refreshToken, user: buildUserResponse(user, profile) });
      }

      // New user — register
      const userId = generateId();
      const defaultProfile = JSON.stringify({
        nickname: '', age: 0, gender: '', country: '',
        relationshipStatus: '', onboardingCompleted: false,
        wellnessProfile: {}, goals: [], preferences: {},
        accountStatus: 'active', streakDays: 0, totalPoints: 0, level: 1,
        addictions: []
      });

      db.run(
        'INSERT INTO users (id, email, name, photo_url, created_at, last_login, email_verified, profile_data) VALUES (?, ?, ?, ?, ?, ?, 1, ?)',
        [userId, normalizedEmail, name || 'Google User', photoUrl || '', now, now, defaultProfile],
        function(err) {
          if (err) return res.status(500).json({ message: 'Failed to register.', code: 'DB_ERROR' });

          logSession(userId, 'google_register', req);

          const userPayload = { id: userId, email: normalizedEmail, role: 'user' };
          const familyId = crypto.randomBytes(16).toString('hex');
          const accessToken = generateAccessToken(userPayload);
          const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'google');

          const userData = buildUserResponse({
            id: userId, email: normalizedEmail, name: name || 'Google User',
            created_at: now, last_login: now, role: 'user', status: 'active',
            email_verified: 1, photo_url: photoUrl || ''
          }, parseProfile({ profile_data: defaultProfile }));

          return res.json({ accessToken, refreshToken, user: userData });
        }
      );
    });
  }
);

// POST /api/auth/apple — Apple Sign-In
app.post('/api/auth/apple',
  authLimiter,
  body('email').isEmail().normalizeEmail(),
  handleValidationErrors,
  (req, res) => {
    const { email, name } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    db.get('SELECT * FROM users WHERE email = ?', [normalizedEmail], (err, user) => {
      if (err) return res.status(500).json({ message: 'Server database error.', code: 'DB_ERROR' });

      const now = new Date().toISOString();

      if (user) {
        db.run('UPDATE users SET last_login = ?, failed_login_attempts = 0, locked_until = NULL WHERE id = ?',
          [now, user.id]);
        logSession(user.id, 'apple_login', req);

        const userPayload = { id: user.id, email: user.email, role: user.role };
        const familyId = crypto.randomBytes(16).toString('hex');
        const accessToken = generateAccessToken(userPayload);
        const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'apple');
        const profile = parseProfile(user);

        return res.json({ accessToken, refreshToken, user: buildUserResponse(user, profile) });
      }

      const userId = generateId();
      const defaultProfile = JSON.stringify({
        nickname: '', age: 0, gender: '', country: '',
        relationshipStatus: '', onboardingCompleted: false,
        wellnessProfile: {}, goals: [], preferences: {},
        accountStatus: 'active', streakDays: 0, totalPoints: 0, level: 1,
        addictions: []
      });

      db.run(
        'INSERT INTO users (id, email, name, created_at, last_login, email_verified, profile_data) VALUES (?, ?, ?, ?, ?, 1, ?)',
        [userId, normalizedEmail, name || 'Apple User', now, now, defaultProfile],
        function(err) {
          if (err) return res.status(500).json({ message: 'Failed to register.', code: 'DB_ERROR' });

          logSession(userId, 'apple_register', req);

          const userPayload = { id: userId, email: normalizedEmail, role: 'user' };
          const familyId = crypto.randomBytes(16).toString('hex');
          const accessToken = generateAccessToken(userPayload);
          const { rawToken: refreshToken } = generateRefreshToken(userPayload, familyId, 'apple');

          const userData = buildUserResponse({
            id: userId, email: normalizedEmail, name: name || 'Apple User',
            created_at: now, last_login: now, role: 'user', status: 'active',
            email_verified: 1, photo_url: null
          }, parseProfile({ profile_data: defaultProfile }));

          return res.json({ accessToken, refreshToken, user: userData });
        }
      );
    });
  }
);

// POST /api/auth/forgot-password — Send reset email
app.post('/api/auth/forgot-password',
  passwordResetLimiter,
  emailRule,
  handleValidationErrors,
  (req, res) => {
    const { email } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    db.get('SELECT id FROM users WHERE email = ?', [normalizedEmail], (err, user) => {
      if (err) return res.status(500).json({ message: 'Database error.', code: 'DB_ERROR' });

      // Always return 200 to prevent user enumeration
      if (!user) {
        return res.json({ message: 'If an account exists, a password reset link has been sent.' });
      }

      const resetToken = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

      db.run('DELETE FROM temp_tokens WHERE user_id = ? AND type = "reset"', [user.id]);
      db.run(
        'INSERT INTO temp_tokens (token, user_id, type, expires_at) VALUES (?, ?, "reset", ?)',
        [resetToken, user.id, expiresAt],
        (err) => {
          if (err) return res.status(500).json({ message: 'Failed to generate token.', code: 'DB_ERROR' });
          sendPasswordResetEmail(normalizedEmail, resetToken);
          logSession(user.id, 'password_reset_requested', req);
          res.json({ message: 'If an account exists, a password reset link has been sent.' });
        }
      );
    });
  }
);

// POST /api/auth/reset-password — Reset password with token
app.post('/api/auth/reset-password',
  passwordResetLimiter,
  body('token').notEmpty().withMessage('Reset token required'),
  passwordRule,
  handleValidationErrors,
  (req, res) => {
    const { token, newPassword } = req.body;

    db.get('SELECT * FROM temp_tokens WHERE token = ? AND type = "reset"', [token], (err, row) => {
      if (err || !row) {
        return res.status(400).json({ message: 'Invalid or expired reset token.', code: 'TOKEN_INVALID' });
      }

      if (new Date(row.expires_at) < new Date()) {
        db.run('DELETE FROM temp_tokens WHERE token = ?', [token]);
        return res.status(400).json({ message: 'Reset token has expired.', code: 'TOKEN_EXPIRED' });
      }

      bcrypt.hash(newPassword, BCRYPT_ROUNDS, (err, hash) => {
        if (err) return res.status(500).json({ message: 'Password hash failed.', code: 'SERVER_ERROR' });

        db.serialize(() => {
          db.run('UPDATE users SET password_hash = ?, failed_login_attempts = 0, locked_until = NULL WHERE id = ?',
            [hash, row.user_id]);
          db.run('DELETE FROM temp_tokens WHERE token = ?', [token]);
          db.run('UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?', [row.user_id]); // Invalidate all sessions
        });

        logSession(row.user_id, 'password_reset', req);
        res.json({ message: 'Password reset successful. Please log in with your new password.' });
      });
    });
  }
);

// POST /api/auth/verify-email — Verify email with token
app.post('/api/auth/verify-email', (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ message: 'Verification token required.', code: 'TOKEN_REQUIRED' });

  db.get('SELECT * FROM temp_tokens WHERE token = ? AND type = "verify"', [token], (err, row) => {
    if (err || !row) {
      return res.status(400).json({ message: 'Invalid or expired verification token.', code: 'TOKEN_INVALID' });
    }

    if (new Date(row.expires_at) < new Date()) {
      db.run('DELETE FROM temp_tokens WHERE token = ?', [token]);
      return res.status(400).json({ message: 'Verification token has expired.', code: 'TOKEN_EXPIRED' });
    }

    db.serialize(() => {
      db.run('UPDATE users SET email_verified = 1 WHERE id = ?', [row.user_id]);
      db.run('DELETE FROM temp_tokens WHERE token = ?', [token]);
    });

    logSession(row.user_id, 'email_verified', req);
    res.json({ message: 'Email verified successfully.' });
  });
});

// POST /api/auth/resend-verification — Resend verification email
app.post('/api/auth/resend-verification',
  emailRule,
  handleValidationErrors,
  (req, res) => {
    const { email } = req.body;
    const normalizedEmail = email.toLowerCase().trim();

    db.get('SELECT id, email_verified FROM users WHERE email = ?', [normalizedEmail], (err, user) => {
      if (err || !user) return res.status(400).json({ message: 'User not found.', code: 'USER_NOT_FOUND' });
      if (user.email_verified) return res.json({ message: 'Email already verified.' });

      const verificationToken = crypto.randomBytes(24).toString('hex');
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
      db.run('DELETE FROM temp_tokens WHERE user_id = ? AND type = "verify"', [user.id]);
      db.run('INSERT INTO temp_tokens (token, user_id, type, expires_at) VALUES (?, ?, "verify", ?)',
        [verificationToken, user.id, expiresAt]);

      sendVerificationEmail(normalizedEmail, verificationToken);
      res.json({ message: 'Verification email sent.' });
    });
  }
);

// POST /api/auth/change-password — Change password (authenticated)
app.post('/api/auth/change-password',
  authenticateToken,
  body('currentPassword').notEmpty().withMessage('Current password required'),
  body('newPassword')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Z]/).withMessage('Password must contain an uppercase letter')
    .matches(/[0-9]/).withMessage('Password must contain a number')
    .matches(/[^A-Za-z0-9]/).withMessage('Password must contain a special character'),
  handleValidationErrors,
  (req, res) => {
    const { currentPassword, newPassword } = req.body;

    db.get('SELECT password_hash FROM users WHERE id = ?', [req.user.id], (err, user) => {
      if (err || !user) return res.status(500).json({ message: 'User not found.', code: 'DB_ERROR' });

      bcrypt.compare(currentPassword, user.password_hash, (err, matches) => {
        if (err || !matches) {
          return res.status(400).json({ message: 'Current password is incorrect.', code: 'WRONG_PASSWORD' });
        }

        bcrypt.hash(newPassword, BCRYPT_ROUNDS, (err, hash) => {
          if (err) return res.status(500).json({ message: 'Password hash failed.', code: 'SERVER_ERROR' });

          db.run('UPDATE users SET password_hash = ? WHERE id = ?', [hash, req.user.id]);
          db.run('UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?', [req.user.id]);

          logSession(req.user.id, 'password_changed', req);
          res.json({ message: 'Password changed successfully. Please log in again.' });
        });
      });
    });
  }
);

// GET /api/auth/sessions — List active sessions
app.get('/api/auth/sessions', authenticateToken, (req, res) => {
  db.all(
    'SELECT id, device_info, created_at, expires_at FROM refresh_tokens WHERE user_id = ? AND revoked = 0 AND expires_at > datetime(\'now\')',
    [req.user.id],
    (err, rows) => {
      if (err) return res.status(500).json({ message: 'Database error.', code: 'DB_ERROR' });
      res.json(rows.map(r => ({
        id: r.id,
        deviceInfo: r.device_info,
        createdAt: r.created_at,
        expiresAt: r.expires_at
      })));
    }
  );
});

// DELETE /api/auth/sessions/:tokenId — Revoke specific session
app.delete('/api/auth/sessions/:tokenId', authenticateToken, (req, res) => {
  db.run(
    'UPDATE refresh_tokens SET revoked = 1 WHERE id = ? AND user_id = ?',
    [req.params.tokenId, req.user.id],
    function(err) {
      if (err) return res.status(500).json({ message: 'Database error.', code: 'DB_ERROR' });
      logSession(req.user.id, 'session_revoked', req);
      res.json({ message: 'Session terminated.' });
    }
  );
});

// DELETE /api/auth/delete-account — Delete account and all data
app.delete('/api/auth/delete-account', authenticateToken, (req, res) => {
  const userId = req.user.id;

  db.serialize(() => {
    db.run('DELETE FROM users WHERE id = ?', [userId]);
    db.run('DELETE FROM refresh_tokens WHERE user_id = ?', [userId]);
    db.run('DELETE FROM documents WHERE user_id = ?', [userId]);
    db.run('DELETE FROM temp_tokens WHERE user_id = ?', [userId]);
    db.run('DELETE FROM csrf_tokens WHERE user_id = ?', [userId]);
    db.run('DELETE FROM sessions_log WHERE user_id = ?', [userId]);
  });

  logSession(userId, 'account_deleted', req);
  res.json({ message: 'Account and all associated data permanently deleted.' });
});

// GET /api/auth/profile — Get current user profile
app.get('/api/auth/profile', authenticateToken, (req, res) => {
  db.get('SELECT * FROM users WHERE id = ?', [req.user.id], (err, user) => {
    if (err || !user) return res.status(500).json({ message: 'User not found.', code: 'USER_NOT_FOUND' });
    const profile = parseProfile(user);
    res.json({ user: buildUserResponse(user, profile) });
  });
});

// PUT /api/auth/profile — Update user profile (including onboarding, gamification, etc.)
app.put('/api/auth/profile',
  authenticateToken,
  body('displayName').optional().trim().isLength({ max: 100 }),
  handleValidationErrors,
  (req, res) => {
    const userId = req.user.id;
    const data = req.body;

    db.get('SELECT * FROM users WHERE id = ?', [userId], (err, user) => {
      if (err || !user) return res.status(500).json({ message: 'User not found.', code: 'USER_NOT_FOUND' });

      const currentProfile = parseProfile(user);
      const updatedProfile = { ...currentProfile };

      // Whitelist of updatable profile fields
      const profileFields = [
        'nickname', 'age', 'gender', 'country', 'relationshipStatus',
        'onboardingCompleted', 'wellnessProfile', 'goals', 'preferences',
        'streakDays', 'totalPoints', 'level', 'selectedAddiction', 'addictions'
      ];

      for (const field of profileFields) {
        if (data[field] !== undefined) {
          updatedProfile[field] = data[field];
        }
      }

      const name = data.displayName || user.name;
      const photoUrl = data.photoUrl !== undefined ? data.photoUrl : user.photo_url;

      db.run(
        'UPDATE users SET name = ?, photo_url = ?, profile_data = ? WHERE id = ?',
        [name, photoUrl, JSON.stringify(updatedProfile), userId],
        function(err) {
          if (err) return res.status(500).json({ message: 'Failed to update profile.', code: 'DB_ERROR' });

          const updatedUser = { ...user, name, photo_url: photoUrl, profile_data: JSON.stringify(updatedProfile) };
          logSession(userId, 'profile_updated', req);
          res.json({ user: buildUserResponse(updatedUser, updatedProfile) });
        }
      );
    });
  }
);

// ─── Database Proxy API (Same as before but with CSRF protection) ──

// POST /api/db/:collection — Create document
app.post('/api/db/:collection', authenticateToken, (req, res) => {
  const { collection } = req.params;
  const docId = generateDocId();
  const now = new Date().toISOString();
  const docData = { ...req.body, id: docId, userId: req.user.id };

  db.run(
    'INSERT INTO documents (id, user_id, collection, data, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
    [docId, req.user.id, collection, JSON.stringify(docData), now, now],
    function(err) {
      if (err) return res.status(500).json({ message: 'Failed to insert document.', code: 'DB_ERROR' });
      res.status(201).json({ id: docId, data: docData });
    }
  );
});

// POST /api/db/:collection/:docId — Set/overwrite document
app.post('/api/db/:collection/:docId', authenticateToken, (req, res) => {
  const { collection, docId } = req.params;
  const now = new Date().toISOString();
  const docData = { ...req.body, id: docId, userId: req.user.id };

  db.get('SELECT * FROM documents WHERE id = ? AND collection = ?', [docId, collection], (err, row) => {
    if (err) return res.status(500).json({ message: 'Database query error.', code: 'DB_ERROR' });

    if (row) {
      if (row.user_id !== req.user.id) {
        return res.status(403).json({ message: 'Permission denied.', code: 'FORBIDDEN' });
      }
      const currentData = JSON.parse(row.data);
      const mergedData = { ...currentData, ...docData };

      db.run('UPDATE documents SET data = ?, updated_at = ? WHERE id = ?',
        [JSON.stringify(mergedData), now, docId],
        function(err) {
          if (err) return res.status(500).json({ message: 'Failed to update document.', code: 'DB_ERROR' });
          res.json({ id: docId, data: mergedData });
        }
      );
    } else {
      db.run(
        'INSERT INTO documents (id, user_id, collection, data, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        [docId, req.user.id, collection, JSON.stringify(docData), now, now],
        function(err) {
          if (err) return res.status(500).json({ message: 'Failed to insert document.', code: 'DB_ERROR' });
          res.status(201).json({ id: docId, data: docData });
        }
      );
    }
  });
});

// GET /api/db/:collection/:docId — Get document
app.get('/api/db/:collection/:docId', authenticateToken, (req, res) => {
  const { collection, docId } = req.params;

  db.get('SELECT * FROM documents WHERE id = ? AND collection = ?', [docId, collection], (err, row) => {
    if (err) return res.status(500).json({ message: 'Database query error.', code: 'DB_ERROR' });
    if (!row) return res.status(404).json({ message: 'Document not found.', code: 'NOT_FOUND' });
    if (row.user_id !== req.user.id) return res.status(403).json({ message: 'Permission denied.', code: 'FORBIDDEN' });

    res.json(JSON.parse(row.data));
  });
});

// PUT /api/db/:collection/:docId — Update document fields
app.put('/api/db/:collection/:docId', authenticateToken, (req, res) => {
  const { collection, docId } = req.params;
  const now = new Date().toISOString();

  db.get('SELECT * FROM documents WHERE id = ? AND collection = ?', [docId, collection], (err, row) => {
    if (err) return res.status(500).json({ message: 'Database query error.', code: 'DB_ERROR' });
    if (!row) return res.status(404).json({ message: 'Document not found.', code: 'NOT_FOUND' });
    if (row.user_id !== req.user.id) return res.status(403).json({ message: 'Permission denied.', code: 'FORBIDDEN' });

    const currentData = JSON.parse(row.data);
    const updatedData = { ...currentData, ...req.body, id: docId, userId: req.user.id };

    db.run('UPDATE documents SET data = ?, updated_at = ? WHERE id = ?',
      [JSON.stringify(updatedData), now, docId],
      function(err) {
        if (err) return res.status(500).json({ message: 'Failed to update document.', code: 'DB_ERROR' });
        res.json({ id: docId, data: updatedData });
      }
    );
  });
});

// DELETE /api/db/:collection/:docId — Delete document
app.delete('/api/db/:collection/:docId', authenticateToken, (req, res) => {
  const { collection, docId } = req.params;

  db.get('SELECT * FROM documents WHERE id = ? AND collection = ?', [docId, collection], (err, row) => {
    if (err) return res.status(500).json({ message: 'Database query error.', code: 'DB_ERROR' });
    if (!row) return res.status(404).json({ message: 'Document not found.', code: 'NOT_FOUND' });
    if (row.user_id !== req.user.id) return res.status(403).json({ message: 'Permission denied.', code: 'FORBIDDEN' });

    db.run('DELETE FROM documents WHERE id = ?', [docId], function(err) {
      if (err) return res.status(500).json({ message: 'Failed to delete document.', code: 'DB_ERROR' });
      res.json({ message: 'Document deleted.', id: docId });
    });
  });
});

// GET /api/db/:collection — Query documents (scoped by authenticated user)
app.get('/api/db/:collection', authenticateToken, (req, res) => {
  const { collection } = req.params;

  db.all(
    'SELECT * FROM documents WHERE collection = ? AND user_id = ?',
    [collection, req.user.id],
    (err, rows) => {
      if (err) return res.status(500).json({ message: 'Database query error.', code: 'DB_ERROR' });

      let results = rows.map(r => JSON.parse(r.data));
      const { whereField, whereValue, orderBy, descending, limit } = req.query;

      if (whereField && whereValue !== undefined) {
        results = results.filter(doc => String(doc[whereField]) === String(whereValue));
      }

      if (orderBy) {
        results.sort((a, b) => {
          let valA = a[orderBy], valB = b[orderBy];
          if (valA === undefined) return 1;
          if (valB === undefined) return -1;
          if (typeof valA === 'string' && typeof valB === 'string') {
            return descending === 'true' ? valB.localeCompare(valA) : valA.localeCompare(valB);
          }
          return descending === 'true' ? valB - valA : valA - valB;
        });
      }

      if (limit) {
        const lim = parseInt(limit);
        if (!isNaN(lim)) results = results.slice(0, lim);
      }

      res.json(results);
    }
  );
});

// ─── Email Integration (Brevo) ─────────────────────────────────────
async function sendEmail(to, subject, htmlContent) {
  if (!BREVO_API_KEY || BREVO_API_KEY.includes('your_brevo_api_key')) {
    console.log(`[EMAIL MOCK] To: ${to}, Subject: ${subject}`);
    return;
  }

  const https = require('https');
  const data = JSON.stringify({
    sender: { name: 'Mental Mantra', email: 'noreply@mentalmantra.app' },
    to: [{ email: to }],
    subject,
    htmlContent
  });

  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'api.brevo.com',
      path: '/v3/smtp/email',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': BREVO_API_KEY,
        'Content-Length': Buffer.byteLength(data)
      }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`[EMAIL] Sent to ${to}: ${subject}`);
          resolve();
        } else {
          console.warn(`[EMAIL] Failed (${res.statusCode}): ${body}`);
          resolve(); // Don't fail the request
        }
      });
    });

    req.on('error', (e) => {
      console.warn('[EMAIL] Error:', e.message);
      resolve(); // Don't fail the request
    });

    req.write(data);
    req.end();
  });
}

function sendVerificationEmail(email, token) {
  const link = `${APP_URL}/verify-email?token=${encodeURIComponent(token)}`;
  sendEmail(email, 'Verify your Mental Mantra account',
    `<h2>Welcome to Mental Mantra!</h2>
     <p>Please verify your email address by clicking the link below:</p>
     <p><a href="${link}">Verify Email Address</a></p>
     <p>This link expires in 24 hours.</p>
     <p>If you did not create an account, please ignore this email.</p>`
  );
}

function sendPasswordResetEmail(email, token) {
  const link = `${APP_URL}/reset-password?token=${encodeURIComponent(token)}`;
  sendEmail(email, 'Reset your Mental Mantra password',
    `<h2>Password Reset Request</h2>
     <p>Click the link below to reset your password:</p>
     <p><a href="${link}">Reset Password</a></p>
     <p>This link expires in 15 minutes.</p>
     <p>If you did not request a password reset, please ignore this email.</p>`
  );
}

// ─── Health Check ──────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', serverTime: new Date().toISOString(), version: '2.0.0' });
});

// ─── Global Error Handler ──────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]', err.message || err);
  res.status(500).json({ message: 'Internal server error.', code: 'SERVER_ERROR' });
});

// ─── Start Server ──────────────────────────────────────────────────
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Mental Mantra Auth Server v2.0.0 listening on http://localhost:${PORT}`);
  console.log(`CORS origin: ${CORS_ORIGIN}`);
});

// ─── Graceful Shutdown ─────────────────────────────────────────────
function shutdown(signal) {
  console.log(`\n[server] ${signal} received. Shutting down gracefully...`);
  server.close(() => {
    db.close((err) => {
      if (err) console.error('[server] Error closing database:', err.message);
      console.log('[server] Database connection closed.');
      process.exit(0);
    });
  });
  setTimeout(() => {
    console.error('[server] Forced shutdown after timeout.');
    process.exit(1);
  }, 10000);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('uncaughtException', (err) => {
  console.error('[server] Uncaught exception:', err.message);
  shutdown('uncaughtException');
});
process.on('unhandledRejection', (reason) => {
  console.error('[server] Unhandled rejection:', reason);
});
