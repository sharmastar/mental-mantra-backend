import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ai_chat_provider.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack, // Premium spring bounce feel
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard', style: GoogleFonts.outfit(fontSize: 13)),
                  backgroundColor: AppTheme.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.isStreaming)
                  _buildStreamingBubble(context)
                else
                  _buildBubble(context),
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    right: isUser ? 8 : 0,
                    left: isUser ? 0 : 8,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.outfit(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.25),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    // Beautiful V5 organic palette colors
    final userBgColor = isDark
        ? AppTheme.primaryColor.withValues(alpha: 0.18)
        : AppTheme.primaryColor.withValues(alpha: 0.12);
    final userBorderColor = AppTheme.primaryColor.withValues(alpha: 0.25);
    final botBgColor = isDark
        ? const Color(0xFF16132A)
        : const Color(0xFFF5F2FF);
    final botBorderColor = isDark
        ? const Color(0xFF2D2852)
        : const Color(0xFFE0DBF0);

    final textColor = isDark ? Colors.white : const Color(0xFF1A1530);

    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isUser ? userBgColor : botBgColor,
        border: Border.all(
          color: isUser ? userBorderColor : botBorderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(28), // 28px Organic Radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: isUser
          ? Text(
              message.text,
              style: GoogleFonts.outfit(
                color: textColor,
                fontSize: 15.5,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            )
          : MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.outfit(
                  color: textColor.withValues(alpha: 0.9),
                  fontSize: 15.5,
                  height: 1.5,
                ),
                strong: GoogleFonts.outfit(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
                h1: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                h2: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                listBullet: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                ),
                code: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      width: 3.5,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStreamingBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final botBgColor = isDark ? const Color(0xFF16132A) : const Color(0xFFF5F2FF);
    final botBorderColor = isDark ? const Color(0xFF2D2852) : const Color(0xFFE0DBF0);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1530);

    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: botBgColor,
        border: Border.all(color: botBorderColor, width: 1),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: message.text.isEmpty
          ? const SizedBox(
              width: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(delay: 0),
                  SizedBox(width: 4),
                  _Dot(delay: 150),
                  SizedBox(width: 4),
                  _Dot(delay: 300),
                ],
              ),
            )
          : Text(
              '${message.text}▌',
              style: GoogleFonts.outfit(
                color: textColor.withValues(alpha: 0.9),
                fontSize: 15.5,
                height: 1.45,
              ),
            ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });

    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

