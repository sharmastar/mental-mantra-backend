import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/personalization/personalization_repository.dart';
import '../../../../core/personalization/personalization_context.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../providers/ai_chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/voice_overlay.dart';
import '../../../../core/widgets/nova_orb.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _scrollController = ScrollController();
  final Throttler _sendThrottle = Throttler(interval: const Duration(milliseconds: 600));
  bool _showScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(aiChatProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sendThrottle.reset();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final show = max - current > 200;
    if (show != _showScrollDown && mounted) {
      setState(() => _showScrollDown = show);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
    ref.read(aiChatProvider.notifier).sendMessage(trimmed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startVoiceInput() async {
    HapticFeedback.mediumImpact();
    final result = await NovaVoiceOverlay.show(context);
    if (result != null && result.trim().isNotEmpty && mounted) {
      _sendMessage(result);
    }
  }

  OrbState _getOrbState(AiChatState state) {
    if (state.error != null) return OrbState.error;
    if (state.isTyping) return OrbState.typing;
    if (state.isLoading) return OrbState.thinking;
    return OrbState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background gradient matching earth tones
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF12101E), Color(0xFF1A1530)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFF8F7FC), Color(0xFFF0EBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(state, isDark),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10),
            
            // Nova presence orb header pined at the top of the canvas
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  NovaOrb(state: _getOrbState(state)),
                  const SizedBox(height: 8),
                  Text(
                    state.isTyping ? 'reflecting...' : 'listening',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white30 : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  _buildMessageList(state, isDark),
                  if (_showScrollDown && state.messages.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF16132A).withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D2852) : const Color(0xFFE0DBF0),
                            ),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF1A1530),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (state.isTyping) const TypingIndicator(),
            if (state.error != null)
              if (state.error != null) _buildErrorBar(state.error!),
            ChatInputBar(
              onSend: _sendMessage,
              onVoice: _startVoiceInput,
              enabled: !state.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBar(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.outfit(color: AppTheme.errorColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AiChatState state, bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1530);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF1A1530).withValues(alpha: 0.7);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Nova',
        style: GoogleFonts.playfairDisplay(
          color: titleColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: iconColor),
          color: isDark ? const Color(0xFF16132A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onSelected: (val) {
            if (val == 'clear') {
              HapticFeedback.mediumImpact();
              ref.read(aiChatProvider.notifier).clearChat();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, color: isDark ? Colors.white70 : const Color(0xFF1A1530), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Clear Chat',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : const Color(0xFF1A1530),
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

  Widget _buildMessageList(AiChatState state, bool isDark) {
    if (state.messages.isEmpty && !state.isLoading) {
      return FutureBuilder<PersonalizationContext>(
        future: PersonalizationRepository().build(),
        builder: (context, snapshot) {
          final ctx = snapshot.data;
          final greeting = ctx?.domainGreeting ?? 'Welcome back. How are you feeling today?';
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🌿',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hello, I\'m Nova.',
                    style: GoogleFonts.playfairDisplay(
                      color: isDark ? Colors.white : const Color(0xFF1A1530),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    greeting,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : const Color(0xFF1A1530).withValues(alpha: 0.7),
                      fontSize: 15.5,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  PremiumBounceInteraction(
                    onTap: () => _sendMessage('Hello, Nova. I want to check in.'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        'Let\'s Begin',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) => ChatBubble(message: state.messages[index]),
    );
  }
}



