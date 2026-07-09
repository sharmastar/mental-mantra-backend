// backend/src/routes/journal.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const { NotFoundError } = require('../middleware/errorHandler');
const router = express.Router();
router.use(authenticateToken);

// GET /api/journal
router.get('/', async (req, res, next) => {
  try {
    const { limit = 20, skip = 0, search } = req.query;
    const where = { userId: req.user.id };
    if (search) where.OR = [{ title: { contains: search } }, { content: { contains: search } }];
    const [entries, total] = await Promise.all([
      prisma.journalEntry.findMany({ where, orderBy: { createdAt: 'desc' }, take: parseInt(limit), skip: parseInt(skip) }),
      prisma.journalEntry.count({ where }),
    ]);
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
    res.json({ success: true, data: { entries: parsedEntries, total, limit: parseInt(limit), skip: parseInt(skip) } });
  } catch (err) { next(err); }
});

// POST /api/journal
router.post('/', async (req, res, next) => {
  try {
    const { title, content, mood, moodEmoji, tags } = req.body;
    if (!content?.trim()) return res.status(422).json({ success: false, message: 'Content is required' });
    const wordCount = content.trim().split(/\s+/).length;
    const entry = await prisma.journalEntry.create({
      data: { userId: req.user.id, title, content: content.trim(), mood, moodEmoji, tags: tags ? JSON.stringify(tags) : '[]', wordCount },
    });
    if (entry && entry.tags) {
      try {
        entry.tags = JSON.parse(entry.tags);
      } catch (e) {
        entry.tags = entry.tags.split(',').filter(Boolean);
      }
    }
    await prisma.user.update({ where: { id: req.user.id }, data: { totalPoints: { increment: 20 } } });
    res.status(201).json({ success: true, data: entry });
  } catch (err) { next(err); }
});

// GET /api/journal/:id
router.get('/:id', async (req, res, next) => {
  try {
    const entry = await prisma.journalEntry.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!entry) throw new NotFoundError('Journal entry');
    if (entry && entry.tags) {
      try {
        entry.tags = JSON.parse(entry.tags);
      } catch (e) {
        entry.tags = entry.tags.split(',').filter(Boolean);
      }
    } else if (entry) {
      entry.tags = [];
    }
    res.json({ success: true, data: entry });
  } catch (err) { next(err); }
});

// PUT /api/journal/:id
router.put('/:id', async (req, res, next) => {
  try {
    const entry = await prisma.journalEntry.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!entry) throw new NotFoundError('Journal entry');
    const { title, content, mood, moodEmoji, tags } = req.body;
    
    let serializedTags = entry.tags;
    if (tags !== undefined) {
      serializedTags = tags ? JSON.stringify(tags) : '[]';
    }

    const updated = await prisma.journalEntry.update({
      where: { id: entry.id },
      data: { title, content, mood, moodEmoji, tags: serializedTags, wordCount: content ? content.trim().split(/\s+/).length : entry.wordCount },
    });
    if (updated && updated.tags) {
      try {
        updated.tags = JSON.parse(updated.tags);
      } catch (e) {
        updated.tags = updated.tags.split(',').filter(Boolean);
      }
    }
    res.json({ success: true, data: updated });
  } catch (err) { next(err); }
});

// DELETE /api/journal/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const entry = await prisma.journalEntry.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!entry) throw new NotFoundError('Journal entry');
    await prisma.journalEntry.delete({ where: { id: entry.id } });
    res.json({ success: true, message: 'Entry deleted' });
  } catch (err) { next(err); }
});

module.exports = router;
