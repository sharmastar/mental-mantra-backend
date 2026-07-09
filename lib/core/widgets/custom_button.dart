import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'debounce_button.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool outlined;
  final bool textButton;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
    this.borderRadius = 16,
    this.isLoading = false,
    this.outlined = false,
    this.textButton = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final txtColor = textColor ?? (outlined ? bgColor : Colors.white);

    if (textButton) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label, style: TextStyle(color: txtColor, fontSize: fontSize, fontWeight: fontWeight)),
      );
    }

    Widget button = GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (isLoading ? bgColor.withValues(alpha: 0.7) : bgColor),
          borderRadius: BorderRadius.circular(borderRadius),
          border: outlined ? Border.all(color: bgColor, width: 1.5) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: txtColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: txtColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (!outlined) {
      button = DebounceButton(onTap: isLoading ? null : onPressed, child: button);
    }

    return button;
  }
}
