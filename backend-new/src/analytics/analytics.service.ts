import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, data: { event: string; properties?: any; sessionId?: string }) {
    return this.prisma.analytics.create({
      data: { userId, event: data.event, properties: data.properties ? JSON.stringify(data.properties) : null, sessionId: data.sessionId },
    });
  }

  async findAll(userId: string) {
    return this.prisma.analytics.findMany({ where: { userId }, orderBy: { createdAt: 'desc' }, take: 100 });
  }
}
