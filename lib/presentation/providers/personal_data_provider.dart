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
        _setError('المستخدم غير مسجل للدخول. يرجى تسجيل الدخول أولاً.');
        return false;
      }
      
      // تشفير الرقم الوطني
      final encryptedNationalId = await _encryptionService.encrypt(data['nationalId']);
      
      // إعداد البيانات للإرسال وفقاً لهيكل قاعدة البيانات
      final personalDataMap = {
        'user_id': user.id,
        'full_name_iraq': data['fullNameIraq']?.toString().trim(),
        'mother_name': data['motherName']?.toString().trim(),
        'current_province': data['currentProvince']?.toString().trim(),
        'birth_date': data['birthDate']?.toString(),
        'birth_place': data['birthPlace']?.toString().trim(),
        'phone_number': data['phoneNumber']?.toString().trim(),
        'national_id_encrypted': encryptedNationalId,
        'national_id_issue_year': data['nationalIdIssueYear'] is int 
            ? data['nationalIdIssueYear'] 
            : int.tryParse(data['nationalIdIssueYear']?.toString() ?? ''),
        'national_id_issuer': data['nationalIdIssuer']?.toString().trim(),
        'full_name_kuwait': data['fullNameKuwait']?.toString().trim(),
        'kuwait_address': data['kuwaitAddress']?.toString().trim(),
        'kuwait_education_level': data['kuwaitEducationLevel']?.toString().trim(),
        'family_members_count': data['familyMembersCount'] is int 
            ? data['familyMembersCount'] 
            : int.tryParse(data['familyMembersCount']?.toString() ?? '0') ?? 0,
        'adults_over_18_count': data['adultsOver18Count'] is int 
            ? data['adultsOver18Count'] 
            : int.tryParse(data['adultsOver18Count']?.toString() ?? '0') ?? 0,
        'exit_method': data['exitMethod']?.toString(),
        'compensation_type': data['compensationTypes'] is List 
            ? (data['compensationTypes'] as List).map((e) => e.toString()).toList()
            : [],
        'kuwait_job_type': data['kuwaitJobType']?.toString(),
        'kuwait_official_status': data['kuwaitOfficialStatus']?.toString(),
        'rights_request_type': data['rightsRequestTypes'] is List 
            ? (data['rightsRequestTypes'] as List).map((e) => e.toString()).toList()
            : [],
      };
      
      // التحقق من البيانات المطلوبة
      final requiredFields = [
        'full_name_iraq', 'mother_name', 'current_province', 
        'birth_date', 'birth_place', 'phone_number', 
        'national_id_encrypted', 'national_id_issue_year', 'national_id_issuer'
      ];
      
      for (final field in requiredFields) {
        if (personalDataMap[field] == null || 
            (personalDataMap[field] is String && (personalDataMap[field] as String).isEmpty)) {
          _setError('يرجى ملء جميع البيانات المطلوبة. الحقل المفقود: ${_getFieldArabicName(field)}');
          _setLoading(false);
          return false;
        }
      }
      
      // إرسال البيانات إلى Supabase
      final response = await _supabase
          .from('user_personal_data')
          .insert(personalDataMap)
          .select()
          .single();
      
      // تحويل البيانات المُستلمة إلى Entity
      _personalData = await _mapToEntity(response);
      
      // تسجيل النشاط
      await _logActivity('personal_data_submitted', {
        'personal_data_id': response['id'],
      });
      
      _setLoading(false);
      return true;
      
    } on PostgrestException catch (e) {
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      final errorMessage = _handleGeneralError(e);
      _setError(errorMessage);
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
          .from('user_personal_data')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        _personalData = await _mapToEntity(response.first);
      }
      
      _setLoading(false);
      
    } on PostgrestException catch (e) {
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
    } catch (e) {
      final errorMessage = _handleGeneralError(e);
      _setError(errorMessage);
      _setLoading(false);
    }
  }
  
  /// تحديث حالة البيانات
  Future<bool> updateDataStatus(String id, DataStatus status) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _supabase
          .from('user_personal_data')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      // تحديث البيانات المحلية
      if (_personalData?.id == id) {
        _personalData = _personalData!.copyWith(
          updatedAt: DateTime.now(),
        );
      }
      
      // تسجيل النشاط
      await _logActivity('data_status_updated', {
        'personal_data_id': id,
      });
      
      _setLoading(false);
      return true;
      
    } on PostgrestException catch (e) {
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      final errorMessage = _handleGeneralError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  /// تحويل البيانات من الخريطة إلى Entity
  Future<PersonalDataEntity> _mapToEntity(Map<String, dynamic> data) async {
    // فك تشفير الرقم الوطني
    final decryptedNationalId = await _encryptionService.decrypt(data['national_id_encrypted']);
    
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
      exitMethod: data['exit_method'] != null 
          ? ExitMethod.values.firstWhere((e) => e.name == data['exit_method'])
          : null,
      compensationTypes: data['compensation_type'] != null
          ? (data['compensation_type'] as List)
              .map((e) => CompensationType.values.firstWhere((type) => type.name == e))
              .toList()
          : [],
      kuwaitJobType: data['kuwait_job_type'] != null
          ? KuwaitJobType.values.firstWhere((e) => e.name == data['kuwait_job_type'])
          : null,
      kuwaitOfficialStatus: data['kuwait_official_status'] != null
          ? KuwaitOfficialStatus.values.firstWhere((e) => e.name == data['kuwait_official_status'])
          : null,
      rightsRequestTypes: data['rights_request_type'] != null
          ? (data['rights_request_type'] as List)
              .map((e) => RightsRequestType.values.firstWhere((type) => type.name == e))
              .toList()
          : [],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
    );
  }
  
  /// معالجة أخطاء PostgreSQL
  String _handlePostgrestError(PostgrestException e) {
    switch (e.code) {
      case '23505': // Unique violation
        return 'لقد تم إرسال البيانات من قبل. لا يمكن إرسال البيانات أكثر من مرة واحدة.';
      case '23503': // Foreign key violation
        return 'خطأ في ربط البيانات. يرجى المحاولة مرة أخرى.';
      case '23502': // Not null violation
        return 'يرجى ملء جميع البيانات المطلوبة.';
      case '23514': // Check constraint violation
        return 'بعض البيانات المدخلة غير صحيحة. يرجى مراجعة البيانات والمحاولة مرة أخرى.';
      case '42601': // Syntax error
        return 'خطأ في معالجة البيانات. يرجى المحاولة مرة أخرى.';
      case '404':
        return 'لم يتم العثور على الخدمة المطلوبة. يرجى التأكد من الاتصال بالإنترنت والمحاولة مرة أخرى.';
      default:
        if (e.message.toLowerCase().contains('not found')) {
          return 'خدمة قاعدة البيانات غير متاحة حالياً. يرجى المحاولة مرة أخرى لاحقاً.';
        } else if (e.message.toLowerCase().contains('duplicate')) {
          return 'لقد تم إرسال هذه البيانات من قبل.';
        } else if (e.message.toLowerCase().contains('permission')) {
          return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
        } else if (e.message.toLowerCase().contains('timeout')) {
          return 'انتهت مهلة الاتصال. يرجى التأكد من الاتصال بالإنترنت والمحاولة مرة أخرى.';
        }
        return 'حدث خطأ أثناء إرسال البيانات: ${e.message}';
    }
  }
  
  /// معالجة الأخطاء العامة
  String _handleGeneralError(dynamic e) {
    if (e.toString().contains('SocketException')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التأكد من الاتصال والمحاولة مرة أخرى.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
    } else if (e.toString().contains('FormatException')) {
      return 'تنسيق البيانات غير صحيح. يرجى مراجعة البيانات المدخلة.';
    } else if (e.toString().contains('AuthException')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    return 'حدث خطأ غير متوقع: ${e.toString()}';
  }
  
  /// الحصول على الاسم العربي للحقل
  String _getFieldArabicName(String fieldName) {
    switch (fieldName) {
      case 'full_name_iraq':
        return 'الاسم الكامل في العراق';
      case 'mother_name':
        return 'اسم الأم';
      case 'current_province':
        return 'المحافظة الحالية';
      case 'birth_date':
        return 'تاريخ الميلاد';
      case 'birth_place':
        return 'مكان الولادة';
      case 'phone_number':
        return 'رقم الهاتف';
      case 'national_id_encrypted':
        return 'رقم الهوية الوطنية';
      case 'national_id_issue_year':
        return 'سنة إصدار الهوية';
      case 'national_id_issuer':
        return 'جهة إصدار الهوية';
      default:
        return fieldName;
    }
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
