import 'package:flutter/material.dart';
import '../../../services/quick_diagnostic.dart';
import 'dart:developer' as developer;

/// شاشة تشخيص سريع لمشكلة رفع المستندات
class QuickDiagnosticScreen extends StatefulWidget {
  const QuickDiagnosticScreen({super.key});

  @override
  State<QuickDiagnosticScreen> createState() => _QuickDiagnosticScreenState();
}

class _QuickDiagnosticScreenState extends State<QuickDiagnosticScreen> {
  bool _isRunning = false;
  String _results = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشخيص مشكلة رفع المستندات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'تشخيص مشكلة 404',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذه الأداة ستقوم بفحص الأسباب المحتملة لمشكلة رفع المستندات وإظهار الحلول المطلوبة.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runDiagnostic,
                icon: _isRunning 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'جاري التشخيص...' : 'بدء التشخيص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isNotEmpty) ...[
              const Text(
                'نتائج التشخيص:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _results,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openSupabaseDashboard,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('فتح Supabase'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
      _results = '';
    });

    try {
      // تشغيل التشخيص
      await QuickDiagnostic.runQuickCheck();
      
      setState(() {
        _results = 'تم تشغيل التشخيص. راجع وحدة التحكم (Console) لرؤية النتائج التفصيلية.\n\nإذا رأيت أي ❌ في وحدة التحكم، يجب حل تلك المشاكل أولاً.';
        _isRunning = false;
      });

    } catch (e) {
      setState(() {
        _results = 'خطأ في تشغيل التشخيص: $e';
        _isRunning = false;
      });
    }
  }

  void _openSupabaseDashboard() {
    // يمكن إضافة رابط لفتح Supabase Dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اذهب إلى Supabase Dashboard → SQL Editor وقم بتشغيل الـ SQL script'),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
