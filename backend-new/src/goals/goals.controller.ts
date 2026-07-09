import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GoalsService } from './goals.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Goals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('goals')
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all goals' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.goalsService.findAll(userId) };
  }

  @Post()
  @ApiOperation({ summary: 'Create a goal' })
  async create(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.goalsService.create(userId, data) };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a goal' })
  async update(@CurrentUser('id') userId: string, @Param('id') id: string, @Body() data: any) {
    return { success: true, data: await this.goalsService.update(userId, id, data) };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a goal' })
  async remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.goalsService.remove(userId, id);
    return { success: true, message: 'Goal deleted successfully' };
  }
}
