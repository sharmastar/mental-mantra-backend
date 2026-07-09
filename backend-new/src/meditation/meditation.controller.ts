import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MeditationService } from './meditation.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Meditation')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('meditation')
export class MeditationController {
  constructor(private readonly meditationService: MeditationService) {}

  @Post('session')
  @ApiOperation({ summary: 'Log a meditation session' })
  async createSession(@CurrentUser('id') userId: string, @Body() data: { sessionName: string; category?: string; durationMin: number }) {
    return { success: true, data: await this.meditationService.createSession(userId, data) };
  }

  @Get('history')
  @ApiOperation({ summary: 'Get meditation history' })
  async getHistory(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.meditationService.getHistory(userId) };
  }
}
