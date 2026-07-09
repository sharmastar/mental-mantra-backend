import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Analytics')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Post()
  @ApiOperation({ summary: 'Track event' })
  async create(@CurrentUser('id') userId: string, @Body() data: { event: string; properties?: any }) {
    return { success: true, data: await this.analyticsService.create(userId, data) };
  }

  @Get()
  @ApiOperation({ summary: 'Get analytics events' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.analyticsService.findAll(userId) };
  }
}
