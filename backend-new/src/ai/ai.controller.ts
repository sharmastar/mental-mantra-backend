import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('AI')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  @Throttle({ default: { limit: 30, ttl: 600000 } })
  @ApiOperation({ summary: 'Chat with AI wellness coach' })
  async chat(@CurrentUser('id') userId: string, @Body() body: { messages: any[] }) {
    return { success: true, ...await this.aiService.chat(userId, body.messages) };
  }

  @Post('generate')
  @ApiOperation({ summary: 'Generate AI response for prompts' })
  async generate(@Body() body: { prompt: string }) {
    return { success: true, ...await this.aiService.generate(body.prompt) };
  }

  @Post('analyze-mood')
  @Throttle({ default: { limit: 20, ttl: 600000 } })
  @ApiOperation({ summary: 'Analyze mood from text' })
  async analyzeMood(@Body() body: { text: string }) {
    return { success: true, data: await this.aiService.analyzeMood(body.text) };
  }

  @Get('daily-insight')
  @ApiOperation({ summary: 'Get daily wellness insight' })
  getDailyInsight() {
    return { success: true, data: this.aiService.getDailyInsight() };
  }
}
