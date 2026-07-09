import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(userId: string) {
    const notifications = await this.prisma.notification.findMany({
      where: { userId }, orderBy: { sentAt: 'desc' }, take: 50,
    });
    return notifications.map(n => {
      if (n.data) { try { n.data = JSON.parse(n.data); } catch {} }
      return n;
    });
  }

  async markRead(userId: string, id: string) {
    const notif = await this.prisma.notification.findFirst({ where: { id, userId } });
    if (!notif) throw new NotFoundException('Notification not found');
    const updated = await this.prisma.notification.update({ where: { id }, data: { isRead: true } });
    if (updated.data) { try { updated.data = JSON.parse(updated.data); } catch {} }
    return updated;
  }

  async markAllRead(userId: string) {
    await this.prisma.notification.updateMany({ where: { userId, isRead: false }, data: { isRead: true } });
  }

  async remove(userId: string, id: string) {
    const notif = await this.prisma.notification.findFirst({ where: { id, userId } });
    if (!notif) throw new NotFoundException('Notification not found');
    await this.prisma.notification.delete({ where: { id } });
  }
}
