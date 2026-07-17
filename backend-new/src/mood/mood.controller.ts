import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MoodService } from './mood.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateMoodDto } from './dto/create-mood.dto';

@ApiTags('Mood')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('mood')
export class MoodController {
  constructor(private readonly moodService: MoodService) {}

  @Post()
  @ApiOperation({ summary: 'Log mood entry' })
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateMoodDto) {
    return { success: true, data: await this.moodService.create(userId, dto) };
  }

  @Get()
  @ApiOperation({ summary: 'Get mood entries' })
  async findAll(@CurrentUser('id') userId: string, @Query() query: any) {
    return { success: true, data: await this.moodService.findAll(userId, query) };
  }

  @Get('analytics')
  @ApiOperation({ summary: 'Get mood analytics' })
  async getAnalytics(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.moodService.getAnalytics(userId) };
  }
}
