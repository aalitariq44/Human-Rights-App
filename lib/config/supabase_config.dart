/// إعدادات الاتصال مع Supabase
class SupabaseConfig {
  // معلومات المشروع
  static const String projectUrl = 'https://wbvrutmijsicrgeiojzq.supabase.co';
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndidnJ1dG1panNpY3JnZWlvanpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4Nzg2NzUsImV4cCI6MjA2OTQ1NDY3NX0.MrIEUp3sN3aVY6ep_v3_Hcu_4ZfZdXO2nAhek7w6KbE';
  
  // إعدادات إضافية
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxLoginAttempts = 5;
}
