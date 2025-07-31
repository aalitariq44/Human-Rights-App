-- ===================================================================
-- تحديث Bucket وسياسات الأمان لتشمل جميع أنواع المستندات الجديدة
-- تشغيل هذا الكود في Supabase SQL Editor لإصلاح مشكلة 404
-- ===================================================================

-- الخطوة 1: التأكد من وجود Bucket مع الإعدادات المحدثة
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
  'user-documents',                    -- معرف الـ bucket
  'user-documents',                    -- اسم الـ bucket
  false,                               -- خاص وليس عام
  20971520,                           -- 20MB حد أقصى لكل ملف
  ARRAY[                              -- أنواع الملفات المسموحة
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/webp',
    'application/pdf',
    'application/json'
  ],
  false,                              -- عدم تحويل AVIF تلقائياً
  NOW(),                              -- وقت الإنشاء
  NOW()                               -- وقت التحديث
) ON CONFLICT (id) DO UPDATE SET
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types,
  updated_at = NOW();

-- ===================================================================
-- الخطوة 2: حذف السياسات القديمة وإنشاء سياسات جديدة محدثة
-- ===================================================================

-- حذف السياسات القديمة
DROP POLICY IF EXISTS "Users can upload to own folder only" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own recent files" ON storage.objects;

-- سياسة الرفع المحدثة: تشمل جميع المجلدات الجديدة
CREATE POLICY "Users can upload to own folder only" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  -- التأكد أن المسار يبدأ بـ user_id الخاص بالمستخدم
  (storage.foldername(name))[1] = auth.uid()::text AND
  -- التأكد من صحة هيكل المجلدات (على الأقل مستويين)
  array_length(storage.foldername(name), 1) >= 2 AND
  -- التأكد من أن المجلد الثاني من المجلدات المسموحة
  (storage.foldername(name))[2] IN (
    'profile',
    'official-documents', 
    'metadata'
  ) AND
  -- قواعد إضافية لمجلد official-documents - تشمل جميع الأنواع الجديدة
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

-- سياسة الحذف: محدودة جداً (فقط خلال 24 ساعة من الرفع)
CREATE POLICY "Users can delete own recent files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text AND
  -- السماح بالحذف فقط خلال 24 ساعة من الرفع
  created_at > NOW() - INTERVAL '24 hours'
);

-- ===================================================================
-- الخطوة 3: تحديث Function للتحقق من هيكل المجلدات
-- ===================================================================

-- Function محدثة للتحقق من سلامة هيكل المجلدات
CREATE OR REPLACE FUNCTION check_folder_structure(file_path TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  folders TEXT[];
BEGIN
  folders := storage.foldername(file_path);
  
  -- التحقق من وجود user_id كمجلد أول
  IF array_length(folders, 1) < 2 THEN
    RETURN FALSE;
  END IF;
  
  -- التحقق من أن المجلد الثاني من المجلدات المسموحة
  IF folders[2] NOT IN ('profile', 'official-documents', 'metadata') THEN
    RETURN FALSE;
  END IF;
  
  -- تحقق إضافي لمجلد official-documents - يشمل جميع الأنواع الجديدة
  IF folders[2] = 'official-documents' THEN
    IF array_length(folders, 1) < 3 THEN
      RETURN FALSE;
    END IF;
    
    IF folders[3] NOT IN (
      'passport', 'iraqi-affairs', 'kuwait-immigration', 
      'residence-permit', 'red-cross', 'birth-certificate',
      'marriage-certificate', 'education-certificate', 'work-contract',
      'medical-report', 'bank-statement', 'property-documents',
      'custom', 'other'
    ) THEN
      RETURN FALSE;
    END IF;
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===================================================================
-- الخطوة 4: إنشاء Function للتحقق من حالة البucket
-- ===================================================================

-- Function للتحقق من حالة وإعدادات البucket
CREATE OR REPLACE FUNCTION check_bucket_status()
RETURNS TABLE(
  bucket_exists BOOLEAN,
  bucket_public BOOLEAN,
  file_size_limit BIGINT,
  allowed_mime_types TEXT[],
  policy_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'user-documents') as bucket_exists,
    COALESCE((SELECT public FROM storage.buckets WHERE id = 'user-documents'), FALSE) as bucket_public,
    COALESCE((SELECT storage.buckets.file_size_limit FROM storage.buckets WHERE id = 'user-documents'), 0) as file_size_limit,
    COALESCE((SELECT sb.allowed_mime_types FROM storage.buckets sb WHERE sb.id = 'user-documents'), ARRAY[]::TEXT[]) as allowed_mime_types,
    (SELECT COUNT(*)::INTEGER FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname LIKE '%user-documents%' OR policyname LIKE '%Users can%') as policy_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===================================================================
-- الخطوة 5: تشغيل تشخيص للتأكد من صحة الإعداد
-- ===================================================================

-- عرض حالة البucket
SELECT * FROM check_bucket_status();

-- عرض جميع السياسات المطبقة على storage.objects
SELECT 
  policyname as policy_name,
  cmd as command,
  COALESCE(qual, with_check) as condition
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND (policyname LIKE '%Users can%' OR policyname LIKE '%user-documents%')
ORDER BY policyname;

-- ===================================================================
-- رسائل التأكيد والتشخيص
-- ===================================================================

DO $$
DECLARE
  bucket_exists BOOLEAN;
  policy_count INTEGER;
BEGIN
  -- التحقق من وجود البucket
  SELECT EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'user-documents') INTO bucket_exists;
  
  -- عد السياسات
  SELECT COUNT(*)::INTEGER INTO policy_count
  FROM pg_policies 
  WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND (policyname LIKE '%Users can%');

  IF bucket_exists THEN
    RAISE NOTICE '✅ Bucket "user-documents" موجود ومُكوّن بنجاح';
  ELSE
    RAISE NOTICE '❌ فشل في إنشاء Bucket "user-documents"';
  END IF;

  IF policy_count >= 4 THEN
    RAISE NOTICE '✅ تم تطبيق جميع السياسات بنجاح (% سياسة)', policy_count;
  ELSE
    RAISE NOTICE '⚠️  تم تطبيق % سياسة فقط من أصل 4', policy_count;
  END IF;

  RAISE NOTICE '✅ تم تحديث Functions المساعدة';
  RAISE NOTICE '✅ تم إضافة دعم لجميع أنواع المستندات الجديدة:';
  RAISE NOTICE '   - passport (جواز السفر)';
  RAISE NOTICE '   - birth-certificate (شهادة الميلاد)';
  RAISE NOTICE '   - marriage-certificate (شهادة الزواج)';
  RAISE NOTICE '   - education-certificate (الشهادات التعليمية)';
  RAISE NOTICE '   - work-contract (عقد العمل)';
  RAISE NOTICE '   - medical-report (التقارير الطبية)';
  RAISE NOTICE '   - bank-statement (كشف حساب بنكي)';
  RAISE NOTICE '   - property-documents (وثائق الممتلكات)';
  RAISE NOTICE '   - custom (مستند مخصص)';
  RAISE NOTICE '';
  RAISE NOTICE '🎯 النظام جاهز للاستخدام!';
  RAISE NOTICE '';
  RAISE NOTICE '📝 خطوات التشخيص التالية:';
  RAISE NOTICE '1. تأكد من استخدام Service Role Key في Dashboard';
  RAISE NOTICE '2. أعد تشغيل التطبيق بعد هذا التحديث';
  RAISE NOTICE '3. جرب رفع مستند جديد';
  RAISE NOTICE '4. في حالة استمرار المشكلة، تحقق من Authentication';
END $$;
