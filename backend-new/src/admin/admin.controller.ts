import { Controller, Get, Patch, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@ApiTags('Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN', 'SUPER_ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('users')
  @ApiOperation({ summary: 'Get all users (admin)' })
  async getUsers(@Query('page') page?: number, @Query('limit') limit?: number) {
    return { success: true, ...await this.adminService.getUsers(page, limit) };
  }

  @Patch('users/:id/status')
  @ApiOperation({ summary: 'Update user status' })
  async updateUserStatus(@Param('id') id: string, @Body() data: any) {
    return { success: true, data: await this.adminService.updateUserStatus(id, data) };
  }

  @Get('analytics')
  @ApiOperation({ summary: 'Get platform analytics' })
  async getAnalytics(@Query('days') days?: number) {
    return { success: true, data: await this.adminService.getAnalytics(days) };
  }

  @Get('reports')
  @ApiOperation({ summary: 'Get reports' })
  async getReports() {
    return { success: true, data: await this.adminService.getReports() };
  }

  @Get('subscriptions')
  @ApiOperation({ summary: 'Get subscriptions' })
  async getSubscriptions() {
    return { success: true, data: await this.adminService.getSubscriptions() };
  }

  @Get('feedback')
  @ApiOperation({ summary: 'Get feedback' })
  async getFeedback() {
    return { success: true, data: await this.adminService.getFeedback() };
  }
}
