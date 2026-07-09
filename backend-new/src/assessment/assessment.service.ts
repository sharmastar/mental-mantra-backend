import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';

@Injectable()
export class AssessmentService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, data: any) {
    const assessment = await this.prisma.assessment.create({
      data: {
        userId, name: data.name, lifestyle: data.lifestyle, reasons: data.reasons,
        duration: data.duration, overwhelmedFrequency: data.overwhelmedFrequency,
        sleepQuality: data.sleepQuality, affectingHabits: data.affectingHabits,
        stressCoping: data.stressCoping, improvementGoals: data.improvementGoals,
        desiredSupport: data.desiredSupport, completed: data.completed || false,
        domain: data.domain, score: data.score,
      },
    });
    if (data.answers && Array.isArray(data.answers)) {
      for (const ans of data.answers) {
        await this.prisma.assessmentAnswer.create({
          data: { assessmentId: assessment.id, questionId: ans.questionId, answer: ans.answer, score: ans.score },
        });
      }
    }
    return this.findOne(assessment.id);
  }

  async findAll(userId: string) {
    return this.prisma.assessment.findMany({
      where: { userId }, orderBy: { createdAt: 'desc' }, include: { answers: true },
    });
  }

  async findOne(id: string) {
    return this.prisma.assessment.findUnique({ where: { id }, include: { answers: true } });
  }
}
