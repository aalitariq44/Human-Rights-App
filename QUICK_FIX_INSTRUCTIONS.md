# تعليمات سريعة لحل مشكلة 404 ⚡

## خطوة واحدة فقط في Supabase:

1. اذهب إلى Supabase Dashboard → SQL Editor
2. انسخ والصق الكود التالي وشغله:

```sql
-- ===================================================================
-- الحل النهائي لخطأ 404 في رفع المستندات
-- ===================================================================

-- التحقق من وجود الجداول المطلوبة
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_personal_data' AND table_schema = 'public') THEN
        RAISE EXCEPTION '❌ جدول user_personal_data غير موجود. يرجى تشغيل create_tables_updated.sql أولاً';
    END IF;
    RAISE NOTICE '✅ جدول user_personal_data موجود';
END $$;

-- حذف جدول المستندات القديم
DROP TABLE IF EXISTS public.documents CASCADE;
RAISE NOTICE '🗑️ تم حذف جدول المستندات القديم';

-- إنشاء جدول المستندات الجديد
CREATE TABLE public.documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    personal_data_id UUID NOT NULL REFERENCES public.user_personal_data(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'personalPhoto', 'passportCopy', 'iraqiAffairsDept', 'kuwaitImmigration',
        'validResidence', 'redCrossInternational', 'birthCertificate',
        'marriageCertificate', 'educationCertificate', 'workContract',
        'medicalReport', 'bankStatement', 'propertyDocuments', 'custom', 'other'
    )),
    file_name TEXT NOT NULL,
    original_file_name TEXT NOT NULL,
    file_path TEXT NOT NULL UNIQUE,
    file_url TEXT,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    mime_type TEXT NOT NULL CHECK (mime_type IN (
        'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf'
    )),
    description TEXT,
    is_required BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT
);

-- إنشاء الفهارس
CREATE INDEX idx_documents_user_id ON public.documents(user_id);
CREATE INDEX idx_documents_personal_data_id ON public.documents(personal_data_id);
CREATE INDEX idx_documents_type ON public.documents(type);
CREATE INDEX idx_documents_is_verified ON public.documents(is_verified);
CREATE INDEX idx_documents_created_at ON public.documents(created_at DESC);

-- تفعيل الأمان
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان
CREATE POLICY "Users can insert own documents" ON public.documents
FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (SELECT 1 FROM public.user_personal_data WHERE id = personal_data_id AND user_id = auth.uid())
);

CREATE POLICY "Users can view own documents" ON public.documents
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own documents" ON public.documents
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (
    auth.uid() = user_id AND
    (OLD.is_verified = NEW.is_verified OR auth.role() = 'service_role')
);

CREATE POLICY "Users can delete own recent documents" ON public.documents
FOR DELETE USING (
    auth.uid() = user_id AND
    created_at > NOW() - INTERVAL '24 hours'
);

-- دالة تحديث التاريخ
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- المحفز
CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- تكوين Storage
INSERT INTO storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types, avif_autodetection, created_at, updated_at
) VALUES (
  'user-documents', 'user-documents', false, 20971520,
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf'],
  false, NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types,
  updated_at = NOW();

-- حذف سياسات Storage القديمة
DROP POLICY IF EXISTS "Users can upload to own folder only" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own files only" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own recent files" ON storage.objects;

-- سياسات Storage الجديدة
CREATE POLICY "Users can upload to own folder only" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view own files only" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update own files only" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete own recent files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user-documents' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text AND
  created_at > NOW() - INTERVAL '24 hours'
);

-- منح الصلاحيات
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.documents TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- رسالة النجاح
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🎉 ===== تم حل مشكلة 404 بنجاح! =====';
  RAISE NOTICE '✅ جدول المستندات يشير الآن إلى user_personal_data';
  RAISE NOTICE '✅ تم دعم جميع أنواع المستندات';
  RAISE NOTICE '✅ تم تطبيق سياسات الأمان';
  RAISE NOTICE '✅ تم تكوين Storage';
  RAISE NOTICE '📱 أعد تشغيل التطبيق الآن';
END $$;
```

## ثم أعد تشغيل التطبيق:
```bash
flutter clean && flutter pub get && flutter run
```

## ✅ انتهى! المشكلة محلولة
