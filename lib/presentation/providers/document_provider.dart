import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/enums.dart';
import '../../services/document_storage_service.dart';

/// مقدم إدارة المستندات
class DocumentProvider extends ChangeNotifier {
  final DocumentStorageService _storageService = DocumentStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  // حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // رسائل الخطأ
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // قائمة المستندات
  List<DocumentEntity> _documents = [];
  List<DocumentEntity> get documents => _documents;

  // المستند المحدد حالياً
  DocumentEntity? _selectedDocument;
  DocumentEntity? get selectedDocument => _selectedDocument;

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تعيين رسالة خطأ
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// اختيار صورة من المعرض
  Future<File?> pickImageFromGallery() async {
    try {
      // طلب إذن الوصول للمعرض
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _setError('يرجى السماح بالوصول إلى معرض الصور');
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // التحقق من صحة الملف
        if (!_validateFile(file)) {
          return null;
        }
        
        return file;
      }
      
      return null;
    } catch (e) {
      _setError('فشل في اختيار الصورة: ${e.toString()}');
      return null;
    }
  }

  /// التقاط صورة بالكاميرا
  Future<File?> takePictureWithCamera() async {
    try {
      // طلب إذن الوصول للكاميرا
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _setError('يرجى السماح بالوصول إلى الكاميرا');
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // التحقق من صحة الملف
        if (!_validateFile(file)) {
          return null;
        }
        
        return file;
      }
      
      return null;
    } catch (e) {
      _setError('فشل في التقاط الصورة: ${e.toString()}');
      return null;
    }
  }

  /// اختيار ملف PDF
  Future<File?> pickPdfFile() async {
    try {
      // طلب إذن الوصول للملفات
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _setError('يرجى السماح بالوصول إلى الملفات');
        return null;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        
        // التحقق من صحة الملف
        if (!_validateFile(file)) {
          return null;
        }
        
        return file;
      }
      
      return null;
    } catch (e) {
      _setError('فشل في اختيار الملف: ${e.toString()}');
      return null;
    }
  }

  /// رفع مستند
  Future<bool> uploadDocument({
    required File file,
    required String originalFileName,
    required DocumentType documentType,
    required String personalDataId,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final document = await _storageService.uploadDocument(
        file: file,
        originalFileName: originalFileName,
        documentType: documentType,
        personalDataId: personalDataId,
        description: description,
      );

      // إضافة المستند إلى القائمة
      _documents.insert(0, document);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف مستند
  Future<bool> deleteDocument(DocumentEntity document) async {
    try {
      _setLoading(true);
      _setError(null);

      await _storageService.deleteDocument(
        document.id!,
        document.filePath,
      );

      // إزالة المستند من القائمة
      _documents.removeWhere((doc) => doc.id == document.id);
      
      // إزالة التحديد إذا كان هذا المستند محدد
      if (_selectedDocument?.id == document.id) {
        _selectedDocument = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// جلب مستندات المستخدم
  Future<void> loadUserDocuments(String personalDataId) async {
    try {
      _setLoading(true);
      _setError(null);

      _documents = await _storageService.getUserDocuments(personalDataId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// تحديد مستند
  void selectDocument(DocumentEntity document) {
    _selectedDocument = document;
    notifyListeners();
  }

  /// إلغاء تحديد المستند
  void clearSelection() {
    _selectedDocument = null;
    notifyListeners();
  }

  /// التحقق من صحة الملف
  bool _validateFile(File file) {
    final fileName = file.path.split('/').last;
    final fileStat = file.statSync();

    // التحقق من نوع الملف
    if (!_storageService.isValidFileType(fileName)) {
      _setError('نوع الملف غير مدعوم. يُسمح فقط بـ JPG، PNG، PDF');
      return false;
    }

    // التحقق من حجم الملف
    if (!_storageService.isValidFileSize(fileStat.size, fileName)) {
      final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                      fileName.toLowerCase().endsWith('.jpeg') || 
                      fileName.toLowerCase().endsWith('.png');
      final maxSize = isImage ? '5 MB' : '10 MB';
      _setError('حجم الملف كبير جداً. الحد الأقصى هو $maxSize');
      return false;
    }

    return true;
  }

  /// الحصول على المستندات حسب النوع
  List<DocumentEntity> getDocumentsByType(DocumentType type) {
    return _documents.where((doc) => doc.type == type).toList();
  }

  /// التحقق من وجود مستند من نوع معين
  bool hasDocumentOfType(DocumentType type) {
    return _documents.any((doc) => doc.type == type);
  }

  /// الحصول على عدد المستندات المرفوعة
  int get uploadedDocumentsCount => _documents.length;

  /// الحصول على عدد المستندات المطلوبة
  int get requiredDocumentsCount {
    return DocumentType.values.where((type) => type != DocumentType.other).length;
  }

  /// التحقق من اكتمال رفع المستندات المطلوبة
  bool get areRequiredDocumentsComplete {
    final requiredTypes = DocumentType.values.where((type) => type != DocumentType.other);
    
    for (final type in requiredTypes) {
      if (!hasDocumentOfType(type)) {
        return false;
      }
    }
    
    return true;
  }

  /// الحصول على نسبة الإكمال
  double get completionPercentage {
    final requiredTypes = DocumentType.values.where((type) => type != DocumentType.other);
    final uploadedRequiredCount = requiredTypes.where(hasDocumentOfType).length;
    
    return uploadedRequiredCount / requiredTypes.length;
  }

  /// مسح جميع البيانات
  void clear() {
    _documents.clear();
    _selectedDocument = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
