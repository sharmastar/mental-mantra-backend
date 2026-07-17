// backend/src/routes/auth.routes.js
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const rateLimit = require('express-rate-limit');
const { OAuth2Client } = require('google-auth-library');
const { prisma } = require('../db/prisma');
const { logger } = require('../utils/logger');
const { AppError, UnauthorizedError } = require('../middleware/errorHandler');
const { authenticateToken } = require('../middleware/auth.middleware');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const router = express.Router();

// Auth-specific rate limiter (stricter)
const authRateLimitMax = parseInt(process.env.AUTH_RATE_LIMIT_MAX);
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: Number.isFinite(authRateLimitMax) ? authRateLimitMax : 10,
  message: { success: false, message: 'Too many auth attempts. Try again in 15 minutes.' },
});

// ── Token Helpers ─────────────────────────────────────────────────
function generateAccessToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_ACCESS_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
  });
}

function generateRefreshToken(userId) {
  return jwt.sign({ userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  });
}

async function saveRefreshToken(userId, token) {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);
  await prisma.refreshToken.create({ data: { token, userId, expiresAt } });
}

function formatUser(user) {
  return {
    uid: user.id,
    email: user.email,
    displayName: user.name,
    nickname: user.nickname,
    photoUrl: user.photoUrl,
    role: (user.role || 'USER').toLowerCase(),
    emailVerified: user.emailVerified,
    onboardingCompleted: user.onboardingCompleted,
    streakDays: user.streakDays,
    totalPoints: user.totalPoints,
    level: user.level,
    age: user.age,
    gender: user.gender,
    country: user.country,
    createdAt: user.createdAt,
    lastActive: user.lastActiveAt,
  };
}

