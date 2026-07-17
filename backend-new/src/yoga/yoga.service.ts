import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateYogaDto } from './dto/create-yoga.dto';

@Injectable()
export class YogaService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.yogaSession.findMany({ where: { userId }, orderBy: { completedAt: 'desc' }, take: 30 });
  }

  async create(userId: string, dto: CreateYogaDto) {
    return this.prisma.yogaSession.create({ data: { userId, sessionName: dto.sessionName, category: dto.category || 'General', durationMin: dto.durationMin } });
  }
}
