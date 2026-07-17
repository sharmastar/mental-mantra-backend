import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

class CompletionPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String userName;
  final VoidCallback onBeginJourney;

  const CompletionPage({
    super.key,
    required this.profile,
    required this.userName,
    required this.onBeginJourney,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = (profile['overallScore'] ?? 50).toDouble();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 180,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 56,
                      color: AppTheme.primaryColor,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1000.ms, color: Colors.white24),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome${userName.isNotEmpty ? ', $userName' : ''}!',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                profile['summary'] ??
                    'Your personalized wellness journey is ready.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              _buildScoreCard(context, 'Overall Wellness', overall),
              const SizedBox(height: 16),
              if (profile['recommendedFocusAreas'] is List &&
                  (profile['recommendedFocusAreas'] as List).isNotEmpty) ...[
                Text('We\'ll focus on:',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['recommendedFocusAreas'] as List)
                      .take(3)
                      .map<Widget>(
                        (area) => Chip(
                          label: Text(area.toString(),
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onBeginJourney,
                  child: const Text('Begin Your Journey'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, String label, double score) {
    final color = score >= 70
        ? Colors.green
        : score >= 45
            ? Colors.orange
            : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 5,
                      color: color,
                      backgroundColor: Colors.grey[200]),
                  Text('${score.round()}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }
}
