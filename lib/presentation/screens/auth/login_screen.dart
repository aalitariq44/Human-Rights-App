import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isOtpMode = false;
  final _otpController = TextEditingController();
  int _failedAttempts = 0; // عداد المحاولات الفاشلة

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_isOtpMode) {
      // التحقق من OTP
      final success = await authProvider.verifyOtp(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );
      
      if (success) {
        if (mounted) {
          _failedAttempts = 0; // إعادة تعيين عداد المحاولات الفاشلة عند النجاح
          context.go(RouteNames.home);
        }
      } else {
        if (mounted) {
          _failedAttempts++;
          String errorMessage = authProvider.errorMessage ?? 'رمز التحقق غير صحيح. يرجى التأكد من الرمز والمحاولة مرة أخرى.';
          
          // تحسين رسائل الخطأ لـ OTP
          if (errorMessage.contains('otp_expired')) {
            errorMessage = 'رمز التحقق منتهي الصلاحية. يرجى طلب رمز جديد.';
          } else if (errorMessage.contains('invalid_otp')) {
            errorMessage = 'رمز التحقق غير صحيح. يرجى التأكد من الرمز المدخل.';
          } else if (errorMessage.contains('token_hash_not_found')) {
            errorMessage = 'رمز التحقق غير موجود أو منتهي الصلاحية. يرجى طلب رمز جديد.';
          }
          
          // إضافة نصائح بعد عدة محاولات فاشلة
          if (_failedAttempts >= 3) {
            errorMessage += '\n\nنصائح:\n• تأكد من إدخال الرمز كاملاً (6 أرقام)\n• تحقق من صندوق البريد والرسائل المحذوفة\n• جرب طلب رمز جديد';
          }
          
          _showErrorSnackBar(errorMessage);
        }
      }
    } else {
      // تسجيل الدخول العادي
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success) {
        if (mounted) {
          _failedAttempts = 0; // إعادة تعيين عداد المحاولات الفاشلة عند النجاح
          context.go(RouteNames.home);
        }
      } else {
        if (mounted) {
          _failedAttempts++; // زيادة عداد المحاولات الفاشلة
          final errorMessage = authProvider.errorMessage;
          if (errorMessage != null && errorMessage.contains('Email not confirmed')) {
            // إذا كان البريد الإلكتروني غير مؤكد، انتقل إلى شاشة التأكيد
            context.go(RouteNames.confirmAccount, extra: _emailController.text.trim());
          } else {
            // عرض رسالة الخطأ الواضحة مع نصائح إضافية
            String displayMessage = errorMessage ?? 'فشل في تسجيل الدخول. يرجى التأكد من البيانات والمحاولة مرة أخرى.';
            
            // إضافة نصائح بعد عدة محاولات فاشلة
            if (_failedAttempts >= 3) {
              displayMessage += '\n\nنصائح:\n• تأكد من صحة البريد الإلكتروني\n• تأكد من صحة كلمة المرور\n• جرب استخدام رمز التحقق بدلاً من كلمة المرور';
            }
            
            _showErrorSnackBar(displayMessage);
          }
        }
      }
    }
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال البريد الإلكتروني');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(_emailController.text.trim());
    
    if (success) {
      setState(() {
        _isOtpMode = true;
      });
      _showSuccessSnackBar('تم إرسال رمز التحقق إلى بريدك الإلكتروني');
    } else {
      String errorMessage = authProvider.errorMessage ?? 'فشل في إرسال رمز التحقق. يرجى المحاولة مرة أخرى.';
      
      // تحسين رسائل الخطأ بناءً على النوع
      if (errorMessage.contains('signup_disabled')) {
        errorMessage = 'خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً.';
      } else if (errorMessage.contains('over_email_send_rate_limit')) {
        errorMessage = 'تم إرسال عدد كبير من الرسائل. يرجى الانتظار دقيقة ثم المحاولة مرة أخرى.';
      } else if (errorMessage.contains('email_not_confirmed')) {
        errorMessage = 'البريد الإلكتروني غير مؤكد. يرجى تأكيد حسابك أولاً من خلال الرابط المرسل إلى بريدك الإلكتروني.';
      } else if (errorMessage.toLowerCase().contains('user not found')) {
        errorMessage = 'لا يوجد حساب مسجل بهذا البريد الإلكتروني. يرجى إنشاء حساب جديد أولاً.';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 5), // زيادة مدة عرض الرسالة
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رمز التحقق';
    }
    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        
                        // شعار التطبيق
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.gavel,
                              size: 50,
                              color: AppColors.textOnPrimaryColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // عنوان الشاشة
                        Text(
                          _isOtpMode ? 'تأكيد رمز التحقق' : 'تسجيل الدخول',
                          style: AppTextStyles.headline2,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          _isOtpMode 
                            ? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني'
                            : 'مرحباً بك في تطبيق حقوقي',
                          style: AppTextStyles.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 48),
                        
                        if (!_isOtpMode) ...[
                          // حقل البريد الإلكتروني
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'البريد الإلكتروني',
                            hintText: 'أدخل بريدك الإلكتروني',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: _validateEmail,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // حقل كلمة المرور
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'كلمة المرور',
                            hintText: 'أدخل كلمة المرور',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword 
                                ? Icons.visibility_outlined 
                                : Icons.visibility_off_outlined),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: _validatePassword,
                          ),
                        ] else ...[
                          // عرض البريد الإلكتروني
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'البريد الإلكتروني',
                            enabled: false,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // حقل رمز التحقق
                          CustomTextField(
                            controller: _otpController,
                            labelText: 'رمز التحقق',
                            hintText: 'أدخل الرمز المكون من 6 أرقام',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.security,
                            validator: _validateOtp,
                            maxLength: 6,
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // أزرار العمل
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.isLoading) {
                              return const LoadingWidget();
                            }
                            
                            return Column(
                              children: [
                                // زر تسجيل الدخول أو تأكيد OTP
                                CustomButton(
                                  text: _isOtpMode ? 'تأكيد الرمز' : 'تسجيل الدخول',
                                  onPressed: _handleLogin,
                                  isFullWidth: true, isOutlined: false,
                                ),
                                
                                if (!_isOtpMode) ...[
                                  const SizedBox(height: 16),
                                  
                                  // زر إرسال OTP
                                  CustomButton(
                                    text: 'تسجيل الدخول برمز التحقق',
                                    onPressed: _sendOtp,
                                    isFullWidth: true,
                                    isOutlined: true,
                                  ),
                                ] else ...[
                                  const SizedBox(height: 16),
                                  
                                  // زر العودة
                                  CustomButton(
                                    text: 'العودة',
                                    onPressed: () {
                                      setState(() {
                                        _isOtpMode = false;
                                        _otpController.clear();
                                      });
                                    },
                                    isFullWidth: true,
                                    isOutlined: true,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // رابط إنشاء حساب جديد
                if (!_isOtpMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: AppTextStyles.bodyText2,
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(RouteNames.register);
                          },
                          child: Text(
                            'إنشاء حساب جديد',
                            style: AppTextStyles.bodyText2.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
