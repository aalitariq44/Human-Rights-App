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
      
      _setError('فشل في تسجيل الدخول');
      _setLoading(false);
      return false;
    } catch (e) {
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
      
      _setError('فشل في إنشاء الحساب');
      _setLoading(false);
      return false;
    } catch (e) {
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
        type: OtpType.signup,
      );
      
      if (response.user != null) {
        _user = response.user;
        _setLoading(false);
        return true;
      }
      
      _setError('رمز التحقق غير صحيح');
      _setLoading(false);
      return false;
    } catch (e) {
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
