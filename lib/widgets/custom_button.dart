import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, emergency }

/// Premium custom button supporting multiple variants, loading states, and icons
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? height;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.height = 52,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? border;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        border = null;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = Colors.white;
        border = null;
        break;
      case ButtonVariant.emergency:
        bgColor = const Color(0xFFB71C1C);
        fgColor = Colors.white;
        border = const BorderSide(color: Colors.white, width: 1.5);
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.primary;
        border = BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white54
              : AppColors.primary,
          width: 1.5,
        );
        break;
    }

    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: variant == ButtonVariant.outline ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            side: border ?? BorderSide.none,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
