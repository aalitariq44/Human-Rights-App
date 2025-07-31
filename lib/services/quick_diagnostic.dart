import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

/// أداة تشخيص سريعة لمشكلة رفع المستندات
class QuickDiagnostic {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// تشخيص سريع للمشكلة الحالية
  static Future<void> runQuickCheck() async {
    print('🔍 بدء التشخيص السريع...\n');

    try {
      // 1. فحص المستخدم
      final user = _supabase.auth.currentUser;
      print('👤 المستخدم: ${user != null ? "✅ مسجل الدخول" : "❌ غير مسجل"}');
      if (user != null) {
        print('   المعرف: ${user.id}');
      }
      print('');

      // 2. فحص الاتصال بـ Supabase
      try {
        final response = await _supabase.rpc('version');
        print('🌐 الاتصال بـ Supabase: ✅ متصل');
        print('   إصدار PostgreSQL: ${response ?? "غير محدد"}');
      } catch (e) {
        print('🌐 الاتصال بـ Supabase: ❌ فشل');
        print('   الخطأ: $e');
      }
      print('');

      // 3. فحص bucket
      try {
        final buckets = await _supabase.storage.listBuckets();
        final userDocsBucket = buckets.where((b) => b.id == 'user-documents').toList();
        
        if (userDocsBucket.isNotEmpty) {
          print('🗄️  Bucket "user-documents": ✅ موجود');
          print('   عام: ${userDocsBucket.first.public ? "⚠️  نعم" : "✅ خاص"}');
          print('   حد الحجم: ${userDocsBucket.first.fileSizeLimit ?? "غير محدد"} بايت');
        } else {
          print('🗄️  Bucket "user-documents": ❌ غير موجود');
        }
      } catch (e) {
        print('🗄️  Bucket "user-documents": ❌ خطأ في الفحص');
        print('   الخطأ: $e');
      }
      print('');

      // 4. فحص Policies
      try {
        final policies = await _supabase.rpc('get_storage_policies_count');
        print('🔒 السياسات: ${policies ?? 0} سياسة موجودة');
      } catch (e) {
        print('🔒 السياسات: ❌ لا يمكن فحصها');
        print('   الخطأ: $e');
      }
      print('');

      // 5. اختبار رفع بسيط
      if (user != null) {
        try {
          final testPath = '${user.id}/profile/diagnostic_test.txt';
          final testContent = utf8.encode('اختبار تشخيصي');
          
          await _supabase.storage
              .from('user-documents')
              .uploadBinary(testPath, testContent);
          
          print('📤 اختبار الرفع: ✅ نجح');
          
          // حذف الملف التجريبي
          await _supabase.storage
              .from('user-documents')
              .remove([testPath]);
          
        } catch (e) {
          print('📤 اختبار الرفع: ❌ فشل');
          print('   الخطأ: $e');
          
          // تفصيل الخطأ
          if (e.toString().contains('404')) {
            print('   📋 المشكلة المحتملة: Bucket غير موجود أو Policies غير صحيحة');
          } else if (e.toString().contains('403')) {
            print('   📋 المشكلة المحتملة: لا توجد أذونات كافية');
          } else if (e.toString().contains('401')) {
            print('   📋 المشكلة المحتملة: مشكلة في المصادقة');
          }
        }
      }
      print('');

      print('🎯 خلاصة التشخيص:');
      print('   إذا ظهر أي ❌ أعلاه، هذا هو السبب في مشكلة رفع المستندات');
      print('   يجب حل جميع المشاكل الظاهرة بـ ❌ أولاً');
      print('');
      print('💡 الخطوات التالية:');
      if (user == null) {
        print('   1. تسجيل الدخول أولاً');
      } else {
        print('   1. تشغيل SQL script في Supabase Dashboard');
        print('   2. تأكد من أن Service Role Key صحيح');
        print('   3. إعادة محاولة رفع المستند');
      }

    } catch (e) {
      print('❌ خطأ عام في التشخيص: $e');
    }
  }
}
