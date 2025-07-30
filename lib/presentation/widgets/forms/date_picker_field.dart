import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// حقل اختيار التاريخ
class DatePickerField extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;

  const DatePickerField({
    Key? key,
    required this.labelText,
    this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy/MM/dd', 'ar');
    
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
        FormField<DateTime>(
          initialValue: selectedDate,
          validator: validator,
          builder: (fieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: enabled ? () => _selectDate(context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: hintText ?? 'اختر التاريخ',
                      prefixIcon: Icon(
                        prefixIcon ?? Icons.calendar_today,
                        color: enabled 
                          ? AppColors.textSecondaryColor 
                          : AppColors.disabledColor,
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
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
                        borderSide: BorderSide(
                          color: fieldState.hasError 
                            ? AppColors.errorColor 
                            : AppColors.borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: fieldState.hasError 
                            ? AppColors.errorColor 
                            : AppColors.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: fieldState.hasError 
                            ? AppColors.errorColor 
                            : AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.disabledColor),
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
                    ),
                    child: Text(
                      selectedDate != null 
                        ? dateFormatter.format(selectedDate!)
                        : (hintText ?? 'اختر التاريخ'),
                      style: selectedDate != null 
                        ? AppTextStyles.inputText
                        : AppTextStyles.hintText,
                    ),
                  ),
                ),
                if (fieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      fieldState.errorText!,
                      style: AppTextStyles.errorText,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.textOnPrimaryColor,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
}
