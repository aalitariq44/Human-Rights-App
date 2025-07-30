import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/personal_data_provider.dart';

/// التطبيق الرئيسي
class HoqoqiApp extends StatelessWidget {
  const HoqoqiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PersonalDataProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'حقوقي',
            debugShowCheckedModeBanner: false,
            
            // الثيم
            theme: AppTheme.lightTheme,
            
            // دعم اللغة العربية
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'), // العربية السعودية
              Locale('ar', 'IQ'), // العربية العراق
              Locale('ar', 'KW'), // العربية الكويت
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // التنقل
            routerConfig: AppRouter.router,
            
            // إعدادات إضافية
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
