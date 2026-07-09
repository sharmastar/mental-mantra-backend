const { Router } = require('express');
const { authMiddleware, requireRole } = require('../middleware/auth.middleware');
const { prisma } = require('../db/prisma');
const { AppError } = require('../middleware/errorHandler');

const router = Router();
router.use(authMiddleware);

router.post('/history', async (req, res, next) => {
  try {
    const { trackName, category, durationSec } = req.body;
    if (!trackName || !category) throw new AppError('trackName and category required', 400);
    const history = await prisma.musicHistory.create({
      data: { userId: req.user.id, trackName, category, durationSec: durationSec || 0 },
    });
    req.user = await prisma.user.update({
      where: { id: req.user.id },
      data: { totalPoints: { increment: 2 } },
    });
    res.json({ success: true, data: history });
  } catch (err) { next(err); }
});

router.get('/history', async (req, res, next) => {
  try {
    const history = await prisma.musicHistory.findMany({
      where: { userId: req.user.id },
      orderBy: { playedAt: 'desc' },
      take: 50,
    });
    res.json({ success: true, data: history });
  } catch (err) { next(err); }
});

router.delete('/history/:id', async (req, res, next) => {
  try {
    await prisma.musicHistory.deleteMany({
      where: { id: req.params.id, userId: req.user.id },
    });
    res.json({ success: true });
  } catch (err) { next(err); }
});

router.post('/playlist', async (req, res, next) => {
  try {
    const { name, description, tracks } = req.body;
    if (!name) throw new AppError('Playlist name required', 400);
    const playlist = await prisma.playlist.create({
      data: { userId: req.user.id, name, description, tracks: tracks ? JSON.stringify(tracks) : null },
    });
    res.json({ success: true, data: playlist });
  } catch (err) { next(err); }
});

router.get('/playlists', async (req, res, next) => {
  try {
    const playlists = await prisma.playlist.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: playlists.map(p => ({ ...p, tracks: p.tracks ? JSON.parse(p.tracks) : [] })) });
  } catch (err) { next(err); }
});

router.post('/favorites', async (req, res, next) => {
  try {
    const { itemId, itemType } = req.body;
    if (!itemId || !itemType) throw new AppError('itemId and itemType required', 400);
    const existing = await prisma.favorite.findUnique({
      where: { userId_itemId_itemType: { userId: req.user.id, itemId, itemType } },
    });
    if (existing) {
      await prisma.favorite.delete({ where: { id: existing.id } });
      return res.json({ success: true, favorited: false });
    }
    await prisma.favorite.create({ data: { userId: req.user.id, itemId, itemType } });
    res.json({ success: true, favorited: true });
  } catch (err) { next(err); }
});

router.get('/favorites', async (req, res, next) => {
  try {
    const favorites = await prisma.favorite.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: favorites });
  } catch (err) { next(err); }
});

module.exports = router;
