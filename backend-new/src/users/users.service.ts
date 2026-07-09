import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) return null;
    if (user.goalTags) { try { user.goalTags = JSON.parse(user.goalTags); } catch { user.goalTags = user.goalTags?.split(',').filter(Boolean) as any; } }
    return { ...user, uid: user.id };
  }

  async updateMe(userId: string, data: any) {
    const updates: any = {};
    if (data.name) { updates.name = data.name; updates.displayName = data.name; }
    if (data.nickname !== undefined) updates.nickname = data.nickname;
    if (data.photoUrl !== undefined) updates.photoUrl = data.photoUrl;
    if (data.age !== undefined) updates.age = data.age;
    if (data.gender !== undefined) updates.gender = data.gender;
    if (data.country !== undefined) updates.country = data.country;
    return this.prisma.user.update({ where: { id: userId }, data: updates });
  }

  async completeOnboarding(userId: string, data: any) {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        nickname: data.nickname,
        age: data.age,
        gender: data.gender,
        goalTags: data.goals ? JSON.stringify(data.goals) : '[]',
        primaryChallenge: data.primaryChallenge,
        onboardingCompleted: true,
      },
    });
  }

  async getStats(userId: string) {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const [moodCount, journalCount, meditationCount, habitCompletions] = await Promise.all([
      this.prisma.moodEntry.count({ where: { userId, loggedAt: { gte: startOfMonth } } }),
      this.prisma.journalEntry.count({ where: { userId, createdAt: { gte: startOfMonth } } }),
      this.prisma.meditationSession.count({ where: { userId, completedAt: { gte: startOfMonth } } }),
      this.prisma.habitLog.count({ where: { userId, date: { gte: startOfMonth } } }),
    ]);
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    return {
      thisMonth: { moodEntries: moodCount, journalEntries: journalCount, meditationSessions: meditationCount, habitsCompleted: habitCompletions },
      overall: { streakDays: user?.streakDays || 0, totalPoints: user?.totalPoints || 0, level: user?.level || 1 },
    };
  }

  async updateFcmToken(userId: string, token: string) {
    await this.prisma.user.update({ where: { id: userId }, data: { fcmToken: token } });
  }
}
