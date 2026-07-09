import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

enum ProfileStepType {
  name,
  ageGroup,
  gender,
  country,
  occupation,
  relationship,
  livingSituation,
}

class ProfileInfoCard extends StatefulWidget {
  final ProfileStepType stepType;
  final String? initialValue;
  final ValueChanged<String> onSubmitted;

  const ProfileInfoCard({
    super.key,
    required this.stepType,
    this.initialValue,
    required this.onSubmitted,
  });

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  final TextEditingController _textController = TextEditingController();
  String _selectedOption = '';
  String _searchQuery = '';

  // Suggestions for nicknames based on name
  final List<String> _nicknameSuggestions = [
    'ZenSeeker',
    'MantraPal',
    'InnerPeace',
    'CalmMind',
    'HopefulHeart',
    'MindfulHero',
    'Warrior',
    'SereneSoul',
  ];

  // Options for each step
  final Map<ProfileStepType, List<String>> _stepOptions = {
    ProfileStepType.ageGroup: [
      'Under 18',
      '18-24',
      '25-34',
      '35-44',
      '45-54',
      '55+',
    ],
    ProfileStepType.gender: [
      'Female',
      'Male',
      'Non-binary',
      'Self-identify',
      'Prefer not to say',
    ],
    ProfileStepType.occupation: [
      'Student',
      'Working Professional',
      'Self-employed',
      'Homemaker',
      'Between Jobs',
      'Retired',
      'Other',
    ],
    ProfileStepType.relationship: [
      'Single',
      'In a relationship',
      'Married',
      'Divorced / Separated',
      'Widowed',
      'Prefer not to say',
    ],
    ProfileStepType.livingSituation: [
      'Living alone',
      'With family / partner',
      'With roommates / friends',
      'Other',
    ],
  };

  // Popular Countries list
  final List<String> _countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'Singapore',
    'United Arab Emirates',
    'South Africa',
    'New Zealand',
    'France',
    'Japan',
    'Brazil',
    'Mexico',
    'Saudi Arabia',
    'Netherlands',
    'Ireland',
    'Switzerland',
    'Norway',
    'Sweden',
    'Denmark',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      if (widget.stepType == ProfileStepType.name) {
        _textController.text = widget.initialValue!;
      } else {
        _selectedOption = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.stepType) {
      case ProfileStepType.name:
        return _buildNameInput();
      case ProfileStepType.country:
        return _buildCountrySelect();
      default:
        return _buildOptionGrid();
    }
  }

  // ── Name & Nickname Input Screen ──────────────────────────────────────────
  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'What should we call you?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your name or use a nickname suggestion below. You can change this anytime.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _textController,
          autofocus: true,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Enter your name or nickname',
            hintStyle: const TextStyle(color: Colors.white30),
            counterText: '',
            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          onChanged: (val) {
            widget.onSubmitted(val.trim());
          },
        ),
        const SizedBox(height: 30),
        Text(
          '💡 Uplifting Nickname Suggestions:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _nicknameSuggestions.map((nickname) {
            final isChosen = _textController.text == nickname;
            return ChoiceChip(
              label: Text(nickname),
              selected: isChosen,
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _textController.text = nickname;
                  });
                  widget.onSubmitted(nickname);
                }
              },
              labelStyle: TextStyle(
                color: isChosen ? Colors.white : Colors.white70,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w400,
              ),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isChosen
                      ? AppTheme.primaryColor
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Country Search & Select Screen ────────────────────────────────────────
  Widget _buildCountrySelect() {
    final filtered = _countries
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Where are you located?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecting your country helps us localize mental health resources and helplines.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search country...',
            hintStyle: const TextStyle(color: Colors.white30),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final country = filtered[index];
              final isSelected = _selectedOption == country;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedOption = country;
                    });
                    widget.onSubmitted(country);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, color: Colors.white54, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            country,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Standard Option Selection Grid (Age, Gender, Occupation, etc.) ────────
  Widget _buildOptionGrid() {
    final options = _stepOptions[widget.stepType] ?? [];
    final title = _getStepTitle();
    final subtitle = _getStepSubtitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedOption == option;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedOption = option;
                    });
                    widget.onSubmitted(option);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.white38,
                              width: 2,
                            ),
                            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 12)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Titles Helper ─────────────────────────────────────────────────────────
  String _getStepTitle() {
    switch (widget.stepType) {
      case ProfileStepType.ageGroup:
        return 'What age group do you belong to?';
      case ProfileStepType.gender:
        return 'What is your gender identity?';
      case ProfileStepType.occupation:
        return 'What is your current occupation?';
      case ProfileStepType.relationship:
        return 'What is your relationship status?';
      case ProfileStepType.livingSituation:
        return 'What is your current living situation?';
      default:
        return '';
    }
  }

  String _getStepSubtitle() {
    switch (widget.stepType) {
      case ProfileStepType.ageGroup:
        return 'Age helps us tailor specific stress, academic, or work-related recommendations.';
      case ProfileStepType.gender:
        return 'Help us understand your identity for custom communication styles.';
      case ProfileStepType.occupation:
        return 'Occupation affects work stress, daily routine, and mindfulness advice.';
      case ProfileStepType.relationship:
        return 'This allows us to personalize relationship and emotional connection tips.';
      case ProfileStepType.livingSituation:
        return 'Living situation changes social connectedness and routine adjustments.';
      default:
        return '';
    }
  }
}
