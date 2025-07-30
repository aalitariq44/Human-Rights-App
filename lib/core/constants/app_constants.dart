/// ثوابت التطبيق الرئيسية
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'حقوقي';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق مؤسسة حقوق الإنسان';
  
  // حدود الملفات
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxPdfSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentExtensions = ['pdf'];
  
  // إعدادات الأمان
  static const int minPasswordLength = 8;
  static const int maxLoginAttempts = 5;
  static const Duration sessionTimeout = Duration(minutes: 30);
  
  // رسائل النجاح والخطأ
  static const String successDataSubmitted = 'تم إرسال البيانات بنجاح';
  static const String dataUnderReview = 'البيانات قيد المراجعة من قبل المختصين';
  static const String errorGeneral = 'حدث خطأ، يرجى المحاولة مرة أخرى';
  static const String errorNetwork = 'تأكد من الاتصال بالإنترنت';
  static const String errorFileSize = 'حجم الملف أكبر من المسموح';
  static const String errorFileType = 'نوع الملف غير مدعوم';
}
