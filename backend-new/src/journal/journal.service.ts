import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

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

  async create(userId: string, dto: CreateJournalDto) {
    if (!dto.content?.trim()) throw new NotFoundException('Content is required');
    const wordCount = dto.content.trim().split(/\s+/).length;
    const entry = await this.prisma.journalEntry.create({
      data: {
        userId,
        title: dto.title,
        content: dto.content.trim(),
        mood: dto.mood,
        moodEmoji: dto.moodEmoji,
        tags: dto.tags ? JSON.stringify(dto.tags) : '[]',
        wordCount,
      },
    });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: 20 } } });
    return this.parseTags(entry);
  }

  async update(userId: string, id: string, dto: UpdateJournalDto) {
    const entry = await this.prisma.journalEntry.findFirst({ where: { id, userId } });
    if (!entry) throw new NotFoundException('Journal entry not found');
    const tags = dto.tags !== undefined ? JSON.stringify(dto.tags) : entry.tags;
    const updated = await this.prisma.journalEntry.update({
      where: { id },
      data: {
        title: dto.title !== undefined ? dto.title : entry.title,
        content: dto.content !== undefined ? dto.content.trim() : entry.content,
        mood: dto.mood !== undefined ? dto.mood : entry.mood,
        moodEmoji: dto.moodEmoji !== undefined ? dto.moodEmoji : entry.moodEmoji,
        tags,
        wordCount: dto.content ? dto.content.trim().split(/\s+/).length : entry.wordCount,
      },
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
