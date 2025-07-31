import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  await _handleLogout();
                  break;
                case 'settings':
                  // التنقل لصفحة الإعدادات
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('الإعدادات'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppColors.errorColor),
                  title: Text('تسجيل الخروج', style: TextStyle(color: AppColors.errorColor)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ترحيب بالمستخدم
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final userEmail = authProvider.user?.email ?? 'المستخدم';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'مرحباً بك',
                              style: AppTextStyles.headline4,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userEmail,
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // الخيارات الرئيسية
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // اجعل الخانات أطول قليلاً
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOptionCard(
                      title: 'إدخال البيانات الشخصية',
                      subtitle: 'أدخل بياناتك الشخصية ومعلوماتك',
                      icon: Icons.person_add,
                      color: AppColors.primaryColor,
                      onTap: () {
                        // التنقل لصفحة إدخال البيانات
                        context.go(RouteNames.personalDataForm);
                      },
                    ),
                    _buildOptionCard(
                      title: 'رفع المستندات',
                      subtitle: 'ارفع المستندات والوثائق المطلوبة',
                      icon: Icons.upload_file,
                      color: AppColors.secondaryColor,
                      onTap: () {
                        // التنقل لصفحة رفع المستندات
                        context.go(RouteNames.documentUpload);
                      },
                    ),
                    _buildOptionCard(
                      title: 'المساعدة',
                      subtitle: 'احصل على المساعدة والدعم',
                      icon: Icons.help_outline,
                      color: AppColors.warningColor,
                      onTap: () {
                        // التنقل لصفحة المساعدة
                        context.go(RouteNames.help);
                      },
                    ),
                    _buildOptionCard(
                      title: 'النتيجة',
                      subtitle: 'عرض النتيجة بعد مراجعة البيانات ',
                      icon: Icons.assessment,
                      color: AppColors.infoColor, // You might need to define AppColors.infoColor or use an existing one
                      onTap: () {
                        // Placeholder for navigation to the result page
                        // context.go(RouteNames.result);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.subtitle1,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }
}
