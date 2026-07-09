import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ProfileService } from './profile.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Profile')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get()
  @ApiOperation({ summary: 'Get user profile with stats' })
  async getProfile(@CurrentUser('id') userId: string) {
    const data = await this.profileService.getProfile(userId);
    return { success: true, data };
  }

  @Put()
  @ApiOperation({ summary: 'Update user profile' })
  async updateProfile(@CurrentUser('id') userId: string, @Body() data: any) {
    const result = await this.profileService.updateProfile(userId, data);
    if (!result) return { success: false, message: 'No valid fields to update' };
    return { success: true, data: result };
  }
}
