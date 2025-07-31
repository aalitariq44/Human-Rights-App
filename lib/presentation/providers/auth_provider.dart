import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// موفر المصادقة
class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  /// فحص ما إذا كان البريد الإلكتروني مؤكد
  bool get isEmailConfirmed => _user?.emailConfirmedAt != null;
  
  /// فحص ما إذا كان المستخدم مسجل الدخول ومؤكد البريد الإلكتروني
  bool get isAuthenticatedAndConfirmed => isAuthenticated && isEmailConfirmed;
  
  AuthProvider() {
    _init();
  }
  
  /// تهيئة الموفر
  void _init() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }
  
  /// فحص حالة المصادقة
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      _clearError();
      
      // فحص الجلسة الحالية
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _user = session.user;
      } else {
        _user = null;
      }
      
      _setLoading(false);
    } catch (e) {
      debugPrint('فشل في فحص حالة المصادقة: ${e.toString()}');
      _setError('فشل في فحص حالة المصادقة: $e');
      _setLoading(false);
    }
  }
  
  /// تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        
        _setLoading(false);
        return true;
      }
      
      debugPrint('فشل في تسجيل الدخول');
      _setError('فشل في تسجيل الدخول');
      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      String errorMessage = _translateAuthError(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: ${e.toString()}');
      _setError('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
      _setLoading(false);
      return false;
    }
  }

  /// ترجمة رسائل الخطأ من الإنجليزية إلى العربية
  String _translateAuthError(String errorMessage) {
    // تنظيف الرسالة وتحويلها إلى أحرف صغيرة للمقارنة
    final cleanMessage = errorMessage.toLowerCase().trim();
    
    // رسائل الخطأ الشائعة في Supabase Auth
    if (cleanMessage.contains('invalid login credentials') || 
        cleanMessage.contains('invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (cleanMessage.contains('email not confirmed')) {
      return 'Email not confirmed'; // سيتم التعامل معها بشكل خاص في الشاشة
    } else if (cleanMessage.contains('too many requests') || 
               cleanMessage.contains('rate limit')) {
      return 'تم إرسال عدد كبير من الطلبات. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى';
    } else if (cleanMessage.contains('user not found') || 
               cleanMessage.contains('user does not exist')) {
      return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني';
    } else if (cleanMessage.contains('invalid email') || 
               cleanMessage.contains('email is invalid')) {
      return 'البريد الإلكتروني غير صحيح';
    } else if (cleanMessage.contains('weak password') || 
               cleanMessage.contains('password is too weak')) {
      return 'كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى';
    } else if (cleanMessage.contains('signup disabled') || 
               cleanMessage.contains('sign up is disabled')) {
      return 'خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً';
    } else if (cleanMessage.contains('email already exists') || 
               cleanMessage.contains('user already registered') ||
               cleanMessage.contains('email address is already registered')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    } else if (cleanMessage.contains('password too short') || 
               cleanMessage.contains('password should be at least')) {
      return 'كلمة المرور قصيرة جداً';
    } else if (cleanMessage.contains('invalid password') || 
               cleanMessage.contains('incorrect password')) {
      return 'كلمة المرور غير صحيحة';
    } else if (cleanMessage.contains('network') || 
               cleanMessage.contains('connection') ||
               cleanMessage.contains('socketexception')) {
      return 'خطأ في الاتصال. يرجى التأكد من الاتصال بالإنترنت';
    } else if (cleanMessage.contains('timeout') || 
               cleanMessage.contains('timed out')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    } else if (cleanMessage.contains('server error') || 
               cleanMessage.contains('internal server error')) {
      return 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
    } else if (cleanMessage.contains('unauthorized') || 
               cleanMessage.contains('access denied')) {
      return 'غير مصرح لك بالوصول. يرجى التحقق من بيانات تسجيل الدخول';
    } else {
      // فحص الكلمات المفتاحية
      if (cleanMessage.contains('password')) {
        return 'كلمة المرور غير صحيحة';
      } else if (cleanMessage.contains('email')) {
        return 'البريد الإلكتروني غير صحيح أو غير موجود';
      } else if (cleanMessage.contains('credential')) {
        return 'بيانات تسجيل الدخول غير صحيحة';
      } else if (cleanMessage.contains('network') || cleanMessage.contains('internet')) {
        return 'خطأ في الاتصال. يرجى التأكد من الاتصال بالإنترنت';
      }
      
      // رسالة عامة للأخطاء غير المعروفة
      return 'حدث خطأ في تسجيل الدخول. يرجى التأكد من البيانات والمحاولة مرة أخرى';
    }
  }

  /// ترجمة رسائل الخطأ الخاصة بـ OTP
  String _translateOtpError(String? code, String message) {
    switch (code) {
      case 'signup_disabled':
        return 'خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً';
      case 'over_email_send_rate_limit':
        return 'تم إرسال عدد كبير من الرسائل. يرجى الانتظار دقيقة ثم المحاولة مرة أخرى';
      case 'email_not_confirmed':
        return 'البريد الإلكتروني غير مؤكد. يرجى تأكيد حسابك أولاً من خلال الرابط المرسل إلى بريدك الإلكتروني';
      case 'otp_expired':
        return 'رمز التحقق منتهي الصلاحية. يرجى طلب رمز جديد';
      case 'invalid_otp':
        return 'رمز التحقق غير صحيح. يرجى التأكد من الرمز المدخل';
      case 'token_hash_not_found':
        return 'رمز التحقق غير موجود أو منتهي الصلاحية. يرجى طلب رمز جديد';
      case 'user_not_found':
        return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني. يرجى إنشاء حساب جديد أولاً';
      case 'invalid_email':
        return 'البريد الإلكتروني غير صحيح';
      default:
        // استخدام الترجمة العادية للأخطاء
        return _translateAuthError(message);
    }
  }
  
  /// إنشاء حساب جديد
  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        _setLoading(false);
        return true;
      }
      
      debugPrint('فشل في إنشاء الحساب');
      _setError('فشل في إنشاء الحساب');
      _setLoading(false);
      return false;
    } on AuthApiException catch (e) {
      debugPrint('AuthApiException في signUp: ${e.code} - ${e.message}');
      String errorMessage = _translateOtpError(e.code, e.message);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      debugPrint('AuthException في signUp: ${e.message}');
      String errorMessage = _translateAuthError(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في إنشاء الحساب: ${e.toString()}');
      _setError('خطأ في إنشاء الحساب: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// إرسال OTP للبريد الإلكتروني
  Future<bool> sendOtp(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null,
      );
      
      _setLoading(false);
      return true;
    } on AuthApiException catch (e) {
      debugPrint('AuthApiException في sendOtp: ${e.code} - ${e.message}');
      String errorMessage = _translateOtpError(e.code, e.message);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } on AuthException catch (e) {
      debugPrint('AuthException في sendOtp: ${e.message}');
      String errorMessage = _translateAuthError(e.message);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في إرسال رمز التحقق: ${e.toString()}');
      if (e.toString().contains('SocketException')) {
        _setError('لا يوجد اتصال بالإنترنت. يرجى التأكد من الاتصال والمحاولة مرة أخرى.');
      } else if (e.toString().contains('TimeoutException')) {
        _setError('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
      } else {
        _setError('خطأ في إرسال رمز التحقق: ${e.toString()}');
      }
      _setLoading(false);
      return false;
    }
  }
  
  /// التحقق من OTP
  Future<bool> verifyOtp(String email, String token) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      
      if (response.user != null) {
        _user = response.user;
        
        _setLoading(false);
        return true;
      }
      
      debugPrint('رمز التحقق غير صحيح');
      _setError('رمز التحقق غير صحيح');
      _setLoading(false);
      return false;
    } on AuthApiException catch (e) {
      // تعامل مع أخطاء OTP المختلفة
      if (e.code == 'otp_expired') {
        debugPrint('رمز التحقق منتهي الصلاحية');
        _setError('رمز التحقق منتهي الصلاحية. يرجى طلب رمز جديد.');
      } else if (e.code == 'invalid_otp') {
        debugPrint('رمز التحقق غير صحيح');
        _setError('رمز التحقق غير صحيح. يرجى التأكد من الرمز المدخل.');
      } else if (e.code == 'token_hash_not_found') {
        debugPrint('رمز التحقق غير موجود أو منتهي الصلاحية');
        _setError('رمز التحقق غير موجود أو منتهي الصلاحية. يرجى طلب رمز جديد.');
      } else if (e.code == 'signup_disabled') {
        debugPrint('التسجيل معطل حالياً');
        _setError('خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً.');
      } else {
        debugPrint('خطأ في التحقق من الرمز: ${e.message}');
        _setError('خطأ في التحقق من الرمز: ${e.message}');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في التحقق من الرمز: ${e.toString()}');
      if (e.toString().contains('SocketException')) {
        _setError('لا يوجد اتصال بالإنترنت. يرجى التأكد من الاتصال والمحاولة مرة أخرى.');
      } else if (e.toString().contains('TimeoutException')) {
        _setError('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
      } else {
        _setError('خطأ في التحقق من الرمز: ${e.toString()}');
      }
      _setLoading(false);
      return false;
    }
  }
  
  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تسجيل الخروج: ${e.toString()}');
      _setError('خطأ في تسجيل الخروج: ${e.toString()}');
    }
  }
  
  /// إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _supabase.auth.resetPasswordForEmail(email);
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('خطأ في إعادة تعيين كلمة المرور: ${e.toString()}');
      _setError('خطأ في إعادة تعيين كلمة المرور: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// إعادة إرسال بريد التأكيد
  Future<bool> resendConfirmationEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.auth.resend(type: OtpType.signup, email: email);

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('خطأ في إعادة إرسال بريد التأكيد: ${e.toString()}');
      _setError('خطأ في إعادة إرسال بريد التأكيد: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }
}
