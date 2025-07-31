import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../domain/entities/document_entity.dart';

/// خدمة فتح المستندات
class DocumentViewerService {
  /// فتح مستند في مشغل خارجي
  static Future<bool> openDocument(DocumentEntity document) async {
    try {
      if (document.fileUrl == null) {
        return false;
      }

      final uri = Uri.parse(document.fileUrl!);
      
      // التحقق من إمكانية فتح الرابط
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('خطأ في فتح المستند: $e');
      return false;
    }
  }

  /// التحقق من نوع الملف
  static bool isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// التحقق من ملف PDF
  static bool isPdfFile(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  /// عرض رسالة خطأ
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// عرض رسالة نجاح
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
