import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateUrgeDto } from './dto/create-urge.dto';
import { CreateRecoverySessionDto } from './dto/create-recovery-session.dto';
import { UpdateRecoverySessionDto } from './dto/update-recovery-session.dto';
import { CreateRecoveryGoalDto } from './dto/create-recovery-goal.dto';

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

    // Relapse-based streak logic
    let streak = 0;
    const todayMid = new Date(); todayMid.setHours(0, 0, 0, 0);
    const baseDate = activeGoal ? new Date(activeGoal.startDate) : new Date(todayMid);
    baseDate.setHours(0, 0, 0, 0);

    const lastRelapse = urges.find(u => !u.resisted);
    let referenceDate = baseDate;
    if (lastRelapse) {
      const relapseDate = new Date(lastRelapse.createdAt);
      relapseDate.setHours(0, 0, 0, 0);
      if (relapseDate > baseDate) {
        // Streak is calculated starting the day AFTER the last relapse
        referenceDate = new Date(relapseDate.getTime() + 24 * 60 * 60 * 1000);
      }
    }

    const diffTime = todayMid.getTime() - referenceDate.getTime();
    streak = Math.max(0, Math.floor(diffTime / (1000 * 60 * 60 * 24)));

    return {
      currentStreak: streak,
      bestStreak: streak,
      totalUrgesLogged: totalUrges,
      urgesResisted,
      totalDetoxMinutes,
      totalDetoxSessions,
      recentUrges: urges.slice(0, 5),
      recentSessions: sessions.slice(0, 5),
      activeGoal,
    };
  }

  async getUrges(userId: string, limit: any = 20) {
    const take = limit ? parseInt(limit.toString(), 10) : 20;
    return this.prisma.urgeLog.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take });
  }

  async createUrge(userId: string, dto: CreateUrgeDto) {
    return this.prisma.urgeLog.create({
      data: {
        userId,
        trigger: dto.trigger || 'General',
        intensity: dto.intensity,
        urgeType: dto.urgeType,
        resisted: dto.resisted ?? false,
        copingStrategy: dto.copingStrategy,
        notes: dto.notes,
      },
    });
  }

  async getSessions(userId: string, limit: any = 20) {
    const take = limit ? parseInt(limit.toString(), 10) : 20;
    return this.prisma.detoxSession.findMany({ where: { userId }, orderBy: { startedAt: 'desc' }, take });
  }

  async createSession(userId: string, dto: CreateRecoverySessionDto) {
    return this.prisma.detoxSession.create({
      data: {
        userId,
        sessionType: dto.sessionType,
        durationMin: dto.durationMin,
        startedAt: dto.startedAt ? new Date(dto.startedAt) : new Date(),
      },
    });
  }

  async updateSession(userId: string, id: string, dto: UpdateRecoverySessionDto) {
    const session = await this.prisma.detoxSession.findFirst({ where: { id, userId } });
    if (!session) throw new NotFoundException('Detox session not found');
    return this.prisma.detoxSession.update({
      where: { id },
      data: {
        completedMinutes: dto.completedMinutes ?? session.completedMinutes,
        completed: dto.completed ?? session.completed,
        completedAt: dto.completedAt ? new Date(dto.completedAt) : session.completedAt,
        notes: dto.notes ?? session.notes,
      },
    });
  }

  async getGoals(userId: string) {
    return this.prisma.recoveryGoal.findFirst({ where: { userId, isActive: true } });
  }

  async createGoal(userId: string, dto: CreateRecoveryGoalDto) {
    await this.prisma.recoveryGoal.updateMany({ where: { userId, isActive: true }, data: { isActive: false } });
    return this.prisma.recoveryGoal.create({
      data: {
        userId,
        targetType: dto.targetType,
        targetValue: dto.targetValue,
        startDate: new Date(),
      },
    });
  }
}
