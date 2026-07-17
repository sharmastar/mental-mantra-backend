import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/personalization/personalization_repository.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/widgets/nova_orb.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../providers/nova_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/voice_overlay.dart';
import '../widgets/wellness_action_card.dart';

class NovaChatScreen extends ConsumerStatefulWidget {
  const NovaChatScreen({super.key});

  @override
  ConsumerState<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends ConsumerState<NovaChatScreen> {
  final _scrollController = ScrollController();
  final Throttler _sendThrottle =
      Throttler(interval: const Duration(milliseconds: 600));
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showScrollDown = false;
  int _selectedMoodIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(novaProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sendThrottle.reset();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final show = current > 200;
    if (show != _showScrollDown && mounted) {
      setState(() => _showScrollDown = show);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (!_sendThrottle.tryRun()) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(novaProvider.notifier).sendMessage(trimmed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startVoiceInput() async {
    HapticFeedback.mediumImpact();
    final result = await NovaVoiceOverlay.show(context);
    if (result != null && result.trim().isNotEmpty && mounted) {
      _sendMessage(result);
    }
  }

  OrbState _getOrbState(NovaState state) {
    if (state.isTyping) return OrbState.thinking;
    if (state.isLoading) return OrbState.typing;
    return OrbState.idle;
  }

  String _getOrbLabel(NovaState state) {
    if (state.isTyping) return 'reflecting...';
    if (state.isLoading) return 'thinking...';
    if (state.messages.isEmpty) return 'ready to listen';
    return 'listening';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDark
        ? AppTheme.nightGradient
        : const LinearGradient(
            colors: [AppTheme.lightBg, AppTheme.lightCard],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(state, isDark),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + kToolbarHeight + 4),

              _buildOrbHeader(state, isDark),

              Expanded(
                child: Stack(
                  children: [
                    _buildMessageList(state, isDark),
                    if (_showScrollDown && state.messages.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 16,
                        child: _ScrollDownButton(
                          isDark: isDark,
                          onTap: _scrollToBottom,
                        ),
                      ),
                  ],
                ),
              ),

              if (state.isTyping) ...[
                const SizedBox(height: 4),
                _buildStopButton(),
                const SizedBox(height: 6),
              ],

              if (state.isLoading) ...[
                const TypingIndicator(),
                const SizedBox(height: 6),
              ],

              if (state.error != null) _buildErrorBar(state.error!),

              ChatInputBar(
                onSend: _sendMessage,
                onVoice: _startVoiceInput,
                enabled: !state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbHeader(NovaState state, bool isDark) {
    final hasMessages = state.messages.isNotEmpty;
    final orbSize = hasMessages ? 48.0 : 72.0;
    final verticalPad = hasMessages ? 6.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: verticalPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NovaOrb(state: _getOrbState(state), size: orbSize),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getOrbLabel(state),
              key: ValueKey(_getOrbLabel(state)),
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white24 : Colors.black26,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton() {
    return Center(
      child: PremiumBounceInteraction(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(novaProvider.notifier).stopGenerating();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.warningColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stop_circle_outlined,
                  color: AppTheme.warningColor, size: 15),
              const SizedBox(width: 6),
              Text(
                'Stop',
                style: GoogleFonts.outfit(
                  color: AppTheme.warningColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBar(String error) {
    debugPrint('[NovaChatScreen] Error rendering error bar: $error');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              color: AppTheme.warningColor.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nova is temporarily unavailable.',
                  style: GoogleFonts.outfit(
                    color: AppTheme.warningColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  error,
                  style: GoogleFonts.outfit(
                    color: AppTheme.warningColor.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (ref.watch(novaProvider).lastFailedMessage != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(novaProvider.notifier).retryLastFailedMessage();
              },
              child: Text(
                'Retry',
                style: GoogleFonts.outfit(
                  color: AppTheme.warningColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NovaState state, bool isDark) {
    final titleColor = isDark ? Colors.white : AppTheme.darkCard;
    final iconColor =
        isDark ? Colors.white70 : AppTheme.darkCard.withValues(alpha: 0.7);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon:
            Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.outfit(color: titleColor, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: GoogleFonts.outfit(
                    color: titleColor.withValues(alpha: 0.35)),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            )
          : Text(
              'Nova',
              style: GoogleFonts.outfit(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: iconColor,
              size: 20),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: iconColor, size: 20),
          color: isDark ? AppTheme.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (val) {
            if (val == 'clear') {
              HapticFeedback.mediumImpact();
              _showClearConfirmation(isDark);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: isDark ? Colors.white70 : AppTheme.darkCard,
                      size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Clear Chat',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : AppTheme.darkCard,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClearConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear conversation?',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppTheme.darkCard,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This will remove all messages with Nova. Your wellbeing data is preserved.',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : Colors.black45)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(novaProvider.notifier).clearChat();
            },
            child: Text('Clear',
                style: GoogleFonts.outfit(
                    color: AppTheme.warningColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(NovaState state, bool isDark) {
    final filteredMessages = state.messages.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList().reversed.toList();

    if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: isDark ? Colors.white24 : Colors.black26, size: 40),
            const SizedBox(height: 12),
            Text(
              'No messages match "$_searchQuery"',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white30 : Colors.black38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty && !state.isLoading) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: filteredMessages.length,
      itemBuilder: (context, index) {
        final msg = filteredMessages[index];
        final isLast = index == 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatBubble(
              message: msg,
              isLast: isLast,
            ),
            if (!msg.isUser && msg.wellnessAction != null && !msg.isStreaming)
              WellnessActionCard(action: msg.wellnessAction!),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final personalizationState = ref.watch(personalizationProvider);

    return personalizationState.when(
      data: (ctx) {
        final greeting = ctx.domainGreeting;
        return _buildEmptyStateContent(isDark, greeting);
      },
      loading: () => const Center(
        child: BreathingLogoLoader(),
      ),
      error: (e, _) {
        const greeting = 'How are you feeling today?';
        return _buildEmptyStateContent(isDark, greeting);
      },
    );
  }

  Widget _buildEmptyStateContent(bool isDark, String greeting) {
    final moodEmojis = [
      {'emoji': '😊', 'label': 'Great', 'index': 0},
      {'emoji': '🙂', 'label': 'Good', 'index': 1},
      {'emoji': '😐', 'label': 'Okay', 'index': 2},
      {'emoji': '😔', 'label': 'Difficult', 'index': 3},
      {'emoji': '😢', 'label': 'Struggling', 'index': 4},
    ];

    final topics = [
      'Anxiety',
      'Cravings',
      'Recovery',
      'Motivation',
      'Relationships',
    ];

    final starters = [
      "I'm feeling anxious",
      'I need motivation',
      'Help with cravings',
      "Let's reflect",
      'I need support',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Nova',
                style: GoogleFonts.playfairDisplay(
                  color: isDark ? Colors.white : AppTheme.darkCard,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.outfit(
                color: isDark
                    ? Colors.white70
                    : AppTheme.darkCard.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Mood selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moodEmojis.map((m) {
                final isSelected = _selectedMoodIndex == m['index'] as int;
                return PremiumBounceInteraction(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedMoodIndex = m['index'] as int);
                    final moodMessages = [
                      "I'm feeling great today",
                      "I'm feeling good",
                      "I'm feeling okay",
                      "I'm having a difficult day",
                      "I'm struggling right now",
                    ];
                    _sendMessage(moodMessages[m['index'] as int]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.12)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02)),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m['emoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          m['label'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Support card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nova is here to listen.',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topics.map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Text(
                          topic,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Conversation starters
            Semantics(
              label: 'Quick conversation starters',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: starters.map((starter) {
                  return _QuickChip(
                    label: starter,
                    onTap: () => _sendMessage(starter),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollDownButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ScrollDownButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.arrow_downward_rounded,
            color: isDark ? Colors.white70 : AppTheme.darkCard,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppTheme.primaryColor.withValues(alpha: 0.06)
        : AppTheme.primaryColor.withValues(alpha: 0.03);
    final borderColor = isDark
        ? AppTheme.primaryColor.withValues(alpha: 0.12)
        : AppTheme.primaryColor.withValues(alpha: 0.06);

    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppTheme.darkCard,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
