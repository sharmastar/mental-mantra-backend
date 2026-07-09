import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final VoidCallback onVoice;
  final bool enabled;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onVoice,
    this.enabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isEmpty || !widget.enabled) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // V4 Earth styling
    final barBgColor = isDark ? const Color(0xFF12101E) : const Color(0xFFF8F7FC);
    final fieldBgColor = isDark ? const Color(0xFF16132A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2D2852) : const Color(0xFFE0DBF0);
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.25);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1530);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: barBgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: fieldBgColor,
                borderRadius: BorderRadius.circular(28), // 28px Organic Curves
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                style: GoogleFonts.outfit(color: textColor, fontSize: 15.5),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.enabled ? (_) => _handleSend() : null,
                decoration: InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  hintStyle: GoogleFonts.outfit(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PremiumBounceInteraction(
            onTap: _hasText ? _handleSend : widget.onVoice,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: _hasText
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1C1930), const Color(0xFF16132A)]
                            : [const Color(0xFFF5F2FF), Colors.white],
                      ),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: _hasText ? Colors.transparent : borderColor),
              ),
              child: Icon(
                _hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: _hasText
                    ? Colors.white
                    : (isDark ? Colors.white54 : const Color(0xFF1A1530).withValues(alpha: 0.6)),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

