// backend/src/server.js
'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto');
require('dotenv').config();

const { prisma } = require('./db/prisma');
const { logger } = require('./utils/logger');
const errorHandler = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const moodRoutes = require('./routes/mood.routes');
const journalRoutes = require('./routes/journal.routes');
const habitRoutes = require('./routes/habit.routes');
const meditationRoutes = require('./routes/meditation.routes');
const goalRoutes = require('./routes/goal.routes');
const aiRoutes = require('./routes/ai.routes');
const sleepRoutes = require('./routes/sleep.routes');
const notificationRoutes = require('./routes/notification.routes');
const musicRoutes = require('./routes/music.routes');
const adminRoutes = require('./routes/admin.routes');
const recoveryRoutes = require('./routes/recovery.routes');
const supportRoutes = require('./routes/support.routes');
const profileRoutes = require('./routes/profile.routes');

const app = express();
const PORT = process.env.PORT || 3000;
const API_PREFIX = `/api`;
const isProduction = process.env.NODE_ENV === 'production';

// ── Startup Validation ──────────────────────────────────────────
function validateEnvironment() {
  const required = ['DATABASE_URL'];
  const productionRequired = ['JWT_ACCESS_SECRET', 'JWT_REFRESH_SECRET', 'GOOGLE_CLIENT_ID'];

  if (isProduction) {
    for (const key of required) {
      if (!process.env[key]) {
        logger.error(`FATAL: Missing required env var: ${key}`);
        process.exit(1);
      }
    }
    for (const key of productionRequired) {
      if (!process.env[key] || process.env[key].startsWith('your_') || process.env[key].startsWith('change_this')) {
        logger.error(`FATAL: Production requires a real value for ${key}. Set via environment variable.`);
        process.exit(1);
      }
    }
  } else {
    for (const key of required) {
      if (!process.env[key]) {
        logger.warn(`Missing required env var: ${key} — app may not function correctly`);
      }
    }
  }

  // Auto-generate JWT secrets if using placeholders in development
  if (!isProduction) {
    if (!process.env.JWT_ACCESS_SECRET || process.env.JWT_ACCESS_SECRET.startsWith('change_this')) {
      process.env.JWT_ACCESS_SECRET = crypto.randomBytes(32).toString('hex');
      logger.info('Auto-generated JWT_ACCESS_SECRET for development');
    }
    if (!process.env.JWT_REFRESH_SECRET || process.env.JWT_REFRESH_SECRET.startsWith('change_this')) {
      process.env.JWT_REFRESH_SECRET = crypto.randomBytes(32).toString('hex');
      logger.info('Auto-generated JWT_REFRESH_SECRET for development');
    }
  }
}

validateEnvironment();

// ── Security ──────────────────────────────────────────────────────
app.use(helmet());

// CORS — allow mobile apps (null origin), emulators, and configured origins
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map(o => o.trim())
  .filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    // Allow: no origin (mobile apps, file://) or explicit match
    if (!origin || allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error(`CORS blocked: ${origin}`));
    }
  },
  credentials: !allowedOrigins.includes('*'),
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Global rate limiter
const rateLimitWindowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS);
const rateLimitMax = parseInt(process.env.RATE_LIMIT_MAX_REQUESTS);
app.use(rateLimit({
  windowMs: Number.isFinite(rateLimitWindowMs) ? rateLimitWindowMs : 15 * 60 * 1000,
  max: Number.isFinite(rateLimitMax) ? rateLimitMax : 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Please slow down.' },
}));

// ── Parsing & Compression ─────────────────────────────────────────
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── Logging ───────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined', { stream: { write: (msg) => logger.info(msg.trim()) } }));
}

// ── Health Check ──────────────────────────────────────────────────
app.get('/api/health', async (req, res) => {
  let dbStatus = 'disconnected';
  try {
    await prisma.$queryRaw`SELECT 1`;
    dbStatus = 'connected';
  } catch (e) {
    dbStatus = 'error';
  }
  res.json({
    status: 'ok',
    database: dbStatus,
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Legacy /health redirect
app.get('/health', (req, res) => {
  res.redirect('/api/health');
});

// ── Routes ────────────────────────────────────────────────────────
app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/mood`, moodRoutes);
app.use(`${API_PREFIX}/journal`, journalRoutes);
app.use(`${API_PREFIX}/habits`, habitRoutes);
app.use(`${API_PREFIX}/meditation`, meditationRoutes);
app.use(`${API_PREFIX}/goals`, goalRoutes);
app.use(`${API_PREFIX}/ai`, aiRoutes);
app.use(`${API_PREFIX}/sleep`, sleepRoutes);
app.use(`${API_PREFIX}/notifications`, notificationRoutes);
app.use(`${API_PREFIX}/music`, musicRoutes);
app.use(`${API_PREFIX}/admin`, adminRoutes);
app.use(`${API_PREFIX}/recovery`, recoveryRoutes);
app.use(`${API_PREFIX}/support`, supportRoutes);
app.use(`${API_PREFIX}/profile`, profileRoutes);

// 404
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.url} not found` });
});

// ── Error Handler ─────────────────────────────────────────────────
app.use(errorHandler);

// ── Start ─────────────────────────────────────────────────────────
async function start() {
  try {
    await prisma.$connect();
    logger.info('✅ Database connected');
  } catch (err) {
    logger.warn('⚠️  Database not available — running without DB:', err.message);
  }

  app.listen(PORT, '0.0.0.0', () => {
    logger.info(`🚀 Mental Mantra API running on port ${PORT}`);
    logger.info(`📖 Health: http://localhost:${PORT}/health`);
  });
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  prisma.$disconnect().finally(() => process.exit(1));
});

start();

module.exports = app;
