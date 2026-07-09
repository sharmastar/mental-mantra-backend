import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  const adminPassword = await bcrypt.hash('Admin@123456', 12);

  const admin = await prisma.admin.upsert({
    where: { email: 'admin@mentalmantra.app' },
    update: {},
    create: {
      email: 'admin@mentalmantra.app',
      name: 'Admin',
      passwordHash: adminPassword,
      role: 'SUPER_ADMIN',
    },
  });

  const demoPassword = await bcrypt.hash('Demo@123', 12);

  const demoUser = await prisma.user.upsert({
    where: { email: 'demo@mentalmantra.app' },
    update: {},
    create: {
      email: 'demo@mentalmantra.app',
      passwordHash: demoPassword,
      name: 'Demo User',
      nickname: 'Demo',
      displayName: 'Demo User',
      onboardingCompleted: true,
      age: 28,
      gender: 'Male',
      goalTags: JSON.stringify(['Manage Stress', 'Better Sleep', 'Meditation']),
      primaryChallenge: 'Stress',
      streakDays: 7,
      totalPoints: 450,
      level: 3,
    },
  });

  const habits = ['Morning Meditation', 'Drink 8 Glasses Water', 'Evening Walk', 'Gratitude Journal', 'Read 30 Minutes'];
  for (const name of habits) {
    await prisma.habit.upsert({
      where: { id: `seed-habit-${name.toLowerCase().replace(/\s+/g, '-')}` },
      update: {},
      create: {
        id: `seed-habit-${name.toLowerCase().replace(/\s+/g, '-')}`,
        userId: demoUser.id,
        name,
        icon: 'check_circle',
        color: '#6C63FF',
        frequency: 'daily',
        targetCount: 1,
        streak: 5,
        bestStreak: 12,
      },
    });
  }

  const meditationSessions = [
    { name: 'Morning Calm', category: 'Stress', mins: 10 },
    { name: 'Deep Sleep', category: 'Sleep', mins: 20 },
    { name: 'Focus Flow', category: 'Focus', mins: 15 },
  ];
  for (const s of meditationSessions) {
    await prisma.meditationSession.create({
      data: { userId: demoUser.id, sessionName: s.name, category: s.category, durationMin: s.mins },
    });
  }

  const moods = [
    { mood: 4, emoji: '🙂', label: 'Good' },
    { mood: 5, emoji: '😄', label: 'Great' },
    { mood: 3, emoji: '😐', label: 'Okay' },
    { mood: 4, emoji: '🙂', label: 'Good' },
    { mood: 5, emoji: '😄', label: 'Great' },
  ];
  for (let i = 0; i < moods.length; i++) {
    const date = new Date();
    date.setDate(date.getDate() - (moods.length - i));
    await prisma.moodEntry.create({
      data: { userId: demoUser.id, ...moods[i], loggedAt: date },
    });
  }

  console.log('Seed completed successfully!');
  if (process.env.NODE_ENV !== 'production') {
    console.log(`  Admin: admin@mentalmantra.app / Admin@123456`);
    console.log(`  Demo:  demo@mentalmantra.app / Demo@123`);
  }
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });
