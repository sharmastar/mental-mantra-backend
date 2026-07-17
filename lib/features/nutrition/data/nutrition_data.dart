import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum WellnessCategory {
  hydration('Hydration', Icons.water_drop_outlined, AppTheme.secondaryColor),
  sleepNutrition(
      'Sleep-Supportive Eating', Icons.bedtime_outlined, AppTheme.primaryLight),
  mindfulEating(
      'Mindful Eating', Icons.restaurant_outlined, AppTheme.errorColor),
  energyFoods('Energy & Vitality', Icons.bolt_outlined, AppTheme.warningColor),
  stressEating(
      'Stress & Eating', Icons.psychology_outlined, AppTheme.primaryColor),
  gutHealth(
      'Gut-Brain Connection', Icons.healing_outlined, AppTheme.successColor);

  final String label;
  final IconData icon;
  final Color color;
  const WellnessCategory(this.label, this.icon, this.color);
}

class WellnessTip {
  final String title;
  final String description;
  final WellnessCategory category;
  final IconData icon;
  final String? emoji;

  const WellnessTip({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.emoji,
  });
}

class NutritionTip {
  final String title;
  final String body;
  final String? tip;
  final bool isQuickAction;

  const NutritionTip({
    required this.title,
    required this.body,
    this.tip,
    this.isQuickAction = false,
  });
}

final hydrationTips = [
  const WellnessTip(
    title: 'Start Your Day with Water',
    description:
        'Drink a glass of water first thing in the morning to rehydrate after sleep and kickstart your metabolism.',
    category: WellnessCategory.hydration,
    icon: Icons.water_drop_outlined,
    emoji: '💧',
  ),
  const WellnessTip(
    title: 'Herbal Teas Count Too',
    description:
        'Chamomile, peppermint, and green tea contribute to your hydration while offering additional calming benefits.',
    category: WellnessCategory.hydration,
    icon: Icons.local_cafe_outlined,
    emoji: '🍵',
  ),
  const WellnessTip(
    title: 'Set Hydration Reminders',
    description:
        'Use gentle reminders to sip water throughout the day — your brain function improves with consistent hydration.',
    category: WellnessCategory.hydration,
    icon: Icons.notifications_outlined,
    emoji: '⏰',
  ),
];

final sleepNutritionTips = [
  const WellnessTip(
    title: 'Magnesium-Rich Foods',
    description:
        'Foods like almonds, spinach, and bananas contain magnesium, which supports relaxation and sleep quality.',
    category: WellnessCategory.sleepNutrition,
    icon: Icons.energy_savings_leaf_outlined,
    emoji: '🥜',
  ),
  const WellnessTip(
    title: 'Tart Cherry Juice',
    description:
        'Tart cherries are a natural source of melatonin. A small glass before bed may support your sleep cycle.',
    category: WellnessCategory.sleepNutrition,
    icon: Icons.wine_bar_outlined,
    emoji: '🍒',
  ),
  const WellnessTip(
    title: 'Avoid Caffeine After 2 PM',
    description:
        'Caffeine can stay in your system for 6-8 hours. Switching to herbal tea in the afternoon supports better sleep.',
    category: WellnessCategory.sleepNutrition,
    icon: Icons.coffee_outlined,
    emoji: '☕',
  ),
];

final mindfulEatingTips = [
  const WellnessTip(
    title: 'Eat Without Screens',
    description:
        'When you eat while watching or scrolling, you miss your body\'s fullness signals. Try 10 minutes of screen-free eating.',
    category: WellnessCategory.mindfulEating,
    icon: Icons.phone_disabled_outlined,
    emoji: '📵',
  ),
  const WellnessTip(
    title: 'Chew Slowly',
    description:
        'Aim to chew each bite 20-30 times. This aids digestion and gives your brain time to register fullness.',
    category: WellnessCategory.mindfulEating,
    icon: Icons.timer_outlined,
    emoji: '⏳',
  ),
  const WellnessTip(
    title: 'Gratitude Before Meals',
    description:
        'Take one breath before eating and acknowledge the nourishment in front of you. This simple pause shifts your relationship with food.',
    category: WellnessCategory.mindfulEating,
    icon: Icons.favorite_outline,
    emoji: '🙏',
  ),
];

final stressEatingTips = [
  const WellnessTip(
    title: 'Pause Before You Eat',
    description:
        'Ask yourself: "Am I physically hungry, or am I stressed?" If it\'s stress, try a 2-minute breathing exercise first.',
    category: WellnessCategory.stressEating,
    icon: Icons.pause_circle_outline,
    emoji: '🔄',
  ),
  const WellnessTip(
    title: 'Keep Healthy Snacks Visible',
    description:
        'When stress hits, we reach for what\'s easiest. Keep cut vegetables, nuts, or fruit where you can see them.',
    category: WellnessCategory.stressEating,
    icon: Icons.apple_outlined,
    emoji: '🥗',
  ),
  const WellnessTip(
    title: 'Warm Drinks Calm the Nerves',
    description:
        'A warm cup of herbal tea or warm milk can activate your parasympathetic nervous system, helping you shift from stress mode.',
    category: WellnessCategory.stressEating,
    icon: Icons.local_cafe_outlined,
    emoji: '☕',
  ),
];

final gutHealthTips = [
  const WellnessTip(
    title: 'Include Fermented Foods',
    description:
        'Yogurt, kimchi, and kombucha contain probiotics that support the gut-brain connection, which influences mood.',
    category: WellnessCategory.gutHealth,
    icon: Icons.biotech_outlined,
    emoji: '🧫',
  ),
  const WellnessTip(
    title: 'Fibre Feeds Good Bacteria',
    description:
        'Whole grains, legumes, and vegetables feed the beneficial bacteria in your gut that produce mood-regulating neurotransmitters.',
    category: WellnessCategory.gutHealth,
    icon: Icons.grass_outlined,
    emoji: '🌾',
  ),
  const WellnessTip(
    title: 'Stay Consistent',
    description:
        'Gut health improves with consistency, not perfection. Small daily choices matter more than occasional extremes.',
    category: WellnessCategory.gutHealth,
    icon: Icons.trending_up_outlined,
    emoji: '📈',
  ),
];

final nutritionQuickActions = [
  const NutritionTip(
    title: 'Drink Water',
    body: 'Sip a glass now — your brain and body will thank you.',
    tip: 'Add lemon or cucumber for flavour',
    isQuickAction: true,
  ),
  const NutritionTip(
    title: 'Mindful Bite',
    body: 'Take one bite of your next meal with full attention.',
    tip: 'Notice texture, taste, and temperature',
    isQuickAction: true,
  ),
  const NutritionTip(
    title: 'Herbal Tea',
    body: 'Brew a cup of chamomile or peppermint tea.',
    tip: 'Breathe in the steam before sipping',
    isQuickAction: true,
  ),
  const NutritionTip(
    title: 'Afternoon Reset',
    body: 'Have a handful of nuts or a piece of fruit instead of caffeine.',
    tip: 'Almonds + dark chocolate = brain fuel',
    isQuickAction: true,
  ),
];

final Map<WellnessCategory, List<WellnessTip>> allWellnessTips = {
  WellnessCategory.hydration: hydrationTips,
  WellnessCategory.sleepNutrition: sleepNutritionTips,
  WellnessCategory.mindfulEating: mindfulEatingTips,
  WellnessCategory.stressEating: stressEatingTips,
  WellnessCategory.gutHealth: gutHealthTips,
  WellnessCategory.energyFoods: [],
};
