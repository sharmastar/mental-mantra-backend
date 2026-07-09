import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { YogaService } from './yoga.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Yoga')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('yoga')
export class YogaController {
  constructor(private readonly yogaService: YogaService) {}

  @Get()
  @ApiOperation({ summary: 'Get yoga sessions' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.yogaService.findAll(userId) };
  }

  @Post()
  @ApiOperation({ summary: 'Log yoga session' })
  async create(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.yogaService.create(userId, data) };
  }
}
