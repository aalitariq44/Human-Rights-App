import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/personal_data_provider.dart';
import 'presentation/providers/document_provider.dart';
import 'services/encryption_service.dart';

/// النقطة الرئيسية لدخول التطبيق
void main() async {
  // تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // إعداد الشاشة بدوران عمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // إعداد شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  try {
    // تهيئة Supabase
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.apiKey,
      debug: false, // يمكن تفعيلها في بيئة التطوير
    );
    
    // تهيئة خدمة التشفير
    await EncryptionService.initialize();
    
    // تشغيل التطبيق
    runApp(const HoqoqiMainApp());
    
  } catch (error) {
    // في حالة فشل التهيئة
    debugPrint('خطأ في تهيئة التطبيق: $error');
    runApp(const ErrorApp());
  }
}

/// التطبيق الرئيسي مع إعداد Providers
class HoqoqiMainApp extends StatelessWidget {
  const HoqoqiMainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => PersonalDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DocumentProvider(),
        ),
      ],
      child: const HoqoqiApp(),
    );
  }
}

/// شاشة خطأ في حالة فشل تهيئة التطبيق
class ErrorApp extends StatelessWidget {
  const ErrorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خطأ في التطبيق',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'عذراً، حدث خطأ في تشغيل التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'يرجى إعادة تشغيل التطبيق',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
