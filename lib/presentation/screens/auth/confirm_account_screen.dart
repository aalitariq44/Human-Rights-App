import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class ConfirmAccountScreen extends StatefulWidget {
  final String email;

  const ConfirmAccountScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ConfirmAccountScreen> createState() => _ConfirmAccountScreenState();
}

class _ConfirmAccountScreenState extends State<ConfirmAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtpCode();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtpCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(widget.email);
    if (success) {
      _showSuccessSnackBar('تم إرسال رمز التحقق إلى بريدك الإلكتروني.');
      // التركيز على حقل الإدخال بعد الإرسال
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    } else {
      String errorMessage = authProvider.errorMessage ?? 'فشل في إرسال رمز التحقق.';
      
      // ترجمة رسائل الخطأ المختلفة
      if (errorMessage.contains('Email not confirmed')) {
        errorMessage = 'البريد الإلكتروني غير مؤكد. يرجى التحقق من صندوق الوارد أولاً.';
      } else if (errorMessage.contains('over_email_send_rate_limit')) {
        errorMessage = 'تم إرسال عدد كبير من الرسائل. يرجى الانتظار دقيقة ثم المحاولة مرة أخرى.';
      } else if (errorMessage.contains('signup_disabled')) {
        errorMessage = 'خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً.';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<void> _verifyOtpCode() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(widget.email, _otpController.text.trim());
    
    if (success) {
      _showSuccessSnackBar('تم تأكيد حسابك بنجاح!');
      // انتظار قصير لعرض رسالة النجاح قبل التوجه
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go(RouteNames.home);
      }
    } else {
      String errorMessage = authProvider.errorMessage ?? 'رمز التحقق غير صحيح.';
      
      // ترجمة رسائل الخطأ المختلفة
      if (errorMessage.contains('otp_expired')) {
        errorMessage = 'رمز التحقق منتهي الصلاحية. يرجى طلب رمز جديد.';
      } else if (errorMessage.contains('invalid_otp')) {
        errorMessage = 'رمز التحقق غير صحيح. يرجى التأكد من الرمز المدخل.';
      } else if (errorMessage.contains('token_hash_not_found')) {
        errorMessage = 'رمز التحقق غير موجود أو منتهي الصلاحية. يرجى طلب رمز جديد.';
      } else if (errorMessage.contains('signup_disabled')) {
        errorMessage = 'خدمة التسجيل معطلة حالياً. يرجى المحاولة لاحقاً.';
      }
      
      _showErrorSnackBar(errorMessage);
      // مسح النص وإعادة التركيز
      _otpController.clear();
      _focusNode.requestFocus();
    }
  }

  Future<void> _resendOtpCode() async {
    _otpController.clear();
    await _sendOtpCode();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 32),
                Text(
                  'رمز التحقق',
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'لقد أرسلنا رمز التحقق إلى بريدك الإلكتروني \n${widget.email}.\n يرجى إدخال الرمز المكون من 6 أرقام.',
                  style: AppTextStyles.bodyText2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'الرمز صالح لمدة ساعة واحدة فقط',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.warningColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // حقل إدخال رمز OTP
                TextFormField(
                  controller: _otpController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: AppColors.textHintColor,
                      letterSpacing: 4,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رمز التحقق';
                    }
                    if (value.length != 6) {
                      return 'رمز التحقق يجب أن يكون مكون من 6 أرقام';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const LoadingWidget();
                    }
                    return CustomButton(
                      text: 'تأكيد',
                      onPressed: _verifyOtpCode,
                      isFullWidth: true,
                      isOutlined: false,
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return authProvider.isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                            text: 'إعادة إرسال الرمز',
                            onPressed: () {
                              _resendOtpCode();
                            },
                            isFullWidth: true,
                            isOutlined: true,
                          );
                  },
                ),
                
                const SizedBox(height: 16),
                CustomButton(
                  text: 'العودة إلى تسجيل الدخول',
                  onPressed: () => context.go(RouteNames.login),
                  isFullWidth: true,
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}