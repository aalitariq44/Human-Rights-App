import 'package:flutter/material.dart';
import '../../../services/encryption_service.dart';
import 'encryption_helper.dart';

/// شاشة حل مشاكل إدخال البيانات الشخصية
class PersonalDataRecoveryScreen extends StatefulWidget {
  const PersonalDataRecoveryScreen({super.key});

  @override
  State<PersonalDataRecoveryScreen> createState() => _PersonalDataRecoveryScreenState();
}

class _PersonalDataRecoveryScreenState extends State<PersonalDataRecoveryScreen> {
  bool _isResetting = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حل مشاكل البيانات الشخصية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // شرح المشكلة
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'مشكلة في فك تشفير البيانات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.error, color: Colors.red[700]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'حدث خطأ في فك تشفير البيانات الشخصية المحفوظة. '
                      'قد يكون السبب تحديث في نظام التشفير أو تلف في البيانات المحلية.',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // حالة التشفير الحالية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'حالة نظام التشفير:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EncryptionHelper.buildEncryptionStatusWidget(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // الحلول المقترحة
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'الحلول المقترحة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.lightbulb, color: Colors.blue[700]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSolutionTile(
                      '1. إعادة تشغيل التطبيق',
                      'أغلق التطبيق بالكامل وافتحه مرة أخرى',
                      Icons.refresh,
                      () => _showRestartDialog(),
                    ),
                    
                    const Divider(),
                    
                    _buildSolutionTile(
                      '2. إعادة تعيين نظام التشفير',
                      'سيؤدي هذا إلى حذف البيانات المشفرة وإنشاء نظام تشفير جديد',
                      Icons.security,
                      _isResetting ? null : () => _resetEncryption(),
                    ),
                    
                    const Divider(),
                    
                    _buildSolutionTile(
                      '3. إعادة إدخال البيانات',
                      'قم بإدخال البيانات الشخصية مرة أخرى بعد حل المشكلة',
                      Icons.edit,
                      () => _navigateToPersonalDataForm(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // رسالة الحالة
            if (_statusMessage != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            
            const Spacer(),
            
            // أزرار العمل
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('رجوع'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isResetting ? null : () => _resetEncryption(),
                    child: _isResetting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حاول مرة أخرى'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionTile(
    String title,
    String description,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      trailing: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        description,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12),
      ),
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'إعادة تشغيل التطبيق',
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'يرجى إغلاق التطبيق بالكامل من قائمة التطبيقات الحديثة، '
          'ثم فتحه مرة أخرى لتحديث نظام التشفير.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetEncryption() async {
    setState(() {
      _isResetting = true;
      _statusMessage = null;
    });

    try {
      // إعادة تعيين خدمة التشفير
      await EncryptionService.instance.reset();
      
      setState(() {
        _statusMessage = 'تم إعادة تعيين نظام التشفير بنجاح! يمكنك الآن إدخال البيانات الشخصية مرة أخرى.';
      });
      
      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إعادة تعيين نظام التشفير بنجاح',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = 'فشل في إعادة تعيين نظام التشفير: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في إعادة تعيين التشفير: $e',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isResetting = false;
      });
    }
  }

  void _navigateToPersonalDataForm() {
    // التنقل إلى نموذج البيانات الشخصية
    Navigator.of(context).pushReplacementNamed('/personal-data-form');
  }
}
