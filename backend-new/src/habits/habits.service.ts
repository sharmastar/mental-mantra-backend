import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateHabitDto } from './dto/create-habit.dto';

@Injectable()
export class HabitsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    const habits = await this.prisma.habit.findMany({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'asc' },
    });
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const logs = await this.prisma.habitLog.findMany({
      where: { userId, date: { gte: today } },
    });
    const logMap = Object.fromEntries(logs.map(l => [l.habitId, l]));
    return habits.map(h => ({ ...h, todayDone: !!logMap[h.id] }));
  }

  async create(userId: string, dto: CreateHabitDto) {
    return this.prisma.habit.create({
      data: { userId, name: dto.name, description: dto.description, icon: dto.icon, color: dto.color, frequency: dto.frequency || 'daily', targetCount: dto.targetCount || 1 },
    });
  }

  async log(userId: string, habitId: string) {
    const habit = await this.prisma.habit.findFirst({ where: { id: habitId, userId } });
    if (!habit) throw new NotFoundException('Habit not found');
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const log = await this.prisma.habitLog.upsert({
      where: { habitId_date: { habitId, date: today } },
      update: { count: { increment: 1 } },
      create: { userId, habitId, date: today, count: 1 },
    });
    await this.prisma.habit.update({ where: { id: habitId }, data: { streak: { increment: 1 } } });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: 15 } } });
    return log;
  }

  async remove(userId: string, habitId: string) {
    await this.prisma.habit.updateMany({ where: { id: habitId, userId }, data: { isActive: false } });
  }
}
