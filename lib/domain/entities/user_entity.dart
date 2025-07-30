/// كيان المستخدم
class UserEntity {
  final String id;                     // معرف فريد
  final String email;                  // البريد الإلكتروني
  final String? fullName;              // الاسم الكامل
  final String? phoneNumber;           // رقم الهاتف
  final bool isEmailVerified;          // هل تم التحقق من البريد الإلكتروني
  final DateTime createdAt;            // تاريخ الإنشاء
  final DateTime? updatedAt;           // تاريخ آخر تحديث
  final DateTime? lastLoginAt;         // تاريخ آخر تسجيل دخول
  final bool isActive;                 // هل الحساب نشط
  final String? profileImageUrl;       // رابط صورة الملف الشخصي
  final Map<String, dynamic>? metadata; // بيانات إضافية

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.isEmailVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isActive = true,
    this.profileImageUrl,
    this.metadata,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// الحصول على الحروف الأولى من الاسم
  String get initials {
    if (fullName == null || fullName!.isEmpty) {
      return email.substring(0, 2).toUpperCase();
    }
    
    final nameParts = fullName!.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return fullName!.substring(0, 2).toUpperCase();
    }
  }

  /// اسم العرض (الاسم أو البريد الإلكتروني)
  String get displayName {
    return fullName?.isNotEmpty == true ? fullName! : email;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserEntity &&
      other.id == id &&
      other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, fullName: $fullName)';
  }
}
