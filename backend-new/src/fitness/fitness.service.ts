import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class FitnessService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.fitnessRecord.findMany({ where: { userId }, orderBy: { date: 'desc' }, take: 30 });
  }

  async create(userId: string, data: { activity: string; durationMin: number; calories?: number; notes?: string; date: string }) {
    return this.prisma.fitnessRecord.create({ data: { userId, activity: data.activity, durationMin: data.durationMin, calories: data.calories, notes: data.notes, date: new Date(data.date) } });
  }
}
