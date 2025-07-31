/// طرق الخروج من دولة الكويت
enum ExitMethod {
  voluntaryDeparture('مغادرة طوعية'),
  forcedDeportation('إبعاد قسري'),
  landSmuggling('تهريب عن طريق البر'),
  beforeArmyWithdrawal('قبل انسحاب الجيش');

  const ExitMethod(this.displayName);
  final String displayName;
}

/// أنواع التعويض
enum CompensationType {
  governmentJobServices('خدمات جراء الوظيفة الحكومية'),
  personalFurnitureProperty('أثاث وممتلكات شخصية'),
  moralCompensation('تعويض معنوي'),
  prisonCompensation('تعويض عن السجن بلا تهمة');

  const CompensationType(this.displayName);
  final String displayName;
}

/// طبيعة العمل في الكويت
enum KuwaitJobType {
  civilEmployee('موظف مدني'),
  militaryEmployee('موظف عسكري'),
  student('طالب'),
  freelance('أعمال حرة');

  const KuwaitJobType(this.displayName);
  final String displayName;
}

/// الوضع الرسمي في الكويت
enum KuwaitOfficialStatus {
  resident('مقيم'),
  bidoon('بدون');

  const KuwaitOfficialStatus(this.displayName);
  final String displayName;
}

/// أنواع طلب الحقوق
enum RightsRequestType {
  pensionSalary('راتب تقاعدي'),
  residentialLand('قطعة أرض سكنية');

  const RightsRequestType(this.displayName);
  final String displayName;
}

/// حالة البيانات
enum DataStatus {
  draft('مسودة'),
  submitted('مُرسلة'),
  underReview('قيد المراجعة'),
  approved('مُوافق عليها'),
  rejected('مرفوضة'),
  completed('مكتملة');

  const DataStatus(this.displayName);
  final String displayName;
}

/// نوع المستند
enum DocumentType {
  personalPhoto('الصورة الشخصية'),
  iraqiAffairsDept('وثائق دائرة شؤون العراقي'),
  kuwaitImmigration('وثائق منفذ الهجرة الكويتية'),
  validResidence('إقامة سارية المفعول'),
  redCrossInternational('وثائق الصليب الأحمر الدولي'),
  passportCopy('نسخة من الجواز'),
  birthCertificate('شهادة الميلاد'),
  marriageCertificate('شهادة الزواج'),
  educationCertificate('الشهادات التعليمية'),
  workContract('عقد العمل'),
  medicalReport('التقارير الطبية'),
  bankStatement('كشف حساب بنكي'),
  propertyDocuments('وثائق الممتلكات'),
  custom('مستند مخصص'),
  other('أخرى');

  const DocumentType(this.displayName);
  final String displayName;
}
