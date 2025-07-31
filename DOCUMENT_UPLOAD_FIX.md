# إصلاح مشكلة رفع المستندات - خطأ 404

## المشكلة
```
فشل في رفع المستند
Exception: فشل في رفع المستند:
PostgrestException(message: {}, code: 404, details: Not Found, hint: null)
```

## السبب الجذري
المشكلة كانت في عدة نقاط:

1. **أنواع مستندات جديدة غير مدعومة**: تم إضافة أنواع مستندات جديدة في `DocumentType` enum لكن لم يتم التعامل معها في:
   - `document_view_screen.dart` - وظيفة `_getDocumentTypeIcon` كانت ترمي `UnimplementedError`
   - `document_storage_service.dart` - وظيفة `_generateFilePath` لم تشمل المجلدات الجديدة

2. **سياسات Supabase Storage**: السياسات القديمة لم تشمل المجلدات الجديدة المطلوبة

## الإصلاحات المطبقة

### 1. إصلاح document_view_screen.dart
- أضفت أيقونات لجميع أنواع المستندات الجديدة:
  - `birthCertificate` → `Icons.child_care`
  - `marriageCertificate` → `Icons.favorite`
  - `educationCertificate` → `Icons.school`
  - `workContract` → `Icons.work`
  - `medicalReport` → `Icons.local_hospital`
  - `bankStatement` → `Icons.account_balance`
  - `propertyDocuments` → `Icons.home_work`
  - `custom` → `Icons.note_add`

### 2. إصلاح document_storage_service.dart
- أضفت مسارات مجلدات لجميع أنواع المستندات:
  - `passport` → `official-documents/passport`
  - `birthCertificate` → `official-documents/birth-certificate`
  - `marriageCertificate` → `official-documents/marriage-certificate`
  - `educationCertificate` → `official-documents/education-certificate`
  - `workContract` → `official-documents/work-contract`
  - `medicalReport` → `official-documents/medical-report`
  - `bankStatement` → `official-documents/bank-statement`
  - `propertyDocuments` → `official-documents/property-documents`
  - `custom` → `official-documents/custom`

### 3. تحديث سياسات Supabase
- إنشاء ملف `update_bucket_policies.sql` لتحديث السياسات
- إضافة دعم لجميع المجلدات الجديدة في سياسات RLS
- تحديث Functions للتحقق من صحة هيكل المجلدات

## خطوات التطبيق

1. **تشغيل الكود في Supabase SQL Editor**:
   ```sql
   -- تشغيل محتويات ملف database/update_bucket_policies.sql
   ```

2. **إعادة تشغيل التطبيق**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **اختبار رفع المستندات**:
   - جرب رفع مستند من كل نوع
   - تأكد من عدم ظهور خطأ 404

## نصائح إضافية للتشخيص

### إذا استمرت المشكلة:

1. **تحقق من Authentication**:
   ```dart
   final user = Supabase.instance.client.auth.currentUser;
   print('User ID: ${user?.id}');
   ```

2. **تحقق من Service Role Key في Supabase Dashboard**:
   - اذهب إلى Settings → API
   - تأكد من استخدام `service_role` key وليس `anon` key للعمليات الإدارية

3. **تحقق من حالة البucket**:
   ```sql
   SELECT * FROM check_bucket_status();
   ```

4. **تحقق من السياسات المطبقة**:
   ```sql
   SELECT policyname, cmd, qual 
   FROM pg_policies 
   WHERE schemaname = 'storage' AND tablename = 'objects';
   ```

## الحالات الخاصة

### إذا كان المستخدم غير مسجل الدخول:
- تأكد من أن المستخدم مسجل الدخول قبل محاولة رفع المستندات
- أضف تحقق من `currentUser` في بداية `uploadDocument`

### إذا كانت المشكلة في أنواع ملفات معينة:
- تحقق من `allowed_mime_types` في bucket settings
- تأكد من أن نوع الملف مدعوم في `_getMimeType` function

## رسائل التشخيص المتوقعة بعد التحديث:
```
✅ Bucket "user-documents" موجود ومُكوّن بنجاح
✅ تم تطبيق جميع السياسات بنجاح (4 سياسة)
✅ تم تحديث Functions المساعدة
✅ تم إضافة دعم لجميع أنواع المستندات الجديدة
🎯 النظام جاهز للاستخدام!
```
