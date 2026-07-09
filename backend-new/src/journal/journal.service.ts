import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class JournalService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string, query: { limit?: any; skip?: any; search?: string }) {
    const limit = query.limit ? parseInt(query.limit, 10) : 20;
    const skip = query.skip ? parseInt(query.skip, 10) : 0;
    const where: any = { userId };
    if (query.search) {
      where.OR = [
        { title: { contains: query.search, mode: 'insensitive' } },
        { content: { contains: query.search, mode: 'insensitive' } },
      ];
    }
    const [entries, total] = await Promise.all([
      this.prisma.journalEntry.findMany({ where, orderBy: { createdAt: 'desc' }, take: limit, skip }),
      this.prisma.journalEntry.count({ where }),
    ]);
    return { entries: entries.map(this.parseTags), total, limit, skip };
  }

  async findOne(userId: string, id: string) {
    const entry = await this.prisma.journalEntry.findFirst({ where: { id, userId } });
    if (!entry) throw new NotFoundException('Journal entry not found');
    return this.parseTags(entry);
  }

  async create(userId: string, data: { title?: string; content: string; mood?: number; moodEmoji?: string; tags?: string[] }) {
    if (!data.content?.trim()) throw new NotFoundException('Content is required');
    const wordCount = data.content.trim().split(/\s+/).length;
    const entry = await this.prisma.journalEntry.create({
      data: { userId, title: data.title, content: data.content.trim(), mood: data.mood, moodEmoji: data.moodEmoji, tags: data.tags ? JSON.stringify(data.tags) : '[]', wordCount },
    });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: 20 } } });
    return this.parseTags(entry);
  }

  async update(userId: string, id: string, data: any) {
    const entry = await this.prisma.journalEntry.findFirst({ where: { id, userId } });
    if (!entry) throw new NotFoundException('Journal entry not found');
    const tags = data.tags !== undefined ? JSON.stringify(data.tags) : entry.tags;
    const updated = await this.prisma.journalEntry.update({
      where: { id },
      data: { ...data, tags, wordCount: data.content ? data.content.trim().split(/\s+/).length : entry.wordCount },
    });
    return this.parseTags(updated);
  }

  async remove(userId: string, id: string) {
    const entry = await this.prisma.journalEntry.findFirst({ where: { id, userId } });
    if (!entry) throw new NotFoundException('Journal entry not found');
    await this.prisma.journalEntry.delete({ where: { id } });
  }

  private parseTags(entry: any) {
    if (entry?.tags) {
      try { entry.tags = JSON.parse(entry.tags); } catch { entry.tags = entry.tags.split(',').filter(Boolean); }
    } else {
      entry.tags = [];
    }
    return entry;
  }
}
