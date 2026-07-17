import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/tts_service.dart';
import '../../data/models/nova_conversation_history.dart';
import '../../providers/nova_provider.dart';

class ChatBubble extends ConsumerWidget {
  final NovaMessage message;
  final bool isLast;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLast = false,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.isUser;
    final screenW = MediaQuery.of(context).size.width;
    final maxBubbleWidth = (screenW * 0.78).clamp(200.0, 480.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 450),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.isStreaming)
                  _StreamingBubble(message: message)
                else
                  _StaticBubble(message: message),

                const SizedBox(height: 4),

                Padding(
                  padding: EdgeInsets.only(
                    right: isUser ? 4 : 0,
                    left: isUser ? 0 : 4,
                  ),
                  child: _MetadataRow(
                    message: message,
                    isLast: isLast,
                    formattedTime: _formatTime(message.timestamp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticBubble extends StatelessWidget {
  final NovaMessage message;
  const _StaticBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    final bgColor = isUser
        ? (isDark
            ? AppTheme.primaryColor.withValues(alpha: 0.14)
            : AppTheme.primaryColor.withValues(alpha: 0.08))
        : (isDark ? AppTheme.darkSurface : AppTheme.lightCard);

    final borderColor = isUser
        ? AppTheme.primaryColor.withValues(alpha: 0.20)
        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);

    final textColor = isDark ? Colors.white : AppTheme.darkCard;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        Clipboard.setData(ClipboardData(text: message.text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Copied to clipboard', style: GoogleFonts.outfit(fontSize: 13)),
            backgroundColor: AppTheme.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 0.8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isUser
            ? Text(
                message.text,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: _markdownStyle(context, textColor),
              ),
      ),
    );
  }
}

class _StreamingBubble extends StatelessWidget {
  final NovaMessage message;
  const _StreamingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : AppTheme.darkCard;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: message.text.isEmpty
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(delay: 0),
                SizedBox(width: 5),
                _PulsingDot(delay: 160),
                SizedBox(width: 5),
                _PulsingDot(delay: 320),
              ],
            )
          : Text(
              '${message.text}▌',
              style: GoogleFonts.outfit(
                color: textColor.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final NovaMessage message;
  final bool isLast;
  final String formattedTime;

  const _MetadataRow({
    required this.message,
    required this.isLast,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.22);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedTime,
          style: GoogleFonts.outfit(color: subtleColor, fontSize: 10),
        ),
        if (!message.isUser && !message.isStreaming) ...[
          const SizedBox(width: 10),
          _ActionIcon(
            icon: Icons.copy_rounded,
            size: 13,
            color: subtleColor,
            tooltip: 'Copy',
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied', style: GoogleFonts.outfit(fontSize: 13)),
                  backgroundColor: AppTheme.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionIcon(
            icon: Icons.share_rounded,
            size: 13,
            color: subtleColor,
            tooltip: 'Share',
            onTap: () {
              HapticFeedback.lightImpact();
              Share.share(
                'Nova says:\n\n${message.text}\n\n— Mental Mantra',
              );
            },
          ),
          const SizedBox(width: 8),
          _SpeakerButton(message: message),
          if (isLast) ...[
            const SizedBox(width: 8),
            const _RegenerateButton(),
          ],
        ],
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.size,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final int delay;
  const _PulsingDot({required this.delay});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });

    _animation = Tween<double>(begin: 0.15, end: 0.8).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white : AppTheme.darkCard;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SpeakerButton extends StatelessWidget {
  final NovaMessage message;
  const _SpeakerButton({required this.message});

  void _toggleSpeak(bool isPlaying) {
    HapticFeedback.lightImpact();
    if (isPlaying) {
      TtsService.stop();
    } else {
      TtsService.speak(message.messageId, message.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.22);

    return ValueListenableBuilder<String?>(
      valueListenable: TtsService.speakingIdNotifier,
      builder: (context, speakingId, _) {
        final isPlaying = speakingId == message.messageId;
        return Tooltip(
          message: isPlaying ? 'Stop TTS' : 'Speak',
          child: GestureDetector(
            onTap: () => _toggleSpeak(isPlaying),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                  color: isPlaying ? AppTheme.primaryColor : color,
                  size: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RegenerateButton extends ConsumerWidget {
  const _RegenerateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(novaProvider.notifier).regenerateResponse();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Icon(Icons.refresh_rounded, color: color, size: 13),
        ),
      ),
    );
  }
}

MarkdownStyleSheet _markdownStyle(BuildContext context, Color textColor) {
  return MarkdownStyleSheet(
    p: GoogleFonts.outfit(
      color: textColor.withValues(alpha: 0.9),
      fontSize: 15,
      height: 1.55,
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
    listBullet: TextStyle(color: textColor.withValues(alpha: 0.5)),
    code: GoogleFonts.outfit(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.06),
      fontSize: 13,
    ),
    codeblockDecoration: BoxDecoration(
      color: AppTheme.primaryColor.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: AppTheme.primaryColor.withValues(alpha: 0.35),
          width: 3,
        ),
      ),
    ),
  );
}
