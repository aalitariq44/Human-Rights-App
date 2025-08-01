import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../../../domain/entities/enums.dart';
import '../../providers/document_provider.dart';
import '../../providers/personal_data_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/route_names.dart';
import '../../../services/quick_diagnostic.dart';
import '../../../services/document_viewer_service.dart';
import 'document_image_viewer.dart';

/// شاشة رفع المستندات
class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final TextEditingController _documentNameController = TextEditingController();
  final TextEditingController _customDocumentTypeController = TextEditingController();
  DocumentType _selectedDocumentType = DocumentType.personalPhoto;
  String? _selectedFilePath;
  String? _originalFileName;
  bool _isCustomDocumentType = false;

  @override
  void initState() {
    super.initState();
    _loadUserDocuments();
  }

  @override
  void dispose() {
    _documentNameController.dispose();
    _customDocumentTypeController.dispose();
    super.dispose();
  }

  /// تحميل مستندات المستخدم
  void _loadUserDocuments() {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final personalDataProvider = Provider.of<PersonalDataProvider>(context, listen: false);
    
    // تحميل البيانات الشخصية أولاً
    personalDataProvider.fetchPersonalData().then((_) {
      // ثم تحميل المستندات إذا كانت البيانات الشخصية موجودة
      if (personalDataProvider.personalData?.id != null) {
        documentProvider.loadUserDocuments(personalDataProvider.personalData!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: const Text('رفع المستندات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, child) {
          return Column(
            children: [
              // شريط التقدم
              _buildProgressIndicator(documentProvider),
              
              // المحتوى الرئيسي
              Expanded(
                child: documentProvider.isLoading
                    ? const LoadingWidget(message: 'جاري تحميل المستندات...')
                    : _buildContent(documentProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// بناء شريط التقدم
  Widget _buildProgressIndicator(DocumentProvider documentProvider) {
    final uploadedCount = documentProvider.uploadedDocumentsCount;
    final progress = uploadedCount > 0 ? 1.0 : 0.0; // إما مكتمل أو لا

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المستندات المرفوعة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$uploadedCount مستند',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              uploadedCount > 0 ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            uploadedCount > 0 
                ? 'لديك $uploadedCount مستند مرفوع' 
                : 'لم يتم رفع أي مستندات بعد',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// بناء المحتوى الرئيسي
  Widget _buildContent(DocumentProvider documentProvider) {
    return Consumer<PersonalDataProvider>(
      builder: (context, personalDataProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رسالة الخطأ
              if (documentProvider.errorMessage != null)
                _buildErrorMessage(documentProvider.errorMessage!),

              // رسالة عدم وجود بيانات شخصية
              if (personalDataProvider.personalData?.id == null)
                _buildNoPersonalDataWarning(),

              // نموذج رفع مستند جديد
              _buildUploadForm(),

              const SizedBox(height: 24),

              // قائمة المستندات المرفوعة
              _buildDocumentsList(documentProvider),
            ],
          ),
        );
      },
    );
  }

  /// بناء تحذير عدم وجود بيانات شخصية
  Widget _buildNoPersonalDataWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يجب إرسال البيانات الشخصية أولاً',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'لا يمكن رفع المستندات قبل إرسال البيانات الشخصية. يرجى الذهاب لصفحة البيانات الشخصية وإرسال بياناتك أولاً.',
            style: TextStyle(color: Colors.orange[700]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/personal-data'),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('الذهاب للبيانات الشخصية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء رسالة الخطأ
  Widget _buildErrorMessage(String message) {
    // التحقق من وجود خطأ 404
    final is404Error = message.contains('404') || message.contains('Not Found');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red[700],
                onPressed: () {
                  Provider.of<DocumentProvider>(context, listen: false).clearError();
                },
              ),
            ],
          ),
          if (is404Error) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'هذا خطأ 404 - قد يكون السبب عدم تكوين Supabase بشكل صحيح',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _runQuickDiagnostic,
                icon: const Icon(Icons.healing, size: 16),
                label: const Text('تشخيص المشكلة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// بناء نموذج رفع المستند
  Widget _buildUploadForm() {
    return Consumer<PersonalDataProvider>(
      builder: (context, personalDataProvider, child) {
        final hasPersonalData = personalDataProvider.personalData?.id != null;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رفع مستند جديد',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasPersonalData ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // نوع المستند
                _buildDocumentTypeDropdown(),

                const SizedBox(height: 16),

                // اسم المستند
                _buildDocumentNameField(),

                const SizedBox(height: 16),

                // اختيار الملف
                _buildFileSelection(),

                const SizedBox(height: 16),

                // أزرار الرفع
                _buildUploadButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء قائمة أنواع المستندات
  Widget _buildDocumentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع المستند *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DocumentType>(
          value: _selectedDocumentType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: DocumentType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (DocumentType? value) {
            if (value != null) {
              setState(() {
                _selectedDocumentType = value;
                _isCustomDocumentType = value == DocumentType.custom;
                if (!_isCustomDocumentType) {
                  _customDocumentTypeController.clear();
                }
              });
            }
          },
        ),
        
        // حقل إدخال نوع المستند المخصص
        if (_isCustomDocumentType) ...[
          const SizedBox(height: 12),
          Text(
            'اسم المستند المخصص *',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _customDocumentTypeController,
            decoration: InputDecoration(
              hintText: 'أدخل اسم المستند...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ],
    );
  }

  /// بناء حقل اسم المستند
  Widget _buildDocumentNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف المستند (اختياري)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _documentNameController,
          decoration: InputDecoration(
            hintText: 'أدخل وصف للمستند...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  /// بناء اختيار الملف
  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملف المحدد',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: _selectedFilePath != null
              ? Row(
                  children: [
                    Icon(
                      _getFileIcon(_originalFileName ?? ''),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _originalFileName ?? 'ملف محدد',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                          _originalFileName = null;
                        });
                      },
                    ),
                  ],
                )
              : const Text(
                  'لم يتم تحديد ملف',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      ],
    );
  }

  /// بناء أزرار الرفع
  Widget _buildUploadButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر طريقة الرفع',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUploadOptionButton(
                icon: Icons.photo_library,
                text: 'من المعرض',
                onPressed: _pickFromGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildUploadOptionButton(
                icon: Icons.camera_alt,
                text: 'تصوير',
                onPressed: _takePhoto,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildUploadOptionButton(
                icon: Icons.picture_as_pdf,
                text: 'ملف PDF',
                onPressed: _pickPdfFile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'رفع المستند',
            onPressed: _selectedFilePath != null ? () => _uploadDocument() : () {},
            isLoading: Provider.of<DocumentProvider>(context).isLoading,
            isOutlined: false,
          ),
        ),
      ],
    );
  }

  /// بناء زر خيار الرفع
  Widget _buildUploadOptionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// بناء قائمة المستندات
  Widget _buildDocumentsList(DocumentProvider documentProvider) {
    if (documentProvider.documents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لم يتم رفع أي مستندات بعد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ برفع مستنداتك باستخدام النموذج أعلاه',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المستندات المرفوعة (${documentProvider.documents.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documentProvider.documents.length,
          itemBuilder: (context, index) {
            final document = documentProvider.documents[index];
            return _buildDocumentCard(document, documentProvider);
          },
        ),
      ],
    );
  }

  /// بناء بطاقة المستند
  Widget _buildDocumentCard(
    dynamic document,
    DocumentProvider documentProvider,
  ) {
    // تحديد عنوان المستند
    String documentTitle = document.type.displayName;
    if (document.type == DocumentType.custom && document.description != null) {
      // إذا كان مستند مخصص، استخدم الوصف كعنوان
      documentTitle = document.description!.split(' - ').first;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            _getFileIcon(document.originalFileName),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          documentTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document.originalFileName),
            if (document.description != null && document.type != DocumentType.custom) ...[
              const SizedBox(height: 2),
              Text(
                document.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
                  document.isVerified ? Icons.verified : Icons.pending,
                  size: 14,
                  color: document.isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  document.isVerified ? 'تم التحقق' : 'في الانتظار',
                  style: TextStyle(
                    fontSize: 12,
                    color: document.isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
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
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _confirmDeleteDocument(document, documentProvider),
            ),
          ],
        ),
      ),
    );
  }

  /// اختيار صورة من المعرض
  Future<void> _pickFromGallery() async {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final file = await documentProvider.pickImageFromGallery();
    
    if (file != null) {
      setState(() {
        _selectedFilePath = file.path;
        _originalFileName = path.basename(file.path);
      });
    }
  }

  /// التقاط صورة
  Future<void> _takePhoto() async {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final file = await documentProvider.takePictureWithCamera();
    
    if (file != null) {
      setState(() {
        _selectedFilePath = file.path;
        _originalFileName = path.basename(file.path);
      });
    }
  }

  /// اختيار ملف PDF
  Future<void> _pickPdfFile() async {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    final file = await documentProvider.pickPdfFile();
    
    if (file != null) {
      setState(() {
        _selectedFilePath = file.path;
        _originalFileName = path.basename(file.path);
      });
    }
  }

  /// رفع المستند
  Future<void> _uploadDocument() async {
    if (_selectedFilePath == null || _originalFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد ملف أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // التحقق من المستند المخصص
    if (_selectedDocumentType == DocumentType.custom && 
        _customDocumentTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم المستند المخصص'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final personalDataProvider = Provider.of<PersonalDataProvider>(context, listen: false);
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);

    // التحقق من وجود البيانات الشخصية
    if (personalDataProvider.personalData?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إرسال البيانات الشخصية أولاً قبل رفع المستندات'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      
      // توجيه المستخدم لصفحة البيانات الشخصية
      context.go('/personal-data');
      return;
    }

    String personalDataId = personalDataProvider.personalData!.id!;
    final file = File(_selectedFilePath!);
    
    // تحديد وصف المستند
    String description = _documentNameController.text.trim();
    if (_selectedDocumentType == DocumentType.custom) {
      // إذا كان مستند مخصص، استخدم اسم المستند المخصص كوصف إضافي
      String customName = _customDocumentTypeController.text.trim();
      description = description.isEmpty ? customName : '$customName - $description';
    }

    final success = await documentProvider.uploadDocument(
      file: file,
      originalFileName: _originalFileName!,
      documentType: _selectedDocumentType,
      personalDataId: personalDataId,
      description: description.isEmpty ? null : description,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع المستند بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // مسح النموذج
      setState(() {
        _selectedFilePath = null;
        _originalFileName = null;
        _documentNameController.clear();
        _customDocumentTypeController.clear();
        _isCustomDocumentType = false;
        _selectedDocumentType = DocumentType.personalPhoto;
      });
    }
  }

  /// عرض المستند
  void _viewDocument(dynamic document) async {
    if (document.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رابط المستند غير متاح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // التحقق من نوع الملف
    if (DocumentViewerService.isImageFile(document.originalFileName)) {
      // عرض الصور داخل التطبيق
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DocumentImageViewer(document: document),
        ),
      );
    } else if (DocumentViewerService.isPdfFile(document.originalFileName)) {
      // فتح ملفات PDF في مشغل خارجي
      final success = await DocumentViewerService.openDocument(document);
      
      if (success) {
        DocumentViewerService.showSuccessMessage(
          context, 
          'تم فتح المستند في التطبيق الخارجي'
        );
      } else {
        DocumentViewerService.showErrorMessage(
          context, 
          'لا يمكن فتح المستند. تأكد من وجود تطبيق لقراءة ملفات PDF'
        );
      }
    } else {
      // للملفات الأخرى، فتحها في مشغل خارجي
      final success = await DocumentViewerService.openDocument(document);
      
      if (success) {
        DocumentViewerService.showSuccessMessage(
          context, 
          'تم فتح المستند في التطبيق الخارجي'
        );
      } else {
        DocumentViewerService.showErrorMessage(
          context, 
          'لا يمكن فتح هذا النوع من الملفات'
        );
      }
    }
  }

  /// تأكيد حذف المستند
  void _confirmDeleteDocument(
    dynamic document,
    DocumentProvider documentProvider,
  ) {
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

  /// الحصول على أيقونة الملف
  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      case '.pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.description;
    }
  }

  /// تشغيل التشخيص السريع
  Future<void> _runQuickDiagnostic() async {
    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تشخيص المشكلة...'),
          ],
        ),
      ),
    );

    try {
      // تشغيل التشخيص
      await QuickDiagnostic.runQuickCheck();
      
      // إغلاق مؤشر التحميل
      if (mounted) Navigator.of(context).pop();
      
      // إظهار رسالة للمستخدم
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('نتائج التشخيص'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تم تشغيل التشخيص بنجاح.'),
                SizedBox(height: 8),
                Text(
                  'يرجى فحص وحدة التحكم (Console) لرؤية النتائج التفصيلية.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'إذا رأيت أي ❌ في النتائج، يجب حل تلك المشاكل أولاً.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
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
      
    } catch (e) {
      // إغلاق مؤشر التحميل
      if (mounted) Navigator.of(context).pop();
      
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التشخيص: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
