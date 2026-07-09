// backend/src/routes/goal.routes.js
const express = require('express');
const { prisma } = require('../db/prisma');
const { authenticateToken } = require('../middleware/auth.middleware');
const router = express.Router();

router.use(authenticateToken);

// Get all goals
router.get('/', async (req, res, next) => {
  try {
    const goals = await prisma.goal.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: goals });
  } catch (err) {
    next(err);
  }
});

// Create a new goal
router.post('/', async (req, res, next) => {
  try {
    const { title, description, category, targetValue, currentValue, deadline } = req.body;
    
    if (!title || !category || targetValue === undefined) {
      return res.status(400).json({ success: false, message: 'Title, category, and targetValue are required' });
    }

    const goal = await prisma.goal.create({
      data: {
        userId: req.user.id,
        title,
        description,
        category,
        targetValue: parseInt(targetValue, 10),
        currentValue: currentValue !== undefined ? parseInt(currentValue, 10) : 0,
        deadline: deadline ? new Date(deadline) : null,
      },
    });

    res.status(201).json({ success: true, data: goal });
  } catch (err) {
    next(err);
  }
});

// Update a goal (e.g. progress or details)
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, description, category, targetValue, currentValue, deadline, completed } = req.body;

    const existingGoal = await prisma.goal.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!existingGoal) {
      return res.status(404).json({ success: false, message: 'Goal not found' });
    }

    const updatedData = {};
    if (title !== undefined) updatedData.title = title;
    if (description !== undefined) updatedData.description = description;
    if (category !== undefined) updatedData.category = category;
    if (targetValue !== undefined) updatedData.targetValue = parseInt(targetValue, 10);
    if (currentValue !== undefined) updatedData.currentValue = parseInt(currentValue, 10);
    if (deadline !== undefined) updatedData.deadline = deadline ? new Date(deadline) : null;
    if (completed !== undefined) updatedData.completed = completed;

    // Auto-mark completed if currentValue >= targetValue
    if (updatedData.currentValue !== undefined && existingGoal.targetValue !== undefined) {
      const target = updatedData.targetValue !== undefined ? updatedData.targetValue : existingGoal.targetValue;
      if (updatedData.currentValue >= target) {
        updatedData.completed = true;
      }
    }

    const goal = await prisma.goal.update({
      where: { id },
      data: updatedData,
    });

    res.json({ success: true, data: goal });
  } catch (err) {
    next(err);
  }
});

// Delete a goal
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const existingGoal = await prisma.goal.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!existingGoal) {
      return res.status(404).json({ success: false, message: 'Goal not found' });
    }

    await prisma.goal.delete({
      where: { id },
    });

    res.json({ success: true, message: 'Goal deleted successfully' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
