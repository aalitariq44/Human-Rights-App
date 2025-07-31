import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/encryption_service.dart';
import '../providers/personal_data_provider.dart';
import '../screens/personal_data/personal_data_recovery_screen.dart';

/// Widget لعرض أخطاء فك التشفير مع حلول
class EncryptionErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const EncryptionErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // التحقق من أن الخطأ متعلق بالتشفير
    final isEncryptionError = errorMessage.contains('فشل في فك تشفير البيانات') ||
        errorMessage.contains('Invalid or corrupted pad block') ||
        errorMessage.contains('تالفة أو تم تغيير مفتاح التشفير') ||
        errorMessage.contains('حدث خطأ في فك تشفير البيانات المحفوظة');

    if (!isEncryptionError) {
      // إذا لم يكن خطأ تشفير، عرض رسالة الخطأ العادية
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'حدث خطأ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.error, color: Colors.red[700]),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // عرض widget خاص لأخطاء التشفير
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // عنوان الخطأ
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'مشكلة في فك تشفير البيانات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.security_outlined, color: Colors.orange[700]),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // وصف المشكلة
            const Text(
              'لا يمكن قراءة البيانات الشخصية المحفوظة بسبب مشكلة في نظام التشفير.',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            // الحلول السريعة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الحلول السريعة:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• إعادة تشغيل التطبيق قد يحل المشكلة\n'
                    '• إعادة تعيين نظام التشفير\n'
                    '• إعادة إدخال البيانات الشخصية',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // أزرار العمل
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetailedHelp(context),
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: const Text('مساعدة مفصلة'),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _tryFixEncryption(context),
                    icon: const Icon(Icons.build, size: 16),
                    label: const Text('حاول مرة أخرى'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalDataRecoveryScreen(),
      ),
    );
  }

  Future<void> _tryFixEncryption(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'جاري إعادة تعيين نظام التشفير...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // إعادة تعيين خدمة التشفير
      await EncryptionService.instance.reset();
      
      // إغلاق مؤشر التحميل
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // محاولة إعادة جلب البيانات
      if (context.mounted) {
        final provider = Provider.of<PersonalDataProvider>(context, listen: false);
        await provider.fetchPersonalData();
      }

      // عرض رسالة نجاح
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تم إعادة تعيين نظام التشفير. إذا استمرت المشكلة، يرجى إعادة إدخال البيانات.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // إغلاق مؤشر التحميل
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // عرض رسالة خطأ
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'فشل في إعادة تعيين التشفير: $e',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
