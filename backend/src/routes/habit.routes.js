// backend/src/routes/habit.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const { NotFoundError } = require('../middleware/errorHandler');
const router = express.Router();
router.use(authenticateToken);

router.get('/', async (req, res, next) => {
  try {
    const habits = await prisma.habit.findMany({ where: { userId: req.user.id, isActive: true }, orderBy: { createdAt: 'asc' } });
    // Get today's logs
    const today = new Date(); today.setHours(0,0,0,0);
    const logs = await prisma.habitLog.findMany({ where: { userId: req.user.id, date: { gte: today } } });
    const logMap = Object.fromEntries(logs.map(l => [l.habitId, l]));
    res.json({ success: true, data: habits.map(h => ({ ...h, todayDone: !!logMap[h.id] })) });
  } catch (err) { next(err); }
});

router.post('/', async (req, res, next) => {
  try {
    const { name, description, icon, color, frequency, targetCount } = req.body;
    if (!name) return res.status(422).json({ success: false, message: 'Name required' });
    const habit = await prisma.habit.create({ data: { userId: req.user.id, name, description, icon, color, frequency: frequency || 'daily', targetCount: targetCount || 1 } });
    res.status(201).json({ success: true, data: habit });
  } catch (err) { next(err); }
});

// POST /api/habits/:id/log — mark as done for today
router.post('/:id/log', async (req, res, next) => {
  try {
    const habit = await prisma.habit.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!habit) throw new NotFoundError('Habit');
    const today = new Date(); today.setHours(0,0,0,0);
    const log = await prisma.habitLog.upsert({
      where: { habitId_date: { habitId: habit.id, date: today } },
      update: { count: { increment: 1 } },
      create: { userId: req.user.id, habitId: habit.id, date: today, count: 1 },
    });
    await prisma.habit.update({ where: { id: habit.id }, data: { streak: { increment: 1 } } });
    await prisma.user.update({ where: { id: req.user.id }, data: { totalPoints: { increment: 15 } } });
    res.json({ success: true, data: log });
  } catch (err) { next(err); }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await prisma.habit.updateMany({ where: { id: req.params.id, userId: req.user.id }, data: { isActive: false } });
    res.json({ success: true, message: 'Habit removed' });
  } catch (err) { next(err); }
});

module.exports = router;
