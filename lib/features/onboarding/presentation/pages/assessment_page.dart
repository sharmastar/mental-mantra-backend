import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mental_mantra/features/onboarding/data/models/assessment_question.dart';
import 'package:mental_mantra/features/onboarding/data/assessment_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/features/music/providers/background_music_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AssessmentPage extends ConsumerStatefulWidget {
  final void Function(List<AssessmentResponse> responses) onComplete;
  const AssessmentPage({super.key, required this.onComplete});

  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};
  int _currentPage = 0;
  bool _isSubmitting = false;
  bool _showEncouragement = false;
  String _encouragementText = '';

  late final AnimationController _encourageController;
  late final Animation<double> _encourageOpacity;

  final List<AssessmentQuestion> _questions = AssessmentData.questions;

  // Theme colors
  static const Color _purple = AppTheme.primaryColor;
  static const Color _purpleMid = AppTheme.accentColor;
  static const Color _titleColor = AppTheme.primaryDark;
  static const Color _subtitleColor = AppTheme.secondaryColor;

  @override
  void initState() {
    super.initState();
    _encourageController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _encourageOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _encourageController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _encourageController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    final q = _questions[_currentPage];
    if (!q.isOptional &&
        (_answers[q.id] == null ||
            (_answers[q.id] is List && (_answers[q.id] as List).isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please answer to continue', style: GoogleFonts.outfit()),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // Show encouragement if available
    final encouragement = q.encouragementAfter;
    if (encouragement != null && encouragement.isNotEmpty) {
      _showEncouragementOverlay(encouragement);
    } else {
      _advanceToNextPage();
    }
  }

  void _showEncouragementOverlay(String text) {
    setState(() {
      _encouragementText = text;
      _showEncouragement = true;
    });
    _encourageController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      _encourageController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _showEncouragement = false);
        _advanceToNextPage();
      });
    });
  }

  void _advanceToNextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    } else {
      _submit();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _submit() {
    setState(() => _isSubmitting = true);
    final responses = _questions
        .map((q) => AssessmentResponse(
              questionId: q.id,
              question: q.question,
              type: q.type,
              answer: _answers[q.id],
            ))
        .toList();
    widget.onComplete(responses);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Header: Back + Progress ───────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              size: 20, color: _titleColor),
                          onPressed: _previousPage,
                        )
                      else
                        const SizedBox(width: 48),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: _purpleMid,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(_purple),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentPage + 1}/${_questions.length}',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: _subtitleColor,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          ref.watch(backgroundMusicProvider)
                              ? Icons.music_note
                              : Icons.music_note_outlined,
                          size: 20,
                          color: ref.watch(backgroundMusicProvider)
                              ? _purple
                              : _subtitleColor,
                        ),
                        onPressed: () =>
                            ref.read(backgroundMusicProvider.notifier).toggle(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                        tooltip: ref.watch(backgroundMusicProvider)
                            ? 'Mute Background Music'
                            : 'Play Background Music',
                      ),
                    ],
                  ),
                ),

                // ── Question Pages ────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) =>
                        _buildQuestionPage(_questions[index]),
                  ),
                ),

                // ── Bottom Button ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip button for optional questions
                      if (_questions[_currentPage].isOptional)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _advanceToNextPage();
                            },
                            child: Text('Skip for now',
                                style: GoogleFonts.outfit(
                                    color: _subtitleColor, fontSize: 14)),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == _questions.length - 1
                                          ? 'See My Results'
                                          : 'Continue',
                                      style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentPage == _questions.length - 1
                                          ? Icons.auto_awesome
                                          : Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Encouragement Overlay ─────────────────────────
          if (_showEncouragement)
            Positioned.fill(
              child: FadeTransition(
                opacity: _encourageOpacity,
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: _purple.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Text(
                      _encouragementText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _titleColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Question Page Builder ─────────────────────────────────
  Widget _buildQuestionPage(AssessmentQuestion q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji
          Center(
            child: Text(q.emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),

          // Sensitive badge
          if (q.isSensitive)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: _purple),
                  const SizedBox(width: 4),
                  Text('Your answer is confidential',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: _purple,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

          // Question text
          Text(
            q.question,
            style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                height: 1.3),
          ),

          // Subtitle
          if (q.subtext != null) ...[
            const SizedBox(height: 8),
            Text(
              q.subtext!,
              style: GoogleFonts.outfit(
                  fontSize: 14, color: _subtitleColor, height: 1.4),
            ),
          ],
          const SizedBox(height: 28),

          // Question input
          switch (q.type) {
            'text' => _buildTextInput(q),
            'single_select' => _buildSingleSelect(q),
            'multi_select' => _buildMultiSelect(q),
            'slider' => _buildSlider(q),
            'frequency_scale' => _buildFrequencyScale(q),
            _ => const SizedBox(),
          },
        ],
      ),
    );
  }

  // ── Text Input ────────────────────────────────────────────
  Widget _buildTextInput(AssessmentQuestion q) {
    _textControllers.putIfAbsent(q.id,
        () => TextEditingController(text: _answers[q.id] as String? ?? ''));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textControllers[q.id],
          maxLines: 1,
          style: GoogleFonts.outfit(fontSize: 18, color: _titleColor),
          decoration: InputDecoration(
            hintText: 'Type your name here...',
            hintStyle: GoogleFonts.outfit(
                color: _subtitleColor.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _purple.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _purple, width: 2)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (v) => _answers[q.id] = v,
        ),
        // Suggested nicknames
        if (q.suggestedNames != null && q.suggestedNames!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Or pick a name you like:',
              style: GoogleFonts.outfit(fontSize: 13, color: _subtitleColor)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: q.suggestedNames!.map((name) {
              final isSelected = _answers[q.id] == name;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _answers[q.id] = name;
                    _textControllers[q.id]?.text = name;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _purple : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isSelected
                            ? _purple
                            : _purple.withValues(alpha: 0.2)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: _purple.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : _titleColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Single Select ─────────────────────────────────────────
  Widget _buildSingleSelect(AssessmentQuestion q) {
    return Column(
      children: q.options.map((option) {
        final selected = _answers[q.id] == option.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _answers[q.id] = option.value);
              Future.delayed(const Duration(milliseconds: 150), _nextPage);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color:
                    selected ? _purple.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _purple : AppTheme.lightBorder,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _purple.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  if (option.icon != null) ...[
                    Icon(option.icon,
                        size: 22, color: selected ? _purple : _subtitleColor),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.label,
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selected ? _purple : _titleColor)),
                        if (option.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(option.subtitle!,
                                style: GoogleFonts.outfit(
                                    fontSize: 12, color: _subtitleColor)),
                          ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? _purple : Colors.transparent,
                      border: Border.all(
                          color: selected ? _purple : AppTheme.lightBorder,
                          width: 2),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Multi Select (Chips) ──────────────────────────────────
  Widget _buildMultiSelect(AssessmentQuestion q) {
    final selected = List<String>.from(_answers[q.id] as List? ?? []);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: q.options.map((option) {
        final isSelected = selected.contains(option.value);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              // "None" deselects everything else
              if (option.value == 'None') {
                _answers[q.id] = ['None'];
                return;
              }
              final updated = List<String>.from(selected);
              updated.remove('None');
              if (isSelected) {
                updated.remove(option.value);
              } else {
                updated.add(option.value);
              }
              _answers[q.id] = updated;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _purple.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? _purple : AppTheme.lightBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon,
                      size: 16,
                      color: isSelected
                          ? _purple
                          : (option.color ?? _subtitleColor)),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _purple : _titleColor,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, size: 16, color: _purple),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Frequency Scale ───────────────────────────────────────
  Widget _buildFrequencyScale(AssessmentQuestion q) {
    final selectedValue = _answers[q.id] as String?;
    final frequencyOptions = q.options;

    return Column(
      children: frequencyOptions.map((option) {
        final isSelected = selectedValue == option.value;
        final index = frequencyOptions.indexOf(option);
        // Color gradient from green (Never) → red (Almost Always)
        final gradientColors = [
          AppTheme.successColor,
          AppTheme.primaryLight,
          AppTheme.warningColor,
          AppTheme.secondaryColor,
          AppTheme.errorColor,
        ];
        final indicatorColor =
            gradientColors[index.clamp(0, gradientColors.length - 1)];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _answers[q.id] = option.value);
              Future.delayed(const Duration(milliseconds: 150), _nextPage);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? indicatorColor.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? indicatorColor : AppTheme.lightBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? indicatorColor
                          : indicatorColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option.label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? indicatorColor : _titleColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        size: 22, color: indicatorColor),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Slider ────────────────────────────────────────────────
  Widget _buildSlider(AssessmentQuestion q) {
    final min = q.sliderMin ?? 1;
    final max = q.sliderMax ?? 10;
    final val = (_answers[q.id] as int?) ?? ((max - min) ~/ 2).clamp(min, max);
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Center(
            child: Text(
              '$val',
              style: GoogleFonts.outfit(
                  fontSize: 48, fontWeight: FontWeight.bold, color: _purple),
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _purple,
            thumbColor: _purple,
            inactiveTrackColor: _purpleMid,
            overlayColor: _purple.withValues(alpha: 0.15),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            value: val.toDouble(),
            onChanged: (v) => setState(() => _answers[q.id] = v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: 100,
                  child: Text(q.sliderStartLabel ?? '',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: _subtitleColor))),
              SizedBox(
                  width: 100,
                  child: Text(q.sliderEndLabel ?? '',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: _subtitleColor))),
            ],
          ),
        ),
      ],
    );
  }
}
