-- ===================================================================
-- حل سريع لخطأ 404 في رفع المستندات
-- انسخ هذا الكود بالكامل وشغله في Supabase SQL Editor
-- ===================================================================

-- إنشاء أو تحديث bucket المستندات
INSERT INTO storage.buckets (
  id, 
  name, 
  public, 
  file_size_limit, 
  allowed_mime_types,
  avif_autodetection,
  created_at,
  updated_at
) VALUES (
  'user-documents',
  'user-documents',
  false,
  20971520, -- 20MB
  ARRAY[
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/webp',
    'application/pdf',
    'application/json'
  ],
  false,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types,
  updated_at = NOW();

-- حذف السياسات القديمة إذا وجدت
DROP POLICY IF EXISTS "Users can upload to own folder only" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own recent files" ON storage.objects;

-- سياسة الرفع: المستخدم يرفع في مجلده فقط
CREATE POLICY "Users can upload to own folder only" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  -- التأكد أن المسار يبدأ بـ user_id
  (storage.foldername(name))[1] = auth.uid()::text AND
  -- التأكد من وجود مجلد فرعي على الأقل
  array_length(storage.foldername(name), 1) >= 2 AND
  -- التأكد من أن المجلد الثاني من المجلدات المسموحة
  (storage.foldername(name))[2] IN (
    'profile',
    'official-documents', 
    'metadata'
  ) AND
  -- قواعد إضافية لمجلد المستندات الرسمية
  (
    (storage.foldername(name))[2] != 'official-documents' OR
    (
      array_length(storage.foldername(name), 1) >= 3 AND
      (storage.foldername(name))[3] IN (
        'passport',
        'iraqi-affairs', 
        'kuwait-immigration',
        'residence-permit',
        'red-cross',
        'birth-certificate',
        'marriage-certificate',
        'education-certificate',
        'work-contract',
        'medical-report',
        'bank-statement',
        'property-documents',
        'custom',
        'other'
      )
    )
  )
);

-- سياسة العرض: المستخدم يرى ملفاته فقط
CREATE POLICY "Users can view own files only" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- سياسة التحديث: للملفات في المجلد الشخصي فقط
CREATE POLICY "Users can update own files only" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- سياسة الحذف: محدودة (فقط خلال 24 ساعة من الرفع)
CREATE POLICY "Users can delete own recent files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text AND
  created_at > NOW() - INTERVAL '24 hours'
);

-- رسالة تأكيد
DO $$
BEGIN
  RAISE NOTICE '✅ تم إصلاح مشكلة 404 بنجاح!';
  RAISE NOTICE '🎯 يمكنك الآن رفع المستندات بشكل طبيعي';
  RAISE NOTICE '📱 أعد تشغيل التطبيق واختبر رفع مستند';
END $$;
