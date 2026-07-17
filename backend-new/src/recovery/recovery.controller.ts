import { Controller, Get, Post, Put, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { RecoveryService } from './recovery.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateUrgeDto } from './dto/create-urge.dto';
import { CreateRecoverySessionDto } from './dto/create-recovery-session.dto';
import { UpdateRecoverySessionDto } from './dto/update-recovery-session.dto';
import { CreateRecoveryGoalDto } from './dto/create-recovery-goal.dto';

@ApiTags('Recovery')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('recovery')
export class RecoveryController {
  constructor(private readonly recoveryService: RecoveryService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Get recovery stats' })
  async getStats(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.recoveryService.getStats(userId) };
  }

  @Get('urges')
  @ApiOperation({ summary: 'Get urge logs' })
  async getUrges(@CurrentUser('id') userId: string, @Query('limit') limit?: number) {
    return { success: true, data: await this.recoveryService.getUrges(userId, limit) };
  }

  @Post('urges')
  @ApiOperation({ summary: 'Log an urge' })
  async createUrge(@CurrentUser('id') userId: string, @Body() dto: CreateUrgeDto) {
    return { success: true, data: await this.recoveryService.createUrge(userId, dto) };
  }

  @Get('sessions')
  @ApiOperation({ summary: 'Get detox sessions' })
  async getSessions(@CurrentUser('id') userId: string, @Query('limit') limit?: number) {
    return { success: true, data: await this.recoveryService.getSessions(userId, limit) };
  }

  @Post('sessions')
  @ApiOperation({ summary: 'Start a detox session' })
  async createSession(@CurrentUser('id') userId: string, @Body() dto: CreateRecoverySessionDto) {
    return { success: true, data: await this.recoveryService.createSession(userId, dto) };
  }

  @Put('sessions/:id')
  @ApiOperation({ summary: 'Update a detox session' })
  async updateSession(@CurrentUser('id') userId: string, @Param('id') id: string, @Body() dto: UpdateRecoverySessionDto) {
    return { success: true, data: await this.recoveryService.updateSession(userId, id, dto) };
  }

  @Get('goals')
  @ApiOperation({ summary: 'Get active recovery goal' })
  async getGoals(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.recoveryService.getGoals(userId) };
  }

  @Post('goals')
  @ApiOperation({ summary: 'Create a recovery goal' })
  async createGoal(@CurrentUser('id') userId: string, @Body() dto: CreateRecoveryGoalDto) {
    return { success: true, data: await this.recoveryService.createGoal(userId, dto) };
  }
}
