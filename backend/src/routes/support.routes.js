const { Router } = require('express');
const { authMiddleware } = require('../middleware/auth.middleware');
const { prisma } = require('../db/prisma');
const { AppError } = require('../middleware/errorHandler');

const router = Router();
router.use(authMiddleware);

router.post('/', async (req, res, next) => {
  try {
    const { subject, message } = req.body;
    if (!subject || !message) throw new AppError('Subject and message required', 400);
    const ticket = await prisma.supportTicket.create({
      data: { userId: req.user.id, subject, message },
    });
    res.status(201).json({ success: true, data: ticket });
  } catch (err) { next(err); }
});

router.get('/', async (req, res, next) => {
  try {
    const tickets = await prisma.supportTicket.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: tickets });
  } catch (err) { next(err); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const ticket = await prisma.supportTicket.findFirst({
      where: { id: req.params.id, userId: req.user.id },
    });
    if (!ticket) throw new AppError('Ticket not found', 404);
    res.json({ success: true, data: ticket });
  } catch (err) { next(err); }
});

router.post('/feedback', async (req, res, next) => {
  try {
    const { type, message, rating } = req.body;
    if (!type || !message) throw new AppError('Type and message required', 400);
    const feedback = await prisma.feedback.create({
      data: { userId: req.user.id, type, message, rating },
    });
    res.status(201).json({ success: true, data: feedback });
  } catch (err) { next(err); }
});

module.exports = router;
