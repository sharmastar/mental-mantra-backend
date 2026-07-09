import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class YogaService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.yogaSession.findMany({ where: { userId }, orderBy: { completedAt: 'desc' }, take: 30 });
  }

  async create(userId: string, data: { sessionName: string; category?: string; durationMin: number }) {
    return this.prisma.yogaSession.create({ data: { userId, sessionName: data.sessionName, category: data.category || 'General', durationMin: data.durationMin } });
  }
}
