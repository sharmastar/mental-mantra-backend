import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class FeedbackService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, data: { type: string; message: string; rating?: number }) {
    return this.prisma.feedback.create({ data: { userId, type: data.type, message: data.message, rating: data.rating } });
  }
}
