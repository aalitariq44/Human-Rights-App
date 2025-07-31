-- ===================================================================
-- إنشاء جدول المستندات (Documents Table)
-- يجب تشغيل هذا السكريبت في Supabase SQL Editor
-- ===================================================================

-- إنشاء جدول المستندات
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    personal_data_id UUID NOT NULL REFERENCES public.personal_data(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'personalPhoto',
        'iraqiAffairsDept', 
        'kuwaitImmigration',
        'validResidence',
        'redCrossInternational',
        'other'
    )),
    file_name TEXT NOT NULL,
    original_file_name TEXT NOT NULL,
    file_path TEXT NOT NULL UNIQUE,
    file_url TEXT,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    mime_type TEXT NOT NULL CHECK (mime_type IN (
        'image/jpeg',
        'image/jpg',
        'image/png', 
        'image/webp',
        'application/pdf'
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

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON public.documents(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_personal_data_id ON public.documents(personal_data_id);
CREATE INDEX IF NOT EXISTS idx_documents_type ON public.documents(type);
CREATE INDEX IF NOT EXISTS idx_documents_is_verified ON public.documents(is_verified);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON public.documents(created_at DESC);

-- تفعيل Row Level Security (RLS)
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- سياسات الأمان للمستندات

-- 1. سياسة الإدراج: المستخدم يستطيع إضافة مستندات لبياناته الشخصية فقط
DROP POLICY IF EXISTS "Users can insert own documents" ON public.documents;
CREATE POLICY "Users can insert own documents" ON public.documents
FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
        SELECT 1 FROM public.personal_data 
        WHERE id = personal_data_id AND user_id = auth.uid()
    )
);

-- 2. سياسة القراءة: المستخدم يرى مستنداته فقط
DROP POLICY IF EXISTS "Users can view own documents" ON public.documents;
CREATE POLICY "Users can view own documents" ON public.documents
FOR SELECT USING (auth.uid() = user_id);

-- 3. سياسة التحديث: المستخدم يستطيع تحديث مستنداته فقط (ما عدا حالة التحقق)
DROP POLICY IF EXISTS "Users can update own documents" ON public.documents;
CREATE POLICY "Users can update own documents" ON public.documents
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (
    auth.uid() = user_id AND
    -- منع تغيير حالة التحقق من قبل المستخدم العادي
    (OLD.is_verified = NEW.is_verified OR auth.role() = 'service_role')
);

-- 4. سياسة الحذف: المستخدم يستطيع حذف مستنداته خلال 24 ساعة من الرفع
DROP POLICY IF EXISTS "Users can delete own recent documents" ON public.documents;
CREATE POLICY "Users can delete own recent documents" ON public.documents
FOR DELETE USING (
    auth.uid() = user_id AND
    created_at > NOW() - INTERVAL '24 hours'
);

-- 5. سياسة للمشرفين: يمكنهم رؤية وتحديث جميع المستندات
DROP POLICY IF EXISTS "Admins can manage all documents" ON public.documents;
CREATE POLICY "Admins can manage all documents" ON public.documents
FOR ALL USING (
    auth.role() = 'service_role' OR
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role IN ('admin', 'supervisor')
    )
);

-- إنشاء دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء Trigger لتحديث updated_at
DROP TRIGGER IF EXISTS update_documents_updated_at ON public.documents;
CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- إنشاء دالة للتحقق من صحة نوع المستند مع البيانات الشخصية
CREATE OR REPLACE FUNCTION validate_document_constraints()
RETURNS TRIGGER AS $$
BEGIN
    -- التحقق من أن المستخدم لا يرفع نفس نوع المستند أكثر من مرة (ما عدا "other")
    IF NEW.type != 'other' AND EXISTS (
        SELECT 1 FROM public.documents 
        WHERE user_id = NEW.user_id 
        AND personal_data_id = NEW.personal_data_id 
        AND type = NEW.type 
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
    ) THEN
        RAISE EXCEPTION 'لا يمكن رفع أكثر من مستند واحد من نفس النوع';
    END IF;

    -- التحقق من صحة حجم الملف
    IF NEW.mime_type LIKE 'image/%' AND NEW.file_size > 5242880 THEN -- 5MB
        RAISE EXCEPTION 'حجم الصورة يجب أن يكون أقل من 5 ميجابايت';
    END IF;
    
    IF NEW.mime_type = 'application/pdf' AND NEW.file_size > 10485760 THEN -- 10MB
        RAISE EXCEPTION 'حجم ملف PDF يجب أن يكون أقل من 10 ميجابايت';
    END IF;

    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء Trigger للتحقق من القيود
