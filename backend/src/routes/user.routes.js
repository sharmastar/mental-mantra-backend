// backend/src/routes/user.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();

// All user routes require auth
router.use(authenticateToken);

// GET /api/users/me
router.get('/me', async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true, email: true, name: true, nickname: true, displayName: true,
        photoUrl: true, role: true, emailVerified: true, onboardingCompleted: true,
        age: true, gender: true, country: true, primaryChallenge: true, goalTags: true,
        streakDays: true, longestStreak: true, totalPoints: true, level: true,
        isPremium: true, createdAt: true, lastActiveAt: true,
      },
    });
    if (user) {
      try {
        user.goals = user.goalTags ? JSON.parse(user.goalTags) : [];
      } catch (e) {
        user.goals = user.goalTags ? user.goalTags.split(',').filter(Boolean) : [];
      }
      delete user.goalTags;
    }
    res.json({ success: true, data: { ...user, uid: user.id, displayName: user.name } });
  } catch (err) { next(err); }
});

// PUT /api/users/me
router.put('/me', async (req, res, next) => {
  try {
    const { name, nickname, photoUrl, age, gender, country } = req.body;
    const updated = await prisma.user.update({
      where: { id: req.user.id },
      data: {
        ...(name && { name, displayName: name }),
        ...(nickname !== undefined && { nickname }),
        ...(photoUrl !== undefined && { photoUrl }),
        ...(age !== undefined && { age }),
        ...(gender !== undefined && { gender }),
        ...(country !== undefined && { country }),
      },
    });
    if (updated) {
      try {
        updated.goals = updated.goalTags ? JSON.parse(updated.goalTags) : [];
      } catch (e) {
        updated.goals = updated.goalTags ? updated.goalTags.split(',').filter(Boolean) : [];
      }
      delete updated.goalTags;
    }
    res.json({ success: true, data: { ...updated, uid: updated.id } });
  } catch (err) { next(err); }
});

// POST /api/users/me/onboarding
router.post('/me/onboarding', async (req, res, next) => {
  try {
    const { nickname, age, gender, goals, primaryChallenge } = req.body;
    await prisma.user.update({
      where: { id: req.user.id },
      data: {
        nickname, age, gender,
        goalTags: goals ? JSON.stringify(goals) : '[]',
        primaryChallenge,
        onboardingCompleted: true,
      },
    });
    res.json({ success: true, message: 'Onboarding completed' });
  } catch (err) { next(err); }
});

// GET /api/users/me/stats
router.get('/me/stats', async (req, res, next) => {
  try {
    const userId = req.user.id;
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const [moodCount, journalCount, meditationCount, habitCompletions] = await Promise.all([
      prisma.moodEntry.count({ where: { userId, loggedAt: { gte: startOfMonth } } }),
      prisma.journalEntry.count({ where: { userId, createdAt: { gte: startOfMonth } } }),
      prisma.meditationSession.count({ where: { userId, completedAt: { gte: startOfMonth } } }),
      prisma.habitLog.count({ where: { userId, date: { gte: startOfMonth } } }),
    ]);

    res.json({
      success: true,
      data: {
        thisMonth: { moodEntries: moodCount, journalEntries: journalCount, meditationSessions: meditationCount, habitsCompleted: habitCompletions },
        overall: { streakDays: req.user.streakDays, totalPoints: req.user.totalPoints, level: req.user.level },
      },
    });
  } catch (err) { next(err); }
});

// POST /api/users/me/fcm-token
router.post('/me/fcm-token', async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) return res.status(422).json({ success: false, message: 'FCM token required' });
    await prisma.user.update({ where: { id: req.user.id }, data: { fcmToken: token } });
    res.json({ success: true });
  } catch (err) { next(err); }
});

module.exports = router;
