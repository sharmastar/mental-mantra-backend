const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const rateLimit = require('express-rate-limit');
const { authMiddleware } = require('../middleware/auth.middleware');
const { logger } = require('../utils/logger');
const router = express.Router();

const aiLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 30,
  message: { success: false, message: 'Too many AI requests.' },
});

const geminiKey = process.env.GEMINI_API_KEY;
let genAI = null;
if (geminiKey && !geminiKey.startsWith('your_')) {
  genAI = new GoogleGenerativeAI(geminiKey);
}

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

async function chatWithGemini(messages) {
  if (!genAI) throw new Error('Gemini API not configured');
  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
  const chat = model.startChat({ history: messages.slice(0, -1) });
  const result = await chat.sendMessage(messages[messages.length - 1].parts[0].text);
  return result.response.text();
}

const fallbacks = [
  "I hear you, and I'm here for you. Sometimes just expressing what we're feeling is the first step. Take a deep breath—inhale for 4 counts, hold for 4, exhale for 6. How are you feeling right now?",
  "Thank you for sharing that with me. Your feelings are valid. Remember that difficult emotions are temporary, like clouds passing through the sky. What small thing could bring you comfort right now?",
  "I'm sorry you're going through this. You've shown courage by reaching out. Would you like to try a quick grounding exercise? Notice 5 things you can see, 4 you can touch, 3 you can hear.",
];

// POST /api/ai/chat — authenticated route to prevent abuse
router.post('/chat', authMiddleware, aiLimiter, async (req, res, next) => {
  try {
    const { messages } = req.body;
    if (!messages || !Array.isArray(messages)) {
      return res.status(422).json({ success: false, message: 'Messages array is required' });
    }

    // Always use the base system prompt for safety; append user context if provided
    let systemInstruction = SYSTEM_PROMPT;
    const systemMessageIndex = messages.findIndex(m => m.role === 'system');
    if (systemMessageIndex !== -1) {
      const userInstruction = messages[systemMessageIndex].content || messages[systemMessageIndex].text;
      if (userInstruction) {
        systemInstruction = SYSTEM_PROMPT + '\n\nAdditional context from user:\n' + userInstruction;
      }
    }

    // Filter out system message and map roles to Gemini format ('user' and 'model')
    const chatHistory = messages
      .filter(m => m.role !== 'system')
      .map(m => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content || m.text || '' }]
      }));

    if (chatHistory.length === 0) {
      return res.status(422).json({ success: false, message: 'At least one user message is required' });
    }

    if (!genAI) {
      return res.json({ success: true, reply: fallbacks[Math.floor(Math.random() * fallbacks.length)] });
    }

    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash',
      systemInstruction: systemInstruction
    });

    if (chatHistory.length === 1) {
      const result = await model.generateContent(chatHistory[0].parts[0].text);
      return res.json({ success: true, reply: result.response.text() });
    }

    const history = chatHistory.slice(0, -1);
    const lastMessageText = chatHistory[chatHistory.length - 1].parts[0].text;

    const chat = model.startChat({ history });
    const result = await chat.sendMessage(lastMessageText);
    const reply = result.response.text();

    res.json({ success: true, reply });
  } catch (err) {
    logger.error('Gemini chat error', { error: err.message });
    next(err);
  }
});

// POST /api/ai/generate — authenticated route for client-side AI coach tasks
router.post('/generate', authMiddleware, async (req, res, next) => {
  try {
    const { prompt } = req.body;
    if (!prompt?.trim()) {
      return res.status(422).json({ success: false, message: 'Prompt is required' });
    }

    if (!genAI) {
      return res.json({ success: true, text: JSON.stringify({ overallScore: 50, primaryConcerns: ['Stress Management'], strengths: ['Self-awareness'], riskLevel: 'low', summary: 'AI features require a configured API key.', recommendedFocusAreas: ['Stress Management', 'Sleep'], encouragement: 'Keep going!' }) });
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
    const result = await model.generateContent(prompt);
    const text = result.response.text();

    res.json({ success: true, text });
  } catch (err) {
    logger.error('Gemini generate error', { error: err.message });
    next(err);
  }
});

const moodLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 20,
  message: { success: false, message: 'Too many mood analysis requests.' },
});

router.post('/analyze-mood', authMiddleware, moodLimiter, async (req, res, next) => {
  try {
    const { text } = req.body;
    if (!text) return res.status(422).json({ success: false, message: 'Text required' });

    let sentiment = 'neutral';
    let suggestion = 'Practice mindfulness and self-compassion today.';

    try {
      if (!genAI) throw new Error('Gemini not configured');
      const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
      const prompt = [
        'Analyze the sentiment of the journal entry below and provide a single-sentence wellness suggestion.',
        'Respond with valid JSON only: {"sentiment": "positive|negative|neutral|mixed", "suggestion": "..."}',
        '---BEGIN ENTRY---',
        text,
        '---END ENTRY---',
      ].join('\n');
      const result = await model.generateContent(prompt);
      const raw = result.response.text();
      const jsonMatch = raw.match(/\{[\s\S]*\}/);
      const parsed = JSON.parse(jsonMatch ? jsonMatch[0] : '{}');
      sentiment = parsed.sentiment || 'neutral';
      suggestion = parsed.suggestion || suggestion;
    } catch (err) {
      logger.error('Mood analysis error', { error: err.message });
    }

    res.json({ success: true, data: { sentiment, suggestion } });
  } catch (err) { next(err); }
});

router.get('/daily-insight', aiLimiter, async (req, res) => {
  const insights = [
    "Every breath is an opportunity to start fresh. Your journey to wellness is unique and valid.",
    "Progress isn't always linear. A difficult day doesn't erase your growth.",
    "Self-compassion is the foundation of all healing. Treat yourself with the kindness you'd show a good friend.",
    "Your emotions are messengers, not enemies. Listen to what they're trying to tell you.",
    "Small consistent actions create lasting change. Celebrate every tiny step forward.",
  ];
  res.json({ success: true, data: { insight: insights[new Date().getDate() % insights.length] } });
});

module.exports = router;
