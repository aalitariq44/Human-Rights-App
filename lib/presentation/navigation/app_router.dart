import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoqoqi/presentation/screens/personal_data/personal_data_success_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/personal_data/personal_data_form_screen.dart';
import 'route_names.dart';

/// مسارات التطبيق
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      
      // إذا كان المستخدم غير مسجل الدخول ويحاول الوصول لصفحة محمية
      if (!isAuthenticated) {
        if (state.matchedLocation.startsWith('/home') ||
            state.matchedLocation.startsWith('/personal-data') ||
            state.matchedLocation.startsWith('/document')) {
          return RouteNames.login;
        }
      }
      
      // إذا كان المستخدم مسجل الدخول ويحاول الوصول لصفحات المصادقة
      if (isAuthenticated) {
        if (state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.register ||
            state.matchedLocation == RouteNames.splash) {
          return RouteNames.home;
        }
      }
      
      return null; // لا يوجد إعادة توجيه
    },
    routes: [
      // شاشة البداية
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // شاشات المصادقة
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // الشاشة الرئيسية
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // مسارات البيانات الشخصية
      GoRoute(
        path: RouteNames.personalDataForm,
        name: 'personal-data-form',
        builder: (context, state) => const PersonalDataFormScreen(),
      ),
      
      // شاشة نجاح إرسال البيانات
      GoRoute(
        path: RouteNames.personalDataSuccess,
        name: 'personal-data-success',
        builder: (context, state) => const PersonalDataSuccessScreen(),
      ),
      
      // مسارات المستندات
      // GoRoute(
      //   path: RouteNames.documentUpload,
      //   name: 'document-upload',
      //   builder: (context, state) => const DocumentUploadScreen(),
      // ),
    ],
    
    // معالجة الأخطاء
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use GoRouter context pop instead of Navigator to ensure valid Navigator context
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
          tooltip: 'رجوع',
        ),
      ),
      body: const Center(
        child: Text(
          'الصفحة غير موجودة',
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}