DROP TRIGGER IF EXISTS validate_document_constraints_trigger ON public.documents;
CREATE TRIGGER validate_document_constraints_trigger
    BEFORE INSERT OR UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION validate_document_constraints();

-- إنشاء Views مفيدة

-- 1. عرض إحصائيات المستندات لكل مستخدم
CREATE OR REPLACE VIEW public.user_documents_stats AS
SELECT 
    pd.user_id,
    pd.id as personal_data_id,
    COUNT(d.id) as total_documents,
    COUNT(CASE WHEN d.is_verified = true THEN 1 END) as verified_documents,
    COUNT(CASE WHEN d.is_required = true THEN 1 END) as required_documents,
    COUNT(CASE WHEN d.is_required = true AND d.is_verified = true THEN 1 END) as verified_required_documents,
    SUM(d.file_size) as total_file_size,
    MAX(d.created_at) as last_upload
FROM public.personal_data pd
LEFT JOIN public.documents d ON pd.id = d.personal_data_id
GROUP BY pd.user_id, pd.id;

-- 2. عرض المستندات مع معلومات البيانات الشخصية
CREATE OR REPLACE VIEW public.documents_with_personal_data AS
SELECT 
    d.*,
    pd.full_name,
    pd.id_number,
    pd.phone_number
FROM public.documents d
INNER JOIN public.personal_data pd ON d.personal_data_id = pd.id;

-- إنشاء دالة لحساب نسبة اكتمال المستندات
CREATE OR REPLACE FUNCTION get_documents_completion_percentage(p_personal_data_id UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_required INTEGER := 5; -- عدد أنواع المستندات المطلوبة
    uploaded_required INTEGER;
    percentage DECIMAL(5,2);
BEGIN
    -- حساب عدد المستندات المطلوبة التي تم رفعها
    SELECT COUNT(DISTINCT type) INTO uploaded_required
    FROM public.documents
    WHERE personal_data_id = p_personal_data_id
    AND type IN ('personalPhoto', 'iraqiAffairsDept', 'kuwaitImmigration', 'validResidence', 'redCrossInternational');
    
    -- حساب النسبة المئوية
    percentage := (uploaded_required::DECIMAL / total_required::DECIMAL) * 100;
    
    RETURN percentage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إعطاء صلاحيات للمستخدمين المصادق عليهم
GRANT SELECT, INSERT, UPDATE, DELETE ON public.documents TO authenticated;
GRANT SELECT ON public.user_documents_stats TO authenticated;
GRANT SELECT ON public.documents_with_personal_data TO authenticated;
GRANT EXECUTE ON FUNCTION get_documents_completion_percentage(UUID) TO authenticated;

-- رسائل تأكيد
DO $$
BEGIN
    RAISE NOTICE '✅ تم إنشاء جدول المستندات بنجاح';
    RAISE NOTICE '✅ تم تطبيق سياسات الأمان (RLS)';
    RAISE NOTICE '✅ تم إنشاء الفهارس والمحفزات';
    RAISE NOTICE '✅ تم إنشاء Views والدوال المساعدة';
    RAISE NOTICE '🎯 جدول المستندات جاهز للاستخدام!';
    RAISE NOTICE '';
    RAISE NOTICE '📝 ملاحظات مهمة:';
    RAISE NOTICE '- يمكن للمستخدم رفع مستند واحد فقط من كل نوع';
    RAISE NOTICE '- يمكن حذف المستندات خلال 24 ساعة من الرفع';
    RAISE NOTICE '- تم تطبيق قيود على أحجام الملفات';
    RAISE NOTICE '- المشرفون يمكنهم إدارة جميع المستندات';
END $$;
