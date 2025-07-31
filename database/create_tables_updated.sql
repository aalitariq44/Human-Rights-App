-- قاعدة بيانات تطبيق حقوق الإنسان العراقي - الإصدار المحدث
-- تحديث: يوليو 2025

-- جدول البيانات الشخصية والهوية
CREATE TABLE public.user_personal_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- البيانات الشخصية
  full_name_iraq TEXT NOT NULL,
  mother_name TEXT NOT NULL,
  current_province TEXT NOT NULL,
  birth_date DATE NOT NULL,
  birth_place TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  
  -- بيانات البطاقة الوطنية
  national_id TEXT NOT NULL,
  national_id_issue_year INTEGER NOT NULL,
  national_id_issuer TEXT NOT NULL,
  
  -- بيانات الكويت السابقة
  full_name_kuwait TEXT,
  kuwait_address TEXT,
  kuwait_education_level TEXT,
  family_members_count INTEGER,
  adults_over_18_count INTEGER,
  
  -- أختيارات الخروج من الكويت
  exit_method TEXT CHECK (exit_method IN (
    'voluntary_departure', 
    'forced_deportation', 
    'land_smuggling', 
    'before_army_withdrawal'
  )),
  
  -- نوع طلب التعويض
  compensation_type TEXT[] DEFAULT '{}' CHECK (
    compensation_type <@ ARRAY[
      'government_job_services',
      'personal_furniture_property', 
      'moral_compensation',
      'prison_compensation'
    ]
  ),
  
  -- طبيعة العمل في الكويت
  kuwait_job_type TEXT CHECK (kuwait_job_type IN (
    'civil_employee',
    'military_employee', 
    'student',
    'freelance'
  )),
  
  -- الوضع الرسمي بالكويت
  kuwait_official_status TEXT CHECK (kuwait_official_status IN (
    'resident',
    'bidoon'
  )),
  
  -- نوع طلب الحقوق
  rights_request_type TEXT[] DEFAULT '{}' CHECK (
    rights_request_type <@ ARRAY[
      'pension_salary',
      'residential_land'
    ]
  ),
  
  -- طوابع زمنية
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- التأكد من أن كل مستخدم له سجل واحد فقط
  UNIQUE(user_id)
);

-- جدول سجل الأنشطة
CREATE TABLE public.activity_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  details JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- فهارس للأداء السريع
CREATE INDEX idx_user_personal_data_user_id ON public.user_personal_data(user_id);
CREATE INDEX idx_user_personal_data_created_at ON public.user_personal_data(created_at);
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON public.activity_logs(created_at);
CREATE INDEX idx_activity_logs_action ON public.activity_logs(action);

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ترجيجر لتحديث updated_at عند التعديل
CREATE TRIGGER update_user_personal_data_updated_at 
    BEFORE UPDATE ON public.user_personal_data 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- منح صلاحيات الوصول
-- السماح للمستخدمين المسجلين بإدراج وقراءة بياناتهم الشخصية فقط
ALTER TABLE public.user_personal_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own personal data" 
    ON public.user_personal_data 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own personal data" 
    ON public.user_personal_data 
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own personal data" 
    ON public.user_personal_data 
    FOR UPDATE 
    USING (auth.uid() = user_id);

-- سجل الأنشطة - للمستخدمين المسجلين فقط
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own activity logs" 
    ON public.activity_logs 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own activity logs" 
    ON public.activity_logs 
    FOR SELECT 
    USING (auth.uid() = user_id);

-- منح الصلاحيات للمستخدمين المصادق عليهم
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.user_personal_data TO authenticated;
GRANT ALL ON public.activity_logs TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- إضافة تعليقات توضيحية
COMMENT ON TABLE public.user_personal_data IS 'بيانات المواطنين العراقيين المطالبين بحقوقهم في الكويت';
COMMENT ON TABLE public.activity_logs IS 'سجل أنشطة المستخدمين في النظام';

COMMENT ON COLUMN public.user_personal_data.national_id IS 'رقم الهوية الوطنية';
COMMENT ON COLUMN public.user_personal_data.compensation_type IS 'أنواع التعويضات المطلوبة (مصفوفة)';
COMMENT ON COLUMN public.user_personal_data.rights_request_type IS 'أنواع الحقوق المطلوبة (مصفوفة)';
