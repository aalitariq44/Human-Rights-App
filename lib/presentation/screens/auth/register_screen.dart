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

/// شاشة إنشاء حساب جديد
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح، يرجى تأكيد بريدك الإلكتروني'),
            backgroundColor: AppColors.successColor,
          ),
        );
        context.go(RouteNames.login);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'فشل في إنشاء الحساب'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
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
    
    // التحقق من قوة كلمة المرور
    bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
    bool hasNumbers = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUpperCase) {
      return 'كلمة المرور يجب أن تحتوي على حروف كبيرة';
    }
    if (!hasLowerCase) {
      return 'كلمة المرور يجب أن تحتوي على حروف صغيرة';
    }
    if (!hasNumbers) {
      return 'كلمة المرور يجب أن تحتوي على أرقام';
    }
    if (!hasSpecialCharacters) {
      return 'كلمة المرور يجب أن تحتوي على رموز خاصة';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  Color _getPasswordStrengthColor() {
    final password = _passwordController.text;
    if (password.isEmpty) return AppColors.disabledColor;
    
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    if (score < 2) return AppColors.errorColor;
    if (score < 4) return AppColors.warningColor;
    return AppColors.successColor;
  }

  String _getPasswordStrengthText() {
    final password = _passwordController.text;
    if (password.isEmpty) return '';
    
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    if (score < 2) return 'ضعيفة';
    if (score < 4) return 'متوسطة';
    return 'قوية';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'رجوع',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // شعار التطبيق
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.gavel,
                        size: 40,
                        color: AppColors.textOnPrimaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // عنوان الشاشة
                  Text(
                    'إنشاء حساب جديد',
                    style: AppTextStyles.headline3,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'أدخل معلوماتك لإنشاء حساب جديد',
                    style: AppTextStyles.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
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
                    hintText: 'أدخل كلمة مرور قوية',
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
                    onChanged: (value) => setState(() {}),
                  ),
                  
                  // مؤشر قوة كلمة المرور
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'قوة كلمة المرور: ',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          _getPasswordStrengthText(),
                          style: AppTextStyles.caption.copyWith(
                            color: _getPasswordStrengthColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // حقل تأكيد كلمة المرور
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'تأكيد كلمة المرور',
                    hintText: 'أعد إدخال كلمة المرور',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // زر إنشاء الحساب
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isLoading) {
                        return const LoadingWidget(message: 'جاري إنشاء الحساب...');
                      }
                      
                      return CustomButton(
                        text: 'إنشاء الحساب',
                        onPressed: _handleRegister,
                        isFullWidth: true,
                        icon: Icons.person_add,
                        isOutlined: false, // أو true حسب التصميم المطلوب
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // رابط تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: AppTextStyles.bodyText2,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(RouteNames.login);
                        },
                        child: Text(
                          'تسجيل الدخول',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
