# حل سريع لمشكلة 404 في رفع المستندات

## المشكلة
```
فشل في رفع المستند:
PostgrestException(message: {}, code: 404, details: Not Found, hint: null)
```

## الحل السريع

### الخطوة 1: تشغيل SQL في Supabase
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ والصق المحتوى التالي وشغله:

```sql
-- إنشاء/تحديث bucket المستندات
INSERT INTO storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types,
  avif_autodetection, created_at, updated_at
) VALUES (
  'user-documents', 'user-documents', false, 20971520,
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf', 'application/json'],
  false, NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types,
  updated_at = NOW();

-- حذف السياسات القديمة
DROP POLICY IF EXISTS "Users can upload to own folder only" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own recent files" ON storage.objects;

-- سياسة الرفع المحدثة
CREATE POLICY "Users can upload to own folder only" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text AND
  array_length(storage.foldername(name), 1) >= 2 AND
  (storage.foldername(name))[2] IN ('profile', 'official-documents', 'metadata') AND
  (
    (storage.foldername(name))[2] != 'official-documents' OR
    (
      array_length(storage.foldername(name), 1) >= 3 AND
      (storage.foldername(name))[3] IN (
        'passport', 'iraqi-affairs', 'kuwait-immigration', 'residence-permit', 'red-cross',
        'birth-certificate', 'marriage-certificate', 'education-certificate', 'work-contract',
        'medical-report', 'bank-statement', 'property-documents', 'custom', 'other'
      )
    )
  )
);

-- سياسة العرض
CREATE POLICY "Users can view own files only" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- سياسة التحديث
CREATE POLICY "Users can update own files only" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- سياسة الحذف (محدودة)
CREATE POLICY "Users can delete own recent files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text AND
  created_at > NOW() - INTERVAL '24 hours'
);
```

### الخطوة 2: إعادة تشغيل التطبيق
```bash
flutter clean
flutter pub get
flutter run
```

### الخطوة 3: اختبار الرفع
- اذهب إلى شاشة رفع المستندات
- جرب رفع أي مستند
- يجب أن تعمل الآن!

## إذا استمرت المشكلة

### استخدم أداة التشخيص المدمجة:
1. عندما يظهر خطأ 404، اضغط على زر **"تشخيص المشكلة"**
2. راجع النتائج في وحدة التحكم (Console)
3. أي ❌ في النتائج يحتاج لحل

### أسباب أخرى محتملة:
- **المستخدم غير مسجل الدخول**: تأكد من تسجيل الدخول
- **مشكلة في الشبكة**: تحقق من الاتصال بالإنترنت  
- **Service Role Key خاطئ**: راجع إعدادات Supabase API

## رسائل النجاح المتوقعة:
```
✅ Bucket "user-documents" موجود ومُكوّن بنجاح
✅ تم تطبيق جميع السياسات بنجاح (4 سياسة)
🎯 النظام جاهز للاستخدام!
```

---
**ملاحظة**: هذا الحل يجب أن يعمل في 99% من الحالات. إذا استمرت المشكلة، راجع إعدادات Supabase أو تواصل مع الدعم الفني.