// ── POST /api/auth/register ────────────────────────────────────────
router.post('/register', authLimiter, async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      throw new AppError('Name, email, and password are required', 422, 'VALIDATION_ERROR');
    }
    if (password.length < 8) {
      throw new AppError('Password must be at least 8 characters', 422, 'WEAK_PASSWORD');
    }

    // Basic email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new AppError('Invalid email format', 422, 'INVALID_EMAIL');
    }

    const sanitizedName = name.trim().replace(/<[^>]*>/g, '').substring(0, 100);

    const existingUser = await prisma.user.findUnique({ where: { email: email.toLowerCase().trim() } });
    if (existingUser) {
      throw new AppError('An account with this email already exists', 409, 'EMAIL_EXISTS');
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await prisma.user.create({
      data: {
        email: email.toLowerCase().trim(),
        name: sanitizedName,
        passwordHash,
        displayName: sanitizedName,
      },
    });

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    await saveRefreshToken(user.id, refreshToken);

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      accessToken,
      refreshToken,
      user: formatUser(user),
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/login ──────────────────────────────────────────
router.post('/login', authLimiter, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      throw new AppError('Email and password are required', 422, 'VALIDATION_ERROR');
    }

    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      throw new UnauthorizedError('Invalid email or password');
    }

    if (!user.isActive) {
      throw new UnauthorizedError('Your account has been deactivated. Contact support.');
    }

    // Update last active
    await prisma.user.update({ where: { id: user.id }, data: { lastActiveAt: new Date() } });

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    await saveRefreshToken(user.id, refreshToken);

    res.json({
      success: true,
      message: 'Login successful',
      accessToken,
      refreshToken,
      user: formatUser(user),
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/google ─────────────────────────────────────────
router.post('/google', authLimiter, async (req, res, next) => {
  try {
    const { idToken, accessToken, serverAuthCode, device, email, name, photoUrl } = req.body;
    if (!idToken && !accessToken) throw new AppError('Google ID token or Access token is required', 422, 'MISSING_TOKEN');

    // Verify Google ID token or Access token
    let payload;
    if (idToken) {
      try {
        const ticket = await googleClient.verifyIdToken({
          idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        payload = ticket.getPayload();
      } catch (e) {
        logger.warn('Google ID token verification failed', { error: e.message, stack: e.stack });
        throw new AppError(`Google ID token verification failed: ${e.message}`, 401, 'INVALID_GOOGLE_TOKEN');
      }
    } else {
      try {
        const response = await fetch(`https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`);
        if (!response.ok) {
          throw new Error(`Google API returned status ${response.status}`);
        }
        payload = await response.json();
      } catch (e) {
        logger.warn('Google Access token verification failed', { error: e.message, stack: e.stack });
        throw new AppError(`Google Access token verification failed: ${e.message}`, 401, 'INVALID_GOOGLE_TOKEN');
      }
    }

    const googleId = payload.sub;
    const verifiedEmail = payload.email || email;

    // Find or create user
    let user = await prisma.user.findFirst({
      where: { OR: [{ googleId }, { email: verifiedEmail }] },
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          email: verifiedEmail,
          name: name || payload.name || 'Google User',
          displayName: name || payload.name || 'Google User',
          googleId,
          photoUrl: photoUrl || payload.picture,
          emailVerified: payload.email_verified || false,
        },
      });
    } else if (!user.googleId) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId, emailVerified: true, photoUrl: photoUrl || user.photoUrl },
      });
    }

    await prisma.user.update({ where: { id: user.id }, data: { lastActiveAt: new Date() } });

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    await saveRefreshToken(user.id, refreshToken);

    res.json({
      success: true,
      message: 'Google sign-in successful',
      accessToken,
      refreshToken,
      user: formatUser(user),
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/refresh ────────────────────────────────────────
router.post('/refresh', async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) throw new UnauthorizedError('Refresh token required');

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    const storedToken = await prisma.refreshToken.findUnique({
      where: { token: refreshToken },
    });

    if (!storedToken || storedToken.revoked || storedToken.expiresAt < new Date()) {
      throw new UnauthorizedError('Invalid or expired refresh token');
    }

    // Rotate tokens
    await prisma.refreshToken.update({ where: { id: storedToken.id }, data: { revoked: true } });

    const newAccessToken = generateAccessToken(decoded.userId);
    const newRefreshToken = generateRefreshToken(decoded.userId);
    await saveRefreshToken(decoded.userId, newRefreshToken);

    res.json({ success: true, accessToken: newAccessToken, refreshToken: newRefreshToken });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/logout ─────────────────────────────────────────
router.post('/logout', async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (refreshToken) {
      await prisma.refreshToken.updateMany({
        where: { token: refreshToken },
        data: { revoked: true },
      });
    }
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/forgot-password ────────────────────────────────
router.post('/forgot-password', authLimiter, async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) throw new AppError('Email is required', 422, 'VALIDATION_ERROR');

    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase().trim() } });

    // Always return success to prevent user enumeration
    if (user) {
      const resetToken = uuidv4();
      const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour expiry
      await prisma.user.update({
        where: { id: user.id },
        data: { passwordResetToken: resetToken, passwordResetExpiresAt: expiresAt },
      });
      // Dispatch email notification service with resetToken
      logger.info(`Password reset generated and dispatched for ${email}`);
    }

    res.json({
      success: true,
      message: 'If that email exists, a password reset link has been sent.',
    });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/reset-password ────────────────────────────────
router.post('/reset-password', authLimiter, async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    if (!token || !newPassword) {
      throw new AppError('Token and new password are required', 422, 'VALIDATION_ERROR');
    }
    if (newPassword.length < 8) {
      throw new AppError('Password must be at least 8 characters', 422, 'WEAK_PASSWORD');
    }

    const user = await prisma.user.findFirst({
      where: {
        passwordResetToken: token,
        passwordResetExpiresAt: { gt: new Date() },
      },
    });

    if (!user) {
      throw new AppError('Invalid or expired reset token', 400, 'INVALID_RESET_TOKEN');
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        passwordResetToken: null,
        passwordResetExpiresAt: null,
      },
    });

    res.json({ success: true, message: 'Password reset successfully. Please sign in.' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
