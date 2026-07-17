import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateMoodDto } from './dto/create-mood.dto';

@Injectable()
export class MoodService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateMoodDto) {
    const entry = await this.prisma.moodEntry.create({
      data: { userId, mood: dto.mood, emoji: dto.emoji || '😐', label: dto.label, note: dto.note, tags: dto.tags ? JSON.stringify(dto.tags) : '[]' },
    });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: 10 } } });
    return this.parseTags(entry);
  }

  async findAll(userId: string, query: { limit?: any; skip?: any }) {
    const limit = query.limit ? parseInt(query.limit, 10) : 30;
    const skip = query.skip ? parseInt(query.skip, 10) : 0;
    const entries = await this.prisma.moodEntry.findMany({
      where: { userId }, orderBy: { loggedAt: 'desc' }, take: limit, skip,
    });
    return entries.map(this.parseTags);
  }

  async getAnalytics(userId: string) {
    const since = new Date(Date.now() - 7 * 86400000);
    const entries = await this.prisma.moodEntry.findMany({
      where: { userId, loggedAt: { gte: since } },
      orderBy: { loggedAt: 'asc' },
    });
    const parsed = entries.map(this.parseTags);
    const avg = parsed.length > 0 ? parsed.reduce((s: number, e: any) => s + e.mood, 0) / parsed.length : 0;
    return { entries: parsed, weeklyAverage: avg.toFixed(2), totalEntries: parsed.length };
  }

  private parseTags(entry: any) {
    if (entry?.tags) {
      try { entry.tags = JSON.parse(entry.tags); } catch { entry.tags = entry.tags.split(',').filter(Boolean); }
    } else { entry.tags = []; }
    return entry;
  }
}
