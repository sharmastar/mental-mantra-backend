import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'debounce_button.dart';
import 'premium_bounce_interaction.dart';

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
    this.height = 54, // Modern standard 2026 height is 54px for primary
    this.borderRadius = 16,
    this.isLoading = false,
    this.outlined = false,
    this.textButton = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = AppTheme.primaryColor;

    // Determine colors
    final bool isEnabled = onPressed != null && !isLoading;
    final Color bgColor =
        backgroundColor ?? (outlined ? Colors.transparent : primaryColor);
    final Color txtColor = textColor ??
        (outlined ? (isEnabled ? primaryColor : Colors.grey) : Colors.white);

    if (textButton) {
      return TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)),
              )
            : Text(
                label,
                style: TextStyle(
                  color:
                      isEnabled ? txtColor : Colors.grey.withValues(alpha: 0.5),
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
      );
    }

    Widget buttonContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : (isEnabled
                ? bgColor
                : (isDark ? Colors.white12 : Colors.grey.shade300)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: outlined
            ? Border.all(
                color: isEnabled
                    ? bgColor
                    : (isDark ? Colors.white24 : Colors.grey.shade400),
                width: 1.5)
            : null,
        boxShadow: outlined || !isEnabled
            ? null
            : [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                    outlined ? primaryColor : Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      color: isEnabled ? txtColor : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled
                        ? txtColor
                        : (isDark ? Colors.white38 : Colors.grey.shade600),
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
    );

    // Apply bounce animation on tap (always)
    Widget button = PremiumBounceInteraction(
      onTap: isEnabled ? onPressed : null,
      child: buttonContent,
    );

    // Wrap with debounce for solid buttons to prevent double-taps
    if (!outlined && isEnabled) {
      button = DebounceButton(
        onTap: onPressed,
        child: button, // Keep bounce inside debounce
      );
    }

    return button;
  }
}
