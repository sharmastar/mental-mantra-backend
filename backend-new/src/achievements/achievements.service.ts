import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class AchievementsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.achievement.findMany({ where: { userId }, orderBy: { unlockedAt: 'desc' } });
  }

  async getRewards(userId: string) {
    return this.prisma.reward.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
  }
}
