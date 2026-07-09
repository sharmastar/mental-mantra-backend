const { Router } = require('express');
const { authMiddleware } = require('../middleware/auth.middleware');
const { prisma } = require('../db/prisma');
const { AppError } = require('../middleware/errorHandler');

const router = Router();
router.use(authMiddleware);

router.get('/', async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true, email: true, name: true, nickname: true, displayName: true,
        photoUrl: true, role: true, onboardingCompleted: true, age: true,
        gender: true, country: true, primaryChallenge: true, goals: true,
        relationshipStatus: true, bio: true, streakDays: true, longestStreak: true,
        totalPoints: true, level: true, lastActiveAt: true, isPremium: true,
        createdAt: true,
        _count: { select: { moodEntries: true, journalEntries: true, meditationSessions: true, habits: { where: { isActive: true } } } },
      },
    });
    if (!user) throw new AppError('User not found', 404);
    res.json({ success: true, data: user });
  } catch (err) { next(err); }
});

router.put('/', async (req, res, next) => {
  try {
    const allowed = ['name', 'nickname', 'displayName', 'photoUrl', 'age', 'gender', 'country', 'relationshipStatus', 'bio'];
    const updates = {};
    for (const field of allowed) {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    }
    if (Object.keys(updates).length === 0) throw new AppError('No valid fields to update', 400);
    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: updates,
    });
    res.json({ success: true, data: user });
  } catch (err) { next(err); }
});

router.get('/stats', async (req, res, next) => {
  try {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const [
      monthlyMoods, monthlyJournals, monthlyMeditations, monthlySessions,
      totalHabits, activeHabits,
    ] = await Promise.all([
      prisma.moodEntry.count({ where: { userId: req.user.id, loggedAt: { gte: monthStart } } }),
      prisma.journalEntry.count({ where: { userId: req.user.id, createdAt: { gte: monthStart } } }),
      prisma.meditationSession.count({ where: { userId: req.user.id, completedAt: { gte: monthStart } } }),
      prisma.aiChatMessage.count({ where: { userId: req.user.id, role: 'assistant', createdAt: { gte: monthStart } } }),
      prisma.habit.count({ where: { userId: req.user.id } }),
      prisma.habit.count({ where: { userId: req.user.id, isActive: true } }),
    ]);
    res.json({ success: true, data: { monthlyMoods, monthlyJournals, monthlyMeditations, monthlySessions, totalHabits, activeHabits } });
  } catch (err) { next(err); }
});

module.exports = router;
