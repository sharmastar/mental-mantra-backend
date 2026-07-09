import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class ProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true, email: true, name: true, nickname: true, displayName: true,
        photoUrl: true, role: true, onboardingCompleted: true, age: true,
        gender: true, country: true, primaryChallenge: true, goalTags: true,
        relationshipStatus: true, bio: true, streakDays: true, longestStreak: true,
        totalPoints: true, level: true, lastActiveAt: true, isPremium: true,
        createdAt: true,
        _count: { select: { moodEntries: true, journalEntries: true, meditationSessions: true, habits: { where: { isActive: true } } } },
      },
    });
    return user;
  }

  async updateProfile(userId: string, data: any) {
    const allowed = ['name', 'nickname', 'displayName', 'photoUrl', 'age', 'gender', 'country', 'relationshipStatus', 'bio'];
    const updates: any = {};
    for (const field of allowed) {
      if (data[field] !== undefined) updates[field] = data[field];
    }
    if (Object.keys(updates).length === 0) return null;
    return this.prisma.user.update({ where: { id: userId }, data: updates });
  }
}
