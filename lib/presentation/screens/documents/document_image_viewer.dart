import 'package:flutter/material.dart';
import '../../../domain/entities/document_entity.dart';

/// عارض الصور للمستندات
class DocumentImageViewer extends StatefulWidget {
  final DocumentEntity document;
  
  const DocumentImageViewer({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentImageViewer> createState() => _DocumentImageViewerState();
}

class _DocumentImageViewerState extends State<DocumentImageViewer> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.document.originalFileName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showImageInfo(context),
          ),
        ],
      ),
      body: Center(
        child: _hasError 
          ? _buildErrorWidget()
          : _isLoading
            ? _buildLoadingWidget()
            : _buildImageWidget(),
      ),
    );
  }

  /// بناء عارض الصورة
  Widget _buildImageWidget() {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.network(
        widget.document.fileUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            setState(() {
              _isLoading = false;
            });
            return child;
          }
          return _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
          return _buildErrorWidget();
        },
      ),
    );
  }

  /// بناء ويدجت التحميل
  Widget _buildLoadingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'جاري تحميل الصورة...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  /// بناء ويدجت الخطأ
  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 64,
        ),
        const SizedBox(height: 16),
        const Text(
          'فشل في تحميل الصورة',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          child: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }

  /// عرض معلومات الصورة
  void _showImageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الصورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('اسم الملف:', widget.document.originalFileName),
            _buildInfoRow('نوع المستند:', widget.document.type.displayName),
            _buildInfoRow('حجم الملف:', widget.document.formattedFileSize),
            if (widget.document.description?.isNotEmpty == true)
              _buildInfoRow('الوصف:', widget.document.description!),
            _buildInfoRow('تاريخ الرفع:', _formatDate(widget.document.createdAt)),
            _buildInfoRow('حالة التحقق:', 
              widget.document.isVerified ? 'تم التحقق ✅' : 'في الانتظار ⏳'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// بناء صف المعلومات
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
