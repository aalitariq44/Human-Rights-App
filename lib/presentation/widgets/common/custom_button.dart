import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// أنواع الأزرار المختلفة
enum ButtonVariant {
  filled,
  outline,
  text,
}

/// زر مخصص للتطبيق
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding, required bool isOutlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutlined = variant == ButtonVariant.outline;
    final isTextButton = variant == ButtonVariant.text;
    
    final buttonStyle = isTextButton
      ? TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        )
      : isOutlined 
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primaryColor,
            side: BorderSide(
              color: backgroundColor ?? AppColors.primaryColor,
              width: 1.5,
            ),
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 24, 
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primaryColor,
          foregroundColor: textColor ?? AppColors.textOnPrimaryColor,
          elevation: 2,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );

    final textStyle = AppTextStyles.button.copyWith(
      color: isTextButton || isOutlined 
        ? (textColor ?? AppColors.primaryColor)
        : (textColor ?? AppColors.textOnPrimaryColor),
      fontSize: fontSize,
    );

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTextButton || isOutlined 
                  ? AppColors.primaryColor 
                  : AppColors.textOnPrimaryColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: textStyle),
            ],
          );

    if (isFullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    return isTextButton
        ? TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonChild,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonChild,
              );
  }
}
