import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';

@Injectable()
export class GoalsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.goal.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
  }

  async create(userId: string, dto: CreateGoalDto) {
    return this.prisma.goal.create({
      data: { userId, title: dto.title, description: dto.description, category: dto.category, targetValue: dto.targetValue, currentValue: dto.currentValue || 0, deadline: dto.deadline ? new Date(dto.deadline) : null },
    });
  }

  async update(userId: string, id: string, dto: UpdateGoalDto) {
    const existing = await this.prisma.goal.findFirst({ where: { id, userId } });
    if (!existing) throw new NotFoundException('Goal not found');
    const updates: any = {};
    if (dto.title !== undefined) updates.title = dto.title;
    if (dto.description !== undefined) updates.description = dto.description;
    if (dto.category !== undefined) updates.category = dto.category;
    if (dto.targetValue !== undefined) updates.targetValue = dto.targetValue;
    if (dto.currentValue !== undefined) updates.currentValue = dto.currentValue;
    if (dto.deadline !== undefined) updates.deadline = dto.deadline ? new Date(dto.deadline) : null;
    if (dto.completed !== undefined) updates.completed = dto.completed;
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
