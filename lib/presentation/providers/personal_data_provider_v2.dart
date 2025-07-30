import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/personal_data_entity.dart';
import '../../domain/entities/enums.dart';
import '../../services/encryption_service.dart';

/// مقدم البيانات الشخصية المحسن - يدعم الهيكل الجديد
class PersonalDataProviderV2 extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final EncryptionService _encryptionService = EncryptionService();
  
  // حالة النموذج
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  
  // بيانات النموذج
  PersonalDataEntity? _personalData;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PersonalDataEntity? get personalData => _personalData;
  int get currentStep => _currentStep;
  bool get hasData => _personalData != null;
  
  /// تحديث خطوة النموذج الحالية
  void updateCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
  
  /// حفظ البيانات الشخصية الجديدة
  Future<bool> saveNewPersonalData({
    required String fullNameIraq,
    required String motherName,
    required String currentProvince,
    required DateTime birthDate,
    required String birthPlace,
    required String phoneNumber,
    required String nationalId,
    required int nationalIdIssueYear,
    required String nationalIdIssuer,
    required String fullNameKuwait,
    required String kuwaitAddress,
    required String kuwaitEducationLevel,
    required int familyMembersCount,
    required int adultsOver18Count,
    required ExitMethod exitMethod,
    required List<CompensationType> compensationTypes,
    required KuwaitJobType kuwaitJobType,
    required KuwaitOfficialStatus kuwaitOfficialStatus,
    required List<RightsRequestType> rightsRequestTypes,
    required bool hasIraqiAffairsDept,
    required bool hasKuwaitImmigration,
    required bool hasValidResidence,
    required bool hasRedCrossInternational,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('المستخدم غير مسجل الدخول');
        return false;
      }
      
      // إنشاء كيان البيانات الشخصية
      final personalData = PersonalDataEntity(
        fullNameIraq: fullNameIraq,
        motherName: motherName,
        currentProvince: currentProvince,
        birthDate: birthDate,
        birthPlace: birthPlace,
        phoneNumber: phoneNumber,
        nationalId: nationalId,
        nationalIdIssueYear: nationalIdIssueYear,
        nationalIdIssuer: nationalIdIssuer,
        fullNameKuwait: fullNameKuwait,
        kuwaitAddress: kuwaitAddress,
        kuwaitEducationLevel: kuwaitEducationLevel,
        familyMembersCount: familyMembersCount,
        adultsOver18Count: adultsOver18Count,
        exitMethod: exitMethod,
        compensationTypes: compensationTypes,
        kuwaitJobType: kuwaitJobType,
        kuwaitOfficialStatus: kuwaitOfficialStatus,
        rightsRequestTypes: rightsRequestTypes,
        hasIraqiAffairsDept: hasIraqiAffairsDept,
        hasKuwaitImmigration: hasKuwaitImmigration,
        hasValidResidence: hasValidResidence,
        hasRedCrossInternational: hasRedCrossInternational,
        userId: user.id,
        status: DataStatus.draft,
        createdAt: DateTime.now(),
        notes: notes,
      );
      
      // تشفير البيانات الحساسة
      final encryptedData = await _encryptPersonalData(personalData);
      
      // إعداد البيانات للحفظ
      final dataToSave = {
        'user_id': user.id,
        'encrypted_data': encryptedData,
        'submission_date': DateTime.now().toIso8601String(),
        'status': 'submitted',
        'form_version': '2.0',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // حفظ البيانات في قاعدة البيانات
      await _supabase
          .from('personal_data_submissions_v2')
          .insert(dataToSave);
      
      _personalData = personalData;
      _setLoading(false);
      return true;
      
    } catch (e) {
      _setLoading(false);
      _setError('حدث خطأ أثناء حفظ البيانات: ${e.toString()}');
      return false;
    }
  }
  
  /// إرسال البيانات الشخصية (متوافق مع الكود الحالي)
  Future<bool> submitPersonalData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('المستخدم غير مسجل الدخول');
        return false;
      }
      
      // تشفير الرقم الوطني
      final encryptedNationalId = await _encryptionService.encrypt(data['nationalId']);
      
      // إعداد البيانات للإرسال
      final personalDataMap = {
        'user_id': user.id,
        'full_name_iraq': data['fullNameIraq'],
        'mother_name': data['motherName'],
        'current_province': data['currentProvince'],
        'birth_date': data['birthDate'],
        'birth_place': data['birthPlace'],
        'phone_number': data['phoneNumber'],
        'national_id': encryptedNationalId,
        'national_id_issue_year': data['nationalIdIssueYear'],
        'national_id_issuer': data['nationalIdIssuer'],
        'full_name_kuwait': data['fullNameKuwait'],
        'kuwait_address': data['kuwaitAddress'],
        'kuwait_education_level': data['kuwaitEducationLevel'],
        'family_members_count': data['familyMembersCount'],
        'adults_over_18_count': data['adultsOver18Count'],
        'exit_method': data['exitMethod'],
        'compensation_types': data['compensationTypes'],
        'kuwait_job_type': data['kuwaitJobType'],
        'kuwait_official_status': data['kuwaitOfficialStatus'],
        'rights_request_types': data['rightsRequestTypes'],
        'has_iraqi_affairs_dept': data['hasIraqiAffairsDept'],
        'has_kuwait_immigration': data['hasKuwaitImmigration'],
        'has_valid_residence': data['hasValidResidence'],
        'has_red_cross_international': data['hasRedCrossInternational'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // حفظ البيانات في قاعدة البيانات
      await _supabase
          .from('personal_data_submissions')
          .insert(personalDataMap);
      
      _setLoading(false);
      return true;
      
    } catch (e) {
      _setLoading(false);
      _setError('حدث خطأ أثناء إرسال البيانات: ${e.toString()}');
      return false;
    }
  }
  
  /// تشفير البيانات الشخصية
  Future<String> _encryptPersonalData(PersonalDataEntity data) async {
    final jsonData = {
      'fullNameIraq': data.fullNameIraq,
      'motherName': data.motherName,
      'currentProvince': data.currentProvince,
      'birthDate': data.birthDate.toIso8601String(),
      'birthPlace': data.birthPlace,
      'phoneNumber': data.phoneNumber,
      'nationalId': data.nationalId,
      'nationalIdIssueYear': data.nationalIdIssueYear,
      'nationalIdIssuer': data.nationalIdIssuer,
      'fullNameKuwait': data.fullNameKuwait,
      'kuwaitAddress': data.kuwaitAddress,
      'kuwaitEducationLevel': data.kuwaitEducationLevel,
      'familyMembersCount': data.familyMembersCount,
      'adultsOver18Count': data.adultsOver18Count,
      'exitMethod': data.exitMethod.name,
      'compensationTypes': data.compensationTypes.map((e) => e.name).toList(),
      'kuwaitJobType': data.kuwaitJobType.name,
      'kuwaitOfficialStatus': data.kuwaitOfficialStatus.name,
      'rightsRequestTypes': data.rightsRequestTypes.map((e) => e.name).toList(),
      'hasIraqiAffairsDept': data.hasIraqiAffairsDept,
      'hasKuwaitImmigration': data.hasKuwaitImmigration,
      'hasValidResidence': data.hasValidResidence,
      'hasRedCrossInternational': data.hasRedCrossInternational,
      'notes': data.notes,
    };
    
    return await _encryptionService.encrypt(jsonData.toString());
  }
  
  /// التحقق من صحة البيانات في خطوة معينة
  bool validateStep(int step) {
    if (_personalData == null) return false;
    
    switch (step) {
      case 0: // البيانات الأساسية
        return _personalData!.fullNameIraq.isNotEmpty &&
               _personalData!.motherName.isNotEmpty &&
               _personalData!.phoneNumber.isNotEmpty;
               
      case 1: // بيانات البطاقة الوطنية
        return _personalData!.nationalId.isNotEmpty;
               
      case 2: // بيانات الكويت
        return _personalData!.fullNameKuwait.isNotEmpty;
        
      case 3: // الخيارات
        return _personalData!.compensationTypes.isNotEmpty;
        
      case 4: // المستندات
        return true; // اختياري
        
      default:
        return false;
    }
  }
  
  /// إعادة تعيين البيانات
  void resetData() {
    _personalData = null;
    _currentStep = 0;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// تعيين رسالة الخطأ
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// مسح رسالة الخطأ
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// مسح رسالة الخطأ (دالة عامة)
  void clearError() {
    _clearError();
  }
}
