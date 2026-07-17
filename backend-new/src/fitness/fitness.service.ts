import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateFitnessDto } from './dto/create-fitness.dto';

@Injectable()
export class FitnessService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.fitnessRecord.findMany({ where: { userId }, orderBy: { date: 'desc' }, take: 30 });
  }

  async create(userId: string, dto: CreateFitnessDto) {
    return this.prisma.fitnessRecord.create({ data: { userId, activity: dto.activity, durationMin: dto.durationMin, calories: dto.calories, notes: dto.notes, date: new Date(dto.date) } });
  }
}
