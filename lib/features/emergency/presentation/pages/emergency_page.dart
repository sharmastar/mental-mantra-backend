import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  static const List<Map<String, dynamic>> helplines = [
    {
      'name': 'AASRA',
      'number': '91-9820466726',
      'desc': '24x7 suicide prevention helpline'
    },
    {
      'name': 'iCall',
      'number': '9152987821',
      'desc': 'Mental health helpline (Mon-Sat)'
    },
    {
      'name': 'Vandrevala Foundation',
      'number': '9999666555',
      'desc': '24x7 mental health support'
    },
    {
      'name': 'National Emergency',
      'number': '108',
      'desc': 'Emergency services'
    },
    {
      'name': 'KIRAN Helpline',
      'number': '18005990019',
      'desc': 'Mental health support (MHA)'
    },
    {
      'number': '1098',
      'name': 'Childline India',
      'desc': 'Children in distress'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Help Now?'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text("You're not alone. Help is available 24/7.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.red[800])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('📞 Crisis Helplines',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...helplines.map((h) => _HelplineCard(helpline: h)),
          const SizedBox(height: 24),
          Text('🌬️ Grounding Exercise',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _GroundingExercise(),
          const SizedBox(height: 24),
          Text('📋 Your Safety Plan',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Create a Safety Plan'),
              subtitle: const Text(
                  'Warning signs, coping strategies, support contacts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label:
                  const Text('Quick Exit', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red)),
              onPressed: () => GoRouter.of(context).go(AppRoutes.landing),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final Map<String, dynamic> helpline;
  const _HelplineCard({required this.helpline});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.phone, color: Colors.white)),
        title: Text(helpline['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(helpline['desc'] as String),
        trailing: const Icon(Icons.call),
        onTap: () async {
          final uri = Uri.parse('tel:${helpline['number']}');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
    );
  }
}

class _GroundingExercise extends StatefulWidget {
  @override
  State<_GroundingExercise> createState() => _GroundingExerciseState();
}

class _GroundingExerciseState extends State<_GroundingExercise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _step = 0;
  final List<Map<String, dynamic>> _steps = [
    {'text': '5 things you can SEE', 'icon': Icons.visibility},
    {'text': '4 things you can TOUCH', 'icon': Icons.touch_app},
    {'text': '3 things you can HEAR', 'icon': Icons.hearing},
    {'text': '2 things you can SMELL', 'icon': Icons.air},
    {'text': '1 thing you can TASTE', 'icon': Icons.restaurant},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('5-4-3-2-1 Grounding Technique',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Name things around you:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            ...List.generate(_steps.length, (i) {
              final isCurrent = _step == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrent
                      ? Border.all(color: AppTheme.primaryColor, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(_steps[i]['icon'],
                        size: 18,
                        color: isCurrent ? AppTheme.primaryColor : Colors.grey),
                    const SizedBox(width: 8),
                    Text(_steps[i]['text'],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.normal,
                            color: isCurrent ? AppTheme.primaryColor : null)),
                    const Spacer(),
                    if (isCurrent)
                      const Icon(Icons.arrow_back,
                          size: 16, color: AppTheme.primaryColor),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    setState(() => _step = (_step + 1) % _steps.length),
                child: Text(_step >= _steps.length - 1 ? 'Restart' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
