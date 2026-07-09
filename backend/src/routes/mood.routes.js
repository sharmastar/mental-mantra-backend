// backend/src/routes/mood.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();
router.use(authenticateToken);

// POST /api/mood
router.post('/', async (req, res, next) => {
  try {
    const { mood, emoji, label, note, tags } = req.body;
    if (mood === undefined || !label) return res.status(422).json({ success: false, message: 'mood and label required' });
    const entry = await prisma.moodEntry.create({
      data: { userId: req.user.id, mood: parseInt(mood), emoji: emoji || '😐', label, note, tags: tags ? JSON.stringify(tags) : '[]' },
    });
    if (entry && entry.tags) {
      try {
        entry.tags = JSON.parse(entry.tags);
      } catch (e) {
        entry.tags = entry.tags.split(',').filter(Boolean);
      }
    }
    // Update streak
    await prisma.user.update({ where: { id: req.user.id }, data: { totalPoints: { increment: 10 } } });
    res.status(201).json({ success: true, data: entry });
  } catch (err) { next(err); }
});

// GET /api/mood
router.get('/', async (req, res, next) => {
  try {
    const { limit = 30, skip = 0 } = req.query;
    const entries = await prisma.moodEntry.findMany({
      where: { userId: req.user.id },
      orderBy: { loggedAt: 'desc' },
      take: parseInt(limit),
      skip: parseInt(skip),
    });
    const parsedEntries = entries.map(entry => {
      if (entry && entry.tags) {
        try {
          entry.tags = JSON.parse(entry.tags);
        } catch (e) {
          entry.tags = entry.tags.split(',').filter(Boolean);
        }
      } else {
        entry.tags = [];
      }
      return entry;
    });
    res.json({ success: true, data: parsedEntries });
  } catch (err) { next(err); }
});

// GET /api/mood/analytics
router.get('/analytics', async (req, res, next) => {
  try {
    const since = new Date();
    since.setDate(since.getDate() - 7);
    const entries = await prisma.moodEntry.findMany({
      where: { userId: req.user.id, loggedAt: { gte: since } },
      orderBy: { loggedAt: 'asc' },
    });
    const parsedEntries = entries.map(entry => {
      if (entry && entry.tags) {
        try {
          entry.tags = JSON.parse(entry.tags);
        } catch (e) {
          entry.tags = entry.tags.split(',').filter(Boolean);
        }
      } else {
        entry.tags = [];
      }
      return entry;
    });
    const avg = parsedEntries.length > 0 ? parsedEntries.reduce((s, e) => s + e.mood, 0) / parsedEntries.length : 0;
    res.json({ success: true, data: { entries: parsedEntries, weeklyAverage: avg.toFixed(2), totalEntries: parsedEntries.length } });
  } catch (err) { next(err); }
});

module.exports = router;
