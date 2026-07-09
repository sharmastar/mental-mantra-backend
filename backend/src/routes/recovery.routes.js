const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const { NotFoundError } = require('../middleware/errorHandler');
const router = express.Router();

router.use(authenticateToken);

router.get('/stats', async (req, res, next) => {
  try {
    const userId = req.user.id;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [urges, sessions, activeGoal] = await Promise.all([
      prisma.urgeLog.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take: 50 }),
      prisma.detoxSession.findMany({ where: { userId }, orderBy: { startedAt: 'desc' }, take: 50 }),
      prisma.recoveryGoal.findFirst({ where: { userId, isActive: true } }),
    ]);

    const totalUrges = urges.length;
    const urgesResisted = urges.filter(u => u.resisted).length;
    const totalDetoxMinutes = sessions.filter(s => s.completed).reduce((sum, s) => sum + s.durationMin, 0);
    const totalDetoxSessions = sessions.filter(s => s.completed).length;

    let streak = 0;
    const checkDate = new Date(today);
    while (true) {
      const dayUrges = urges.filter(u => {
        const d = new Date(u.createdAt);
        return d.toDateString() === checkDate.toDateString();
      });
      if (dayUrges.length === 0 && streak > 0) break;
      if (dayUrges.length > 0 && dayUrges.some(u => u.resisted)) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else if (dayUrges.length === 0 && streak === 0) {
        checkDate.setDate(checkDate.getDate() - 1);
        continue;
      } else {
        break;
      }
    }

    res.json({
      success: true,
      data: {
        currentStreak: streak,
        bestStreak: streak,
        totalUrgesLogged: totalUrges,
        urgesResisted,
        totalDetoxMinutes,
        totalDetoxSessions,
        recentUrges: urges.slice(0, 5),
        recentSessions: sessions.slice(0, 5),
        activeGoal,
      },
    });
  } catch (err) { next(err); }
});

router.get('/urges', async (req, res, next) => {
  try {
    const { limit = 20 } = req.query;
    const urges = await prisma.urgeLog.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
      take: parseInt(limit),
    });
    res.json({ success: true, data: urges });
  } catch (err) { next(err); }
});

router.post('/urges', async (req, res, next) => {
  try {
    const { trigger, intensity, urgeType, resisted, copingStrategy, notes } = req.body;
    if (!trigger || !intensity || !urgeType) {
      return res.status(422).json({ success: false, message: 'Trigger, intensity, and urge type are required' });
    }
    const urge = await prisma.urgeLog.create({
      data: { userId: req.user.id, trigger, intensity, urgeType, resisted: resisted || false, copingStrategy, notes },
    });
    res.status(201).json({ success: true, data: urge });
  } catch (err) { next(err); }
});

router.get('/sessions', async (req, res, next) => {
  try {
    const { limit = 20 } = req.query;
    const sessions = await prisma.detoxSession.findMany({
      where: { userId: req.user.id },
      orderBy: { startedAt: 'desc' },
      take: parseInt(limit),
    });
    res.json({ success: true, data: sessions });
  } catch (err) { next(err); }
});

router.post('/sessions', async (req, res, next) => {
  try {
    const { sessionType, durationMin, startedAt } = req.body;
    if (!sessionType || !durationMin) {
      return res.status(422).json({ success: false, message: 'Session type and duration are required' });
    }
    const session = await prisma.detoxSession.create({
      data: {
        userId: req.user.id,
        sessionType,
        durationMin,
        startedAt: startedAt ? new Date(startedAt) : new Date(),
      },
    });
    res.status(201).json({ success: true, data: session });
  } catch (err) { next(err); }
});

router.put('/sessions/:id', async (req, res, next) => {
  try {
    const session = await prisma.detoxSession.findFirst({
      where: { id: req.params.id, userId: req.user.id },
    });
    if (!session) throw new NotFoundError('Detox session');
    const { completedMinutes, completed, completedAt, notes } = req.body;
    const updated = await prisma.detoxSession.update({
      where: { id: session.id },
      data: {
        completedMinutes: completedMinutes ?? session.completedMinutes,
        completed: completed ?? session.completed,
        completedAt: completedAt ? new Date(completedAt) : session.completedAt,
        notes: notes ?? session.notes,
      },
    });
    res.json({ success: true, data: updated });
  } catch (err) { next(err); }
});

router.get('/goals', async (req, res, next) => {
  try {
    const goal = await prisma.recoveryGoal.findFirst({
      where: { userId: req.user.id, isActive: true },
    });
    res.json({ success: true, data: goal });
  } catch (err) { next(err); }
});

router.post('/goals', async (req, res, next) => {
  try {
    const { targetType, targetValue } = req.body;
    if (!targetType || !targetValue) {
      return res.status(422).json({ success: false, message: 'Target type and value are required' });
    }
    await prisma.recoveryGoal.updateMany({
      where: { userId: req.user.id, isActive: true },
      data: { isActive: false },
    });
    const goal = await prisma.recoveryGoal.create({
      data: { userId: req.user.id, targetType, targetValue, startDate: new Date() },
    });
    res.status(201).json({ success: true, data: goal });
  } catch (err) { next(err); }
});

module.exports = router;
