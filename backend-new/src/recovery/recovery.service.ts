import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class RecoveryService {
  constructor(private readonly prisma: PrismaService) {}

  async getStats(userId: string) {
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const [urges, sessions, activeGoal] = await Promise.all([
      this.prisma.urgeLog.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take: 50 }),
      this.prisma.detoxSession.findMany({ where: { userId }, orderBy: { startedAt: 'desc' }, take: 50 }),
      this.prisma.recoveryGoal.findFirst({ where: { userId, isActive: true } }),
    ]);

    const totalUrges = urges.length;
    const urgesResisted = urges.filter(u => u.resisted).length;
    const totalDetoxMinutes = sessions.filter(s => s.completed).reduce((sum, s) => sum + s.durationMin, 0);
    const totalDetoxSessions = sessions.filter(s => s.completed).length;

    let streak = 0;
    const checkDate = new Date(today);
    for (let i = 0; i < 365; i++) {
      const dayUrges = urges.filter(u => new Date(u.createdAt).toDateString() === checkDate.toDateString());
      if (dayUrges.length === 0 && streak > 0) break;
      if (dayUrges.length > 0 && dayUrges.some(u => u.resisted)) { streak++; checkDate.setDate(checkDate.getDate() - 1); }
      else if (dayUrges.length === 0 && streak === 0) { checkDate.setDate(checkDate.getDate() - 1); continue; }
      else break;
    }

    return { currentStreak: streak, bestStreak: streak, totalUrgesLogged: totalUrges, urgesResisted, totalDetoxMinutes, totalDetoxSessions, recentUrges: urges.slice(0, 5), recentSessions: sessions.slice(0, 5), activeGoal };
  }

  async getUrges(userId: string, limit: any = 20) {
    const take = limit ? parseInt(limit.toString(), 10) : 20;
    return this.prisma.urgeLog.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take });
  }

  async createUrge(userId: string, data: any) {
    return this.prisma.urgeLog.create({ data: { userId, trigger: data.trigger, intensity: data.intensity, urgeType: data.urgeType, resisted: data.resisted || false, copingStrategy: data.copingStrategy, notes: data.notes } });
  }

  async getSessions(userId: string, limit: any = 20) {
    const take = limit ? parseInt(limit.toString(), 10) : 20;
    return this.prisma.detoxSession.findMany({ where: { userId }, orderBy: { startedAt: 'desc' }, take });
  }

  async createSession(userId: string, data: any) {
    return this.prisma.detoxSession.create({ data: { userId, sessionType: data.sessionType, durationMin: data.durationMin, startedAt: data.startedAt ? new Date(data.startedAt) : new Date() } });
  }

  async updateSession(userId: string, id: string, data: any) {
    const session = await this.prisma.detoxSession.findFirst({ where: { id, userId } });
    if (!session) throw new NotFoundException('Detox session not found');
    return this.prisma.detoxSession.update({ where: { id }, data: { completedMinutes: data.completedMinutes ?? session.completedMinutes, completed: data.completed ?? session.completed, completedAt: data.completedAt ? new Date(data.completedAt) : session.completedAt, notes: data.notes ?? session.notes } });
  }

  async getGoals(userId: string) {
    return this.prisma.recoveryGoal.findFirst({ where: { userId, isActive: true } });
  }

  async createGoal(userId: string, data: any) {
    await this.prisma.recoveryGoal.updateMany({ where: { userId, isActive: true }, data: { isActive: false } });
    return this.prisma.recoveryGoal.create({ data: { userId, targetType: data.targetType, targetValue: data.targetValue, startDate: new Date() } });
  }
}
