// backend/src/middleware/auth.middleware.js
const jwt = require('jsonwebtoken');
const { prisma } = require('../db/prisma');
const { UnauthorizedError } = require('./errorHandler');

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers['authorization'];
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.slice(7);
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true, email: true, name: true, nickname: true,
        role: true, isActive: true, emailVerified: true,
        onboardingCompleted: true, streakDays: true,
        totalPoints: true, level: true, photoUrl: true,
      },
    });

    if (!user) throw new UnauthorizedError('User not found');
    if (!user.isActive) throw new UnauthorizedError('Account deactivated');

    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return next(new UnauthorizedError());
    if (!roles.includes(req.user.role)) {
      return next(new UnauthorizedError('Insufficient permissions'));
    }
    next();
  };
}

module.exports = { authMiddleware, authenticateToken: authMiddleware, requireRole };
