import { Injectable, Logger } from '@nestjs/common';
import { GoogleGenerativeAI } from '@google/generative-ai';

const SYSTEM_PROMPT = `You are Maya, an empathetic AI wellness companion for Mental Mantra app.
Your role is to provide emotional support, mindfulness guidance, and wellness coaching.

STRICT RULES:
- NEVER diagnose mental illness or medical conditions
- NEVER recommend stopping prescribed medication
- NEVER claim to replace professional therapy
- If someone expresses suicidal thoughts or danger, provide crisis resources (e.g., "Please contact a crisis helpline: 988 in US, iCall 9152987821 in India")
- Use warm, compassionate, supportive language
- Keep responses concise (2-4 paragraphs max)
- Focus on practical coping strategies
- Acknowledge feelings before offering advice
- Include breathing exercises, grounding techniques when appropriate`;

const FALLBACKS = [
  "I hear you, and I'm here for you. Sometimes just expressing what we're feeling is the first step. Take a deep breath—inhale for 4 counts, hold for 4, exhale for 6. How are you feeling right now?",
  "Thank you for sharing that with me. Your feelings are valid. Remember that difficult emotions are temporary, like clouds passing through the sky. What small thing could bring you comfort right now?",
  "I'm sorry you're going through this. You've shown courage by reaching out. Would you like to try a quick grounding exercise? Notice 5 things you can see, 4 you can touch, 3 you can hear.",
];

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private genAI: GoogleGenerativeAI | null = null;

  constructor() {
    const key = process.env.GEMINI_API_KEY;
    if (key && !key.startsWith('your_')) {
      this.genAI = new GoogleGenerativeAI(key);
    }
  }

  async chat(messages: any[]) {
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return { reply: 'Please provide a message to start the conversation.' };
    }

    let systemInstruction = SYSTEM_PROMPT;
    const systemIdx = messages.findIndex(m => m.role === 'system');
    if (systemIdx !== -1 && messages[systemIdx].content) {
      systemInstruction += '\n\nAdditional context:\n' + messages[systemIdx].content;
    }

    const history = messages
      .filter(m => m.role !== 'system')
      .map(m => ({ role: m.role === 'assistant' ? 'model' : 'user', parts: [{ text: m.content || m.text || '' }] }));

    if (!this.genAI || history.length === 0) {
      return { reply: FALLBACKS[Math.floor(Math.random() * FALLBACKS.length)] };
    }

    try {
      const model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash', systemInstruction });
      if (history.length === 1) {
        const result = await model.generateContent(history[0].parts[0].text);
        return { reply: result.response.text() };
      }
      const chat = model.startChat({ history: history.slice(0, -1) });
      const result = await chat.sendMessage(history[history.length - 1].parts[0].text);
      return { reply: result.response.text() };
    } catch (err: any) {
      this.logger.error('Gemini chat error', err.message);
      return { reply: FALLBACKS[Math.floor(Math.random() * FALLBACKS.length)] };
    }
  }

  async generate(prompt: string) {
    if (!this.genAI) {
      return { text: JSON.stringify({ overallScore: 50, primaryConcerns: ['Stress Management'], strengths: ['Self-awareness'], riskLevel: 'low', summary: 'AI features require a configured API key.', recommendedFocusAreas: ['Stress Management', 'Sleep'], encouragement: 'Keep going!' }) };
    }
    try {
      const model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
      const result = await model.generateContent(prompt);
      return { text: result.response.text() };
    } catch (err: any) {
      this.logger.error('Gemini generate error', err.message);
      return { text: 'AI generation failed. Please try again.' };
    }
  }

  async analyzeMood(text: string) {
    let sentiment = 'neutral';
    let suggestion = 'Practice mindfulness and self-compassion today.';
    if (this.genAI) {
      try {
        const model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
        const prompt = [
          'Analyze the sentiment of the journal entry below and provide a single-sentence wellness suggestion.',
          'Respond with valid JSON only: {"sentiment": "positive|negative|neutral|mixed", "suggestion": "..."}',
          '---BEGIN ENTRY---', text, '---END ENTRY---',
        ].join('\n');
        const result = await model.generateContent(prompt);
        const raw = result.response.text();
        const jsonMatch = raw.match(/\{[\s\S]*\}/);
        const parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
        sentiment = parsed.sentiment || 'neutral';
        suggestion = parsed.suggestion || suggestion;
      } catch (err: any) {
        this.logger.error('Mood analysis error', err.message);
      }
    }
    return { sentiment, suggestion };
  }

  getDailyInsight() {
    const insights = [
      "Every breath is an opportunity to start fresh. Your journey to wellness is unique and valid.",
      "Progress isn't always linear. A difficult day doesn't erase your growth.",
      "Self-compassion is the foundation of all healing. Treat yourself with the kindness you'd show a good friend.",
      "Your emotions are messengers, not enemies. Listen to what they're trying to tell you.",
      "Small consistent actions create lasting change. Celebrate every tiny step forward.",
    ];
    return { insight: insights[new Date().getDate() % insights.length] };
  }
}
