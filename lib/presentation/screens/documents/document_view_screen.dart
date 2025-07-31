import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../domain/entities/enums.dart';
import '../../providers/document_provider.dart';
import '../../providers/personal_data_provider.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة عرض المستندات
class DocumentViewScreen extends StatefulWidget {
  const DocumentViewScreen({super.key});

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserDocuments();
  }

  /// تحميل مستندات المستخدم
  void _loadUserDocuments() {
    final personalDataProvider = Provider.of<PersonalDataProvider>(context, listen: false);
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    
    if (personalDataProvider.personalData?.id != null) {
      documentProvider.loadUserDocuments(personalDataProvider.personalData!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستندات المرفوعة'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDocuments,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, child) {
          if (documentProvider.isLoading) {
            return const LoadingWidget(message: 'جاري تحميل المستندات...');
          }

          return Column(
            children: [
              // شريط الإحصائيات
              _buildStatsBar(documentProvider),
              
              // المحتوى الرئيسي
              Expanded(
                child: _buildContent(documentProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/document-upload'),
        child: const Icon(Icons.add),
        tooltip: 'رفع مستند جديد',
      ),
    );
  }

  /// بناء شريط الإحصائيات
  Widget _buildStatsBar(DocumentProvider documentProvider) {
    final totalDocs = documentProvider.documents.length;
    final verifiedDocs = documentProvider.documents.where((doc) => doc.isVerified).length;
    final completion = documentProvider.completionPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي المستندات',
              value: totalDocs.toString(),
              icon: Icons.description,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'المستندات المُحققة',
              value: verifiedDocs.toString(),
              icon: Icons.verified,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'نسبة الإكمال',
              value: '${(completion * 100).toInt()}%',
              icon: Icons.pie_chart,
              color: completion == 1.0 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// بناء المحتوى الرئيسي
  Widget _buildContent(DocumentProvider documentProvider) {
    if (documentProvider.errorMessage != null) {
      return _buildErrorView(documentProvider.errorMessage!);
    }

    if (documentProvider.documents.isEmpty) {
      return _buildEmptyView();
    }

    return _buildDocumentsList(documentProvider);
  }

  /// بناء عرض الخطأ
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUserDocuments,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// بناء عرض فارغ
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مستندات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'لم يتم رفع أي مستندات بعد. ابدأ برفع مستنداتك الآن.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/document-upload'),
            icon: const Icon(Icons.upload_file),
            label: const Text('رفع مستند'),
          ),
        ],
      ),
    );
  }

  /// بناء قائمة المستندات
  Widget _buildDocumentsList(DocumentProvider documentProvider) {
    // تجميع المستندات حسب النوع
    final groupedDocs = <DocumentType, List<DocumentEntity>>{};
    for (final doc in documentProvider.documents) {
      if (!groupedDocs.containsKey(doc.type)) {
        groupedDocs[doc.type] = [];
      }
      groupedDocs[doc.type]!.add(doc);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedDocs.length,
      itemBuilder: (context, index) {
        final type = groupedDocs.keys.elementAt(index);
        final docs = groupedDocs[type]!;
        
        return _buildDocumentTypeSection(type, docs, documentProvider);
      },
    );
  }

  /// بناء قسم نوع المستند
  Widget _buildDocumentTypeSection(
    DocumentType type,
    List<DocumentEntity> docs,
    DocumentProvider documentProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            _getDocumentTypeIcon(type),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          type.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${docs.length} مستند'),
        children: docs.map((doc) => _buildDocumentTile(doc, documentProvider)).toList(),
      ),
    );
  }

  /// بناء بطاقة المستند
  Widget _buildDocumentTile(
    DocumentEntity document,
    DocumentProvider documentProvider,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(document).withOpacity(0.1),
        child: Icon(
          _getFileIcon(document.originalFileName),
          color: _getStatusColor(document),
          size: 20,
        ),
      ),
      title: Text(
        document.originalFileName,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.file_copy,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                document.formattedFileSize,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(document.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(document).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(document),
              style: TextStyle(
                fontSize: 11,
                color: _getStatusColor(document),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.visibility, size: 18),
                SizedBox(width: 8),
                Text('عرض'),
              ],
            ),
            onTap: () => _viewDocument(document),
          ),
          if (document.description?.isNotEmpty == true)
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18),
                  SizedBox(width: 8),
                  Text('الوصف'),
                ],
              ),
              onTap: () => _showDescription(document),
            ),
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('حذف', style: TextStyle(color: Colors.red)),
              ],
            ),
            onTap: () => _confirmDelete(document, documentProvider),
          ),
        ],
      ),
    );
  }

  /// الحصول على لون الحالة
  Color _getStatusColor(DocumentEntity document) {
    if (document.isVerified) {
      return Colors.green;
    } else if (document.rejectionReason != null) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  /// الحصول على نص الحالة
  String _getStatusText(DocumentEntity document) {
    if (document.isVerified) {
      return 'تم التحقق';
    } else if (document.rejectionReason != null) {
      return 'مرفوض';
    } else {
      return 'في الانتظار';
    }
  }

  /// الحصول على أيقونة نوع المستند
  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.personalPhoto:
        return Icons.person;
      case DocumentType.passportCopy:
        return Icons.credit_card;
      case DocumentType.iraqiAffairsDept:
        return Icons.location_city;
      case DocumentType.kuwaitImmigration:
        return Icons.flight_takeoff;
      case DocumentType.validResidence:
        return Icons.home;
      case DocumentType.redCrossInternational:
        return Icons.medical_services;
      case DocumentType.birthCertificate:
        return Icons.child_care;
      case DocumentType.marriageCertificate:
        return Icons.favorite;
      case DocumentType.educationCertificate:
        return Icons.school;
      case DocumentType.workContract:
        return Icons.work;
      case DocumentType.medicalReport:
        return Icons.local_hospital;
      case DocumentType.bankStatement:
        return Icons.account_balance;
      case DocumentType.propertyDocuments:
        return Icons.home_work;
      case DocumentType.custom:
        return Icons.note_add;
      case DocumentType.other:
        return Icons.description;
    }
  }

  /// الحصول على أيقونة الملف
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.description;
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// عرض المستند
  void _viewDocument(DocumentEntity document) {
    // TODO: تنفيذ عرض المستند
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ عرض المستند قريباً'),
      ),
    );
  }

  /// عرض الوصف
  void _showDescription(DocumentEntity document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.type.displayName),
        content: Text(document.description ?? 'لا يوجد وصف'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// تأكيد الحذف
  void _confirmDelete(DocumentEntity document, DocumentProvider documentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${document.originalFileName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await documentProvider.deleteDocument(document);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المستند بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
