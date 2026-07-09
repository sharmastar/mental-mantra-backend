import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/recovery_provider.dart';
import '../../data/models/recovery_models.dart';

class UrgeLoggerPage extends ConsumerStatefulWidget {
  const UrgeLoggerPage({super.key});

  @override
  ConsumerState<UrgeLoggerPage> createState() => _UrgeLoggerPageState();
}

class _UrgeLoggerPageState extends ConsumerState<UrgeLoggerPage> {
  final _triggerController = TextEditingController();
  UrgeType _selectedUrgeType = UrgeType.gaming;
  int _intensity = 5;
  String? _selectedCoping;
  bool _resisted = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_triggerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what triggered the urge')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final urge = UrgeLog(
      trigger: _triggerController.text.trim(),
      urgeType: _selectedUrgeType,
      intensity: _intensity,
      resisted: _resisted,
      copingStrategy: _selectedCoping,
    );

    final success = await ref.read(recoveryProvider.notifier).logUrge(urge);
    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resisted ? 'Urge resisted! Stay strong' : 'Logged. Next time you will resist'),
          backgroundColor: _resisted ? AppTheme.successColor : AppTheme.warningColor,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Log an Urge')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What type of urge?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UrgeType.values.map((type) => ChoiceChip(
                label: Text(_urgeTypeLabel(type)),
                selected: _selectedUrgeType == type,
                onSelected: (_) => setState(() => _selectedUrgeType = type),
                selectedColor: _urgeTypeColor(type).withValues(alpha: 0.2),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Text('What triggered it?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _triggerController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Saw a game ad, felt bored, got stressed...',
                fillColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              ),
            ),
            const SizedBox(height: 24),
            Text('Intensity (1-10)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('1', style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: Slider(
                    value: _intensity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: _intensity > 7 ? AppTheme.errorColor : _intensity > 4 ? AppTheme.warningColor : AppTheme.successColor,
                    onChanged: (v) => setState(() => _intensity = v.round()),
                  ),
                ),
                const Text('10', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Center(
              child: Text(
                _intensity <= 3 ? 'Mild' : _intensity <= 6 ? 'Moderate' : 'Strong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _intensity > 7 ? AppTheme.errorColor : _intensity > 4 ? AppTheme.warningColor : AppTheme.successColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Did you resist?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ResistOption(
                    label: 'Yes, I resisted',
                    icon: Icons.check_circle,
                    color: AppTheme.successColor,
                    isSelected: _resisted,
                    onTap: () => setState(() => _resisted = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResistOption(
                    label: 'No, I gave in',
                    icon: Icons.cancel_outlined,
                    color: AppTheme.errorColor,
                    isSelected: !_resisted,
                    onTap: () => setState(() => _resisted = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('What helped? (optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: UrgeLog.copingStrategies.map((s) => FilterChip(
                label: Text(s['label'] as String, style: const TextStyle(fontSize: 12)),
                selected: _selectedCoping == s['id'],
                onSelected: (_) => setState(() => _selectedCoping = _selectedCoping == s['id'] ? null : s['id'] as String),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                avatar: Icon(s['icon'] as IconData, size: 16, color: _selectedCoping == s['id'] ? AppTheme.primaryColor : Colors.grey),
              )).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Log Urge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _urgeTypeLabel(UrgeType type) => switch (type) {
    UrgeType.gaming => 'Gaming',
    UrgeType.socialMedia => 'Social Media',
    UrgeType.appBrowsing => 'App Browsing',
    UrgeType.videoStreaming => 'Video Streaming',
    UrgeType.shopping => 'Shopping',
    UrgeType.other => 'Other',
  };

  Color _urgeTypeColor(UrgeType type) => switch (type) {
    UrgeType.gaming => const Color(0xFFFF6B9D),
    UrgeType.socialMedia => const Color(0xFF4FC3F7),
    UrgeType.appBrowsing => const Color(0xFFFFB547),
    UrgeType.videoStreaming => const Color(0xFFFF5252),
    UrgeType.shopping => const Color(0xFFAB47BC),
    UrgeType.other => Colors.grey,
  };
}

class _ResistOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _ResistOption({required this.label, required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.1) : (Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : AppTheme.lightCard),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? color : null), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
