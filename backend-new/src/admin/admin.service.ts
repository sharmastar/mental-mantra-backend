import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async getUsers(page: any = 1, limit: any = 20) {
    const p = page ? parseInt(page.toString(), 10) : 1;
    const l = limit ? parseInt(limit.toString(), 10) : 20;
    const skip = (p - 1) * l;
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        skip, take: l, orderBy: { createdAt: 'desc' },
        select: { id: true, email: true, name: true, role: true, isActive: true, isPremium: true, streakDays: true, totalPoints: true, level: true, createdAt: true, lastActiveAt: true },
      }),
      this.prisma.user.count(),
    ]);
    return { data: users, pagination: { page: p, limit: l, total, pages: Math.ceil(total / l) } };
  }

  async updateUserStatus(id: string, data: any) {
    return this.prisma.user.update({ where: { id }, data: { ...(data.isActive !== undefined && { isActive: data.isActive }), ...(data.isPremium !== undefined && { isPremium: data.isPremium }), ...(data.role && { role: data.role }) } });
  }

  async getAnalytics(days = 30) {
    const since = new Date(Date.now() - days * 86400000);
    const [totalUsers, activeUsers, newUsers, premiumUsers] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { lastActiveAt: { gte: since } } }),
      this.prisma.user.count({ where: { createdAt: { gte: since } } }),
      this.prisma.user.count({ where: { isPremium: true } }),
    ]);
    const [totalMoods, totalJournals, totalMeditations, totalSessions] = await Promise.all([
      this.prisma.moodEntry.count({ where: { loggedAt: { gte: since } } }),
      this.prisma.journalEntry.count({ where: { createdAt: { gte: since } } }),
      this.prisma.meditationSession.count({ where: { completedAt: { gte: since } } }),
      this.prisma.aIChatMessage.count({ where: { createdAt: { gte: since } } }),
    ]);
    return { totalUsers, activeUsers, newUsers, premiumUsers, totalMoods, totalJournals, totalMeditations, totalSessions };
  }

  async getReports() {
    return this.prisma.report.findMany({ orderBy: { createdAt: 'desc' }, take: 50, include: { user: { select: { id: true, name: true, email: true } } } });
  }

  async getSubscriptions() {
    return this.prisma.subscription.findMany({ include: { user: { select: { id: true, name: true, email: true } } }, orderBy: { createdAt: 'desc' } });
  }

  async getFeedback() {
    return this.prisma.feedback.findMany({ include: { user: { select: { id: true, name: true, email: true } } }, orderBy: { createdAt: 'desc' }, take: 100 });
  }
}
