import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// قائمة منسدلة مخصصة
class DropdownField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;

  const DropdownField({
    Key? key,
    required this.labelText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: AppTextStyles.labelText,
          ),
        ),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null 
              ? Icon(
                  prefixIcon, 
                  color: enabled 
                    ? AppColors.textSecondaryColor 
                    : AppColors.disabledColor,
                ) 
              : null,
            filled: true,
            fillColor: enabled 
              ? AppColors.surfaceColor 
              : AppColors.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor, 
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.errorColor, 
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.disabledColor),
            ),
            hintStyle: AppTextStyles.hintText,
            errorStyle: AppTextStyles.errorText,
          ),
          style: AppTextStyles.inputText,
        ),
      ],
    );
  }
}
