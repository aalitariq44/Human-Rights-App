import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../domain/entities/document_entity.dart';
import '../domain/entities/enums.dart';

/// خدمة إدارة تخزين المستندات في Supabase Storage
class DocumentStorageService {
  static final DocumentStorageService _instance = DocumentStorageService._internal();
  factory DocumentStorageService() => _instance;
  DocumentStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'user-documents';
  final Uuid _uuid = const Uuid();

  /// رفع مستند جديد
  Future<DocumentEntity> uploadDocument({
    required File file,
    required String originalFileName,
    required DocumentType documentType,
    required String personalDataId,
    String? description,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // ضغط الملف إذا كان صورة
      File processedFile = await _processFile(file);
      
      // إنشاء مسار الملف في Storage
      final fileName = _generateFileName(originalFileName, documentType);
      final filePath = _generateFilePath(user.id, documentType, fileName);
      
      // رفع الملف إلى Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .upload(filePath, processedFile);

      // الحصول على رابط الملف
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      // الحصول على معلومات الملف
      final fileStats = await processedFile.stat();
      final mimeType = _getMimeType(originalFileName);

      // إنشاء كيان المستند
      final document = DocumentEntity(
        id: _uuid.v4(),
        userId: user.id,
        personalDataId: personalDataId,
        type: documentType,
        fileName: fileName,
        originalFileName: originalFileName,
        filePath: filePath,
        fileUrl: publicUrl,
        fileSize: fileStats.size,
        mimeType: mimeType,
        description: description,
        isRequired: _isRequiredDocument(documentType),
        createdAt: DateTime.now(),
      );

      // حفظ معلومات المستند في قاعدة البيانات
      await _saveDocumentMetadata(document);

      return document;
    } catch (e) {
      throw Exception('فشل في رفع المستند: ${e.toString()}');
    }
  }

  /// حذف مستند
  Future<void> deleteDocument(String documentId, String filePath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // حذف الملف من Storage
      await _supabase.storage
          .from(_bucketName)
          .remove([filePath]);

      // حذف معلومات المستند من قاعدة البيانات
      await _supabase
          .from('documents')
          .delete()
          .eq('id', documentId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('فشل في حذف المستند: ${e.toString()}');
    }
  }

  /// الحصول على مستندات المستخدم
  Future<List<DocumentEntity>> getUserDocuments(String personalDataId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final response = await _supabase
          .from('documents')
          .select()
          .eq('user_id', user.id)
          .eq('personal_data_id', personalDataId)
          .order('created_at', ascending: false);

      return response.map<DocumentEntity>((data) => _mapToDocumentEntity(data)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستندات: ${e.toString()}');
    }
  }

  /// معالجة الملف (ضغط الصور)
  Future<File> _processFile(File file) async {
    final extension = path.extension(file.path).toLowerCase();
    
    // ضغط الصور فقط
    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      return await _compressImage(file);
    }
    
    return file;
  }

  /// ضغط الصورة
  Future<File> _compressImage(File file) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/compressed_${path.basename(file.path)}',
        quality: 85,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );
      
      if (compressedFile != null) {
        return File(compressedFile.path);
      } else {
        return file;
      }
    } catch (e) {
      // في حالة فشل الضغط، نعيد الملف الأصلي
      return file;
    }
  }

  /// إنشاء اسم فريد للملف
  String _generateFileName(String originalFileName, DocumentType documentType) {
    final extension = path.extension(originalFileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = _uuid.v4().split('-').first;
    return '${documentType.name}_${timestamp}_$uniqueId$extension';
  }

  /// إنشاء مسار الملف في Storage
  String _generateFilePath(String userId, DocumentType documentType, String fileName) {
    final folderMap = {
      DocumentType.personalPhoto: 'profile',
      DocumentType.iraqiAffairsDept: 'official-documents/iraqi-affairs',
      DocumentType.kuwaitImmigration: 'official-documents/kuwait-immigration',
      DocumentType.validResidence: 'official-documents/residence-permit',
      DocumentType.redCrossInternational: 'official-documents/red-cross',
      DocumentType.other: 'official-documents/other',
    };

    final folder = folderMap[documentType] ?? 'official-documents/other';
    return '$userId/$folder/$fileName';
  }

  /// الحصول على نوع MIME
  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// التحقق من أن المستند مطلوب
  bool _isRequiredDocument(DocumentType documentType) {
    // جميع أنواع المستندات مطلوبة باستثناء "أخرى"
    return documentType != DocumentType.other;
  }

  /// حفظ معلومات المستند في قاعدة البيانات
  Future<void> _saveDocumentMetadata(DocumentEntity document) async {
    await _supabase.from('documents').insert({
      'id': document.id,
      'user_id': document.userId,
      'personal_data_id': document.personalDataId,
      'type': document.type.name,
      'file_name': document.fileName,
      'original_file_name': document.originalFileName,
      'file_path': document.filePath,
      'file_url': document.fileUrl,
      'file_size': document.fileSize,
      'mime_type': document.mimeType,
      'description': document.description,
      'is_required': document.isRequired,
      'is_verified': document.isVerified,
      'created_at': document.createdAt.toIso8601String(),
    });
  }

  /// تحويل البيانات إلى كيان مستند
  DocumentEntity _mapToDocumentEntity(Map<String, dynamic> data) {
    return DocumentEntity(
      id: data['id'],
      userId: data['user_id'],
      personalDataId: data['personal_data_id'],
      type: DocumentType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => DocumentType.other,
      ),
      fileName: data['file_name'],
      originalFileName: data['original_file_name'],
      filePath: data['file_path'],
      fileUrl: data['file_url'],
      fileSize: data['file_size'],
      mimeType: data['mime_type'],
      description: data['description'],
      isRequired: data['is_required'] ?? false,
      isVerified: data['is_verified'] ?? false,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
      verifiedBy: data['verified_by'],
      verifiedAt: data['verified_at'] != null 
          ? DateTime.parse(data['verified_at']) 
          : null,
      rejectionReason: data['rejection_reason'],
    );
  }

  /// التحقق من صحة نوع الملف
  bool isValidFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    const validExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    return validExtensions.contains(extension);
  }

  /// التحقق من صحة حجم الملف
  bool isValidFileSize(int fileSize, String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      // الصور: حد أقصى 5 MB
      return fileSize <= 5 * 1024 * 1024;
    } else if (extension == '.pdf') {
      // ملفات PDF: حد أقصى 10 MB
      return fileSize <= 10 * 1024 * 1024;
    }
    
    return false;
  }
}
