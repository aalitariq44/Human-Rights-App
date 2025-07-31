import 'package:flutter/material.dart';
import '../../../services/encryption_service.dart';

/// مساعد لحل مشاكل التشفير
class EncryptionHelper {
  /// التحقق من صحة البيانات المشفرة
  static Future<bool> isEncryptionWorking() async {
    try {
      const testString = 'test_encryption_123';
      final encrypted = await EncryptionService.instance.encrypt(testString);
      final decrypted = await EncryptionService.instance.decrypt(encrypted);
      return decrypted == testString;
    } catch (e) {
      return false;
    }
  }

  /// حل مشكلة فك التشفير
  static Future<String> handleDecryptionError(
    String encryptedData, {
    Function()? onReset,
  }) async {
    try {
      // محاولة فك التشفير مرة أخرى
      return await EncryptionService.instance.decrypt(encryptedData);
    } catch (e) {
      // إذا فشل، قدم رسالة واضحة
      if (e.toString().contains('Invalid or corrupted pad block') ||
          e.toString().contains('تالفة أو تم تغيير مفتاح التشفير')) {
        
        // محاولة إعادة تعيين التشفير
        try {
          await EncryptionService.instance.reset();
          onReset?.call();
          throw Exception('تم إعادة تعيين نظام التشفير. يرجى إعادة إدخال البيانات.');
        } catch (resetError) {
          throw Exception('فشل في حل مشكلة التشفير. يرجى الاتصال بالدعم الفني.');
        }
      }
      
      rethrow;
    }
  }

  /// عرض رسالة خطأ التشفير للمستخدم
  static void showEncryptionError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'مشكلة في التشفير',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'الخطوات المقترحة:',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. إعادة تشغيل التطبيق\n'
                '2. إعادة إدخال البيانات الشخصية\n'
                '3. الاتصال بالدعم الفني إذا استمرت المشكلة',
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// إنشاء widget يعرض حالة التشفير
  static Widget buildEncryptionStatusWidget() {
    return FutureBuilder<bool>(
      future: isEncryptionWorking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        final isWorking = snapshot.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWorking ? Icons.security : Icons.warning,
              color: isWorking ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isWorking ? 'التشفير يعمل بشكل طبيعي' : 'مشكلة في التشفير',
              style: TextStyle(
                color: isWorking ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}
