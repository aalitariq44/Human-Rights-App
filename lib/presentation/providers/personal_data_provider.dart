import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/personal_data_entity.dart';
import '../../domain/entities/enums.dart';
import '../../services/encryption_service.dart';

/// موفر البيانات الشخصية
class PersonalDataProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final EncryptionService _encryptionService = EncryptionService.instance;
  
  PersonalDataEntity? _personalData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  PersonalDataEntity? get personalData => _personalData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _personalData != null;
  
  /// إرسال البيانات الشخصية
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
        'status': DataStatus.submitted.name,
        'created_at': DateTime.now().toIso8601String(),
        'submitted_at': DateTime.now().toIso8601String(),
      };
      
      // إرسال البيانات إلى Supabase
      final response = await _supabase
          .from('personal_data')
          .insert(personalDataMap)
          .select()
          .single();
      
      // تحويل البيانات المُستلمة إلى Entity
      _personalData = await _mapToEntity(response);
      
      // تسجيل النشاط
      await _logActivity('personal_data_submitted', {
        'personal_data_id': response['id'],
        'status': DataStatus.submitted.name,
      });
      
      _setLoading(false);
      return true;
      
    } catch (e) {
      _setError('خطأ في إرسال البيانات: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// جلب البيانات الشخصية للمستخدم الحالي
  Future<void> fetchPersonalData() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('المستخدم غير مسجل الدخول');
        return;
      }
      
      final response = await _supabase
          .from('personal_data')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        _personalData = await _mapToEntity(response.first);
      }
      
      _setLoading(false);
      
    } catch (e) {
      _setError('خطأ في جلب البيانات: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  /// تحديث حالة البيانات
  Future<bool> updateDataStatus(String id, DataStatus status) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _supabase
          .from('personal_data')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      // تحديث البيانات المحلية
      if (_personalData?.id == id) {
        _personalData = _personalData!.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      
      // تسجيل النشاط
      await _logActivity('data_status_updated', {
        'personal_data_id': id,
        'new_status': status.name,
      });
      
      _setLoading(false);
      return true;
      
    } catch (e) {
      _setError('خطأ في تحديث الحالة: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  /// تحويل البيانات من الخريطة إلى Entity
  Future<PersonalDataEntity> _mapToEntity(Map<String, dynamic> data) async {
    // فك تشفير الرقم الوطني
    final decryptedNationalId = await _encryptionService.decrypt(data['national_id']);
    
    return PersonalDataEntity(
      id: data['id'],
      userId: data['user_id'],
      fullNameIraq: data['full_name_iraq'],
      motherName: data['mother_name'],
      currentProvince: data['current_province'],
      birthDate: DateTime.parse(data['birth_date']),
      birthPlace: data['birth_place'],
      phoneNumber: data['phone_number'],
      nationalId: decryptedNationalId,
      nationalIdIssueYear: data['national_id_issue_year'],
      nationalIdIssuer: data['national_id_issuer'],
      fullNameKuwait: data['full_name_kuwait'],
      kuwaitAddress: data['kuwait_address'],
      kuwaitEducationLevel: data['kuwait_education_level'],
      familyMembersCount: data['family_members_count'],
      adultsOver18Count: data['adults_over_18_count'],
      exitMethod: ExitMethod.values.firstWhere(
        (e) => e.name == data['exit_method'],
      ),
      compensationTypes: (data['compensation_types'] as List)
          .map((e) => CompensationType.values.firstWhere((type) => type.name == e))
          .toList(),
      kuwaitJobType: KuwaitJobType.values.firstWhere(
        (e) => e.name == data['kuwait_job_type'],
      ),
      kuwaitOfficialStatus: KuwaitOfficialStatus.values.firstWhere(
        (e) => e.name == data['kuwait_official_status'],
      ),
      rightsRequestTypes: (data['rights_request_types'] as List)
          .map((e) => RightsRequestType.values.firstWhere((type) => type.name == e))
          .toList(),
      hasIraqiAffairsDept: data['has_iraqi_affairs_dept'],
      hasKuwaitImmigration: data['has_kuwait_immigration'],
      hasValidResidence: data['has_valid_residence'],
      hasRedCrossInternational: data['has_red_cross_international'],
      status: DataStatus.values.firstWhere(
        (e) => e.name == data['status'],
      ),
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
      submittedAt: data['submitted_at'] != null 
          ? DateTime.parse(data['submitted_at']) 
          : null,
      notes: data['notes'],
    );
  }
  
  /// تسجيل النشاط
  Future<void> _logActivity(String action, Map<String, dynamic> details) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('activity_logs').insert({
        'user_id': user.id,
        'action': action,
        'details': details,
        'ip_address': 'unknown', // يمكن تحسينه لاحقاً
        'user_agent': 'mobile_app',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // تجاهل أخطاء تسجيل النشاط
      debugPrint('Error logging activity: $e');
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }
  
  void clearData() {
    _personalData = null;
    notifyListeners();
  }
}
