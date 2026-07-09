// backend/src/routes/meditation.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();
router.use(authenticateToken);

// POST /api/meditation/session — log a completed session
router.post('/session', async (req, res, next) => {
  try {
    const { sessionName, category, durationMin } = req.body;
    if (!sessionName || !durationMin) return res.status(422).json({ success: false, message: 'sessionName and durationMin required' });
    const session = await prisma.meditationSession.create({
      data: { userId: req.user.id, sessionName, category: category || 'General', durationMin: parseInt(durationMin) },
    });
    await prisma.user.update({ where: { id: req.user.id }, data: { totalPoints: { increment: durationMin } } });
    res.status(201).json({ success: true, data: session });
  } catch (err) { next(err); }
});

// GET /api/meditation/history
router.get('/history', async (req, res, next) => {
  try {
    const sessions = await prisma.meditationSession.findMany({ where: { userId: req.user.id }, orderBy: { completedAt: 'desc' }, take: 50 });
    const totalMin = sessions.reduce((s, e) => s + e.durationMin, 0);
    res.json({ success: true, data: { sessions, totalMinutes: totalMin, totalSessions: sessions.length } });
  } catch (err) { next(err); }
});

module.exports = router;
