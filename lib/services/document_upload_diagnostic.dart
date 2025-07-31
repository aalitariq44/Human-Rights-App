import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';

/// أداة تشخيص مشاكل رفع المستندات
class DocumentUploadDiagnostic {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  /// تشخيص شامل لمشكلة رفع المستندات
  static Future<Map<String, dynamic>> diagnose() async {
    final results = <String, dynamic>{};
    
    try {
      // 1. التحقق من المستخدم
      final user = _supabase.auth.currentUser;
      results['user_authenticated'] = user != null;
      results['user_id'] = user?.id;
      
      // 2. التحقق من وجود البucket
      try {
        final buckets = await _supabase.storage.listBuckets();
        final userDocsBucket = buckets.firstWhere(
          (bucket) => bucket.id == 'user-documents',
          orElse: () => throw Exception('Bucket not found'),
        );
        results['bucket_exists'] = true;
        results['bucket_public'] = userDocsBucket.public;
        results['bucket_file_size_limit'] = userDocsBucket.fileSizeLimit;
      } catch (e) {
        results['bucket_exists'] = false;
        results['bucket_error'] = e.toString();
      }
      
      // 3. اختبار رفع ملف تجريبي
      if (user != null) {
        try {
          // إنشاء ملف نصي بسيط للاختبار
          final testPath = '${user.id}/profile/test_file.txt';
          final testContent = Uint8List.fromList(utf8.encode('Test file content'));
          await _supabase.storage
              .from('user-documents')
              .uploadBinary(testPath, testContent);
          
          results['upload_test'] = 'success';
          
          // حذف الملف التجريبي
          await _supabase.storage
              .from('user-documents')
              .remove([testPath]);
              
        } catch (e) {
          results['upload_test'] = 'failed';
          results['upload_error'] = e.toString();
        }
      }
      
      // 4. التحقق من جدول المستندات
      try {
        await _supabase
            .from('documents')
            .select('count')
            .limit(1);
        results['documents_table_exists'] = true;
      } catch (e) {
        results['documents_table_exists'] = false;
        results['documents_table_error'] = e.toString();
      }
      
    } catch (e) {
      results['general_error'] = e.toString();
    }
    
    return results;
  }
  
  /// طباعة تقرير التشخيص
  static void printDiagnosticReport(Map<String, dynamic> results) {
    print('=== تقرير تشخيص رفع المستندات ===\n');
    
    // حالة المستخدم
    print('👤 حالة المستخدم:');
    print('   مُصدق: ${results['user_authenticated'] ? '✅' : '❌'}');
    if (results['user_id'] != null) {
      print('   معرف المستخدم: ${results['user_id']}');
    }
    print('');
    
    // حالة البucket
    print('🗄️  حالة Bucket:');
    print('   موجود: ${results['bucket_exists'] ? '✅' : '❌'}');
    if (results['bucket_exists'] == true) {
      print('   عام: ${results['bucket_public'] ? '⚠️  نعم' : '✅ لا'}');
      print('   حد الحجم: ${results['bucket_file_size_limit']} بايت');
    } else {
      print('   خطأ: ${results['bucket_error']}');
    }
    print('');
    
    // اختبار الرفع
    if (results.containsKey('upload_test')) {
      print('📤 اختبار الرفع:');
      print('   النتيجة: ${results['upload_test'] == 'success' ? '✅ نجح' : '❌ فشل'}');
      if (results['upload_error'] != null) {
        print('   خطأ: ${results['upload_error']}');
      }
      print('');
    }
    
    // جدول المستندات
    print('🗃️  جدول المستندات:');
    print('   موجود: ${results['documents_table_exists'] ? '✅' : '❌'}');
    if (results['documents_table_error'] != null) {
      print('   خطأ: ${results['documents_table_error']}');
    }
    print('');
    
    // أخطاء عامة
    if (results['general_error'] != null) {
      print('⚠️  خطأ عام: ${results['general_error']}');
      print('');
    }
    
    print('=== نهاية التقرير ===');
  }
  
  /// تشغيل التشخيص وطباعة التقرير
  static Future<void> runDiagnosis() async {
    print('جاري تشغيل التشخيص...\n');
    final results = await diagnose();
    printDiagnosticReport(results);
  }
}
