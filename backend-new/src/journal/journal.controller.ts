import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JournalService } from './journal.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Journal')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('journal')
export class JournalController {
  constructor(private readonly journalService: JournalService) {}

  @Get()
  @ApiOperation({ summary: 'Get journal entries' })
  async findAll(@CurrentUser('id') userId: string, @Query() query: any) {
    return { success: true, data: await this.journalService.findAll(userId, query) };
  }

  @Post()
  @ApiOperation({ summary: 'Create journal entry' })
  async create(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.journalService.create(userId, data) };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get journal entry by id' })
  async findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return { success: true, data: await this.journalService.findOne(userId, id) };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update journal entry' })
  async update(@CurrentUser('id') userId: string, @Param('id') id: string, @Body() data: any) {
    return { success: true, data: await this.journalService.update(userId, id, data) };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete journal entry' })
  async remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.journalService.remove(userId, id);
    return { success: true, message: 'Entry deleted' };
  }
}
