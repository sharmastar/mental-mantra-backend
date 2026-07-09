import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { HabitsService } from './habits.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Habits')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('habits')
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all habits' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.habitsService.findAll(userId) };
  }

  @Post()
  @ApiOperation({ summary: 'Create a habit' })
  async create(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.habitsService.create(userId, data) };
  }

  @Post(':id/log')
  @ApiOperation({ summary: 'Log habit completion' })
  async log(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return { success: true, data: await this.habitsService.log(userId, id) };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a habit' })
  async remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.habitsService.remove(userId, id);
    return { success: true, message: 'Habit removed' };
  }
}
