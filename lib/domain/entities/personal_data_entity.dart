import 'enums.dart';

/// كيان البيانات الشخصية
class PersonalDataEntity {
  // البيانات الأساسية
  final String fullNameIraq;           // الاسم الرباعي واللقب في العراق
  final String motherName;             // اسم الأم
  final String currentProvince;        // المحافظة حالياً
  final DateTime birthDate;            // تاريخ الميلاد
  final String birthPlace;             // مكان الميلاد
  final String phoneNumber;            // رقم الهاتف
  
  // بيانات البطاقة الوطنية
  final String nationalId;             // رقم البطاقة الوطنية (مشفر)
  final int nationalIdIssueYear;       // سنة الإصدار
  final String nationalIdIssuer;       // جهة الإصدار
  
  // بيانات الكويت السابقة
  final String fullNameKuwait;         // الاسم الرباعي واللقب في دولة الكويت سابقاً
  final String kuwaitAddress;          // عنوان السكن في دولة الكويت سابقاً
  final String kuwaitEducationLevel;   // التحصيل الدراسي في الكويت
  final int familyMembersCount;        // عدد أفراد الأسرة حال الخروج من الكويت
  final int adultsOver18Count;         // عدد من تم الـ18 عام حال الخروج من الكويت
  
  // خيارات متعددة
  final ExitMethod exitMethod;         // طريقة الخروج من دولة الكويت
  final List<CompensationType> compensationTypes; // نوع طلب التعويض
  final KuwaitJobType kuwaitJobType;   // طبيعة العمل في دولة الكويت سابقاً
  final KuwaitOfficialStatus kuwaitOfficialStatus; // الوضع الرسمي بالكويت
  final List<RightsRequestType> rightsRequestTypes; // نوع طلب الحقوق
  
  // المستمسكات الثبوتية
  final bool hasIraqiAffairsDept;      // دائرة شؤون العراقي
  final bool hasKuwaitImmigration;     // منفذ الهجرة الكويتية
  final bool hasValidResidence;        // إقامة سارية المفعول
  final bool hasRedCrossInternational; // الصليب الأحمر الدولي
  
  // معلومات إضافية
  final String? id;                    // معرف فريد
  final String userId;                 // معرف المستخدم
  final DataStatus status;             // حالة البيانات
  final DateTime createdAt;            // تاريخ الإنشاء
  final DateTime? updatedAt;           // تاريخ آخر تحديث
  final DateTime? submittedAt;         // تاريخ الإرسال
  final String? notes;                 // ملاحظات

  const PersonalDataEntity({
    required this.fullNameIraq,
    required this.motherName,
    required this.currentProvince,
    required this.birthDate,
    required this.birthPlace,
    required this.phoneNumber,
    required this.nationalId,
    required this.nationalIdIssueYear,
    required this.nationalIdIssuer,
    required this.fullNameKuwait,
    required this.kuwaitAddress,
    required this.kuwaitEducationLevel,
    required this.familyMembersCount,
    required this.adultsOver18Count,
    required this.exitMethod,
    required this.compensationTypes,
    required this.kuwaitJobType,
    required this.kuwaitOfficialStatus,
    required this.rightsRequestTypes,
    required this.hasIraqiAffairsDept,
    required this.hasKuwaitImmigration,
    required this.hasValidResidence,
    required this.hasRedCrossInternational,
    this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.notes,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  PersonalDataEntity copyWith({
    String? fullNameIraq,
    String? motherName,
    String? currentProvince,
    DateTime? birthDate,
    String? birthPlace,
    String? phoneNumber,
    String? nationalId,
    int? nationalIdIssueYear,
    String? nationalIdIssuer,
    String? fullNameKuwait,
    String? kuwaitAddress,
    String? kuwaitEducationLevel,
    int? familyMembersCount,
    int? adultsOver18Count,
    ExitMethod? exitMethod,
    List<CompensationType>? compensationTypes,
    KuwaitJobType? kuwaitJobType,
    KuwaitOfficialStatus? kuwaitOfficialStatus,
    List<RightsRequestType>? rightsRequestTypes,
    bool? hasIraqiAffairsDept,
    bool? hasKuwaitImmigration,
    bool? hasValidResidence,
    bool? hasRedCrossInternational,
    String? id,
    String? userId,
    DataStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    String? notes,
  }) {
    return PersonalDataEntity(
      fullNameIraq: fullNameIraq ?? this.fullNameIraq,
      motherName: motherName ?? this.motherName,
      currentProvince: currentProvince ?? this.currentProvince,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      nationalIdIssueYear: nationalIdIssueYear ?? this.nationalIdIssueYear,
      nationalIdIssuer: nationalIdIssuer ?? this.nationalIdIssuer,
      fullNameKuwait: fullNameKuwait ?? this.fullNameKuwait,
      kuwaitAddress: kuwaitAddress ?? this.kuwaitAddress,
      kuwaitEducationLevel: kuwaitEducationLevel ?? this.kuwaitEducationLevel,
      familyMembersCount: familyMembersCount ?? this.familyMembersCount,
      adultsOver18Count: adultsOver18Count ?? this.adultsOver18Count,
      exitMethod: exitMethod ?? this.exitMethod,
      compensationTypes: compensationTypes ?? this.compensationTypes,
      kuwaitJobType: kuwaitJobType ?? this.kuwaitJobType,
      kuwaitOfficialStatus: kuwaitOfficialStatus ?? this.kuwaitOfficialStatus,
      rightsRequestTypes: rightsRequestTypes ?? this.rightsRequestTypes,
      hasIraqiAffairsDept: hasIraqiAffairsDept ?? this.hasIraqiAffairsDept,
      hasKuwaitImmigration: hasKuwaitImmigration ?? this.hasKuwaitImmigration,
      hasValidResidence: hasValidResidence ?? this.hasValidResidence,
      hasRedCrossInternational: hasRedCrossInternational ?? this.hasRedCrossInternational,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      notes: notes ?? this.notes,
    );
  }

  /// التحقق من اكتمال البيانات الأساسية
  bool get isBasicDataComplete {
    return fullNameIraq.isNotEmpty &&
           motherName.isNotEmpty &&
           currentProvince.isNotEmpty &&
           birthPlace.isNotEmpty &&
           phoneNumber.isNotEmpty;
  }

  /// التحقق من اكتمال بيانات البطاقة الوطنية
  bool get isNationalIdDataComplete {
    return nationalId.isNotEmpty &&
           nationalIdIssueYear > 0 &&
           nationalIdIssuer.isNotEmpty;
  }

  /// التحقق من اكتمال بيانات الكويت
  bool get isKuwaitDataComplete {
    return fullNameKuwait.isNotEmpty &&
           kuwaitAddress.isNotEmpty &&
           kuwaitEducationLevel.isNotEmpty &&
           familyMembersCount > 0 &&
           adultsOver18Count >= 0;
  }

  /// التحقق من اكتمال جميع البيانات
  bool get isComplete {
    return isBasicDataComplete &&
           isNationalIdDataComplete &&
           isKuwaitDataComplete &&
           compensationTypes.isNotEmpty &&
           rightsRequestTypes.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PersonalDataEntity &&
      other.id == id &&
      other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'PersonalDataEntity(id: $id, fullNameIraq: $fullNameIraq, status: $status)';
  }
}
