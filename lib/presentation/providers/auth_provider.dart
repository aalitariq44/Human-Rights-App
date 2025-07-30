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
    } on AuthApiException catch (e) {
      // تعامل خاص عند عدم تأكيد البريد الإلكتروني
      if (e.code == 'email_not_confirmed') {
        debugPrint('البريد الإلكتروني غير مؤكد');
        _setError('البريد الإلكتروني غير مؤكد. يرجى تأكيد حسابك من خلال الرابط المرسل إلى بريدك.');
      } else {
        debugPrint('خطأ في تسجيل الدخول: ${e.message}');
        _setError('خطأ في تسجيل الدخول: ${e.message}');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: ${e.toString()}');
      _setError('خطأ في تسجيل الدخول: ${e.toString()}');
      _setLoading(false);
      return false;
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
    } catch (e) {
      debugPrint('خطأ في إرسال رمز التحقق: ${e.toString()}');
      _setError('خطأ في إرسال رمز التحقق: ${e.toString()}');
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
        type: OtpType.magiclink,
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
      } else {
        debugPrint('خطأ في التحقق من الرمز: ${e.message}');
        _setError('خطأ في التحقق من الرمز: ${e.message}');
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('خطأ في التحقق من الرمز: ${e.toString()}');
      _setError('خطأ في التحقق من الرمز: ${e.toString()}');
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
