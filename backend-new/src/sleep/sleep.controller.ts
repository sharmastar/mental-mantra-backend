import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SleepService } from './sleep.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateSleepDto } from './dto/create-sleep.dto';

@ApiTags('Sleep')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sleep')
export class SleepController {
  constructor(private readonly sleepService: SleepService) {}

  @Get()
  @ApiOperation({ summary: 'Get sleep logs' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.sleepService.findAll(userId) };
  }

  @Post()
  @ApiOperation({ summary: 'Log sleep' })
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateSleepDto) {
    return { success: true, data: await this.sleepService.create(userId, dto) };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete sleep log' })
  async remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.sleepService.remove(userId, id);
    return { success: true, message: 'Sleep log deleted' };
  }
}
