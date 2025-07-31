import 'package:flutter/material.dart';
import '../../../services/encryption_service.dart';

/// مربع حوار لحل مشاكل التشفير
class EncryptionRecoveryDialog extends StatefulWidget {
  const EncryptionRecoveryDialog({super.key});

  @override
  State<EncryptionRecoveryDialog> createState() => _EncryptionRecoveryDialogState();
}

class _EncryptionRecoveryDialogState extends State<EncryptionRecoveryDialog> {
  bool _isResetting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'مشكلة في فك تشفير البيانات',
        textAlign: TextAlign.right,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حدث خطأ في فك تشفير البيانات المحفوظة. قد يكون السبب:',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '• تغيير في نظام التشفير\n'
              '• بيانات تالفة في التخزين المحلي\n'
              '• تحديث في إعدادات الأمان',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'الحلول المقترحة:',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '1. إعادة تشغيل التطبيق\n'
              '2. إعادة تعيين نظام التشفير\n'
              '3. إعادة إدخال البيانات الشخصية',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResetting ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isResetting ? null : _resetEncryption,
          child: _isResetting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إعادة تعيين التشفير'),
        ),
      ],
    );
  }

  Future<void> _resetEncryption() async {
    setState(() {
      _isResetting = true;
    });

    try {
      // إعادة تعيين خدمة التشفير
      await EncryptionService.instance.reset();
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إعادة تعيين نظام التشفير بنجاح. يرجى إعادة إدخال البيانات الشخصية.',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في إعادة تعيين التشفير: $e',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// عرض مربع حوار استعادة التشفير
Future<bool?> showEncryptionRecoveryDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const EncryptionRecoveryDialog(),
  );
}
