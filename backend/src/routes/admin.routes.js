const { Router } = require('express');
const { authMiddleware, requireRole } = require('../middleware/auth.middleware');
const { prisma } = require('../db/prisma');

const router = Router();
router.use(authMiddleware);
router.use(requireRole('ADMIN'));

router.get('/users', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        skip, take: limit,
        orderBy: { createdAt: 'desc' },
        select: { id: true, email: true, name: true, role: true, isActive: true, isPremium: true, streakDays: true, totalPoints: true, level: true, createdAt: true, lastActiveAt: true },
      }),
      prisma.user.count(),
    ]);
    res.json({ success: true, data: users, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (err) { next(err); }
});

router.patch('/users/:id/status', async (req, res, next) => {
  try {
    const { isActive, isPremium, role } = req.body;
    const user = await prisma.user.update({
      where: { id: req.params.id },
      data: { ...(isActive !== undefined && { isActive }), ...(isPremium !== undefined && { isPremium }), ...(role && { role }) },
    });
    res.json({ success: true, data: user });
  } catch (err) { next(err); }
});

router.get('/analytics', async (req, res, next) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const since = new Date(Date.now() - days * 86400000);
    const [totalUsers, activeUsers, newUsers, premiumUsers] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { lastActiveAt: { gte: since } } }),
      prisma.user.count({ where: { createdAt: { gte: since } } }),
      prisma.user.count({ where: { isPremium: true } }),
    ]);
    const [totalMoods, totalJournals, totalMeditations, totalSessions] = await Promise.all([
      prisma.moodEntry.count({ where: { loggedAt: { gte: since } } }),
      prisma.journalEntry.count({ where: { createdAt: { gte: since } } }),
      prisma.meditationSession.count({ where: { completedAt: { gte: since } } }),
      prisma.aiChatMessage.count({ where: { createdAt: { gte: since } } }),
    ]);
    res.json({
      success: true,
      data: { totalUsers, activeUsers, newUsers, premiumUsers, totalMoods, totalJournals, totalMeditations, totalSessions },
    });
  } catch (err) { next(err); }
});

router.get('/reports', async (req, res, next) => {
  try {
    const reports = await prisma.report.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: { user: { select: { id: true, name: true, email: true } } },
    });
    res.json({ success: true, data: reports });
  } catch (err) { next(err); }
});

router.get('/subscriptions', async (req, res, next) => {
  try {
    const subs = await prisma.subscription.findMany({
      include: { user: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: subs });
  } catch (err) { next(err); }
});

router.get('/feedback', async (req, res, next) => {
  try {
    const feedback = await prisma.feedback.findMany({
      include: { user: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    res.json({ success: true, data: feedback });
  } catch (err) { next(err); }
});

module.exports = router;
