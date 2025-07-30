import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// مجموعة خانات اختيار متعددة
class CheckboxGroup<T> extends StatelessWidget {
  final List<T> options;
  final List<T> selectedValues;
  final void Function(List<T>) onChanged;
  final String Function(T) getDisplayName;
  final bool enabled;

  const CheckboxGroup({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.getDisplayName,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        
        return CheckboxListTile(
          title: Text(
            getDisplayName(option),
            style: AppTextStyles.bodyText1.copyWith(
              color: enabled 
                ? AppColors.textPrimaryColor 
                : AppColors.disabledColor,
            ),
          ),
          value: isSelected,
          onChanged: enabled ? (bool? value) {
            final newSelectedValues = List<T>.from(selectedValues);
            
            if (value == true) {
              if (!newSelectedValues.contains(option)) {
                newSelectedValues.add(option);
              }
            } else {
              newSelectedValues.remove(option);
            }
            
            onChanged(newSelectedValues);
          } : null,
          activeColor: AppColors.primaryColor,
          checkColor: AppColors.textOnPrimaryColor,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}
