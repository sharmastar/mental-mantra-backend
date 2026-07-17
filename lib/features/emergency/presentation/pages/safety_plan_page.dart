import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../data/models/emergency_models.dart';

class SafetyPlanPage extends ConsumerStatefulWidget {
  const SafetyPlanPage({super.key});

  @override
  ConsumerState<SafetyPlanPage> createState() => _SafetyPlanPageState();
}

class _SafetyPlanPageState extends ConsumerState<SafetyPlanPage> {
  late SafetyPlan _plan;
  late List<String> _reasons;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _plan = SafetyPlan();
    _reasons = [];
    _loadPlan();
  }

  void _loadPlan() {
    final saved = _SafetyPlanStorage.load();
    if (saved != null) {
      setState(() {
        _plan = SafetyPlan.fromJson(saved);
        _reasons = List<String>.from(
            (saved['reasons'] as List?)?.cast<String>() ?? []);
      });
    }
  }

  void _savePlan() async {
    final data = _plan.toJson();
    data['reasons'] = _reasons;
    await _SafetyPlanStorage.save(data);
    setState(() => _hasUnsavedChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Safety Plan saved'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
    }
  }

  void _markDirty() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Plan'),
        actions: [
          if (_hasUnsavedChanges)
            TextButton.icon(
              onPressed: _savePlan,
              icon: const Icon(Icons.save, size: 20),
              label: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoBanner(isDark: isDark),
            const SizedBox(height: 20),
            const _SectionHeader(
              title: 'Warning Signs',
              subtitle: 'What tells you a crisis might be developing?',
              icon: Icons.warning_amber_rounded,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 8),
            _EditableChipList(
              items: _plan.warningSigns,
              placeholder:
                  'e.g. Isolating myself, poor sleep, negative self-talk',
              color: AppTheme.warningColor,
              onChanged: (items) {
                _plan.warningSigns = items;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Triggers',
              subtitle: 'Situations, people, or feelings that increase risk',
              icon: Icons.local_fire_department,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            _EditableChipList(
              items: _plan.copingStrategies,
              placeholder: 'e.g. Loneliness, work stress, certain websites',
              color: AppTheme.errorColor,
              onChanged: (items) {
                _plan.copingStrategies = items;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Trusted Contacts',
              subtitle: 'People you can reach out to for support',
              icon: Icons.people,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            _ContactList(
              contacts: _plan.socialSupports,
              color: AppTheme.primaryColor,
              placeholder: 'Add a trusted person',
              onChanged: (contacts) {
                _plan.socialSupports = contacts;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Emergency Contacts',
              subtitle: 'Helplines and professionals to call in a crisis',
              icon: Icons.phone,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            _ContactList(
              contacts: _plan.professionalContacts,
              isProfessional: true,
              color: AppTheme.errorColor,
              placeholder: 'Add a helpline or therapist',
              onChanged: (contacts) {
                _plan.professionalContacts = contacts;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Safe Environments',
              subtitle: 'Places that help you feel grounded and safe',
              icon: Icons.home,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 8),
            _EditableChipList(
              items: _plan.safeEnvironments,
              placeholder: 'e.g. My room, a park, a library',
              color: AppTheme.successColor,
              onChanged: (items) {
                _plan.safeEnvironments = items;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Reasons to Recover',
              subtitle: 'Why your recovery matters to you',
              icon: Icons.favorite,
              color: Color(0xFFFF6B9D),
            ),
            const SizedBox(height: 8),
            _ReasonsList(
              reasons: _reasons,
              onChanged: (items) {
                _reasons = items;
                _markDirty();
              },
            ),
            const SizedBox(height: 40),
            if (_hasUnsavedChanges)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _savePlan,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save Safety Plan',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SafetyPlanStorage {
  static const _key = 'safety_plan_data';

  static Map<String, dynamic>? load() {
    try {
      final data = HiveStorage.getCache(_key);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> planJson) async {
    try {
      await HiveStorage.saveCache(_key, planJson);
    } catch (_) {}
  }
}

class _InfoBanner extends StatelessWidget {
  final bool isDark;
  const _InfoBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined,
              color: AppTheme.primaryColor.withValues(alpha: 0.7), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your Safety Plan is saved locally on this device. Fill it out when you are feeling calm so it is ready when you need it.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              Text(subtitle,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableChipList extends StatefulWidget {
  final List<String> items;
  final String placeholder;
  final Color color;
  final ValueChanged<List<String>> onChanged;

  const _EditableChipList({
    required this.items,
    required this.placeholder,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_EditableChipList> createState() => _EditableChipListState();
}

class _EditableChipListState extends State<_EditableChipList> {
  final _controller = TextEditingController();

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => widget.items.add(text));
    widget.onChanged(widget.items);
    _controller.clear();
  }

  void _remove(int index) {
    HapticFeedback.lightImpact();
    setState(() => widget.items.removeAt(index));
    widget.onChanged(widget.items);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.items.length, (i) {
              return Chip(
                label: Text(widget.items[i],
                    style:
                        const TextStyle(fontFamily: 'Outfit', fontSize: 13)),
                deleteIcon:
                    Icon(Icons.close, size: 16, color: widget.color),
                onDeleted: () => _remove(i),
                backgroundColor: widget.color.withValues(alpha: 0.08),
                side: BorderSide(
                    color: widget.color.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              );
            }),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: Colors.grey.shade400),
                  filled: true,
                  fillColor: widget.color.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: widget.color.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: widget.color.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: widget.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  isDense: true,
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add, color: widget.color, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactList extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final bool isProfessional;
  final Color color;
  final String placeholder;
  final ValueChanged<List<EmergencyContact>> onChanged;

  const _ContactList({
    required this.contacts,
    required this.color,
    required this.placeholder,
    required this.onChanged,
    this.isProfessional = false,
  });

  @override
  State<_ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<_ContactList> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  void _add() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      widget.contacts.add(EmergencyContact(
        name: name,
        phone: phone,
        relationship:
            widget.isProfessional ? 'Professional' : 'Trusted Person',
        isProfessional: widget.isProfessional,
      ));
    });
    widget.onChanged(widget.contacts);
    _nameCtrl.clear();
    _phoneCtrl.clear();
  }

  void _remove(int index) {
    HapticFeedback.lightImpact();
    setState(() => widget.contacts.removeAt(index));
    widget.onChanged(widget.contacts);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.contacts.isNotEmpty)
          ...List.generate(widget.contacts.length, (i) {
            final c = widget.contacts[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: widget.color.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Icon(
                      widget.isProfessional
                          ? Icons.local_hospital
                          : Icons.person,
                      color: widget.color,
                      size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        if (c.phone.isNotEmpty)
                          Text(c.phone,
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: Colors.grey.shade400),
                    onPressed: () => _remove(i),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameCtrl,
                style:
                    const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.grey.shade400),
                  filled: true,
                  fillColor: widget.color.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            widget.color.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            widget.color.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: widget.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _phoneCtrl,
                style:
                    const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone',
                  hintStyle: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.grey.shade400),
                  filled: true,
                  fillColor: widget.color.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            widget.color.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            widget.color.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: widget.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.add, color: widget.color, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReasonsList extends StatefulWidget {
  final List<String> reasons;
  final ValueChanged<List<String>> onChanged;

  const _ReasonsList({required this.reasons, required this.onChanged});

  @override
  State<_ReasonsList> createState() => _ReasonsListState();
}

class _ReasonsListState extends State<_ReasonsList> {
  final _controller = TextEditingController();

  static const _suggestions = [
    'For my family and loved ones',
    'To live the life I deserve',
    'To feel proud of myself',
    'For my health and wellbeing',
    'Because I am worth it',
  ];

  void _add(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => widget.reasons.add(t));
    widget.onChanged(widget.reasons);
    _controller.clear();
  }

  void _remove(int index) {
    HapticFeedback.lightImpact();
    setState(() => widget.reasons.removeAt(index));
    widget.onChanged(widget.reasons);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.reasons.isNotEmpty)
          ...List.generate(widget.reasons.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFF6B9D)
                        .withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite,
                      color: Color(0xFFFF6B9D), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.reasons[i],
                        style: const TextStyle(
                            fontFamily: 'Outfit', fontSize: 14)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade400),
                    onPressed: () => _remove(i),
                  ),
                ],
              ),
            );
          }),
        if (widget.reasons.isEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .where((s) => !widget.reasons.contains(s))
                .map((s) => GestureDetector(
                      onTap: () => _add(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFF6B9D)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                color: Color(0xFFFF6B9D), size: 14),
                            const SizedBox(width: 4),
                            Text(s,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    color: Color(0xFFFF6B9D))),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style:
                    const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add your own reason...',
                  hintStyle: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFFF6B9D)
                      .withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0xFFFF6B9D)
                            .withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0xFFFF6B9D)
                            .withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFFF6B9D), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: _add,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _add(_controller.text),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFF6B9D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add,
                    color: Color(0xFFFF6B9D), size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
