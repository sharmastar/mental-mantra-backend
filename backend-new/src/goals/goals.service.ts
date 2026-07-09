import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class GoalsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.goal.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
  }

  async create(userId: string, data: any) {
    return this.prisma.goal.create({
      data: { userId, title: data.title, description: data.description, category: data.category, targetValue: data.targetValue, currentValue: data.currentValue || 0, deadline: data.deadline ? new Date(data.deadline) : null },
    });
  }

  async update(userId: string, id: string, data: any) {
    const existing = await this.prisma.goal.findFirst({ where: { id, userId } });
    if (!existing) throw new NotFoundException('Goal not found');
    const updates: any = {};
    if (data.title !== undefined) updates.title = data.title;
    if (data.description !== undefined) updates.description = data.description;
    if (data.category !== undefined) updates.category = data.category;
    if (data.targetValue !== undefined) updates.targetValue = data.targetValue;
    if (data.currentValue !== undefined) updates.currentValue = data.currentValue;
    if (data.deadline !== undefined) updates.deadline = data.deadline ? new Date(data.deadline) : null;
    if (data.completed !== undefined) updates.completed = data.completed;
    const target = updates.targetValue ?? existing.targetValue;
    const current = updates.currentValue ?? existing.currentValue;
    if (current >= target) updates.completed = true;
    return this.prisma.goal.update({ where: { id }, data: updates });
  }

  async remove(userId: string, id: string) {
    const existing = await this.prisma.goal.findFirst({ where: { id, userId } });
    if (!existing) throw new NotFoundException('Goal not found');
    await this.prisma.goal.delete({ where: { id } });
  }
}
