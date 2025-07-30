import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// أنماط النصوص للتطبيق
class AppTextStyles {
  // النصوص الكبيرة
  static TextStyle get headline1 => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
    height: 1.2,
  );
  
  static TextStyle get headline2 => GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get headline3 => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get headline4 => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get headline5 => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get headline6 => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryColor,
    height: 1.4,
  );
  
  // نصوص الجسم
  static TextStyle get bodyText1 => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle get bodyText2 => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryColor,
    height: 1.5,
  );
  
  // نصوص الأزرار
  static TextStyle get button => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimaryColor,
    height: 1.2,
  );
  
  // نصوص التسميات
  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryColor,
    height: 1.3,
  );
  
  static TextStyle get overline => GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryColor,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // نصوص خاصة
  static TextStyle get subtitle1 => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get subtitle2 => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryColor,
    height: 1.4,
  );
  
  // نصوص النماذج
  static TextStyle get inputText => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get labelText => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryColor,
    height: 1.2,
  );
  
  static TextStyle get hintText => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textHintColor,
    height: 1.4,
  );
  
  static TextStyle get errorText => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
    height: 1.3,
  );
  
  // نصوص الحالة
  static TextStyle get successText => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.successColor,
    height: 1.4,
  );
  
  static TextStyle get warningText => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warningColor,
    height: 1.4,
  );
  
  static TextStyle get infoText => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.infoColor,
    height: 1.4,
  );
}
