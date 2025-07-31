import 'package:flutter/material.dart';
import '../../../services/document_upload_diagnostic.dart';

/// شاشة تشخيص مشاكل رفع المستندات
class DocumentDiagnosticScreen extends StatefulWidget {
  const DocumentDiagnosticScreen({super.key});

  @override
  State<DocumentDiagnosticScreen> createState() => _DocumentDiagnosticScreenState();
}

class _DocumentDiagnosticScreenState extends State<DocumentDiagnosticScreen> {
  Map<String, dynamic>? _diagnosticResults;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشخيص رفع المستندات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تشخيص مشاكل رفع المستندات',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'هذه الأداة تساعد في تشخيص مشاكل رفع المستندات والتحقق من الإعدادات.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runDiagnostic,
                      icon: _isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isRunning ? 'جاري التشخيص...' : 'بدء التشخيص'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_diagnosticResults != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتائج التشخيص',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildDiagnosticResults(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _diagnosticResults = null;
    });

    try {
      final results = await DocumentUploadDiagnostic.diagnose();
      setState(() {
        _diagnosticResults = results;
      });
    } catch (e) {
      setState(() {
        _diagnosticResults = {'error': e.toString()};
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Widget _buildDiagnosticResults() {
    final results = _diagnosticResults!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // حالة المستخدم
        _buildSection(
          title: '👤 حالة المستخدم',
          children: [
            _buildResultItem(
              'مُصدق',
              results['user_authenticated'] ?? false,
            ),
            if (results['user_id'] != null)
              _buildInfoItem('معرف المستخدم', results['user_id']),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // حالة البucket
        _buildSection(
          title: '🗄️ حالة Bucket',
          children: [
            _buildResultItem(
              'موجود',
              results['bucket_exists'] ?? false,
            ),
            if (results['bucket_exists'] == true) ...[
              _buildResultItem(
                'خاص (غير عام)',
                !(results['bucket_public'] ?? true),
                isWarning: results['bucket_public'] == true,
              ),
              _buildInfoItem(
                'حد الحجم',
                '${(results['bucket_file_size_limit'] ?? 0) ~/ (1024 * 1024)} MB',
              ),
            ],
            if (results['bucket_error'] != null)
              _buildErrorItem('خطأ البucket', results['bucket_error']),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // اختبار الرفع
        if (results.containsKey('upload_test'))
          _buildSection(
            title: '📤 اختبار الرفع',
            children: [
              _buildResultItem(
                'النتيجة',
                results['upload_test'] == 'success',
              ),
              if (results['upload_error'] != null)
                _buildErrorItem('خطأ الرفع', results['upload_error']),
            ],
          ),
        
        const SizedBox(height: 16),
        
        // جدول المستندات
        _buildSection(
          title: '🗃️ جدول المستندات',
          children: [
            _buildResultItem(
              'موجود',
              results['documents_table_exists'] ?? false,
            ),
            if (results['documents_table_error'] != null)
              _buildErrorItem('خطأ الجدول', results['documents_table_error']),
          ],
        ),
        
        // أخطاء عامة
        if (results['general_error'] != null) ...[
          const SizedBox(height: 16),
          _buildSection(
            title: '⚠️ خطأ عام',
            children: [
              _buildErrorItem('الخطأ', results['general_error']),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildResultItem(String label, bool isSuccess, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isWarning ? Colors.orange : (isSuccess ? Colors.green : Colors.red),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            isSuccess ? 'نجح' : 'فشل',
            style: TextStyle(
              color: isWarning ? Colors.orange : (isSuccess ? Colors.green : Colors.red),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(String label, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
