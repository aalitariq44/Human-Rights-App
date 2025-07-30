import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// موفر الثيم
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  /// تحميل الثيم المحفوظ
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      // في حالة فشل التحميل، استخدم الثيم الافتراضي
      _isDarkMode = false;
    }
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }
  
  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveTheme();
    notifyListeners();
  }
  
  /// حفظ إعداد الثيم
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // تجاهل خطأ الحفظ
    }
  }
}
