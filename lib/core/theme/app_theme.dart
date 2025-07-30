import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';

/// ثيم التطبيق الرئيسي
class AppTheme {
  // ثيم فاتح
  static ThemeData get lightTheme {
    return ThemeData(
      // الألوان الأساسية
      primarySwatch: _createMaterialColor(AppColors.primaryColor),
      primaryColor: AppColors.primaryColor,
      primaryColorDark: AppColors.primaryDarkColor,
      primaryColorLight: AppColors.primaryLightColor,
      
      // ألوان الخلفية
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardColor,
      dividerColor: AppColors.dividerColor,
      
      // ColorScheme للإصدارات الحديثة
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(AppColors.primaryColor),
        backgroundColor: AppColors.backgroundColor,
        errorColor: AppColors.errorColor,
        brightness: Brightness.light,
      ).copyWith(
        secondary: AppColors.secondaryColor,
        surface: AppColors.surfaceColor,
        onPrimary: AppColors.textOnPrimaryColor,
        onSecondary: AppColors.textOnPrimaryColor,
        onSurface: AppColors.textPrimaryColor,
        onBackground: AppColors.textPrimaryColor,
        onError: AppColors.textOnPrimaryColor,
      ),
      
      // أنماط النص
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        displaySmall: AppTextStyles.headline3,
        headlineLarge: AppTextStyles.headline4,
        headlineMedium: AppTextStyles.headline5,
        headlineSmall: AppTextStyles.headline6,
        titleLarge: AppTextStyles.headline6,
        titleMedium: AppTextStyles.subtitle1,
        titleSmall: AppTextStyles.subtitle2,
        bodyLarge: AppTextStyles.bodyText1,
        bodyMedium: AppTextStyles.bodyText2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.labelText,
        labelSmall: AppTextStyles.overline,
      ),
      
      // أنماط الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ),
      
      // أنماط النماذج
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        labelStyle: AppTextStyles.labelText,
        hintStyle: AppTextStyles.hintText,
        errorStyle: AppTextStyles.errorText,
      ),
      
      // أنماط البطاقات
      cardTheme: CardThemeData(
        color: AppColors.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: AppColors.shadowColor,
      ),
      
      // أنماط AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline6.copyWith(
          color: AppColors.textOnPrimaryColor,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      // أنماط الأيقونات
      iconTheme: const IconThemeData(
        color: AppColors.textSecondaryColor,
        size: 24,
      ),
      
      primaryIconTheme: const IconThemeData(
        color: AppColors.textOnPrimaryColor,
        size: 24,
      ),
      
      // أنماط أخرى
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // دعم RTL
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // ألوان إضافية
      disabledColor: AppColors.disabledColor,
      useMaterial3: true,
    );
  }
  
  /// إنشاء MaterialColor من لون واحد
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}
