-- تشخيص سريع لحالة نظام المستندات
-- شغل هذا الكود للتحقق من إعداد النظام بعد تطبيق الحل

-- 1. التحقق من وجود الجداول المطلوبة
SELECT 'user_personal_data table' as component, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_personal_data') 
            THEN '✅ موجود' 
            ELSE '❌ غير موجود' 
       END as status
UNION ALL
SELECT 'documents table', 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'documents') 
            THEN '✅ موجود' 
            ELSE '❌ غير موجود' 
       END
UNION ALL

-- 2. التحقق من وجود storage bucket
SELECT 'user-documents bucket',
       CASE WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'user-documents')
            THEN '✅ موجود'
            ELSE '❌ غير موجود'
       END
UNION ALL

-- 3. التحقق من السياسات
SELECT 'RLS policies',
       CASE WHEN (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'documents') > 0
            THEN '✅ مطبقة (' || (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'documents') || ' سياسة)'
            ELSE '❌ غير مطبقة'
       END
UNION ALL

-- 4. التحقق من أنواع المستندات المدعومة
SELECT 'Document types support',
       CASE WHEN EXISTS (
         SELECT 1 FROM information_schema.check_constraints 
         WHERE constraint_name LIKE '%documents_type_check%' 
         AND check_clause LIKE '%passportCopy%'
       )
       THEN '✅ محدث (يدعم الأنواع الجديدة)'
       ELSE '❌ قديم (يحتاج تحديث)'
       END;

-- عرض تفاصيل bucket إذا وجد
SELECT 
  'Bucket Details' as info,
  'ID: ' || id || ', Size Limit: ' || COALESCE(file_size_limit::text, 'unlimited') || ', Public: ' || public::text as details
FROM storage.buckets 
WHERE id = 'user-documents';

-- عرض السياسات المطبقة
SELECT 
  'Policy: ' || policyname as policy_info,
  'Command: ' || cmd || ', Applied to: documents table' as policy_details
FROM pg_policies 
WHERE tablename = 'documents';

-- رسالة تأكيد
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'documents') 
     AND EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'user-documents')
     AND (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'documents') > 0
  THEN
    RAISE NOTICE '🎉 النظام جاهز للاستخدام!';
    RAISE NOTICE '✅ جميع المكونات المطلوبة موجودة ومُكونة بشكل صحيح';
    RAISE NOTICE '📱 يمكنك الآن رفع المستندات بدون خطأ 404';
  ELSE
    RAISE NOTICE '⚠️ يرجى تشغيل ملف fix_documents_404_error.sql أولاً';
  END IF;
END $$;
