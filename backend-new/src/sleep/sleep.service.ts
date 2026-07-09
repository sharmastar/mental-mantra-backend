import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class SleepService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.sleepLog.findMany({
      where: { userId }, orderBy: { date: 'desc' }, take: 30,
    });
  }

  async create(userId: string, data: { bedtime: string; wakeTime: string; quality?: number; notes?: string; date: string }) {
    const bedDateTime = new Date(data.bedtime);
    const wakeDateTime = new Date(data.wakeTime);
    const durationMin = Math.round((wakeDateTime.getTime() - bedDateTime.getTime()) / 60000);
    if (durationMin <= 0) throw new BadRequestException('Wake time must be after bedtime');
    return this.prisma.sleepLog.create({
      data: { userId, bedtime: bedDateTime, wakeTime: wakeDateTime, durationMin, quality: data.quality, notes: data.notes, date: new Date(data.date) },
    });
  }

  async remove(userId: string, id: string) {
    const log = await this.prisma.sleepLog.findFirst({ where: { id, userId } });
    if (!log) throw new NotFoundException('Sleep log not found');
    await this.prisma.sleepLog.delete({ where: { id } });
  }
}
