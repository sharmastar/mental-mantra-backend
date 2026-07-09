import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ai_chat_provider.dart';
import 'chat_bubble.dart';
import 'chat_input_bar.dart';
import 'typing_indicator.dart';

class ChatFloatingWidget extends ConsumerStatefulWidget {
  final Widget child;
  const ChatFloatingWidget({super.key, required this.child});

  @override
  ConsumerState<ChatFloatingWidget> createState() => _ChatFloatingWidgetState();
}

class _ChatFloatingWidgetState extends ConsumerState<ChatFloatingWidget>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _showNewBadge = true;
  bool _hasLoadedHistory = false;
  final _scrollController = ScrollController();
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  bool _hapticFired = false;

  void _onScroll() {
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      final isNearBottom = max - current > 150;
      if (isNearBottom && !_hapticFired) {
        HapticFeedback.lightImpact();
        _hapticFired = true;
      } else if (!isNearBottom) {
        _hapticFired = false;
      }
    }
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
      _showNewBadge = false;
    });
    if (_isOpen && !_hasLoadedHistory) {
      _hasLoadedHistory = true;
      Future.microtask(() => ref.read(aiChatProvider.notifier).loadHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        widget.child,
        if (_isOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
            ),
          ),
          Positioned(
            right: 16,
            bottom: bottomInset + 80,
            width: 360,
            height: 520,
            child: Material(
              color: Colors.transparent,
              child: _ChatPanel(
                scrollController: _scrollController,
                onClose: _toggle,
                isDark: isDark,
              ),
            ),
          ),
        ],
        Positioned(
          right: 16,
          bottom: bottomInset + 16,
          child: GestureDetector(
            onTap: _toggle,
            child: _isOpen
                ? Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  )
                : AnimatedBuilder(
                    animation: _bobAnimation,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _bobAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Talk to Nova',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_left_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        if (_showNewBadge && !_isOpen)
          Positioned(
            right: 16,
            bottom: bottomInset + 16,
            child: AnimatedBuilder(
              animation: _bobAnimation,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _bobAnimation.value),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatPanel extends ConsumerWidget {
  final ScrollController scrollController;
  final VoidCallback onClose;
  final bool isDark;

  const _ChatPanel({
    required this.scrollController,
    required this.onClose,
    required this.isDark,
  });

  static const _quickPrompts = [
    'I feel stressed',
    'Help me relax',
    'Trouble sleeping',
    'Give me a quote',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiChatProvider);
    final messages = state.messages;
    final isTyping = state.isTyping;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(context),
          Divider(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          Expanded(
            child: messages.isEmpty && !isTyping
                ? _buildEmptyState(context)
                : _buildMessagesList(context, messages, isTyping),
          ),
          if (messages.isEmpty && !isTyping)
            _buildQuickPrompts(context, ref),
          Divider(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          _buildInputBar(ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova Companion',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Supportive chat, not therapy',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌸', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'How are you, really?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nova is here to listen. Try a prompt or type anything.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, List<ChatMessage> messages, bool isTyping) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TypingIndicator(),
                ),
              ],
            ),
          );
        }
        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ChatBubble(message: msg),
        );
      },
    );
  }

  Widget _buildQuickPrompts(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _quickPrompts.map((prompt) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(aiChatProvider.notifier).sendMessage(prompt);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lavender.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Text(
                prompt,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar(WidgetRef ref) {
    return ChatInputBar(
      onSend: (text) => ref.read(aiChatProvider.notifier).sendMessage(text),
      onVoice: () {},
      enabled: !ref.watch(aiChatProvider).isTyping,
    );
  }
}
