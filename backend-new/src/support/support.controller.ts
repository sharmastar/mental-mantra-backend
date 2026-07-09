import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Support')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Post()
  @ApiOperation({ summary: 'Create support ticket' })
  async create(@CurrentUser('id') userId: string, @Body() data: { subject: string; message: string }) {
    return { success: true, data: await this.supportService.create(userId, data) };
  }

  @Get()
  @ApiOperation({ summary: 'Get support tickets' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.supportService.findAll(userId) };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get ticket by id' })
  async findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return { success: true, data: await this.supportService.findOne(userId, id) };
  }
}
