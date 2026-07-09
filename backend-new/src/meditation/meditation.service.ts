import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class MeditationService {
  constructor(private readonly prisma: PrismaService) {}

  async createSession(userId: string, data: { sessionName: string; category?: string; durationMin: number }) {
    const session = await this.prisma.meditationSession.create({
      data: { userId, sessionName: data.sessionName, category: data.category || 'General', durationMin: data.durationMin },
    });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: data.durationMin } } });
    return session;
  }

  async getHistory(userId: string) {
    const sessions = await this.prisma.meditationSession.findMany({
      where: { userId }, orderBy: { completedAt: 'desc' }, take: 50,
    });
    const totalMin = sessions.reduce((s, e) => s + e.durationMin, 0);
    return { sessions, totalMinutes: totalMin, totalSessions: sessions.length };
  }
}
