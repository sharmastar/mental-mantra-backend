import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AssessmentService } from './assessment.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Assessment')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('assessment')
export class AssessmentController {
  constructor(private readonly assessmentService: AssessmentService) {}

  @Post()
  @ApiOperation({ summary: 'Submit assessment' })
  async create(@CurrentUser('id') userId: string, @Body() data: any) {
    return { success: true, data: await this.assessmentService.create(userId, data) };
  }

  @Get()
  @ApiOperation({ summary: 'Get all assessments' })
  async findAll(@CurrentUser('id') userId: string) {
    return { success: true, data: await this.assessmentService.findAll(userId) };
  }
}
