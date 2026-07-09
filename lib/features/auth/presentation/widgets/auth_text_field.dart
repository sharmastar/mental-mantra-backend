import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.enabled = true,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  bool _hasFocus = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnimation = CurvedAnimation(parent: _focusController, curve: Curves.easeInOut);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = AppTheme.primaryColor;
    final labelColor = isDark ? AppTheme.primaryLight : const Color(0xFF1E6C64);
    final textColor = isDark ? const Color(0xFFE2F3F2) : const Color(0xFF092828);
    final hintColor = isDark ? const Color(0xFF6B8A88) : const Color(0xFF9EAEAD);
    final fillColor = isDark ? AppTheme.darkCard : const Color(0xFFFFFFFF);
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    const errorColor = AppTheme.errorColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_focusAnimation.value * 2),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: Color.lerp(labelColor, primaryColor, _focusAnimation.value)!,
                  fontSize: 13,
                  fontWeight: _hasFocus ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.controller.text.isNotEmpty && widget.validator != null
                  ? (_hasFocus ? primaryColor : borderColor)
                  : _hasFocus ? primaryColor : borderColor,
              width: _hasFocus ? 2.0 : 1.0,
            ),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enabled,
            focusNode: _focusNode,
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
            cursorColor: primaryColor,
            validator: widget.validator,
            inputFormatters: widget.keyboardType == TextInputType.emailAddress
                ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                : null,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 15, fontWeight: FontWeight.w400),
              prefixIcon: Icon(widget.prefixIcon, color: _hasFocus ? primaryColor : hintColor, size: 20),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(color: errorColor, fontSize: 12, fontWeight: FontWeight.w500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}
