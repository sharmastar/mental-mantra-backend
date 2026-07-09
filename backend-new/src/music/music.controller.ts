import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MusicService } from './music.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Music')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('music')
export class MusicController {
  constructor(private readonly musicService: MusicService) {}

  @Post('history')
  @ApiOperation({ summary: 'Add music history' })
  async addHistory(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.musicService.addHistory(userId, data) };
  }

  @Get('history')
  @ApiOperation({ summary: 'Get music history' })
  async getHistory(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.musicService.getHistory(userId) };
  }

  @Delete('history/:id')
  @ApiOperation({ summary: 'Delete music history entry' })
  async deleteHistory(@CurrentUser('id') userId: string, @Param('id') id: string) {
    await this.musicService.deleteHistory(userId, id);
    return { success: true };
  }

  @Post('playlist')
  @ApiOperation({ summary: 'Create playlist' })
  async createPlaylist(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.musicService.createPlaylist(userId, data) };
  }

  @Get('playlists')
  @ApiOperation({ summary: 'Get playlists' })
  async getPlaylists(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.musicService.getPlaylists(userId) };
  }

  @Post('favorites')
  @ApiOperation({ summary: 'Toggle favorite' })
  async toggleFavorite(@CurrentUser('id') userId: string, @Body() data: { itemId: string; itemType: string }) {
    return { success: true, ...await this.musicService.toggleFavorite(userId, data) };
  }

  @Get('favorites')
  @ApiOperation({ summary: 'Get favorites' })
  async getFavorites(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.musicService.getFavorites(userId) };
  }
}
