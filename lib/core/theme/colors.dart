import 'package:flutter/material.dart';

/// ألوان التطبيق
class AppColors {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF1976D2);      // أزرق احترافي
  static const Color primaryDarkColor = Color(0xFF1565C0);  // أزرق داكن
  static const Color primaryLightColor = Color(0xFFBBDEFB); // أزرق فاتح
  
  // الألوان الثانوية
  static const Color secondaryColor = Color(0xFF388E3C);     // أخضر للنجاح
  static const Color accentColor = Color(0xFF2196F3);        // أزرق فاتح للتأكيد
  
  // ألوان الحالة
  static const Color successColor = Color(0xFF4CAF50);       // أخضر للنجاح
  static const Color errorColor = Color(0xFFD32F2F);         // أحمر للأخطاء
  static const Color warningColor = Color(0xFFF57C00);       // برتقالي للتحذيرات
  static const Color infoColor = Color(0xFF2196F3);          // أزرق للمعلومات
  
  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFFAFAFA);    // رمادي فاتح جداً
  static const Color surfaceColor = Color(0xFFFFFFFF);       // أبيض
  static const Color cardColor = Color(0xFFF5F5F5);          // رمادي فاتح للبطاقات
  static const Color dividerColor = Color(0xFFE0E0E0);       // رمادي للفواصل
  
  // ألوان النص
  static const Color textPrimaryColor = Color(0xFF212121);   // نص أساسي داكن
  static const Color textSecondaryColor = Color(0xFF757575); // نص ثانوي رمادي
  static const Color textHintColor = Color(0xFF9E9E9E);      // نص التلميح
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF); // نص على اللون الأساسي
  
  // ألوان إضافية
  static const Color shadowColor = Color(0x1F000000);        // ظل خفيف
  static const Color borderColor = Color(0xFFE0E0E0);        // لون الحدود
  static const Color disabledColor = Color(0xFFBDBDBD);      // لون العناصر المعطلة
}

/// تدرجات لونية للتطبيق
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryColor, AppColors.primaryDarkColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.successColor, AppColors.secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [AppColors.surfaceColor, AppColors.cardColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
