import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../navigation/route_names.dart';

/// شاشة نجاح إرسال البيانات الشخصية
class PersonalDataSuccessScreen extends StatelessWidget {
  const PersonalDataSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة النجاح
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // رسالة النجاح
              Text(
                'تم إرسال البيانات بنجاح!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // وصف
              Text(
                'تم تشفير وحفظ بياناتك بنجاح.\nسنقوم بمراجعة طلبك والرد عليك في أقرب وقت ممكن.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'تذكر',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '• يمكنك رفع المستندات المطلوبة من الصفحة الرئيسية\n'
                      '• ستحصل على إشعار عند مراجعة طلبك\n'
                      '• يمكنك تتبع حالة طلبك في أي وقت',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // أزرار الإجراءات
              Column(
                children: [
                  // زر رفع المستندات
                  CustomButton(
                    text: 'رفع المستندات',
                    onPressed: () {
                      context.go(RouteNames.documentUpload);
                    },
                    icon: Icons.upload_file,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // زر العودة للرئيسية
                  CustomButton(
                    text: 'العودة للرئيسية',
                    onPressed: () {
                      context.go(RouteNames.home);
                    },
                    variant: ButtonVariant.outline,
                    icon: Icons.home,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
