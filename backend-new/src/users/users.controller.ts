import { Controller, Get, Post, Put, Delete, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UpdateUserDto, OnboardingDto, FcmTokenDto } from './dto/update-user.dto';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  async getMe(@CurrentUser('id') userId: string) {
    const data = await this.usersService.getMe(userId);
    return { success: true, data };
  }

  @Put('me')
  @ApiOperation({ summary: 'Update current user profile' })
  async updateMe(@CurrentUser('id') userId: string, @Body() dto: UpdateUserDto) {
    const data = await this.usersService.updateMe(userId, dto);
    return { success: true, data };
  }

  @Post('me/onboarding')
  @ApiOperation({ summary: 'Complete onboarding' })
  async completeOnboarding(@CurrentUser('id') userId: string, @Body() dto: OnboardingDto) {
    await this.usersService.completeOnboarding(userId, dto);
    return { success: true, message: 'Onboarding completed' };
  }

  @Get('me/stats')
  @ApiOperation({ summary: 'Get user statistics' })
  async getStats(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.usersService.getStats(userId) };
  }

  @Post('me/fcm-token')
  @ApiOperation({ summary: 'Update FCM token' })
  async updateFcmToken(@CurrentUser('id') userId: string, @Body() dto: FcmTokenDto) {
    await this.usersService.updateFcmToken(userId, dto.token);
    return { success: true };
  }

  @Delete('me')
  @ApiOperation({ summary: 'Delete current user account' })
  async deleteMe(@CurrentUser('id') userId: string) {
    await this.usersService.deleteAccount(userId);
    return { success: true, message: 'Account deleted successfully' };
  }

  @Get('me/dashboard')
  @ApiOperation({ summary: 'Get aggregated dashboard data for startup' })
  async getDashboard(@CurrentUser('id') userId: string) {
    const data = await this.usersService.getDashboard(userId);
    return { success: true, data };
  }
}
