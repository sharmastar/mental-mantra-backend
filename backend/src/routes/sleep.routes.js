// backend/src/routes/sleep.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();

router.use(authenticateToken);

// Get sleep logs
router.get('/', async (req, res, next) => {
  try {
    const logs = await prisma.sleepLog.findMany({
      where: { userId: req.user.id },
      orderBy: { date: 'desc' },
      take: 30, // Limit to last 30 logs
    });
    res.json({ success: true, data: logs });
  } catch (err) {
    next(err);
  }
});

// Log a sleep session
router.post('/', async (req, res, next) => {
  try {
    const { bedtime, wakeTime, quality, notes, date } = req.body;

    if (!bedtime || !wakeTime || !date) {
      return res.status(400).json({ success: false, message: 'Bedtime, wakeTime, and date are required' });
    }

    const bedDateTime = new Date(bedtime);
    const wakeDateTime = new Date(wakeTime);
    
    // Calculate sleep duration in minutes
    const durationMin = Math.round((wakeDateTime - bedDateTime) / (1000 * 60));

    if (durationMin <= 0) {
      return res.status(400).json({ success: false, message: 'Wake time must be after bedtime' });
    }

    const sleepLog = await prisma.sleepLog.create({
      data: {
        userId: req.user.id,
        bedtime: bedDateTime,
        wakeTime: wakeDateTime,
        durationMin,
        quality: quality !== undefined ? parseInt(quality, 10) : null,
        notes,
        date: new Date(date),
      },
    });

    res.status(201).json({ success: true, data: sleepLog });
  } catch (err) {
    next(err);
  }
});

// Delete a sleep log
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const existingLog = await prisma.sleepLog.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!existingLog) {
      return res.status(404).json({ success: false, message: 'Sleep log not found' });
    }

    await prisma.sleepLog.delete({
      where: { id },
    });

    res.json({ success: true, message: 'Sleep log deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
