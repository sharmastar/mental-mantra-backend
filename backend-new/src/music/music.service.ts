import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class MusicService {
  constructor(private readonly prisma: PrismaService) {}

  async addHistory(userId: string, data: { trackName: string; category: string; durationSec?: number }) {
    const history = await this.prisma.musicHistory.create({
      data: { userId, trackName: data.trackName, category: data.category, durationSec: data.durationSec || 0 },
    });
    await this.prisma.user.update({ where: { id: userId }, data: { totalPoints: { increment: 2 } } });
    return history;
  }

  async getHistory(userId: string) {
    return this.prisma.musicHistory.findMany({ where: { userId }, orderBy: { playedAt: 'desc' }, take: 50 });
  }

  async deleteHistory(userId: string, id: string) {
    await this.prisma.musicHistory.deleteMany({ where: { id, userId } });
  }

  async createPlaylist(userId: string, data: { name: string; description?: string; tracks?: any[] }) {
    return this.prisma.playlist.create({
      data: { userId, name: data.name, description: data.description, tracks: data.tracks ? JSON.stringify(data.tracks) : null },
    });
  }

  async getPlaylists(userId: string) {
    const playlists = await this.prisma.playlist.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
    return playlists.map(p => ({ ...p, tracks: p.tracks ? JSON.parse(p.tracks) : [] }));
  }

  async toggleFavorite(userId: string, data: { itemId: string; itemType: string }) {
    const existing = await this.prisma.favorite.findUnique({
      where: { userId_itemId_itemType: { userId, itemId: data.itemId, itemType: data.itemType } },
    });
    if (existing) {
      await this.prisma.favorite.delete({ where: { id: existing.id } });
      return { favorited: false };
    }
    await this.prisma.favorite.create({ data: { userId, itemId: data.itemId, itemType: data.itemType } });
    return { favorited: true };
  }

  async getFavorites(userId: string) {
    return this.prisma.favorite.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });
  }
}
