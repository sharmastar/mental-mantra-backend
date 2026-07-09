import { Controller, Get, Patch, Post, Delete, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get notifications' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.notificationsService.findAll(userId) };
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  async markRead(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return { success: true, data: await this.notificationsService.markRead(userId, id) };
  }

  @Post('read-all')
  @ApiOperation({ summary: 'Mark all as read' })
  async markAllRead(@CurrentUser('id') userId: string) {
    await this.notificationsService.markAllRead(userId);
    return { success: true, message: 'All notifications marked as read' };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete notification' })
  async remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.notificationsService.remove(userId, id);
    return { success: true, message: 'Notification deleted' };
  }
}
