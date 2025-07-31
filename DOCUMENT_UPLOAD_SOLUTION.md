# حل مشكلة رفع المستندات - خطأ 404

## الملخص
تم إصلاح مشكلة `PostgrestException(message: {}, code: 404, details: Not Found, hint: null)` عند رفع المستندات.

## المشاكل التي تم إصلاحها:

### 1. أنواع المستندات الجديدة غير المدعومة ✅
- **المشكلة**: كانت هناك أنواع مستندات جديدة في enum لكن لم يتم التعامل معها في الكود
- **الحل**: تم إضافة دعم كامل لجميع أنواع المستندات في:
  - `document_view_screen.dart` (الأيقونات)
  - `document_storage_service.dart` (مسارات المجلدات)

### 2. سياسات Supabase Storage ✅
- **المشكلة**: السياسات القديمة لم تشمل المجلدات الجديدة
- **الحل**: إنشاء ملف `update_bucket_policies.sql` محدث

### 3. أدوات التشخيص ✅
- **تم إضافة**: `DocumentUploadDiagnostic` class للتشخيص البرمجي
- **تم إضافة**: `DocumentDiagnosticScreen` للتشخيص عبر الواجهة

## خطوات الحل:

### الخطوة 1: تشغيل تحديث قاعدة البيانات 🔧
```sql
-- في Supabase SQL Editor، قم بتشغيل محتويات ملف:
-- database/update_bucket_policies.sql
```

### الخطوة 2: إعادة تشغيل التطبيق 📱
```bash
flutter clean
flutter pub get
flutter run
```

### الخطوة 3: اختبار رفع المستندات ✅
- جرب رفع مستند من أي نوع
- يجب أن تعمل جميع الأنواع الآن

## في حالة استمرار المشكلة:

### استخدم أداة التشخيص المدمجة:
```dart
// في أي مكان في التطبيق
import 'package:your_app/services/document_upload_diagnostic.dart';

// تشغيل التشخيص
await DocumentUploadDiagnostic.runDiagnosis();
```

### أو استخدم شاشة التشخيص:
```dart
// إضافة شاشة التشخيص للتنقل
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DocumentDiagnosticScreen(),
  ),
);
```

## نقاط التحقق الإضافية:

### 1. التحقق من Authentication:
```dart
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  // المستخدم غير مسجل الدخول
}
```

### 2. التحقق من Service Role Key:
- اذهب إلى Supabase Dashboard → Settings → API
- تأكد من استخدام `service_role` key للعمليات الإدارية

### 3. التحقق من حالة البucket:
```sql
SELECT * FROM check_bucket_status();
```

## أنواع المستندات المدعومة الآن:

✅ **الصورة الشخصية** - `profile/`
✅ **نسخة من الجواز** - `official-documents/passport/`
✅ **وثائق دائرة شؤون العراقي** - `official-documents/iraqi-affairs/`
✅ **وثائق منفذ الهجرة الكويتية** - `official-documents/kuwait-immigration/`
✅ **إقامة سارية المفعول** - `official-documents/residence-permit/`
✅ **وثائق الصليب الأحمر الدولي** - `official-documents/red-cross/`
✅ **شهادة الميلاد** - `official-documents/birth-certificate/`
✅ **شهادة الزواج** - `official-documents/marriage-certificate/`
✅ **الشهادات التعليمية** - `official-documents/education-certificate/`
✅ **عقد العمل** - `official-documents/work-contract/`
✅ **التقارير الطبية** - `official-documents/medical-report/`
✅ **كشف حساب بنكي** - `official-documents/bank-statement/`
✅ **وثائق الممتلكات** - `official-documents/property-documents/`
✅ **مستند مخصص** - `official-documents/custom/`
✅ **أخرى** - `official-documents/other/`

## رسائل النجاح المتوقعة بعد التحديث:
```
✅ Bucket "user-documents" موجود ومُكوّن بنجاح
✅ تم تطبيق جميع السياسات بنجاح (4 سياسة)
✅ تم تحديث Functions المساعدة
✅ تم إضافة دعم لجميع أنواع المستندات الجديدة
🎯 النظام جاهز للاستخدام!
```

## الملفات التي تم تعديلها:
- ✅ `lib/presentation/screens/documents/document_view_screen.dart`
- ✅ `lib/services/document_storage_service.dart`
- ✅ `database/update_bucket_policies.sql` (جديد)
- ✅ `lib/services/document_upload_diagnostic.dart` (جديد)
- ✅ `lib/presentation/screens/documents/document_diagnostic_screen.dart` (جديد)

المشكلة يجب أن تكون محلولة الآن! 🎉
