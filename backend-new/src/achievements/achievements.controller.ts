import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AchievementsService } from './achievements.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Achievements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('achievements')
export class AchievementsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  @Get()
  @ApiOperation({ summary: 'Get achievements' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.achievementsService.findAll(userId) };
  }

  @Get('rewards')
  @ApiOperation({ summary: 'Get rewards' })
  async getRewards(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.achievementsService.getRewards(userId) };
  }
}
