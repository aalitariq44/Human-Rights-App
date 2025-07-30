import 'enums.dart';

/// كيان المستند
class DocumentEntity {
  final String? id;                    // معرف فريد
  final String userId;                 // معرف المستخدم
  final String personalDataId;         // معرف البيانات الشخصية
  final DocumentType type;             // نوع المستند
  final String fileName;               // اسم الملف
  final String originalFileName;       // اسم الملف الأصلي
  final String filePath;               // مسار الملف
  final String? fileUrl;               // رابط الملف
  final int fileSize;                  // حجم الملف (بالبايت)
  final String mimeType;               // نوع MIME
  final String? description;           // وصف المستند
  final bool isRequired;               // هل المستند مطلوب
  final bool isVerified;               // هل تم التحقق من المستند
  final DateTime createdAt;            // تاريخ الإنشاء
  final DateTime? updatedAt;           // تاريخ آخر تحديث
  final String? verifiedBy;            // من قام بالتحقق
  final DateTime? verifiedAt;          // تاريخ التحقق
  final String? rejectionReason;       // سبب الرفض (إن وجد)

  const DocumentEntity({
    this.id,
    required this.userId,
    required this.personalDataId,
    required this.type,
    required this.fileName,
    required this.originalFileName,
    required this.filePath,
    this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    this.description,
    required this.isRequired,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  DocumentEntity copyWith({
    String? id,
    String? userId,
    String? personalDataId,
    DocumentType? type,
    String? fileName,
    String? originalFileName,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    String? description,
    bool? isRequired,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personalDataId: personalDataId ?? this.personalDataId,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  /// التحقق من أن الملف صورة
  bool get isImage {
    return mimeType.startsWith('image/');
  }

  /// التحقق من أن الملف PDF
  bool get isPdf {
    return mimeType == 'application/pdf';
  }

  /// الحصول على حجم الملف بتنسيق مقروء
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// الحصول على امتداد الملف
  String get fileExtension {
    return fileName.split('.').last.toLowerCase();
  }

  /// التحقق من صحة نوع الملف
  bool get isValidFileType {
    const validImageExtensions = ['jpg', 'jpeg', 'png'];
    const validDocumentExtensions = ['pdf'];
    
    final extension = fileExtension;
    
    if (isImage) {
      return validImageExtensions.contains(extension);
    } else if (isPdf) {
      return validDocumentExtensions.contains(extension);
    }
    
    return false;
  }

  /// التحقق من صحة حجم الملف
  bool get isValidFileSize {
    const maxImageSize = 5 * 1024 * 1024; // 5 MB
    const maxDocumentSize = 10 * 1024 * 1024; // 10 MB
    
    if (isImage) {
      return fileSize <= maxImageSize;
    } else if (isPdf) {
      return fileSize <= maxDocumentSize;
    }
    
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DocumentEntity &&
      other.id == id &&
      other.userId == userId &&
      other.personalDataId == personalDataId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ personalDataId.hashCode;

  @override
  String toString() {
    return 'DocumentEntity(id: $id, type: $type, fileName: $fileName)';
  }
}
