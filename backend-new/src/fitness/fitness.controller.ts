import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FitnessService } from './fitness.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateFitnessDto } from './dto/create-fitness.dto';

@ApiTags('Fitness')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('fitness')
export class FitnessController {
  constructor(private readonly fitnessService: FitnessService) {}

  @Get()
  @ApiOperation({ summary: 'Get fitness records' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.fitnessService.findAll(userId) };
  }

  @Post()
  @ApiOperation({ summary: 'Log fitness activity' })
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateFitnessDto) {
    return { success: true, data: await this.fitnessService.create(userId, dto) };
  }
}
