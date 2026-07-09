// backend/src/routes/notification.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();

router.use(authenticateToken);

// Get all notifications for a user
router.get('/', async (req, res, next) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { sentAt: 'desc' },
      take: 50,
    });
    const parsedNotifs = notifications.map(notif => {
      if (notif && notif.data) {
        try {
          notif.data = JSON.parse(notif.data);
        } catch (e) {
          // Keep as is
        }
      }
      return notif;
    });
    res.json({ success: true, data: parsedNotifs });
  } catch (err) {
    next(err);
  }
});

// Mark a notification as read
router.patch('/:id/read', async (req, res, next) => {
  try {
    const { id } = req.params;

    const existingNotif = await prisma.notification.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!existingNotif) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    const notification = await prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });

    if (notification && notification.data) {
      try {
        notification.data = JSON.parse(notification.data);
      } catch (e) {
        // Keep as is
      }
    }

    res.json({ success: true, data: notification });
  } catch (err) {
    next(err);
  }
});

// Mark all notifications as read
router.post('/read-all', async (req, res, next) => {
  try {
    await prisma.notification.updateMany({
      where: { userId: req.user.id, isRead: false },
      data: { isRead: true },
    });
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (err) {
    next(err);
  }
});

// Delete a notification
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const existingNotif = await prisma.notification.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!existingNotif) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    await prisma.notification.delete({
      where: { id },
    });

    res.json({ success: true, message: 'Notification deleted' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
