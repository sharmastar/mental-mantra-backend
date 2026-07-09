import { Module } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { PrismaModule } from './common/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProfileModule } from './profile/profile.module';
import { AssessmentModule } from './assessment/assessment.module';
import { JournalModule } from './journal/journal.module';
import { MoodModule } from './mood/mood.module';
import { HabitsModule } from './habits/habits.module';
import { MeditationModule } from './meditation/meditation.module';
import { GoalsModule } from './goals/goals.module';
import { AiModule } from './ai/ai.module';
import { SleepModule } from './sleep/sleep.module';
import { NotificationsModule } from './notifications/notifications.module';
import { MusicModule } from './music/music.module';
import { AdminModule } from './admin/admin.module';
import { RecoveryModule } from './recovery/recovery.module';
import { SupportModule } from './support/support.module';
import { FeedbackModule } from './feedback/feedback.module';
import { AchievementsModule } from './achievements/achievements.module';
import { FitnessModule } from './fitness/fitness.module';
import { YogaModule } from './yoga/yoga.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ThrottlerModule.forRoot([{
      ttl: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
      limit: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    }]),
    PrismaModule,
    AuthModule,
    UsersModule,
    ProfileModule,
    AssessmentModule,
    JournalModule,
    MoodModule,
    HabitsModule,
    MeditationModule,
    GoalsModule,
    AiModule,
    SleepModule,
    NotificationsModule,
    MusicModule,
    AdminModule,
    RecoveryModule,
    SupportModule,
    FeedbackModule,
    AchievementsModule,
    FitnessModule,
    YogaModule,
    AnalyticsModule,
  ],
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
