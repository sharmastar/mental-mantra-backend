// lib/features/journal/presentation/pages/journal_entry_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

import '../../data/models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../../../../services/ai/journal_insight_engine.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JournalEntryPage extends ConsumerStatefulWidget {
  final String? entryId;
  const JournalEntryPage({super.key, this.entryId});

  @override
  ConsumerState<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends ConsumerState<JournalEntryPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  int _selectedMoodIndex = -1;
  bool _isSaving = false;
  int _wordCount = 0;

  final _moods = ['😄', '🙂', '😐', '😞', '😢'];

  // AI Insight fields
  final _insightEngine = JournalInsightEngine();
  JournalInsight? _insight;
  Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _bodyCtrl.removeListener(_updateWordCount);
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _bodyCtrl.text.trim();
    final count = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    if (count != _wordCount) {
      setState(() => _wordCount = count);
      _scheduleAnalysis(text);
    }
  }

  void _scheduleAnalysis(String text) {
    _analysisTimer?.cancel();
    if (text.length < 20) {
      if (_insight != null) setState(() => _insight = null);
      return;
    }
    _analysisTimer = Timer(const Duration(milliseconds: 1500), () async {
      final result = await _insightEngine.analyzeEntry(text);
      if (mounted) {
        setState(() => _insight = result);
      }
    });
  }

  Future<void> _save() async {
    if (_bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write something first')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(journalRepositoryProvider);
      final entry = JournalEntry(
        id: widget.entryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim().isEmpty
            ? 'Untitled'
            : _titleCtrl.text.trim(),
        content: _bodyCtrl.text.trim(),
        mood: _selectedMoodIndex >= 0 ? _selectedMoodIndex + 1 : 3,
        emotions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (widget.entryId != null) {
        await repo.updateEntry(widget.entryId!, entry.toJson());
      } else {
        await repo.createEntry(entry);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Journal saved ✓'),
            backgroundColor: AppTheme.successColor));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(icon: const Icon(Icons.image_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.mic_outlined), onPressed: () {}),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mood Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            child: Row(
              children: [
                Text('How do you feel?',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const Spacer(),
                ..._moods.asMap().entries.map((e) => GestureDetector(
                      onTap: () => setState(() => _selectedMoodIndex = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedMoodIndex == e.key
                              ? AppTheme.primaryColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedMoodIndex == e.key
                              ? Border.all(color: AppTheme.primaryColor)
                              : null,
                        ),
                        child: Text(e.value,
                            style: TextStyle(
                                fontSize:
                                    _selectedMoodIndex == e.key ? 24 : 20)),
                      ),
                    )),
              ],
            ),
          ),

          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Give it a title...',
                hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
              ),
            ),
          ),

          const Divider(height: 1),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 16, height: 1.7),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'What\'s on your mind? Express yourself freely...',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),

          if (_insight != null) _buildInsightBanner(isDark),

          // Bottom Tools
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                  top: BorderSide(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Text('Word count: $_wordCount',
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const Spacer(),
                  if (_insight != null)
                    TextButton.icon(
                      onPressed: () => _showAiFeedbackSheet(context, isDark),
                      icon: const Icon(Icons.psychology,
                          size: 18, color: AppTheme.primaryColor),
                      label: const Text('AI Analysis',
                          style: TextStyle(
                              color: AppTheme.primaryColor, fontSize: 13)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBanner(bool isDark) {
    if (_insight!.cognitiveDistortions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryColor.withAlpha(30)
            : AppTheme.primaryColor.withAlpha(20),
        border:
            Border(top: BorderSide(color: AppTheme.primaryColor.withAlpha(50))),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Noticed cognitive distortion: ${_insight!.cognitiveDistortions.first}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  void _showAiFeedbackSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: AppTheme.primaryColor, size: 28),
                SizedBox(width: 12),
                Text('AI Journal Insight',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _insight!.aiFeedback,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (_insight!.cognitiveDistortions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Cognitive Distortions Detected:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._insight!.cognitiveDistortions.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record,
                            size: 10, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(d, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
